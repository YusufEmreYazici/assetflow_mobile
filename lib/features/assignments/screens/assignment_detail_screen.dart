import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/features/assignments/screens/return_device_screen.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';

final _assignmentDetailProvider = FutureProvider.autoDispose
    .family<Assignment, String>((ref, id) async {
      return AssignmentService().getById(id);
    });

class AssignmentDetailScreen extends ConsumerWidget {
  final String id;
  const AssignmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_assignmentDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.navy,
            strokeWidth: 2,
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                'Zimmet yüklenemedi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(_assignmentDetailProvider(id)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (a) => _AssignmentDetailBody(assignment: a),
      ),
    );
  }
}

class _AssignmentDetailBody extends StatelessWidget {
  final Assignment assignment;
  const _AssignmentDetailBody({required this.assignment});

  static final _dateFmt = DateFormat('dd MMM yyyy', 'tr_TR');

  IconData get _deviceIcon => switch (assignment.deviceName?.toLowerCase()) {
    final n when n != null && n.contains('laptop') => Icons.laptop_outlined,
    final n when n != null && n.contains('monitör') => Icons.monitor_outlined,
    final n when n != null && n.contains('yazıcı') => Icons.print_outlined,
    final n when n != null && n.contains('telefon') =>
      Icons.smartphone_outlined,
    _ => Icons.devices_outlined,
  };

  String get _typeLabel => assignmentTypeLabels[assignment.type] ?? 'Zimmet';

  String get _returnConditionLabel => assignment.returnCondition != null
      ? (returnConditionLabels[assignment.returnCondition!] ?? '?')
      : '—';

  @override
  Widget build(BuildContext context) {
    final a = assignment;

    return Column(
      children: [
        // ── Navy header ──────────────────────────────────────────────────
        Container(
          color: AppColors.navy,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 14,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: 18,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: goBackOrHome(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZİMMET · $_typeLabel',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.assetTag ?? a.id,
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppChip(
                      label: a.isActive ? 'Aktif' : 'İade Edildi',
                      tone: a.isActive ? ChipTone.success : ChipTone.neutral,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Body ────────────────────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Zimmet bilgileri
              _Card(
                title: 'ZİMMET BİLGİLERİ',
                children: [
                  _KvRow('Zimmet Tarihi', _dateFmt.format(a.assignedAt)),
                  if (a.expectedReturnDate != null)
                    _KvRow(
                      'Beklenen İade',
                      _dateFmt.format(a.expectedReturnDate!),
                    ),
                  if (a.returnedAt != null)
                    _KvRow('İade Tarihi', _dateFmt.format(a.returnedAt!)),
                  if (!a.isActive && a.returnCondition != null)
                    _KvRow('İade Durumu', _returnConditionLabel),
                  if (a.assignedByName != null)
                    _KvRow('Zimmetleyen', a.assignedByName!),
                  if (a.notes != null && a.notes!.isNotEmpty)
                    _KvRow('Notlar', a.notes!),
                ],
              ),
              const SizedBox(height: 12),

              // Cihaz kartı (tıklanabilir)
              if (a.deviceId != null)
                GestureDetector(
                  onTap: () => context.push('/devices/${a.deviceId}'),
                  child: _Card(
                    title: 'CİHAZ',
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _deviceIcon,
                              size: 20,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.deviceName ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (a.assetTag != null)
                                  Text(
                                    a.assetTag!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (a.deviceBrand != null || a.deviceModel != null) ...[
                        const SizedBox(height: 12),
                        _KvRow(
                          'Marka / Model',
                          [
                            a.deviceBrand,
                            a.deviceModel,
                          ].whereType<String>().join(' '),
                        ),
                      ],
                      if (a.deviceSerialNumber != null)
                        _KvRow('Seri No', a.deviceSerialNumber!),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Personel kartı (tıklanabilir)
              if (a.employeeId != null)
                GestureDetector(
                  onTap: () => context.push('/person/${a.employeeId}'),
                  child: _Card(
                    title: 'ZİMMETLİ KİŞİ',
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.navy.withValues(
                              alpha: 0.12,
                            ),
                            child: Text(
                              (a.employeeName?.isNotEmpty == true)
                                  ? a.employeeName![0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.employeeName ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  [
                                    if (a.employeeRegistrationNumber != null)
                                      a.employeeRegistrationNumber!,
                                    if (a.employeeDepartment != null)
                                      a.employeeDepartment!,
                                  ].join(' · '),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (a.employeeTitle != null) ...[
                        const SizedBox(height: 8),
                        _KvRow('Ünvan', a.employeeTitle!),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),

        // ── İade Et button (active only) ────────────────────────────────
        if (a.isActive)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_outlined),
                label: Text(
                  'İade Et',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await navigator.push(
                    MaterialPageRoute(
                      builder: (_) => ReturnDeviceScreen(assignment: a),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const _Card({required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  final String k;
  final String v;
  const _KvRow(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';

final _deviceAssignmentsProvider = FutureProvider.autoDispose
    .family<List<Assignment>, String>((ref, deviceId) async {
      final result = await AssignmentService().getAll(page: 1, pageSize: 100);
      return result.items.where((a) => a.deviceId == deviceId).toList();
    });

class DeviceAssignmentsTab extends ConsumerWidget {
  final String deviceId;
  const DeviceAssignmentsTab({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_deviceAssignmentsProvider(deviceId));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Zimmetler yüklenemedi.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (assignments) {
        final active = assignments.where((a) => a.isActive).toList();
        final past = assignments.where((a) => !a.isActive).toList();

        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Zimmet kaydı bulunamadı',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            100,
          ),
          children: [
            if (active.isNotEmpty) ...[
              _SectionLabel('AKTİF ZİMMET'),
              const SizedBox(height: 8),
              ...active.map(
                (a) => _AssignmentCard(assignment: a, isActive: true),
              ),
              if (past.isNotEmpty) const SizedBox(height: 16),
            ],
            if (past.isNotEmpty) ...[
              _SectionLabel('GEÇMİŞ ZİMMETLER'),
              const SizedBox(height: 8),
              ...past.map(
                (a) => _AssignmentCard(assignment: a, isActive: false),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final bool isActive;
  const _AssignmentCard({required this.assignment, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isActive ? AppColors.success : AppColors.surfaceDivider,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isActive)
              Container(
                width: 3,
                constraints: const BoxConstraints(minHeight: 60),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(AppRadius.md),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.employeeName ?? 'Bilinmiyor',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AppChip(
                          label: isActive ? 'AKTİF' : 'İADE',
                          tone: isActive ? ChipTone.success : ChipTone.neutral,
                        ),
                      ],
                    ),
                    if (assignment.employeeTitle != null ||
                        assignment.employeeDepartment != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          assignment.employeeTitle,
                          assignment.employeeDepartment,
                        ].whereType<String>().join(' · '),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaItem(
                          icon: Icons.calendar_today_outlined,
                          text: dateFormat.format(assignment.assignedAt),
                        ),
                        if (assignment.returnedAt != null) ...[
                          const SizedBox(width: 12),
                          _MetaItem(
                            icon: Icons.assignment_return_outlined,
                            text: dateFormat.format(assignment.returnedAt!),
                          ),
                        ],
                        if (assignment.assetTag != null) ...[
                          const SizedBox(width: 12),
                          _MetaItem(
                            icon: Icons.tag,
                            text: assignment.assetTag!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

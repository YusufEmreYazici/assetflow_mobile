import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/core/widgets/app_tab_bar.dart';
import 'package:assetflow_mobile/core/widgets/kv_row.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';

final _personDetailProvider =
    FutureProvider.autoDispose.family<Employee, String>((ref, id) async {
  return EmployeeService().getById(id);
});

final _personAssignmentsProvider =
    FutureProvider.autoDispose.family<List<Assignment>, String>((ref, employeeId) async {
  final result = await AssignmentService().getAll(page: 1, pageSize: 100);
  return result.items.where((a) => a.employeeId == employeeId).toList();
});

class PersonDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const PersonDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen> {
  int _tabIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTab(int i) {
    setState(() => _tabIndex = i);
    _pageController.animateToPage(i,
        duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_personDetailProvider(widget.id));
    return async.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: Column(
          children: [
            Container(color: AppColors.navy, height: MediaQuery.of(context).padding.top + 90),
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))),
          ],
        ),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(backgroundColor: AppColors.navy, foregroundColor: Colors.white, title: const Text('Hata')),
        body: const Center(child: Text('Personel yüklenemedi.')),
      ),
      data: (emp) => _buildDetail(emp),
    );
  }

  Widget _buildDetail(Employee emp) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          _PersonHeader(employee: emp),
          AppTabBar(
            tabs: const ['Zimmetler', 'İletişim'],
            activeIndex: _tabIndex,
            onChanged: _onTab,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _tabIndex = i),
              children: [
                _AssignmentsTab(employeeId: emp.id),
                _ContactTab(employee: emp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  final Employee employee;
  const _PersonHeader({required this.employee});

  String get _initials {
    final parts = employee.fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return employee.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,
                      ),
                    ),
                    if (employee.title != null || employee.department != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [employee.title, employee.department]
                            .whereType<String>().join(' · '),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        AppChip(
                          label: employee.isActive ? 'AKTİF' : 'PASİF',
                          tone: employee.isActive ? ChipTone.success : ChipTone.neutral,
                        ),
                        if (employee.registrationNumber != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            employee.registrationNumber!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoCell(label: 'ZİMMET', value: '${employee.assignedDeviceCount} cihaz'),
              const SizedBox(width: 8),
              _InfoCell(
                label: 'BAŞLANGIÇ',
                value: employee.hireDate != null
                    ? DateFormat('MMM yyyy', 'tr_TR').format(employee.hireDate!)
                    : '—',
              ),
              const SizedBox(width: 8),
              _InfoCell(label: 'DURUM', value: employee.isActive ? 'Aktif' : 'Pasif'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9, letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentsTab extends ConsumerWidget {
  final String employeeId;
  const _AssignmentsTab({required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_personAssignmentsProvider(employeeId));
    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
      ),
      error: (_, __) => Center(
        child: Text('Zimmetler yüklenemedi.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
      ),
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text('Zimmet kaydı bulunamadı.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        final dateFormat = DateFormat('dd/MM/yyyy');
        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100),
          children: assignments.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: a.isActive ? AppColors.success : AppColors.surfaceDivider),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(a.deviceName ?? '—',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  ),
                  AppChip(label: a.isActive ? 'AKTİF' : 'İADE', tone: a.isActive ? ChipTone.success : ChipTone.neutral),
                ]),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(a.assignedAt)}${a.returnedAt != null ? ' → ${dateFormat.format(a.returnedAt!)}' : ''}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          )).toList(),
        );
      },
    );
  }
}

class _ContactTab extends StatelessWidget {
  final Employee employee;
  const _ContactTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceDivider),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              if (employee.email != null)
                KvRow(label: 'E-posta', value: employee.email!),
              if (employee.phone != null)
                KvRow(label: 'Telefon', value: employee.phone!),
              if (employee.registrationNumber != null)
                KvRow(label: 'Sicil No', value: employee.registrationNumber!, mono: true),
              if (employee.department != null)
                KvRow(label: 'Departman', value: employee.department!),
              if (employee.title != null)
                KvRow(label: 'Ünvan', value: employee.title!, last: true),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_header.dart';
import 'package:assetflow_mobile/core/widgets/section_header.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'kpi_card.dart';
import 'activity_tile.dart';
import 'quick_action.dart';

class DashboardAView extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  const DashboardAView({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashAsync = ref.watch(dashboardProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AppHeader(
            userName: authState.fullName ?? authState.email ?? 'Kullanıcı',
            role: _roleLabel(authState.role),
            onMenu: onMenuTap,
            onNotif: () => context.push('/notifications'),
            showNotifBadge: false,
          ),
        ),
        SliverToBoxAdapter(
          child: dashAsync.when(
            loading: () => _buildContent(context, null),
            error: (_, __) => _buildContent(context, null),
            data: (d) => _buildContent(context, d),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DashboardData? data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'ÖZET', padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        label: 'Toplam Cihaz',
                        value: data != null ? '${data.totalDevices}' : '—',
                        delta: '▲ 3 bu ay',
                        accent: AppColors.navy,
                        icon: Icons.devices_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        label: 'Aktif Zimmet',
                        value: data != null ? '${data.assignedDevices}' : '—',
                        delta: '▲ 5 bu hafta',
                        accent: AppColors.success,
                        icon: Icons.assignment_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        label: 'Personel',
                        value: data != null ? '${data.totalEmployees}' : '—',
                        delta: '22 lokasyon',
                        accent: AppColors.textSecondary,
                        icon: Icons.people_outline,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KpiCard(
                        label: 'Uyarılar',
                        value: data != null ? '${data.expiringWarranties}' : '—',
                        delta: 'Garanti · 60 gün',
                        accent: AppColors.warning,
                        background: AppColors.warningBg,
                        icon: Icons.warning_amber_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'HIZLI İŞLEMLER', padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuickAction(
                      icon: Icons.add,
                      label: 'Yeni Cihaz',
                      primary: true,
                      onTap: () => context.push('/devices/new'),
                    ),
                    const SizedBox(width: 10),
                    QuickAction(
                      icon: Icons.assignment_outlined,
                      label: 'Zimmetle',
                      onTap: () => context.push('/assignments'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Activity feed
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'AKTİVİTE AKIŞI',
                  padding: EdgeInsets.zero,
                  action: TextButton(
                    onPressed: () => context.push('/audit-log'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'TÜMÜ →',
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: AppColors.navyLight, letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: List.generate(kMockActivity.length, (i) {
                      return ActivityTile(
                        item: kMockActivity[i],
                        isLast: i == kMockActivity.length - 1,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Warranty alerts
          if (data != null && data.expiringWarranties > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'GARANTİ UYARILARI', padding: EdgeInsets.zero),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: const Border(
                        left: BorderSide(color: AppColors.warning, width: 3),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.expiringWarranties} cihazın garantisi 60 gün içinde dolacak',
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cihazları inceleyip uzatma talebinde bulunun.',
                                style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.textSecondary, height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.warning),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) => switch (role) {
        'Admin'   => 'Yönetici',
        'Manager' => 'Müdür',
        'ITAdmin' => 'IT Yönetici',
        _         => role ?? '',
      };
}

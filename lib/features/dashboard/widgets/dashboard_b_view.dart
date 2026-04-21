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
import 'activity_tile.dart';
import 'mini_bar_chart.dart';
import 'metric_strip.dart';
import 'status_bar.dart';
import 'quick_action.dart';

class DashboardBView extends ConsumerWidget {
  final VoidCallback? onMenuTap;
  const DashboardBView({super.key, this.onMenuTap});

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
          ),
        ),
        SliverToBoxAdapter(
          child: dashAsync.when(
            loading: () => _buildContent(context, null),
            error: (err, stack) => _buildContent(context, null),
            data: (d) => _buildContent(context, d),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DashboardData? data) {
    final totalDevices = data?.totalDevices ?? 158;
    final assigned = data?.assignedDevices ?? 94;
    final inStorage = data?.inStorageDevices ?? 42;
    final maintenance = 8;
    final retired = totalDevices - assigned - inStorage - maintenance;
    final employees = data?.totalEmployees ?? 158;
    final warnings = data?.expiringWarranties ?? 7;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero KPI card
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.surfaceDivider),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ENVANTER DURUMU · NİSAN 2026',
                              style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary, letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$totalDevices',
                                  style: GoogleFonts.inter(
                                    fontSize: 32, fontWeight: FontWeight.w500,
                                    color: AppColors.navy, letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'toplam cihaz',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '▲ 3 BU AY',
                              style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w500,
                                color: AppColors.success, letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Son 6 ay',
                            style: GoogleFonts.inter(
                              fontSize: 10, color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 90,
                            child: MiniBarChart(
                              height: 36,
                              data: const [142, 147, 150, 152, 155, 158],
                              labels: const ['K', 'A', 'O', 'Ş', 'M', 'N'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StatusBar(segments: [
                    StatusSegment(label: 'Zimmetli', value: assigned,     color: AppColors.success),
                    StatusSegment(label: 'Depoda',   value: inStorage,    color: AppColors.info),
                    StatusSegment(label: 'Bakımda',  value: maintenance,  color: AppColors.warning),
                    StatusSegment(label: 'Emekli',   value: retired > 0 ? retired : 14, color: AppColors.textTertiary),
                  ]),
                ],
              ),
            ),
          ),

          // Metric strip
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 14, AppSpacing.xl, 0),
            child: Row(
              children: [
                MetricStrip(
                  label: 'Aktif Zimmet',
                  value: '$assigned',
                  trend: '▲ 5 bu hafta',
                  accent: AppColors.success,
                ),
                const SizedBox(width: 10),
                MetricStrip(
                  label: 'Personel',
                  value: '$employees',
                  trend: '22 lokasyon',
                  accent: AppColors.navy,
                ),
                const SizedBox(width: 10),
                MetricStrip(
                  label: 'Uyarı',
                  value: '$warnings',
                  trend: 'Garanti · 60g',
                  accent: AppColors.warning,
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'HIZLI İŞLEMLER', padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                Row(
                  children: [
                    QuickAction(icon: Icons.add,              label: 'Cihaz',  primary: true,
                        onTap: () => context.push('/devices/new')),
                    const SizedBox(width: 8),
                    QuickAction(icon: Icons.assignment_outlined, label: 'Zimmet',
                        onTap: () => context.push('/assignments')),
                    const SizedBox(width: 8),
                    QuickAction(icon: Icons.upload_outlined,  label: 'İade',
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ),

          // Recent activity
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'SON HAREKETLER',
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
                    children: List.generate(4, (i) => ActivityTile(
                      item: kMockActivity[i],
                      isLast: i == 3,
                    )),
                  ),
                ),
              ],
            ),
          ),

          // Location distribution
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'LOKASYON DAĞILIMI', padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _locationRows.asMap().entries.map((e) {
                      final i = e.key;
                      final r = e.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: i < _locationRows.length - 1
                            ? const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.surfaceDivider),
                                ),
                              )
                            : null,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12, color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${r.count}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: r.pct,
                                minHeight: 4,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: const AlwaysStoppedAnimation(AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

class _LocationRow {
  final String name;
  final int count;
  final double pct;
  const _LocationRow(this.name, this.count, this.pct);
}

const _locationRows = [
  _LocationRow('Ankara Genel Müdürlük', 52, 0.33),
  _LocationRow('Mersin Limanı',         38, 0.24),
  _LocationRow('İzmit Terminal',        26, 0.16),
  _LocationRow('Aliağa Rafineri',       18, 0.11),
  _LocationRow('Diğer (18 lokasyon)',   24, 0.16),
];

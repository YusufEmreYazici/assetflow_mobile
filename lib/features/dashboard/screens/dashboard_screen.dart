import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/stat_card.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/device_type_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary500,
        backgroundColor: AppColors.dark800,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          await ref.read(dashboardProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            _DashboardAppBar(authState: authState, ref: ref),
            dashboardAsync.when(
              data: (data) => _DashboardBody(data: data),
              loading: () => const SliverToBoxAdapter(child: _DashboardShimmer()),
              error: (error, _) => SliverToBoxAdapter(
                child: _DashboardError(error: error, onRetry: () => ref.invalidate(dashboardProvider)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────

class _DashboardAppBar extends StatelessWidget {
  final AuthState authState;
  final WidgetRef ref;

  const _DashboardAppBar({required this.authState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(now);
    final firstName = (authState.fullName ?? 'Kullanıcı').split(' ').first;
    final initials = (authState.fullName ?? 'K')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return SliverAppBar(
      backgroundColor: AppColors.dark900,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      expandedHeight: 100,
      toolbarHeight: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppColors.dark900,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_greeting()}, $firstName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => context.go('/more'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary700.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }
}

// ─── Dashboard Body ───────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  final dynamic data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentAssignmentsProvider);
    final hasExpired = (data.expiredWarranties as int) > 0;
    final hasExpiring = (data.expiringWarranties as int) > 0;

    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 16),

        // ── Kritik Uyarı Banner ──────────────────────────
        if (hasExpired)
          _AlertBanner(
            color: AppColors.error,
            icon: Icons.gpp_bad_outlined,
            message: '${data.expiredWarranties} cihazın garantisi bitti — acil işlem gerekiyor',
          )
        else if (hasExpiring)
          _AlertBanner(
            color: AppColors.warning,
            icon: Icons.shield_outlined,
            message: '${data.expiringWarranties} cihazın garantisi yakında bitiyor',
          ),

        // ── KPI Grid ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(title: 'GENEL BAKIŞ'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                icon: Icons.devices_rounded,
                value: '${data.totalDevices}',
                label: 'Toplam Cihaz',
                color: AppColors.primary500,
              ),
              StatCard(
                icon: Icons.assignment_ind_rounded,
                value: '${data.assignedDevices}',
                label: 'Zimmetli',
                color: AppColors.success,
                sublabel: data.totalDevices > 0
                    ? '%${((data.assignedDevices / data.totalDevices) * 100).round()}'
                    : null,
              ),
              StatCard(
                icon: Icons.inventory_2_rounded,
                value: '${data.inStorageDevices}',
                label: 'Depoda',
                color: AppColors.info,
              ),
              StatCard(
                icon: Icons.people_rounded,
                value: '${data.totalEmployees}',
                label: 'Toplam Personel',
                color: AppColors.primary400,
              ),
              StatCard(
                icon: Icons.schedule_rounded,
                value: '${data.expiringWarranties}',
                label: 'Garanti Uyarı',
                color: AppColors.warning,
                sublabel: hasExpiring ? 'DİKKAT' : null,
              ),
              StatCard(
                icon: Icons.gpp_bad_rounded,
                value: '${data.expiredWarranties}',
                label: 'Garanti Biten',
                color: AppColors.error,
                sublabel: hasExpired ? 'KRİTİK' : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Hızlı İşlemler ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(title: 'HIZLI İŞLEMLER'),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 82,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _QuickAction(
                icon: Icons.assignment_add,
                label: 'Zimmet Ata',
                color: AppColors.success,
                onTap: () => context.go('/assignments'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.add_box_rounded,
                label: 'Cihaz Ekle',
                color: AppColors.primary500,
                onTap: () => context.go('/devices'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.person_add_rounded,
                label: 'Personel Ekle',
                color: AppColors.info,
                onTap: () => context.go('/employees'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.qr_code_scanner,
                label: 'QR Tara',
                color: AppColors.primary400,
                onTap: () => context.go('/assignments'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Cihaz Dağılımı ───────────────────────────────
        if (data.devicesByType.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(title: 'CİHAZ DAĞILIMI'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DeviceTypeChart(devicesByType: data.devicesByType),
          ),
          const SizedBox(height: 24),
        ],

        // ── Son Aktiviteler ──────────────────────────────
        recentAsync.when(
          data: (items) => items.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _RecentActivitySection(items: items),
                ),
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _recentShimmer(),
          ),
          error: (e, _) => const SizedBox.shrink(),
        ),

        // ── Garanti Yaklaşanlar ──────────────────────────
        if (data.upcomingWarrantyExpirations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(title: 'GARANTİ UYARILARI'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WarrantySection(items: data.upcomingWarrantyExpirations),
          ),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _recentShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: 130,
              decoration: BoxDecoration(color: AppColors.dark800, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          Container(height: 180,
              decoration: BoxDecoration(color: AppColors.dark800, borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Alert Banner ─────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  const _AlertBanner({required this.color, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action ─────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.dark800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Activity Section ─────────────────────────────────────────────────

class _RecentActivitySection extends StatelessWidget {
  final List<Assignment> items;
  const _RecentActivitySection({required this.items});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'tr_TR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'SON AKTİVİTELER'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final a = items[i];
              final isLast = i == items.length - 1;
              final typeLabel = AssignmentTypeLabels[a.type] ?? 'Zimmet';
              final typeColor = a.type == 0
                  ? AppColors.success
                  : a.type == 1
                      ? AppColors.info
                      : AppColors.warning;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Row(
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.assignment_turned_in_rounded,
                                color: typeColor,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.deviceName ?? '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                a.employeeName ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(a.assignedAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 60, color: AppColors.border),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Warranty Section ─────────────────────────────────────────────────────────

class _WarrantySection extends StatelessWidget {
  final List<dynamic> items;
  const _WarrantySection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.map<Widget>((item) {
          final Color accentColor;
          final String urgencyLabel;
          if (item.daysRemaining <= 0) {
            accentColor = AppColors.error;
            urgencyLabel = 'BİTTİ';
          } else if (item.daysRemaining < 30) {
            accentColor = AppColors.error;
            urgencyLabel = 'KRİTİK';
          } else if (item.daysRemaining < 90) {
            accentColor = AppColors.warning;
            urgencyLabel = 'UYARI';
          } else {
            accentColor = AppColors.success;
            urgencyLabel = 'NORMAL';
          }
          final dateStr = DateFormat('dd MMM yyyy', 'tr_TR').format(item.warrantyEndDate);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: urgencyLabel == 'NORMAL' ? 0.15 : 0.3),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_user_outlined, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.deviceName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.assignedTo ?? 'Atanmamış',
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.daysRemaining <= 0
                            ? urgencyLabel
                            : '${item.daysRemaining} gün',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Shimmer ──────────────────────────────────────────────────────────────────

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid shimmer
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.25,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (_) => Container(
                decoration: BoxDecoration(
                  color: AppColors.dark800,
                  borderRadius: BorderRadius.circular(14),
                ),
              )),
            ),
            const SizedBox(height: 24),
            // Quick actions shimmer
            SizedBox(
              height: 82,
              child: Row(
                children: List.generate(4, (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.dark800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 24),
            // Activity shimmer
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _DashboardError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _DashboardError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Veriler yüklenemedi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sunucu bağlantısını kontrol edin',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

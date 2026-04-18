import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/device_type_chart.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_app_bar.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_error.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_kpi_grid.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/quick_actions_row.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/recent_activity_section.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/warranty_alerts_section.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_shimmer.dart';
import 'package:assetflow_mobile/core/utils/seen_notification_store.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/notification_panel.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/section_header.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _panelSeen = false;
  bool _alertShown = false; // session başına bir kez kritik popup göster
  final Set<String> _readNotifIds = {};

  @override
  void initState() {
    super.initState();
    _loadReadNotifIds();
  }

  Future<void> _loadReadNotifIds() async {
    final seen = await SeenNotificationStore.instance.getAll();
    final panelIds = seen.where((id) => id.startsWith('panel_')).toSet();
    if (mounted) setState(() => _readNotifIds.addAll(panelIds));
  }

  void _showCriticalAlert(BuildContext context, DashboardData data) {
    final hasExpired = data.expiredWarranties > 0;
    final hasExpiring = data.expiringWarranties > 0;
    if (!hasExpired && !hasExpiring) return;

    final isExpired = hasExpired;
    final color = isExpired ? AppColors.error : AppColors.warning;
    final icon = isExpired ? Icons.gpp_bad_rounded : Icons.shield_outlined;
    final title = isExpired
        ? 'Kritik: Garanti Süresi Doldu'
        : 'Uyarı: Garanti Yaklaşıyor';
    final message = isExpired
        ? '${data.expiredWarranties} cihazın garanti süresi dolmuş. Acil işlem gerekiyor.'
        : '${data.expiringWarranties} cihazın garanti süresi 90 gün içinde bitiyor.';

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.dark800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tamam'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          final d = ref.read(dashboardProvider).valueOrNull;
                          final r =
                              ref.read(recentAssignmentsProvider).valueOrNull ??
                              [];
                          if (d != null) _openNotifications(this.context, d, r);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'İncele',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNotifications(
    BuildContext context,
    DashboardData data,
    List<Assignment> recent,
  ) {
    setState(() => _panelSeen = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationPanel(
        data: data,
        recentAssignments: recent,
        readNotifIds: Set.from(_readNotifIds),
        onMarkRead: (id) async {
          await SeenNotificationStore.instance.markSeen(id);
          if (mounted) setState(() => _readNotifIds.add(id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final recentAsync = ref.watch(recentAssignmentsProvider);
    final authState = ref.watch(authProvider);

    // İlk başarılı yüklemede kritik uyarı popup'ı — session başına bir kez
    ref.listen<AsyncValue<DashboardData>>(dashboardProvider, (prev, next) {
      if (!_alertShown && next is AsyncData<DashboardData>) {
        _alertShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showCriticalAlert(context, next.value);
        });
      }
    });

    // Sadece okunmayan bildirimler sayılır
    final notifCount = dashboardAsync.maybeWhen(
      data: (d) {
        final unreadWarranty = d.upcomingWarrantyExpirations
            .where((e) => !_readNotifIds.contains('panel_w_${e.deviceId}'))
            .length;
        final unreadAssign =
            recentAsync.valueOrNull
                ?.where((a) => !_readNotifIds.contains('panel_a_${a.id}'))
                .length ??
            0;
        return unreadWarranty + unreadAssign;
      },
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary500,
        backgroundColor: AppColors.dark800,
        onRefresh: () async {
          setState(() {
            _panelSeen = false;
            _alertShown = false;
            _readNotifIds.clear();
          });
          ref.invalidate(dashboardProvider);
          await ref.read(dashboardProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            DashboardAppBar(
              authState: authState,
              notifCount: notifCount,
              panelSeen: _panelSeen,
              onNotifTap: () {
                final data = dashboardAsync.valueOrNull;
                final recent = recentAsync.valueOrNull ?? [];
                if (data != null) _openNotifications(context, data, recent);
              },
            ),

            // ── Body ──
            dashboardAsync.when(
              data: (data) => SliverToBoxAdapter(
                child: _DashboardContent(data: data, recentAsync: recentAsync),
              ),
              loading: () =>
                  const SliverToBoxAdapter(child: DashboardShimmer()),
              error: (error, _) => SliverToBoxAdapter(
                child: DashboardError(
                  error: error,
                  onRetry: () {
                    ref.invalidate(dashboardProvider);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Content ────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final dynamic data;
  final AsyncValue<List<Assignment>> recentAsync;

  const _DashboardContent({required this.data, required this.recentAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ── KPI Grid ──────────────────────────────────
        DashboardKpiGrid(data: data),
        const SizedBox(height: 24),

        // ── Hızlı İşlemler ──
        const QuickActionsRow(),
        const SizedBox(height: 24),

        // ── Cihaz Dağılımı ──
        if (data.devicesByType.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DashboardSectionHeader(title: 'CİHAZ DAĞILIMI'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DeviceTypeChart(devicesByType: data.devicesByType),
          ),
          const SizedBox(height: 24),
        ],

        // ── Son Aktiviteler ──
        recentAsync.when(
          data: (items) => items.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecentActivitySection(items: items),
                ),
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _recentShimmer(),
          ),
          error: (e, _) => const SizedBox.shrink(),
        ),

        // ── Garanti Yaklaşanlar ──
        if (data.upcomingWarrantyExpirations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DashboardSectionHeader(title: 'GARANTİ UYARILARI'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WarrantyAlertsSection(
              items: data.upcomingWarrantyExpirations,
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _recentShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 130,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

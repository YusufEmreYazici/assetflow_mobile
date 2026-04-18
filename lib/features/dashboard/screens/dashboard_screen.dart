import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
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

  void _showCriticalAlert(BuildContext context, DashboardData data) {
    final hasExpired = data.expiredWarranties > 0;
    final hasExpiring = data.expiringWarranties > 0;
    if (!hasExpired && !hasExpiring) return;

    final isExpired = hasExpired;
    final color = isExpired ? AppColors.error : AppColors.warning;
    final icon = isExpired ? Icons.gpp_bad_rounded : Icons.shield_outlined;
    final title = isExpired ? 'Kritik: Garanti Süresi Doldu' : 'Uyarı: Garanti Yaklaşıyor';
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
                            borderRadius: BorderRadius.circular(10)),
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
                          final r = ref.read(recentAssignmentsProvider).valueOrNull ?? [];
                          if (d != null) _openNotifications(this.context, d, r);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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

  void _openNotifications(BuildContext context, DashboardData data, List<Assignment> recent) {
    setState(() => _panelSeen = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationPanel(
        data: data,
        recentAssignments: recent,
        readNotifIds: Set.from(_readNotifIds),
        onMarkRead: (id) => setState(() => _readNotifIds.add(id)),
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
            .where((e) => !_readNotifIds.contains('w_${e.deviceId}'))
            .length;
        final unreadAssign = recentAsync.valueOrNull
                ?.where((a) => !_readNotifIds.contains('a_${a.id}'))
                .length ?? 0;
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
                child: _DashboardContent(
                  data: data,
                  recentAsync: recentAsync,
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: DashboardShimmer()),
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

  const _DashboardContent({
    required this.data,
    required this.recentAsync,
  });

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
            child: WarrantyAlertsSection(items: data.upcomingWarrantyExpirations),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 14,
            width: 130,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(4))),
        Container(
            height: 180,
            decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(12))),
        const SizedBox(height: 20),
      ]),
    );
  }
}


// ─── Notification Panel ───────────────────────────────────────────────────────

class _NotificationPanel extends StatefulWidget {
  final DashboardData data;
  final List<Assignment> recentAssignments;
  final Set<String> readNotifIds;
  final void Function(String id) onMarkRead;

  const _NotificationPanel({
    required this.data,
    required this.recentAssignments,
    required this.readNotifIds,
    required this.onMarkRead,
  });

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel> {
  late final Set<String> _localRead;

  @override
  void initState() {
    super.initState();
    _localRead = Set.from(widget.readNotifIds);
  }

  void _markRead(String id, VoidCallback navigate) {
    if (!_localRead.contains(id)) {
      setState(() => _localRead.add(id));
      widget.onMarkRead(id); // AppBar badge'ini güncelle
    }
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    final warrantyItems = widget.data.upcomingWarrantyExpirations;
    final recentAssignments = widget.recentAssignments;

    final unreadWarranty = warrantyItems.where((e) => !_localRead.contains('w_${e.deviceId}')).length;
    final unreadAssign = recentAssignments.where((a) => !_localRead.contains('a_${a.id}')).length;
    final unreadCount = unreadWarranty + unreadAssign;
    final totalCount = warrantyItems.length + recentAssignments.length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              children: [
                Icon(
                  unreadCount > 0
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  color: unreadCount > 0
                      ? AppColors.primary400
                      : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  )
                else if (totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Tümü okundu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                const Spacer(),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      final allIds = {
                        ...warrantyItems.map((e) => 'w_${e.deviceId}'),
                        ...recentAssignments.map((a) => 'a_${a.id}'),
                      };
                      setState(() => _localRead.addAll(allIds));
                      for (final id in allIds) {
                        widget.onMarkRead(id);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary400,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Tümünü Okundu İşaretle',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textTertiary, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // İçerik
          if (totalCount == 0)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.notifications_none_rounded,
                      color: AppColors.textTertiary, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Yeni bildirim yok',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                shrinkWrap: true,
                children: [
                  // Garanti uyarıları
                  if (warrantyItems.isNotEmpty) ...[
                    _PanelSectionHeader(
                      title: 'GARANTİ UYARILARI',
                      count: unreadWarranty,
                      totalCount: warrantyItems.length,
                      color: widget.data.expiredWarranties > 0
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                    ...warrantyItems.map((item) {
                      final id = 'w_${item.deviceId}';
                      final isRead = _localRead.contains(id);
                      return _WarrantyNotifTile(
                        item: item,
                        isRead: isRead,
                        onTap: () => _markRead(id, () {
                          final router = GoRouter.of(context);
                          Navigator.pop(context);
                          router.go('/devices/${item.deviceId}');
                        }),
                      );
                    }),
                  ],

                  // Son zimmetler
                  if (recentAssignments.isNotEmpty) ...[
                    _PanelSectionHeader(
                      title: 'SON ZİMMETLER',
                      count: unreadAssign,
                      totalCount: recentAssignments.length,
                      color: AppColors.success,
                    ),
                    ...recentAssignments.map((a) {
                      final id = 'a_${a.id}';
                      final isRead = _localRead.contains(id);
                      return _AssignmentNotifTile(
                        assignment: a,
                        isRead: isRead,
                        onTap: () => _markRead(id, () {
                          final router = GoRouter.of(context);
                          Navigator.pop(context);
                          router.go('/assignments');
                        }),
                      );
                    }),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PanelSectionHeader extends StatelessWidget {
  final String title;
  final int count;       // okunmayan sayısı
  final int totalCount;  // toplam
  final Color color;

  const _PanelSectionHeader({
    required this.title,
    required this.count,
    required this.totalCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final allRead = count == 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: allRead ? AppColors.textTertiary : color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 6),
          if (!allRead)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Okundu',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
          const Spacer(),
          Text(
            '$totalCount öğe',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarrantyNotifTile extends StatelessWidget {
  final WarrantyAlertItem item;
  final bool isRead;
  final VoidCallback onTap;

  const _WarrantyNotifTile({
    required this.item,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = item.daysRemaining <= 0;
    final isCritical = item.daysRemaining <= 30;
    final baseColor = isExpired || isCritical ? AppColors.error : AppColors.warning;
    final color = isRead ? AppColors.textTertiary : baseColor;
    final label = isExpired ? 'Bitti' : '${item.daysRemaining} gün kaldı';
    final dateStr = DateFormat('dd MMM yyyy', 'tr_TR').format(item.warrantyEndDate);

    return Container(
      color: isRead ? AppColors.dark900.withValues(alpha: 0.4) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isRead ? Icons.check_circle_outline : Icons.verified_user_outlined,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          item.deviceName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isRead ? AppColors.textTertiary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.assignedTo != null
              ? '${item.assignedTo} · $dateStr'
              : dateStr,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isRead ? 'Okundu' : label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isRead ? Icons.check : Icons.chevron_right,
              color: isRead ? AppColors.success : AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentNotifTile extends StatelessWidget {
  final Assignment assignment;
  final bool isRead;
  final VoidCallback onTap;

  const _AssignmentNotifTile({
    required this.assignment,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = AssignmentTypeLabels[assignment.type] ?? 'Zimmet';
    final baseColor = assignment.type == 0
        ? AppColors.success
        : assignment.type == 1
            ? AppColors.info
            : AppColors.warning;
    final typeColor = isRead ? AppColors.textTertiary : baseColor;
    final dateStr = DateFormat('dd MMM, HH:mm', 'tr_TR').format(assignment.assignedAt);

    return Container(
      color: isRead ? AppColors.dark900.withValues(alpha: 0.4) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isRead
                ? Icons.assignment_turned_in_rounded
                : Icons.assignment_turned_in_rounded,
            color: typeColor,
            size: 20,
          ),
        ),
        title: Text(
          assignment.deviceName ?? '-',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isRead ? AppColors.textTertiary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${assignment.employeeName ?? '-'} · $dateStr',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isRead ? 'Okundu' : typeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isRead ? Icons.check : Icons.chevron_right,
              color: isRead ? AppColors.success : AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}



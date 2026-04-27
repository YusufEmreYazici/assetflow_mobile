import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/data/models/notification_model.dart';
import 'package:assetflow_mobile/features/notifications/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tabIndex = 0;
  bool _isNavigating = false;

  static const _tabs = ['Tümü', 'Okunmamış', 'Garanti', 'Zimmet', 'Bakım', 'Güvenlik', 'Sistem'];

  List<NotificationItem> _filtered(List<NotificationItem> all) {
    return all.where((n) {
      switch (_tabIndex) {
        case 1:
          return !n.isRead;
        case 2:
          return n.category == 'warranty';
        case 3:
          return n.category == 'assignment';
        case 4:
          return n.category == 'maintenance';
        case 5:
          return n.category == 'security';
        case 6:
          return n.category == 'system';
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _handleTap(NotificationItem notif) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      if (!notif.isRead) {
        unawaited(ref.read(notificationProvider.notifier).markAsRead(notif.id));
      }

      if (!mounted) return;

      if (notif.relatedEntityId == null || notif.relatedEntityId!.isEmpty) {
        // No specific entity — navigate to the relevant list screen (shell route → use go())
        final fallbackRoute = switch (notif.type) {
          0 || 1 || 9 => '/devices',
          2 || 3 || 8 => '/assignments',
          5 => '/software-licenses',
          6 => '/subscriptions',
          7 => '/consumables',
          _ => null,
        };
        if (fallbackRoute != null && mounted) {
          context.go(fallbackRoute);
        }
        return;
      }

      final entityType = notif.relatedEntityType ?? '';
      final entityId = notif.relatedEntityId!;

      final route = switch (entityType) {
        'Device' => '/devices/$entityId',
        'Assignment' => '/assignments/$entityId',
        'Employee' => '/person/$entityId',
        'Location' => '/location/$entityId',
        'SoftwareLicense' => '/software-licenses/$entityId',
        'Subscription' => '/subscriptions/$entityId',
        'Consumable' || 'ConsumableAsset' => '/consumables/$entityId',
        _ => null,
      };

      if (route == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu bildirim için detay sayfası mevcut değil')),
          );
        }
        return;
      }

      if (mounted) {
        try {
          context.push(route);
        } catch (e) {
          debugPrint('Notification nav error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sayfa açılamadı')),
            );
          }
        }
      }
    } finally {
      if (mounted) _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          // Header
          notifState.when(
            data: (items) => _buildHeader(items),
            loading: () => _buildHeader([]),
            error: (e, st) => _buildHeader([]),
          ),
          // Tabs
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  final isActive = e.key == _tabIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? AppColors.navy
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.navy
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // List
          Expanded(
            child: notifState.when(
              loading: () => _buildShimmer(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bildirimler yüklenemedi',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(notificationProvider.notifier).load(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                final filtered = _filtered(items);
                if (filtered.isEmpty) return const EmptyState.noNotifications();
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationProvider.notifier).load(),
                  color: AppColors.primary500,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      20,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _NotifCard(
                      notif: filtered[i],
                      onTap: () => _handleTap(filtered[i]),
                      onDelete: () => ref
                          .read(notificationProvider.notifier)
                          .delete(filtered[i].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceWhite,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: 8,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<NotificationItem> items) {
    final unreadCount = items.where((n) => !n.isRead).length;
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 18,
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirimler',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount okunmamış',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () =>
                  ref.read(notificationProvider.notifier).markAllAsRead(),
              child: Text(
                'Tümünü Oku',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationItem notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon => switch (notif.type) {
    0 || 1 => Icons.warning_amber_outlined,
    2 => Icons.assignment_outlined,
    3 => Icons.assignment_return_outlined,
    5 || 6 => Icons.autorenew_outlined,
    7 => Icons.inventory_2_outlined,
    8 => Icons.access_time_filled_outlined,
    9 => Icons.inventory_2_outlined,
    10 => Icons.build_outlined,
    11 => Icons.security_outlined,
    _ => Icons.settings_outlined,
  };

  Color get _color => switch (notif.type) {
    0 || 1 => AppColors.warning,
    2 => AppColors.success,
    3 => AppColors.info,
    5 || 6 => AppColors.warning,
    7 => AppColors.error,
    8 => AppColors.info,
    9 => AppColors.warning,
    10 => AppColors.warning,
    11 => AppColors.error,
    _ => AppColors.textSecondary,
  };

  Color get _bgColor => switch (notif.type) {
    0 || 1 => AppColors.warningBg,
    2 => AppColors.successBg,
    3 => AppColors.infoBg,
    5 || 6 => AppColors.warningBg,
    7 || 11 => AppColors.errorBg,
    8 => AppColors.infoBg,
    9 || 10 => AppColors.warningBg,
    _ => AppColors.surfaceLight,
  };

  String _relativeTime() {
    final diff = DateTime.now().difference(notif.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM', 'tr_TR').format(notif.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final hasNavigation =
        notif.relatedEntityId != null ||
        notif.type <=
            3; // type<=3 = warranty/assignment → has a list to navigate to

    return Dismissible(
      key: ValueKey(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? AppColors.surfaceWhite : _bgColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: notif.isRead
                  ? AppColors.surfaceDivider
                  : _color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: notif.isRead ? 0.08 : 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(_icon, size: 18, color: _color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: notif.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _color,
                              shape: BoxShape.circle,
                            ),
                          )
                        else if (hasNavigation)
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.message,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _relativeTime(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (notif.isRead && hasNavigation) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Detaya git',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.navy,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}

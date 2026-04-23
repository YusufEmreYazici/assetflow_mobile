import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tabIndex = 0;
  bool _isNavigating = false;

  static const _tabs = ['Tümü', 'Okunmamış', 'Garanti', 'Zimmet', 'Sistem'];

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
      // 1. İlk tık = okunmamışsa sadece okundu işaretle
      if (!notif.isRead) {
        await ref.read(notificationProvider.notifier).markAsRead(notif.id);
        return;
      }

      // 2. Okunmuş + tekrar tık = ilgili ekrana git
      if (!mounted) return;

      if (notif.relatedEntityId == null || notif.relatedEntityId!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu bildirime bağlı bir detay sayfası yok.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final entityType = notif.relatedEntityType ?? '';
      final entityId = notif.relatedEntityId!;

      String? route;
      switch (entityType) {
        case 'Device':
          route = '/devices/$entityId';
        case 'Assignment':
          route = '/assignments/$entityId';
        case 'Employee':
          route = '/person/$entityId';
        case 'Location':
          route = '/location/$entityId';
        default:
          // type bazlı fallback
          if (notif.type <= 1) {
            // warranty → devices
            route = '/devices';
          } else if (notif.type == 2 || notif.type == 3) {
            route = '/assignments';
          }
      }

      if (route != null && mounted) {
        context.push(route);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detay sayfası bulunamadı.')),
        );
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
              border: Border(bottom: BorderSide(color: AppColors.surfaceDivider)),
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? AppColors.navy : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.navy : AppColors.textSecondary,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Bildirimler yüklenemedi', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(notificationProvider.notifier).load(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                final filtered = _filtered(items);
                if (filtered.isEmpty) return const EmptyState.noNotifications();
                return RefreshIndicator(
                  onRefresh: () => ref.read(notificationProvider.notifier).load(),
                  color: AppColors.primary500,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _NotifCard(
                      notif: filtered[i],
                      onTap: () => _handleTap(filtered[i]),
                      onDelete: () => ref.read(notificationProvider.notifier).delete(filtered[i].id),
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
              child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirimler',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount okunmamış',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: () => ref.read(notificationProvider.notifier).markAllAsRead(),
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

  const _NotifCard({required this.notif, required this.onTap, required this.onDelete});

  IconData get _icon => switch (notif.type) {
    0 || 1 => Icons.warning_amber_outlined,
    2 => Icons.assignment_outlined,
    3 => Icons.assignment_return_outlined,
    _ => Icons.settings_outlined,
  };

  Color get _color => switch (notif.type) {
    0 || 1 => AppColors.warning,
    2 => AppColors.success,
    3 => AppColors.info,
    _ => AppColors.textSecondary,
  };

  Color get _bgColor => switch (notif.type) {
    0 || 1 => AppColors.warningBg,
    2 => AppColors.successBg,
    3 => AppColors.infoBg,
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
    final hasNavigation = notif.relatedEntityId != null || notif.type <= 3;

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
              color: notif.isRead ? AppColors.surfaceDivider : _color.withValues(alpha: 0.3),
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
                              fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
                          )
                        else if (hasNavigation)
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.message,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _relativeTime(),
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary),
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

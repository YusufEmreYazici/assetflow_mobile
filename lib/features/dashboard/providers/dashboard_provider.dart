import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/dashboard_service.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/core/utils/seen_notification_store.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  final service = ref.watch(dashboardServiceProvider);
  final cache = CacheManager.instance;

  try {
    final data = await service.get();
    await cache.set(
      'dashboard',
      data.toJson(),
      ttl: const Duration(minutes: 30),
    );
    final warrantyKey = 'sys_warranty_${SeenNotificationStore.todayKey()}';
    final alreadySent = await SeenNotificationStore.instance.isSeen(warrantyKey);
    if (!alreadySent && data.upcomingWarrantyExpirations.isNotEmpty) {
      await NotificationService.instance.checkWarrantyAlerts(
        data.upcomingWarrantyExpirations,
      );
      await SeenNotificationStore.instance.markSeen(warrantyKey);
    }
    return data;
  } catch (e) {
    final cached = await cache.getStale('dashboard');
    if (cached != null) {
      return DashboardData.fromJson(cached as Map<String, dynamic>);
    }
    rethrow;
  }
});

final recentAssignmentsProvider = FutureProvider.autoDispose<List<Assignment>>((
  ref,
) async {
  final cache = CacheManager.instance;
  try {
    final result = await AssignmentService().getAll(
      page: 1,
      pageSize: 5,
      isActive: true,
    );
    await cache.set(
      'recent_assignments',
      result.items.map((a) => a.toJson()).toList(),
      ttl: const Duration(minutes: 15),
    );
    return result.items;
  } catch (_) {
    final cached = await cache.getStale('recent_assignments');
    if (cached != null) {
      return (cached as List)
          .map((j) => Assignment.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
});

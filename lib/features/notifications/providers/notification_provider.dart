import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/notification_model.dart';

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final ApiClient _api;

  NotificationNotifier(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final response = await _api.dio.get(ApiConstants.notifications);
      final items = (response.data as List<dynamic>)
          .map((j) => NotificationItem.fromJson(j as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      state = AsyncValue.data(items);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.dio.put(ApiConstants.notificationMarkRead(id));
      _updateLocal(id, isRead: true, readAt: DateTime.now());
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.dio.post(ApiConstants.notificationsMarkAllRead);
      final now = DateTime.now();
      state.whenData((items) {
        if (!mounted) return;
        state = AsyncValue.data(
          items
              .map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: now))
              .toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    try {
      await _api.dio.delete(ApiConstants.notificationById(id));
      state.whenData((items) {
        if (!mounted) return;
        state = AsyncValue.data(items.where((n) => n.id != id).toList());
      });
    } catch (_) {}
  }

  void _updateLocal(String id, {required bool isRead, DateTime? readAt}) {
    state.whenData((items) {
      if (!mounted) return;
      state = AsyncValue.data(
        items
            .map(
              (n) =>
                  n.id == id ? n.copyWith(isRead: isRead, readAt: readAt) : n,
            )
            .toList(),
      );
    });
  }
}

final notificationProvider =
    StateNotifierProvider<
      NotificationNotifier,
      AsyncValue<List<NotificationItem>>
    >((ref) {
      return NotificationNotifier(ApiClient.instance);
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationProvider)
      .when(
        data: (items) => items.where((n) => !n.isRead).length,
        loading: () => 0,
        error: (e, st) => 0,
      );
});

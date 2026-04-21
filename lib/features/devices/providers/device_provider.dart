import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/services/offline_cache_service.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

class DeviceListState {
  final List<Device> devices;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const DeviceListState({
    this.devices = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  DeviceListState copyWith({
    List<Device>? devices,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return DeviceListState(
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class DeviceNotifier extends StateNotifier<DeviceListState> {
  final DeviceService _service;
  static const _pageSize = 15;

  DeviceNotifier(this._service) : super(const DeviceListState()) {
    loadDevices();
  }

  Future<void> loadDevices({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(isLoading: true, error: null, page: 1);
    }
    try {
      final result = await _service.getAll(page: 1, pageSize: _pageSize);
      await CacheManager.instance.set(
        'devices_page1',
        result.items.map((d) => d.toJson()).toList(),
        ttl: const Duration(minutes: 15),
      );
      await OfflineCacheService.cacheDevices(result.items);
      state = state.copyWith(
        devices: result.items,
        isLoading: false,
        page: 1,
        hasMore: result.page < result.totalPages,
      );
    } on DioException catch (e) {
      if (OfflineCacheService.hasDeviceCache) {
        state = state.copyWith(
          devices: OfflineCacheService.getCachedDevices(),
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      final cached = await CacheManager.instance.getStale('devices_page1');
      if (cached != null) {
        final items = (cached as List)
            .map((j) => Device.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(devices: items, isLoading: false, page: 1, hasMore: false);
        return;
      }
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      if (OfflineCacheService.hasDeviceCache) {
        state = state.copyWith(
          devices: OfflineCacheService.getCachedDevices(),
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      final cached = await CacheManager.instance.getStale('devices_page1');
      if (cached != null) {
        final items = (cached as List)
            .map((j) => Device.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(devices: items, isLoading: false, page: 1, hasMore: false);
        return;
      }
      state = state.copyWith(isLoading: false, error: 'Beklenmeyen bir hata olustu.');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _service.getAll(page: nextPage, pageSize: _pageSize);
      state = state.copyWith(
        devices: [...state.devices, ...result.items],
        isLoadingMore: false,
        page: nextPage,
        hasMore: result.page < result.totalPages,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        devices: state.devices.where((d) => d.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => loadDevices(reset: true);

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) return data['message'] as String;
    }
    return 'Bir hata olustu. Lutfen tekrar deneyin.';
  }
}

final deviceProvider =
    StateNotifierProvider.autoDispose<DeviceNotifier, DeviceListState>((ref) {
      final service = ref.watch(deviceServiceProvider);
      return DeviceNotifier(service);
    });

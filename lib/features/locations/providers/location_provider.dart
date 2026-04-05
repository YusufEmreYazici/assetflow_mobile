import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

class LocationListState {
  final List<Location> locations;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const LocationListState({
    this.locations = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  LocationListState copyWith({
    List<Location>? locations,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return LocationListState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationListState> {
  final LocationService _service;

  LocationNotifier(this._service) : super(const LocationListState()) {
    loadLocations();
  }

  Future<void> loadLocations({bool reset = true}) async {
    if (reset) state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final result = await _service.getAll(page: 1, pageSize: 50);
      state = state.copyWith(
        locations: result.items,
        isLoading: false,
        page: 1,
        hasMore: result.page < result.totalPages,
      );
    } on DioException catch (e) {
      String msg = 'Bir hata olustu.';
      if (e.response?.data is Map<String, dynamic>) {
        msg = (e.response!.data as Map)['error'] ?? msg;
      }
      state = state.copyWith(isLoading: false, error: msg);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Beklenmeyen bir hata olustu.');
    }
  }

  Future<bool> deleteLocation(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        locations: state.locations.where((l) => l.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => loadLocations(reset: true);
}

final locationProvider =
    StateNotifierProvider.autoDispose<LocationNotifier, LocationListState>((ref) {
  return LocationNotifier(ref.watch(locationServiceProvider));
});

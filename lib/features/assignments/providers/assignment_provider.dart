import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';

final assignmentServiceProvider = Provider<AssignmentService>(
  (ref) => AssignmentService(),
);

enum AssignmentFilter { all, active, returned }

class AssignmentListState {
  final List<Assignment> assignments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final String searchQuery;
  final AssignmentFilter filter;

  const AssignmentListState({
    this.assignments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.searchQuery = '',
    this.filter = AssignmentFilter.all,
  });

  AssignmentListState copyWith({
    List<Assignment>? assignments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    String? searchQuery,
    AssignmentFilter? filter,
  }) {
    return AssignmentListState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }
}

class AssignmentNotifier extends StateNotifier<AssignmentListState> {
  final AssignmentService _service;
  static const _pageSize = 15;

  AssignmentNotifier(this._service) : super(const AssignmentListState()) {
    loadAssignments();
  }

  bool? get _activeFilter {
    switch (state.filter) {
      case AssignmentFilter.active:
        return true;
      case AssignmentFilter.returned:
        return false;
      case AssignmentFilter.all:
        return null;
    }
  }

  Future<void> loadAssignments({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(isLoading: true, error: null, page: 1);
    }
    try {
      final result = await _service.getAll(
        page: 1,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        isActive: _activeFilter,
      );
      final cacheKey = 'assignments_${state.filter.name}_page1';
      if (state.searchQuery.isEmpty) {
        await CacheManager.instance.set(
          cacheKey,
          result.items.map((a) => a.toJson()).toList(),
          ttl: const Duration(minutes: 15),
        );
      }
      state = state.copyWith(
        assignments: result.items,
        isLoading: false,
        page: 1,
        hasMore: result.page < result.totalPages,
      );
    } on DioException catch (e) {
      if (state.searchQuery.isEmpty) {
        final cacheKey = 'assignments_${state.filter.name}_page1';
        final cached = await CacheManager.instance.getStale(cacheKey);
        if (cached != null) {
          final items = (cached as List)
              .map((j) => Assignment.fromJson(j as Map<String, dynamic>))
              .toList();
          state = state.copyWith(
            assignments: items,
            isLoading: false,
            page: 1,
            hasMore: false,
          );
          return;
        }
      }
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (_) {
      if (state.searchQuery.isEmpty) {
        final cacheKey = 'assignments_${state.filter.name}_page1';
        final cached = await CacheManager.instance.getStale(cacheKey);
        if (cached != null) {
          final items = (cached as List)
              .map((j) => Assignment.fromJson(j as Map<String, dynamic>))
              .toList();
          state = state.copyWith(
            assignments: items,
            isLoading: false,
            page: 1,
            hasMore: false,
          );
          return;
        }
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Beklenmeyen bir hata olustu.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _service.getAll(
        page: nextPage,
        pageSize: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        isActive: _activeFilter,
      );
      state = state.copyWith(
        assignments: [...state.assignments, ...result.items],
        isLoadingMore: false,
        page: nextPage,
        hasMore: result.page < result.totalPages,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadAssignments(reset: true);
  }

  Future<void> setFilter(AssignmentFilter filter) async {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter, searchQuery: '');
    await loadAssignments(reset: true);
  }

  Future<bool> returnDevice(
    String id, {
    required int returnCondition,
    String? returnNotes,
    String? deviceNotes,
    bool retireDevice = false,
  }) async {
    try {
      final assignment = state.assignments.where((a) => a.id == id).firstOrNull;
      await _service.returnDevice(
        id,
        returnCondition: returnCondition,
        returnNotes: returnNotes,
        deviceNotes: deviceNotes,
        retireDevice: retireDevice,
      );

      final conditionLabel =
          ReturnConditionLabels[returnCondition] ?? 'Bilinmiyor';
      await NotificationService.instance.notifyAssignmentReturned(
        employeeName: assignment?.employeeName ?? 'Bilinmiyor',
        deviceName: assignment?.deviceName ?? 'Bilinmiyor',
        condition: conditionLabel,
      );

      if (retireDevice) {
        await NotificationService.instance.notifyDeviceRetired(
          deviceName: assignment?.deviceName ?? 'Bilinmiyor',
        );
      }

      await loadAssignments(reset: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => loadAssignments(reset: true);

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) return data['error'] as String;
    }
    return 'Bir hata olustu.';
  }
}

final assignmentProvider =
    StateNotifierProvider.autoDispose<AssignmentNotifier, AssignmentListState>((
      ref,
    ) {
      return AssignmentNotifier(ref.watch(assignmentServiceProvider));
    });

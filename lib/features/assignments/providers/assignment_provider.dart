import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';

final assignmentServiceProvider = Provider<AssignmentService>((ref) => AssignmentService());

class AssignmentListState {
  final List<Assignment> assignments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final String searchQuery;

  const AssignmentListState({
    this.assignments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.searchQuery = '',
  });

  AssignmentListState copyWith({
    List<Assignment>? assignments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    String? searchQuery,
  }) {
    return AssignmentListState(
      assignments: assignments ?? this.assignments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AssignmentNotifier extends StateNotifier<AssignmentListState> {
  final AssignmentService _service;
  static const _pageSize = 15;

  AssignmentNotifier(this._service) : super(const AssignmentListState()) {
    loadAssignments();
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
      );
      state = state.copyWith(
        assignments: result.items,
        isLoading: false,
        page: 1,
        hasMore: result.page < result.totalPages,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Beklenmeyen bir hata olustu.');
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

  Future<bool> returnDevice(String id) async {
    try {
      await _service.returnDevice(id);
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
    StateNotifierProvider.autoDispose<AssignmentNotifier, AssignmentListState>((ref) {
  return AssignmentNotifier(ref.watch(assignmentServiceProvider));
});

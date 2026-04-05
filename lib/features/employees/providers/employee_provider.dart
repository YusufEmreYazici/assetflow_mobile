import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) => EmployeeService());

class EmployeeListState {
  final List<Employee> employees;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const EmployeeListState({
    this.employees = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  EmployeeListState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return EmployeeListState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

class EmployeeNotifier extends StateNotifier<EmployeeListState> {
  final EmployeeService _service;
  static const _pageSize = 15;

  EmployeeNotifier(this._service) : super(const EmployeeListState()) {
    loadEmployees();
  }

  Future<void> loadEmployees({bool reset = true}) async {
    if (reset) {
      state = state.copyWith(isLoading: true, error: null, page: 1);
    }
    try {
      final result = await _service.getAll(page: 1, pageSize: _pageSize);
      state = state.copyWith(
        employees: result.items,
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
      final result = await _service.getAll(page: nextPage, pageSize: _pageSize);
      state = state.copyWith(
        employees: [...state.employees, ...result.items],
        isLoadingMore: false,
        page: nextPage,
        hasMore: result.page < result.totalPages,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _service.delete(id);
      state = state.copyWith(
        employees: state.employees.where((e) => e.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => loadEmployees(reset: true);

  String _extractError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) return data['error'] as String;
    }
    return 'Bir hata olustu. Lutfen tekrar deneyin.';
  }
}

final employeeProvider =
    StateNotifierProvider.autoDispose<EmployeeNotifier, EmployeeListState>((ref) {
  return EmployeeNotifier(ref.watch(employeeServiceProvider));
});

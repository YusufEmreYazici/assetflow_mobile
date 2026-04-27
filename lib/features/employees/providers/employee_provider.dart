import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/services/offline_cache_service.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';

final employeeServiceProvider = Provider<EmployeeService>(
  (ref) => EmployeeService(),
);

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
      await CacheManager.instance.set(
        'employees_page1',
        result.items.map((e) => e.toJson()).toList(),
        ttl: const Duration(minutes: 15),
      );
      await OfflineCacheService.cacheEmployees(result.items);
      state = state.copyWith(
        employees: result.items,
        isLoading: false,
        page: 1,
        hasMore: result.page < result.totalPages,
      );
    } on DioException catch (e) {
      if (OfflineCacheService.hasEmployeeCache) {
        state = state.copyWith(
          employees: OfflineCacheService.getCachedEmployees(),
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      final cached = await CacheManager.instance.getStale('employees_page1');
      if (cached != null) {
        final items = (cached as List)
            .map((j) => Employee.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          employees: items,
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      state = state.copyWith(isLoading: false, error: _extractError(e));
    } catch (e) {
      debugPrint('[EmployeeProvider] loadEmployees error: $e');
      if (OfflineCacheService.hasEmployeeCache) {
        state = state.copyWith(
          employees: OfflineCacheService.getCachedEmployees(),
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      final cached = await CacheManager.instance.getStale('employees_page1');
      if (cached != null) {
        final items = (cached as List)
            .map((j) => Employee.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          employees: items,
          isLoading: false,
          page: 1,
          hasMore: false,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Veri yüklenemedi: ${e.toString().split('\n').first}',
      );
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

  Future<void> deleteEmployee(String id) async {
    await _service.delete(id);
    state = state.copyWith(
      employees: state.employees.where((e) => e.id != id).toList(),
    );
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
    StateNotifierProvider.autoDispose<EmployeeNotifier, EmployeeListState>((
      ref,
    ) {
      return EmployeeNotifier(ref.watch(employeeServiceProvider));
    });

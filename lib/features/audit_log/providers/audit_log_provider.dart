import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';
import 'package:assetflow_mobile/data/services/audit_log_service.dart';

class AuditLogState {
  final List<AuditLog> logs;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final String? filterAction;
  final String? filterEntity;

  const AuditLogState({
    this.logs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.filterAction,
    this.filterEntity,
  });

  AuditLogState copyWith({
    List<AuditLog>? logs,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    String? filterAction,
    String? filterEntity,
    bool clearError = false,
    bool clearFilterAction = false,
    bool clearFilterEntity = false,
  }) =>
      AuditLogState(
        logs: logs ?? this.logs,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        error: clearError ? null : (error ?? this.error),
        filterAction: clearFilterAction ? null : (filterAction ?? this.filterAction),
        filterEntity: clearFilterEntity ? null : (filterEntity ?? this.filterEntity),
      );
}

class AuditLogNotifier extends StateNotifier<AuditLogState> {
  final AuditLogService _service;
  static const _pageSize = 20;

  AuditLogNotifier(this._service) : super(const AuditLogState());

  Future<void> load({bool reset = false}) async {
    if (reset) {
      state = state.copyWith(isLoading: true, logs: [], page: 1, hasMore: true, clearError: true);
    } else {
      if (!state.hasMore || state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final page = reset ? 1 : state.page;
      final result = await _service.getAll(
        page: page,
        pageSize: _pageSize,
        action: state.filterAction,
        entityName: state.filterEntity,
      );

      final newLogs = reset ? result.items : [...state.logs, ...result.items];
      state = state.copyWith(
        logs: newLogs,
        isLoading: false,
        isLoadingMore: false,
        page: page + 1,
        hasMore: result.items.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setFilterAction(String? action) async {
    state = action == null
        ? state.copyWith(clearFilterAction: true)
        : state.copyWith(filterAction: action);
    await load(reset: true);
  }

  Future<void> setFilterEntity(String? entity) async {
    state = entity == null
        ? state.copyWith(clearFilterEntity: true)
        : state.copyWith(filterEntity: entity);
    await load(reset: true);
  }
}

final auditLogProvider =
    StateNotifierProvider.autoDispose<AuditLogNotifier, AuditLogState>(
  (ref) => AuditLogNotifier(AuditLogService()),
);

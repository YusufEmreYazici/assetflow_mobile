import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/consumable_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';
import 'package:assetflow_mobile/data/services/consumable_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final consumableServiceProvider = Provider<ConsumableService>((_) => ConsumableService());

// ── List state ────────────────────────────────────────────────────────────────

class ConsumableListState {
  final PagedResult<Consumable>? result;
  final bool isLoading;
  final String? error;
  final String search;
  final int page;

  const ConsumableListState({
    this.result,
    this.isLoading = false,
    this.error,
    this.search = '',
    this.page = 1,
  });

  ConsumableListState copyWith({
    PagedResult<Consumable>? result,
    bool? isLoading,
    String? error,
    String? search,
    int? page,
    bool clearError = false,
  }) =>
      ConsumableListState(
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        search: search ?? this.search,
        page: page ?? this.page,
      );
}

class ConsumableListNotifier extends StateNotifier<ConsumableListState> {
  final ConsumableService _service;

  ConsumableListNotifier(this._service) : super(const ConsumableListState());

  Future<void> load({bool reset = false}) async {
    if (reset) {
      state = state.copyWith(page: 1, clearError: true);
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getAll(
        page: state.page,
        search: state.search,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String search) {
    state = state.copyWith(search: search, page: 1);
    load();
  }
}

final consumableListProvider =
    StateNotifierProvider.autoDispose<ConsumableListNotifier, ConsumableListState>((ref) {
  final notifier = ConsumableListNotifier(ref.read(consumableServiceProvider));
  notifier.load();
  return notifier;
});

// ── Detail state ──────────────────────────────────────────────────────────────

class ConsumableDetailState {
  final Consumable? consumable;
  final List<StockMovement> movements;
  final bool isLoading;
  final bool isMutating;
  final String? error;
  final String? successMessage;

  const ConsumableDetailState({
    this.consumable,
    this.movements = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.error,
    this.successMessage,
  });

  ConsumableDetailState copyWith({
    Consumable? consumable,
    List<StockMovement>? movements,
    bool? isLoading,
    bool? isMutating,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) =>
      ConsumableDetailState(
        consumable: consumable ?? this.consumable,
        movements: movements ?? this.movements,
        isLoading: isLoading ?? this.isLoading,
        isMutating: isMutating ?? this.isMutating,
        error: clearError ? null : (error ?? this.error),
        successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      );
}

class ConsumableDetailNotifier extends StateNotifier<ConsumableDetailState> {
  final ConsumableService _service;
  final String id;

  ConsumableDetailNotifier(this._service, this.id) : super(const ConsumableDetailState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final consumable = await _service.getById(id);
      final movements = await _service.getMovementHistory(id);
      state = state.copyWith(isLoading: false, consumable: consumable, movements: movements);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> stockIn(int quantity, String? reason) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _service.stockIn(id, quantity: quantity, reason: reason);
      await load();
      state = state.copyWith(isMutating: false, successMessage: 'Stok girişi kaydedildi');
      return true;
    } catch (e) {
      state = state.copyWith(isMutating: false, error: 'İşlem başarısız: ${e.toString()}');
      return false;
    }
  }

  Future<bool> stockOut(int quantity, String? reason) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _service.stockOut(id, quantity: quantity, reason: reason);
      await load();
      state = state.copyWith(isMutating: false, successMessage: 'Stok çıkışı kaydedildi');
      return true;
    } catch (e) {
      state = state.copyWith(isMutating: false, error: 'İşlem başarısız: ${e.toString()}');
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final consumableDetailProvider = StateNotifierProvider.autoDispose
    .family<ConsumableDetailNotifier, ConsumableDetailState, String>((ref, id) {
  final notifier = ConsumableDetailNotifier(ref.read(consumableServiceProvider), id);
  notifier.load();
  return notifier;
});

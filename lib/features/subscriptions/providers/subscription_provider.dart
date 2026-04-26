import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/subscription_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';
import 'package:assetflow_mobile/data/services/subscription_service.dart';

final subscriptionServiceProvider =
    Provider<SubscriptionService>((_) => SubscriptionService());

class SubscriptionListState {
  final PagedResult<Subscription>? result;
  final bool isLoading;
  final String? error;
  final String search;

  const SubscriptionListState({
    this.result,
    this.isLoading = false,
    this.error,
    this.search = '',
  });

  SubscriptionListState copyWith({
    PagedResult<Subscription>? result,
    bool? isLoading,
    String? error,
    String? search,
    bool clearError = false,
  }) =>
      SubscriptionListState(
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        search: search ?? this.search,
      );
}

class SubscriptionListNotifier extends StateNotifier<SubscriptionListState> {
  final SubscriptionService _service;

  SubscriptionListNotifier(this._service) : super(const SubscriptionListState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getAll(search: state.search);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
    load();
  }
}

final subscriptionListProvider =
    StateNotifierProvider.autoDispose<SubscriptionListNotifier, SubscriptionListState>((ref) {
  final notifier = SubscriptionListNotifier(ref.read(subscriptionServiceProvider));
  notifier.load();
  return notifier;
});

final subscriptionDetailProvider =
    FutureProvider.autoDispose.family<Subscription, String>((ref, id) {
  return ref.read(subscriptionServiceProvider).getById(id);
});

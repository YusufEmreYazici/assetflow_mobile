import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/software_license_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';
import 'package:assetflow_mobile/data/services/software_license_service.dart';

final softwareLicenseServiceProvider =
    Provider<SoftwareLicenseService>((_) => SoftwareLicenseService());

class SoftwareLicenseListState {
  final PagedResult<SoftwareLicense>? result;
  final bool isLoading;
  final String? error;
  final String search;

  const SoftwareLicenseListState({
    this.result,
    this.isLoading = false,
    this.error,
    this.search = '',
  });

  SoftwareLicenseListState copyWith({
    PagedResult<SoftwareLicense>? result,
    bool? isLoading,
    String? error,
    String? search,
    bool clearError = false,
  }) =>
      SoftwareLicenseListState(
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        search: search ?? this.search,
      );
}

class SoftwareLicenseListNotifier extends StateNotifier<SoftwareLicenseListState> {
  final SoftwareLicenseService _service;

  SoftwareLicenseListNotifier(this._service) : super(const SoftwareLicenseListState());

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

final softwareLicenseListProvider = StateNotifierProvider.autoDispose<
    SoftwareLicenseListNotifier, SoftwareLicenseListState>((ref) {
  final notifier = SoftwareLicenseListNotifier(ref.read(softwareLicenseServiceProvider));
  notifier.load();
  return notifier;
});

final softwareLicenseDetailProvider =
    FutureProvider.autoDispose.family<SoftwareLicense, String>((ref, id) {
  return ref.read(softwareLicenseServiceProvider).getById(id);
});

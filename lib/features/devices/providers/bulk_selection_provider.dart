import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkSelectionState {
  final bool isActive;
  final Set<String> selectedIds;

  const BulkSelectionState({
    required this.isActive,
    required this.selectedIds,
  });

  int get count => selectedIds.length;
  bool get isEmpty => selectedIds.isEmpty;

  BulkSelectionState copyWith({bool? isActive, Set<String>? selectedIds}) {
    return BulkSelectionState(
      isActive: isActive ?? this.isActive,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class BulkSelectionNotifier extends StateNotifier<BulkSelectionState> {
  BulkSelectionNotifier()
      : super(const BulkSelectionState(isActive: false, selectedIds: {}));

  void enter() => state = state.copyWith(isActive: true);

  void exit() =>
      state = const BulkSelectionState(isActive: false, selectedIds: {});

  void toggle(String id) {
    final next = {...state.selectedIds};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  void selectAll(Iterable<String> ids) {
    state = state.copyWith(selectedIds: ids.toSet());
  }

  void clearAll() {
    state = state.copyWith(selectedIds: {});
  }
}

final bulkSelectionProvider = StateNotifierProvider.autoDispose<
    BulkSelectionNotifier, BulkSelectionState>((ref) {
  return BulkSelectionNotifier();
});

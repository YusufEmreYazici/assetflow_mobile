import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const _key = 'favorite_devices';

  FavoritesNotifier() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    state = list.toSet();
  }

  Future<void> toggle(String deviceId) async {
    final next = {...state};
    if (next.contains(deviceId)) {
      next.remove(deviceId);
    } else {
      next.add(deviceId);
    }
    state = next;
    await _save();
  }

  Future<void> addAll(Iterable<String> ids) async {
    state = {...state, ...ids};
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

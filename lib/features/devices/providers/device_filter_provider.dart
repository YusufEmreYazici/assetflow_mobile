import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/models/device_filter.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/favorites_provider.dart';

// ── Filter state ─────────────────────────────────────────────────────────────

final deviceFilterProvider = StateProvider<DeviceFilter>((ref) {
  return const DeviceFilter();
});

// ── Presets ───────────────────────────────────────────────────────────────────

class FilterPresetsNotifier extends StateNotifier<List<FilterPreset>> {
  static const _key = 'device_filter_presets';

  FilterPresetsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        state = list
            .map((e) => FilterPreset.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> add(String name, DeviceFilter filter) async {
    final preset = FilterPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      filter: filter,
      createdAt: DateTime.now(),
    );
    state = [...state, preset];
    await _save();
  }

  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((p) => p.toJson()).toList()),
    );
  }
}

final filterPresetsProvider =
    StateNotifierProvider<FilterPresetsNotifier, List<FilterPreset>>((ref) {
      return FilterPresetsNotifier();
    });

// ── Filtered device list ──────────────────────────────────────────────────────

final filteredDevicesProvider = Provider.autoDispose<List<Device>>((ref) {
  final devices = ref.watch(deviceProvider).devices;
  final filter = ref.watch(deviceFilterProvider);
  final favorites = ref.watch(favoritesProvider);

  if (filter.isEmpty) return devices;
  return devices.where((d) => filter.matches(d, favorites: favorites)).toList();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DashboardVariant { a, b }

const _kPrefKey = 'dashboard_variant';

class DashboardVariantNotifier extends StateNotifier<DashboardVariant> {
  DashboardVariantNotifier() : super(DashboardVariant.a) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefKey);
    if (raw == 'b') state = DashboardVariant.b;
  }

  Future<void> setVariant(DashboardVariant v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefKey, v == DashboardVariant.b ? 'b' : 'a');
  }
}

final dashboardVariantProvider =
    StateNotifierProvider<DashboardVariantNotifier, DashboardVariant>(
  (ref) => DashboardVariantNotifier(),
);

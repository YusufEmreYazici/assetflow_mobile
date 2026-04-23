import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  HapticService._();

  static const String _enabledKey = 'haptic_enabled';
  static bool _enabled = true;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  static bool get isEnabled => _enabled;

  /// Hafif titreşim — button tap, chip select
  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Orta titreşim — success action, favorite toggle
  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Güçlü titreşim — delete confirmation, logout
  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Seçim titreşimi — dropdown, filter chip, switch
  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Kısa titreşim — hata, uyarı
  static void vibrate() {
    if (!_enabled) return;
    HapticFeedback.vibrate();
  }
}

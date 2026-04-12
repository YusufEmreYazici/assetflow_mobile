import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  CacheManager._();
  static final CacheManager instance = CacheManager._();

  static const Duration _defaultTtl = Duration(minutes: 15);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Cache data with a key and optional TTL
  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final prefs = await _prefs;
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': (ttl ?? _defaultTtl).inMilliseconds,
    };
    await prefs.setString('cache_$key', jsonEncode(cacheEntry));
  }

  /// Get cached data, returns null if expired or not found
  Future<dynamic> get(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      final timestamp = entry['timestamp'] as int;
      final ttl = entry['ttl'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - timestamp > ttl) {
        // Expired
        await prefs.remove('cache_$key');
        return null;
      }

      return entry['data'];
    } catch (_) {
      await prefs.remove('cache_$key');
      return null;
    }
  }

  /// Get cached data regardless of expiry (for offline use)
  Future<dynamic> getStale(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;

    try {
      final entry = jsonDecode(raw) as Map<String, dynamic>;
      return entry['data'];
    } catch (_) {
      return null;
    }
  }

  /// Clear specific cache
  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove('cache_$key');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

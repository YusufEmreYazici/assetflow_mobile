import 'package:shared_preferences/shared_preferences.dart';

/// Bildirimlerin "daha önce gösterildi mi" durumunu kalıcı olarak saklar.
/// Panel okundu takibi, kritik popup ve sistem bildirimi deduplication için.
class SeenNotificationStore {
  SeenNotificationStore._();
  static final SeenNotificationStore instance = SeenNotificationStore._();

  static const _prefix = 'seen_notif_';

  /// [id] daha önce görüldü mü?
  Future<bool> isSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$id') ?? false;
  }

  /// [id]'yi görüldü olarak işaretle.
  Future<void> markSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$id', true);
  }

  /// Tüm görüldü ID'lerini döndür (prefix çıkarılmış hâliyle).
  Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((k) => k.startsWith(_prefix))
        .map((k) => k.substring(_prefix.length))
        .toSet();
  }

  /// Tüm seen state'i temizle. Profil "önbellek temizle" + test için.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Bugünün tarihini YYYY-MM-DD formatında döndürür (günlük key'ler için).
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

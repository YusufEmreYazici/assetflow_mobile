import 'package:shared_preferences/shared_preferences.dart';

/// Stores per-channel notification on/off preferences.
class NotificationSettings {
  NotificationSettings._();
  static final NotificationSettings instance = NotificationSettings._();

  static const _prefix = 'notif_channel_';

  // Channel keys
  static const String assignments = 'assignments';
  static const String warranty = 'warranty';
  static const String devices = 'devices';
  static const String sap = 'sap';
  static const String system = 'system';

  static const allChannels = [assignments, warranty, devices, sap, system];

  static const Map<String, String> channelLabels = {
    assignments: 'Zimmet Bildirimleri',
    warranty: 'Garanti Uyarıları',
    devices: 'Cihaz Durum Değişiklikleri',
    sap: 'SAP Entegrasyon',
    system: 'Sistem & Raporlar',
  };

  static const Map<String, String> channelDescriptions = {
    assignments: 'Zimmet atama, iade ve gecikme bildirimleri',
    warranty: 'Garanti süresi biten ve yaklaşan cihazlar',
    devices: 'Bakım, emeklilik ve yeni stok ekleme',
    sap: 'SAP üzerinden personel ve varlık aktarımları',
    system: 'Haftalık/aylık otomatik raporlar',
  };

  Future<bool> isEnabled(String channel) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$channel') ?? true; // default: açık
  }

  Future<void> setEnabled(String channel, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$channel', enabled);
  }

  Future<Map<String, bool>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final ch in allChannels)
        ch: prefs.getBool('$_prefix$ch') ?? true,
    };
  }
}

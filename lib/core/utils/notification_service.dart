import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/core/utils/notification_settings.dart' as ns;

/// Notification channel IDs
class _Channels {
  static const assignment = 'assetflow_assignments';
  static const warranty = 'assetflow_warranty';
  static const device = 'assetflow_devices';
  static const sap = 'assetflow_sap';
  static const system = 'assetflow_system';
}

/// Notification ID ranges to prevent collision
class _Ids {
  // Assignment: 1000-1099
  static const assignmentNew = 1000;
  static const assignmentReturn = 1001;
  static const assignmentExpiring = 1002;
  static const assignmentOverdue = 1003;

  // Warranty: 1100-1199
  static const warrantyCritical = 1100;
  static const warrantyWarning = 1101;
  static const warrantyExpired = 1102;

  // Device: 1200-1299
  static const deviceMaintenance = 1200;
  static const deviceNewStock = 1201;
  static const deviceRetired = 1202;

  // SAP: 1300-1399
  static const sapNewEmployee = 1300;
  static const sapEmployeeLeaving = 1301;
  static const sapBudgetApproved = 1302;
  static const sapAssetsImported = 1303;

  // System: 1400-1499
  static const systemWeeklyReport = 1400;
  static const systemMonthlySummary = 1401;
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(initSettings);
      _initialized = true;

      // Request permission on Android 13+
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Don't crash the app if notification init fails
      _initialized = false;
    }
  }

  // ─────────────────────────────────────────────
  //  CORE: Show notification with channel support
  // ─────────────────────────────────────────────

  /// Maps internal channelId to NotificationSettings key
  static String? _settingsKey(String channelId) {
    if (channelId == _Channels.assignment) {
      return ns.NotificationSettings.assignments;
    }
    if (channelId == _Channels.warranty) {
      return ns.NotificationSettings.warranty;
    }
    if (channelId == _Channels.device) return ns.NotificationSettings.devices;
    if (channelId == _Channels.sap) return ns.NotificationSettings.sap;
    if (channelId == _Channels.system) return ns.NotificationSettings.system;
    return null;
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? channelDesc,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_initialized) return;
    // Check user preference for this channel
    final key = _settingsKey(channelId);
    if (key != null) {
      final enabled = await ns.NotificationSettings.instance.isEnabled(key);
      if (!enabled) return;
    }
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: priority,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.show(id, title, body, details);
    } catch (_) {
      // Silently fail - don't crash the app for a notification
    }
  }

  // ─────────────────────────────────────────────
  //  1. ZIMMET (ASSIGNMENT) BILDIRIMLERI
  // ─────────────────────────────────────────────

  /// Yeni zimmet: "Emre Yilmaz'a MacBook Pro 14" zimmetlendi"
  Future<void> notifyAssignmentCreated({
    required String employeeName,
    required String deviceName,
    String? department,
  }) async {
    await _show(
      id: _Ids.assignmentNew,
      title: 'Yeni Zimmet',
      body: department != null
          ? "$employeeName'a $deviceName zimmetlendi ($department)"
          : "$employeeName'a $deviceName zimmetlendi",
      channelId: _Channels.assignment,
      channelName: 'Zimmet Bildirimleri',
      channelDesc: 'Zimmet atama ve iade bildirimleri',
    );
  }

  /// Iade: "Ahmet Kaya, Dell Monitor'u iade etti"
  Future<void> notifyAssignmentReturned({
    required String employeeName,
    required String deviceName,
    String? condition,
  }) async {
    await _show(
      id: _Ids.assignmentReturn,
      title: 'Cihaz Iade Edildi',
      body: condition != null
          ? '$employeeName, $deviceName iade etti (Durum: $condition)'
          : '$employeeName, $deviceName iade etti',
      channelId: _Channels.assignment,
      channelName: 'Zimmet Bildirimleri',
    );
  }

  /// Gecici zimmet suresi doluyor
  Future<void> notifyAssignmentExpiring({
    required String employeeName,
    required String deviceName,
    required int daysRemaining,
  }) async {
    await _show(
      id: _Ids.assignmentExpiring,
      title: 'Gecici Zimmet Suresi Doluyor',
      body:
          "$employeeName'in gecici zimmeti $daysRemaining gun icinde doluyor ($deviceName)",
      channelId: _Channels.assignment,
      channelName: 'Zimmet Bildirimleri',
    );
  }

  /// Iade tarihi gecmis
  Future<void> notifyAssignmentOverdue({
    required String employeeName,
    required String deviceName,
    required int daysOverdue,
  }) async {
    await _show(
      id: _Ids.assignmentOverdue,
      title: 'Iade Tarihi Gecti!',
      body:
          "$employeeName'in iade tarihi gecti! ($deviceName - $daysOverdue gun gecikme)",
      channelId: _Channels.assignment,
      channelName: 'Zimmet Bildirimleri',
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  // ─────────────────────────────────────────────
  //  2. GARANTI BILDIRIMLERI
  // ─────────────────────────────────────────────

  /// Garanti uyarilari (dashboard'dan tetiklenir)
  Future<void> checkWarrantyAlerts(List<WarrantyAlertItem> items) async {
    if (items.isEmpty) return;

    final critical = items.where((i) => i.daysRemaining <= 30).toList();
    final warning = items
        .where((i) => i.daysRemaining > 30 && i.daysRemaining <= 90)
        .toList();
    final expired = items.where((i) => i.daysRemaining <= 0).toList();

    if (expired.isNotEmpty) {
      await _show(
        id: _Ids.warrantyExpired,
        title: '${expired.length} Cihazin Garantisi Bitti!',
        body: expired.length == 1
            ? '${expired.first.deviceName} garantisi doldu'
            : '${expired.map((e) => e.deviceName).take(3).join(", ")} ve digerleri',
        channelId: _Channels.warranty,
        channelName: 'Garanti Bildirimleri',
        channelDesc: 'Garanti suresi uyarilari',
        importance: Importance.max,
      );
    }

    if (critical.isNotEmpty) {
      await _show(
        id: _Ids.warrantyCritical,
        title: '${critical.length} Cihazin Garantisi Bitiyor!',
        body: critical.length == 1
            ? '${critical.first.deviceName} - ${critical.first.daysRemaining} gun kaldi'
            : '${critical.map((e) => e.deviceName).take(3).join(", ")} ve digerleri',
        channelId: _Channels.warranty,
        channelName: 'Garanti Bildirimleri',
      );
    }

    if (warning.isNotEmpty) {
      await _show(
        id: _Ids.warrantyWarning,
        title: '${warning.length} Cihazda Garanti Uyarisi',
        body: warning.length == 1
            ? '${warning.first.deviceName} - ${warning.first.daysRemaining} gun kaldi'
            : warning.map((e) => e.deviceName).take(3).join(', '),
        channelId: _Channels.warranty,
        channelName: 'Garanti Bildirimleri',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
    }
  }

  // ─────────────────────────────────────────────
  //  3. CIHAZ DURUM BILDIRIMLERI
  // ─────────────────────────────────────────────

  /// Cihaz bakima alindi
  Future<void> notifyDeviceMaintenance({
    required String deviceName,
    String? reason,
  }) async {
    await _show(
      id: _Ids.deviceMaintenance,
      title: 'Cihaz Bakima Alindi',
      body: reason != null
          ? '$deviceName bakima alindi: $reason'
          : '$deviceName bakima alindi',
      channelId: _Channels.device,
      channelName: 'Cihaz Bildirimleri',
      channelDesc: 'Cihaz durum degisiklikleri',
    );
  }

  /// Yeni cihazlar depoya eklendi
  Future<void> notifyNewDevicesAdded({required int count}) async {
    await _show(
      id: _Ids.deviceNewStock,
      title: 'Yeni Cihaz Eklendi',
      body: '$count yeni cihaz depoya eklendi',
      channelId: _Channels.device,
      channelName: 'Cihaz Bildirimleri',
    );
  }

  /// Cihaz emekliye ayrildi
  Future<void> notifyDeviceRetired({
    required String deviceName,
    String? assetCode,
  }) async {
    await _show(
      id: _Ids.deviceRetired,
      title: 'Cihaz Emekliye Ayrildi',
      body: assetCode != null
          ? '$deviceName ($assetCode) emekliye ayrildi'
          : '$deviceName emekliye ayrildi',
      channelId: _Channels.device,
      channelName: 'Cihaz Bildirimleri',
    );
  }

  // ─────────────────────────────────────────────
  //  4. SAP ENTEGRASYON BILDIRIMLERI (GELECEK)
  // ─────────────────────────────────────────────

  /// Yeni personel SAP'den aktarildi
  Future<void> notifySapNewEmployee({
    required String employeeName,
    required String department,
  }) async {
    await _show(
      id: _Ids.sapNewEmployee,
      title: 'Yeni Personel (SAP)',
      body: '$employeeName ($department) - cihaz atamasi bekliyor',
      channelId: _Channels.sap,
      channelName: 'SAP Bildirimleri',
      channelDesc: 'SAP entegrasyon bildirimleri',
    );
  }

  /// Personel isten ayriliyor
  Future<void> notifySapEmployeeLeaving({
    required String employeeName,
    required int assignedDeviceCount,
  }) async {
    await _show(
      id: _Ids.sapEmployeeLeaving,
      title: 'Personel Ayriliyor (SAP)',
      body:
          '$employeeName isten ayriliyor - $assignedDeviceCount zimmetli cihazi var',
      channelId: _Channels.sap,
      channelName: 'SAP Bildirimleri',
      importance: Importance.max,
    );
  }

  /// Butce onaylandi
  Future<void> notifySapBudgetApproved({
    required double amount,
    String? description,
  }) async {
    final formatted =
        '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} TL';
    await _show(
      id: _Ids.sapBudgetApproved,
      title: 'Butce Onaylandi (SAP)',
      body: description != null
          ? '$formatted ekipman butcesi onaylandi: $description'
          : '$formatted ekipman butcesi onaylandi',
      channelId: _Channels.sap,
      channelName: 'SAP Bildirimleri',
    );
  }

  /// SAP'den varliklar aktarildi
  Future<void> notifySapAssetsImported({required int count}) async {
    await _show(
      id: _Ids.sapAssetsImported,
      title: 'Varlik Aktarimi (SAP)',
      body: "SAP'den $count yeni varlik aktarildi",
      channelId: _Channels.sap,
      channelName: 'SAP Bildirimleri',
    );
  }

  // ─────────────────────────────────────────────
  //  5. SISTEM BILDIRIMLERI
  // ─────────────────────────────────────────────

  /// Haftalik envanter raporu
  Future<void> notifyWeeklyReport({
    required int totalDevices,
    required int assignedDevices,
    required int newAssignments,
    required int returns,
  }) async {
    await _show(
      id: _Ids.systemWeeklyReport,
      title: 'Haftalik Envanter Raporu',
      body:
          'Toplam: $totalDevices cihaz, $assignedDevices zimmetli | Bu hafta: $newAssignments zimmet, $returns iade',
      channelId: _Channels.system,
      channelName: 'Sistem Bildirimleri',
      channelDesc: 'Rapor ve ozet bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  /// Aylik ozet
  Future<void> notifyMonthlySummary({
    required int newAssignments,
    required int returns,
    required int newDevices,
  }) async {
    await _show(
      id: _Ids.systemMonthlySummary,
      title: 'Aylik Ozet Raporu',
      body:
          'Bu ay $newAssignments yeni zimmet, $returns iade, $newDevices yeni cihaz eklendi',
      channelId: _Channels.system,
      channelName: 'Sistem Bildirimleri',
      importance: Importance.defaultImportance,
    );
  }
}

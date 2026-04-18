# NOTIFICATION_BUG_ANALYSIS.md

**Tarih:** 2026-04-18  
**Kapsam:** Bildirim sistemi — 3 persistence sorununun teshisi ve çözüm mimarisi

---

## ADIM 1 — NotificationService İncelemesi

**Dosya:** `lib/core/utils/notification_service.dart`

### Tanımlı Bildirim Metodları

| Method | Kanal | Sabit ID | Parametreler |
|---|---|---|---|
| `notifyAssignmentCreated` | `assetflow_assignments` | `1000` | employeeName, deviceName, department? |
| `notifyAssignmentReturned` | `assetflow_assignments` | `1001` | employeeName, deviceName, condition? |
| `notifyAssignmentExpiring` | `assetflow_assignments` | `1002` | employeeName, deviceName, daysRemaining |
| `notifyAssignmentOverdue` | `assetflow_assignments` | `1003` | employeeName, deviceName, daysOverdue |
| `checkWarrantyAlerts` | `assetflow_warranty` | `1100/1101/1102` | List\<WarrantyAlertItem\> |
| `notifyDeviceMaintenance` | `assetflow_devices` | `1200` | deviceName, reason? |
| `notifyNewDevicesAdded` | `assetflow_devices` | `1201` | count |
| `notifyDeviceRetired` | `assetflow_devices` | `1202` | deviceName, assetCode? |
| `notifySapNewEmployee` | `assetflow_sap` | `1300` | employeeName, department |
| `notifySapEmployeeLeaving` | `assetflow_sap` | `1301` | employeeName, assignedDeviceCount |
| `notifySapBudgetApproved` | `assetflow_sap` | `1302` | amount, description? |
| `notifySapAssetsImported` | `assetflow_sap` | `1303` | count |
| `notifyWeeklyReport` | `assetflow_system` | `1400` | totalDevices, assignedDevices, newAssignments, returns |
| `notifyMonthlySummary` | `assetflow_system` | `1401` | newAssignments, returns, newDevices |

### ID Üretim Yöntemi
**Tamamen deterministik — sabit sabitler.** Her `notifyXxx` çağrısı aynı `_Ids.xxx` sabitini kullanır. `flutter_local_notifications`'da aynı ID ile `show()` çağrısı, varolan bildirimi **günceller/değiştirir** — ama ses/titreşim yeniden tetiklenir.

### "Seen" Takibi
**Yok.** `NotificationService` içinde hiçbir "bu daha önce gösterildi mi" kontrolü bulunmuyor. Her çağrı koşulsuz olarak `_show()` fonksiyonunu çalıştırır.

### init() Nerede Çağrılıyor
`lib/main.dart`, satır 31:
```dart
Future.microtask(() {
  ref.read(authProvider.notifier).checkAuth();
  NotificationService.instance.init();
});
```
`_AssetFlowAppState.initState()` içinde, her uygulama başlatmada tek seferlik çağrılır. `_initialized` flag'i sayesinde tekrar init olmaz.

---

## ADIM 2 — Kritik Uyarı Popup Akışı

**Dosya:** `lib/features/dashboard/screens/dashboard_screen.dart`

### Tetiklenme Koşulu
```dart
ref.listen<AsyncValue<DashboardData>>(dashboardProvider, (prev, next) {
  if (!_alertShown && next is AsyncData<DashboardData>) {
    _alertShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showCriticalAlert(context, next.value);
    });
  }
});
```
`dashboardProvider` ilk kez `AsyncData` döndürdüğünde, `_alertShown == false` ise tetiklenir.

### `_alertShown` Nerede Tutuluyor
```dart
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _alertShown = false; // satır 29
```
**`_DashboardScreenState` sınıfının instance alanı** — tamamen RAM'de, hiçbir persistent storage'a yazılmıyor.

### Her Açılışta Reset mi?
**Evet.** `_DashboardScreenState` widget her oluşturulduğunda `_alertShown = false` ile başlar. App restart = yeni State instance = `_alertShown` tekrar `false`. Aynı gün uygulama kapatılıp açılsa bile popup yeniden gösterilir.

---

## ADIM 3 — Panel Okundu Durumu

### `_readNotifIds` Nerede Tanımlı
```dart
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final Set<String> _readNotifIds = {}; // satır 30
```
**`_DashboardScreenState` instance alanı** — RAM'de, persistent değil.

### Nasıl Güncelleniyor
Tek güncelleme yeri `_openNotifications()`:
```dart
onMarkRead: (id) => setState(() => _readNotifIds.add(id)),
```
`NotificationPanel`'dan gelen `onMarkRead` callback'i tetiklendiğinde `setState` ile eklenir.

### SharedPreferences'a Yazılıyor mu?
**Hayır.** `_readNotifIds`'in SharedPreferences veya başka bir kalıcı depolama ile hiçbir bağlantısı yok.

### App Yeniden Başlatılınca Ne Olur
`_DashboardScreenState` yeniden oluşturulur → `_readNotifIds = {}` (boş Set) → panel açıldığında tüm bildirimler "okunmamış" görünür → `notifCount` badge sıfırdan başlar.

---

## ADIM 4 — Sistem Bildirimi Çağrı Noktaları

### Tüm Çağrı Noktaları

| Dosya | Satır | Method | Tetikleyici Event | "Daha önce bildirildi" kontrolü |
|---|---|---|---|---|
| `assign_device_screen.dart` | 145 | `notifyAssignmentCreated` | Zimmet atama form submit | **YOK** |
| `assignment_provider.dart` | 166 | `notifyAssignmentReturned` | İade işlemi tamamlandığında | **YOK** |
| `dashboard_provider.dart` | 26 | `checkWarrantyAlerts` | Dashboard her yüklendiğinde | **YOK** |
| `device_form_screen.dart` | 146 | `notifyNewDevicesAdded` | Cihaz ekleme formu submit | **YOK** |
| `device_form_screen.dart` | 149 | `notifyDeviceRetired` | Cihaz durumu "emekli" yapılınca | **YOK** |
| `device_form_screen.dart` | 154 | `notifyDeviceMaintenance` | Cihaz durumu "bakım" yapılınca | **YOK** |
| `sap_provider.dart` | 96 | `notifySapNewEmployee` | SAP sync — yeni personel | **YOK** |
| `sap_provider.dart` | 114 | `notifySapAssetsImported` | SAP sync — varlık aktarımı | **YOK** |
| `sap_provider.dart` | 132 | `notifySapBudgetApproved` | SAP sync — bütçe onayı | **YOK** |

### En Kritik Sorun: `checkWarrantyAlerts`
`dashboardProvider` bir `FutureProvider.autoDispose` — `DashboardScreen` her açıldığında (veya `ref.invalidate` çağrıldığında) yeniden tetiklenir. Her tetiklenmede `checkWarrantyAlerts` çağrılır ve:
- Süresi dolmuş garanti varsa → ID `1102` ile sistem bildirimi
- Kritik (<30 gün) varsa → ID `1100` ile sistem bildirimi
- Uyarı (<90 gün) varsa → ID `1101` ile sistem bildirimi

Aynı ID → `flutter_local_notifications` bildirimi değiştirir/yeniler, kullanıcı her dashboard açışında ses/titreşim alır.

---

## ADIM 5 — Mevcut Persistence Kullanımı

### SharedPreferences Kullanan Sınıflar

| Sınıf | Dosya | Key Prefix | Ne Saklar |
|---|---|---|---|
| `TokenManager` | `lib/core/utils/token_manager.dart` | (doğrudan key) | JWT access/refresh token, kullanıcı bilgisi |
| `CacheManager` | `lib/core/utils/cache_manager.dart` | `cache_` | API yanıtları (TTL + timestamp ile) |
| `NotificationSettings` | `lib/core/utils/notification_settings.dart` | `notif_channel_` | Kanal bazlı bildirim açık/kapalı tercihleri |

### NotificationSettings Nasıl Çalışıyor
Singleton pattern (`_()` private constructor + `static final instance`). Her kanal için `prefs.getBool('notif_channel_<kanal>')` okur/yazar. Default: `true` (açık). `isEnabled(key)` ile kontrol, `setEnabled(key, bool)` ile güncelleme.

### Yeni SeenNotificationsStore için Mevcut Pattern Uyumluluğu
`NotificationSettings` ile birebir aynı pattern kullanılabilir:
- Singleton (`_()` + `static final instance`)
- `SharedPreferences.getInstance()` her method'da
- String key prefix sistemi (`seen_notif_`)
- `isSeen(id)`, `markSeen(id)` metodları

---

## ADIM 6 — 3 Sorunun Root Cause Teshisi

### Sorun 1: Kritik Uyarı Popup Her Açılışta Gösteriliyor

**Root Cause:**
`_alertShown` → `_DashboardScreenState` instance field → sadece RAM'de yaşar → app kapandığında veya widget rebuild olduğunda sıfırlanır.

**Nasıl Persist Edilebilir:**
SharedPreferences'a `seen_critical_alert_YYYY-MM-DD` (gün bazlı) veya `seen_critical_alert_v{expiredCount}_{expiringCount}` (içerik bazlı) key ile yazılabilir. Uygulama açılışında bu key okunarak popup atlanabilir.

---

### Sorun 2: Panel Okundu Durumu Sıfırlanıyor

**Root Cause:**
`_readNotifIds` → `_DashboardScreenState` instance field (`final Set<String> _readNotifIds = {}`) → sadece RAM → app restart = boş set.

**Nasıl Persist Edilebilir:**
SharedPreferences'a `seen_notif_w_{deviceId}` ve `seen_notif_a_{assignmentId}` key'leri ile yazılabilir. `_DashboardScreenState.initState()`'de okuma yapılır.

---

### Sorun 3: Sistem Bildirimi Tekrar Atılıyor

**Root Cause:**
`checkWarrantyAlerts` → `dashboardProvider` her yüklenişinde çağrılır → "bu garanti için bugün bildirim atıldı mı?" kontrolü **yok** → aynı `_Ids.warrantyExpired` (1102) ile tekrar `_plugin.show()` çağrılır.

**`flutter_local_notifications`'da Aynı ID Davranışı:**
Aynı ID ile `show()` çağrısı varolan bildirimi **override eder** (bildirim çekmecesinde güncellenir), ama ses/titreşim yeniden tetiklenir. "Zaten gösterildi, sessiz geç" mantığı yoktur.

**"Bu event için bildirim atıldı" Takibi:**
SharedPreferences'a `seen_warranty_sys_{date}` key'i ile yazılabilir. Bugünkü tarih key'i varsa `checkWarrantyAlerts` sistem bildirimi atlamayı uygular; yoksa bildirim atar ve key'i kaydeder.

---

## ADIM 7 — Önerilen Çözüm Mimarisi: SeenNotificationStore

### Konum
`lib/core/utils/seen_notification_store.dart`

Mevcut `NotificationSettings` ile aynı dizin, aynı singleton pattern.

### Önerilen Interface

```dart
class SeenNotificationStore {
  SeenNotificationStore._();
  static final SeenNotificationStore instance = SeenNotificationStore._();

  static const _prefix = 'seen_notif_';

  Future<bool> isSeen(String id) async { ... }
  Future<void> markSeen(String id) async { ... }
  Future<void> markAllSeen(List<String> ids) async { ... }
  Future<void> clearAll() async { ... }  // profil ekranı "önbellek temizle" için
  Future<Set<String>> getAll() async { ... }
}
```

### Kullanılacak ID Pattern'leri

| Kullanım | ID Pattern | Örnek |
|---|---|---|
| Panel okundu — garanti | `panel_w_{deviceId}` | `panel_w_42` |
| Panel okundu — zimmet | `panel_a_{assignmentId}` | `panel_a_101` |
| Kritik popup (gün bazlı) | `critical_alert_{YYYY-MM-DD}` | `critical_alert_2026-04-18` |
| Sistem bildirimi — garanti (gün bazlı) | `sys_warranty_{YYYY-MM-DD}` | `sys_warranty_2026-04-18` |
| Sistem bildirimi — zimmet atama | `sys_assign_{assignmentId}` | `sys_assign_101` |
| Sistem bildirimi — zimmet iade | `sys_return_{assignmentId}` | `sys_return_101` |

### Her Sorun İçin Entegrasyon Noktası

**Sorun 1 — Kritik popup:**
`_DashboardScreenState.initState()` veya `build()` içinde `ref.listen` callback'inde, `_alertShown` yerine:
```dart
final seen = await SeenNotificationStore.instance.isSeen('critical_alert_2026-04-18');
if (!seen) { _showCriticalAlert(); await SeenNotificationStore.instance.markSeen('...'); }
```

**Sorun 2 — Panel okundu:**
`_DashboardScreenState.initState()`:
```dart
_readNotifIds = await SeenNotificationStore.instance.getAll();
```
`onMarkRead` callback'inde:
```dart
await SeenNotificationStore.instance.markSeen(id);
setState(() => _readNotifIds.add(id));
```

**Sorun 3 — Garanti sistem bildirimi:**
`dashboard_provider.dart` içinde `checkWarrantyAlerts` çağrısı öncesi:
```dart
final key = 'sys_warranty_${DateTime.now().toIso8601String().substring(0,10)}';
final alreadySent = await SeenNotificationStore.instance.isSeen(key);
if (!alreadySent) {
  await NotificationService.instance.checkWarrantyAlerts(data.upcomingWarrantyExpirations);
  await SeenNotificationStore.instance.markSeen(key);
}
```

### Neden Ayrı Dosya?

`CacheManager` → API cache (TTL-based, data)  
`NotificationSettings` → kullanıcı tercihleri (kanal açık/kapalı)  
`SeenNotificationStore` → event deduplication (gösterildi/gösterilmedi)

Sorumluluklar farklı, karıştırmak bakımı güçleştirir.

---

## Özet Tablosu

| Sorun | Değişken | Şu an yaşadığı yer | Persist ediliyor mu | Root cause |
|---|---|---|---|---|
| Kritik popup tekrarı | `_alertShown` | `_DashboardScreenState` RAM | ❌ | Widget rebuild = false'a dönüyor |
| Panel okundu sıfırlanması | `_readNotifIds` | `_DashboardScreenState` RAM | ❌ | App restart = boş Set |
| Garanti bildirimi tekrarı | (yok) | `checkWarrantyAlerts` her dashboard yükünde | ❌ | Hiç kontrol yok |

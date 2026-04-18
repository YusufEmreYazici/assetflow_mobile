# SPEC_MOBILE_002 — Bildirim Persistence Fix

**Hedef proje:** `C:\Workspace\Personal_Projects\assetflow_mobile`
**Tip:** Bug fix + yeni altyapi (SeenNotificationStore)
**Tahmini sure:** 45 dakika
**Referans envanter:** `NOTIFICATION_BUG_ANALYSIS.md`

---

## Amac

3 farkli yerde ayni sorunun (persistent storage eksikligi) cozumunu tek bir ortak altyapi (`SeenNotificationStore`) ile yapmak:

1. **Kritik uyari popup**: Her app acilisinda tekrar cikiyor → sadece yeni gun veya yeni icerik geldiginde cikmali
2. **Panel okundu durumu**: Session bitince sifirlaniyor → kullanici okuduysa kalici sessizlik
3. **Telefon sistem bildirimi**: Her dashboard acilisinda garanti icin ses/titresim → gun basina bir kez bildirim

**Felsefe:** Kullanici "okundu" isaretlemeden bildirim tekrar gosterilir (onemli kacabilir), isaretledigi anda kalici sessizlik. Sistem bildirimi gunluk sessizlik (aym gun icinde 5 kere dashboard acsa bile bir kez ses).

---

## Mimari Kararlar

### 1) Tek sorumluluk: SeenNotificationStore

Yeni sinif `lib/core/utils/seen_notification_store.dart`. Sorumlulugu TEK: "Bu ID gosterildi mi?" ve "Bu ID'yi gosterildi olarak isaretle". Baska hicbir sey yapmaz (bildirim atmaz, data fetch etmez, UI'a karismaz).

### 2) Mevcut pattern'e uyum

`NotificationSettings` ile birebir ayni pattern:
- Singleton (`._()` private constructor + `static final instance`)
- `SharedPreferences.getInstance()` her method icinde
- String key prefix (`seen_notif_`)

Boylece codebase bakim kolayligi — 3 ay sonra kim baksa tanıdık geleçek.

### 3) ID pattern'leri deterministik

Envanterden:

| Kullanim | ID Pattern | Ornek | Scope |
|---|---|---|---|
| Panel okundu — garanti | `panel_w_{deviceId}` | `panel_w_42` | Kalici (okundu = sonsuza dek) |
| Panel okundu — zimmet | `panel_a_{assignmentId}` | `panel_a_101` | Kalici |
| Kritik popup (gun bazli) | `critical_alert_{YYYY-MM-DD}` | `critical_alert_2026-04-18` | Gunluk |
| Sistem bildirimi — garanti (gun bazli) | `sys_warranty_{YYYY-MM-DD}` | `sys_warranty_2026-04-18` | Gunluk |

**Kritik karar — gunluk vs kalici:**
- Panel okundu = **kalici sessizlik**. Kullanici acik secik "okundum" dedi.
- Kritik popup = **gunluk** çünkü her gün yeni bir "durum goruntusu" demektir (dun 3 cihaz expired, bugun 5 olabilir). Kullanici her gün bir kez uyarilmali.
- Sistem bildirimi = **gunluk** çünkü aym şey.

Zimmet bildirimleri (`notifyAssignmentCreated` vb.) event-based — zaten bir kez olan bir event, bu SPEC'te ELLEMEYECEGIZ. Cunku zimmet atmak tekrarlanabilir bir islem degil, zaten dogal olarak bir kez atiliyor.

### 4) Sadece 3 sorun fix edilecek, digerleri DOKUNMAZ

`notifyAssignmentCreated`, `notifyAssignmentReturned`, `notifyDeviceMaintenance`, `notifyNewDevicesAdded`, `notifyDeviceRetired`, `notifySapNewEmployee`, `notifySapEmployeeLeaving`, `notifySapBudgetApproved`, `notifySapAssetsImported`, `notifyWeeklyReport`, `notifyMonthlySummary` — hepsi **event-based**, zaten bir kez atiliyorlar, deduplication gerekli degil. Bu SPEC'te dokunulmayacak.

### 5) Async init hazir

`_DashboardScreenState.initState()` async degil. `_readNotifIds` async olarak yuklenecek: `initState`'te `Future.microtask` ile store'dan okunur, `setState` ile UI'a yansitilir. Loading flicker olabilir ama kabul edilebilir — bir kerelik ve cok kisa.

### 6) Test edilebilirlik

`SeenNotificationStore` singleton ama `clearAll()` method'u var. Test sirasinda temiz slate'e gecmek icin. Profile ekraninda "onbelleyi temizle" buttonu zaten `CacheManager.clearAll()` cagiriyor — ayni yere `SeenNotificationStore.clearAll()` eklemek kolay.

---

## Veri / Tipler

### SeenNotificationStore interface

```dart
class SeenNotificationStore {
  SeenNotificationStore._();
  static final SeenNotificationStore instance = SeenNotificationStore._();

  static const _prefix = 'seen_notif_';

  /// Tek bir ID gosterildi mi kontrol et
  Future<bool> isSeen(String id) async;

  /// Bir ID'yi gosterildi olarak isaretle
  Future<void> markSeen(String id) async;

  /// Tum seen ID'leri getir (panel initState icin)
  Future<Set<String>> getAll() async;

  /// Tum seen state'i temizle (profil ekrani "onbellek temizle" icin)
  Future<void> clearAll() async;

  /// Helper: bugunun tarihini YYYY-MM-DD formatinda dondur
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
           '${now.month.toString().padLeft(2, '0')}-'
           '${now.day.toString().padLeft(2, '0')}';
  }
}
```

### SharedPreferences key yapisi

```
seen_notif_panel_w_42
seen_notif_panel_a_101
seen_notif_critical_alert_2026-04-18
seen_notif_sys_warranty_2026-04-18
```

`getAll()` methodu `SharedPreferences.getKeys()` ile tum `seen_notif_` prefix'li key'leri filtreleyip prefix'i cikararak doner.

---

## Dokunulacak Dosyalar

### Yeni Dosya (1)

- `lib/core/utils/seen_notification_store.dart` — singleton store

### Degistirilecek Dosyalar (3)

- `lib/features/dashboard/screens/dashboard_screen.dart` — `_alertShown` ve `_readNotifIds` store'a bagla
- `lib/features/dashboard/providers/dashboard_provider.dart` — `checkWarrantyAlerts` cagrisindan once gunluk kontrol
- `lib/features/profile/screens/profile_screen.dart` — "onbellek temizle" buttonu'nun `clearAll` mantigina `SeenNotificationStore.clearAll()` ekle

### Dokunulmayan (sirf dokumentasyon icin liste)

- `notification_service.dart` — dokunulmuyor, bu sadece "bildir" gorevi yapar, filtering isimiz degil
- `notification_settings.dart` — kanal on/off, ayri bir konu
- Diger 11 notifyXxx cagrisi — event-based, deduplication gerekmez

---

## Gorevler

### T1 — SeenNotificationStore olustur

**Dosya:** `lib/core/utils/seen_notification_store.dart`

**Detaylar:**
- Singleton pattern, `NotificationSettings` ile ayni kalip
- 5 method: `isSeen`, `markSeen`, `getAll`, `clearAll`, `todayKey` (static helper)
- `SharedPreferences.getInstance()` her method icinde (performans yeterli, her tiklama bir degil)
- Key prefix `seen_notif_`
- Turkce XML comment'lar

**Kabul kriteri:**
- `flutter analyze` temiz
- Dosya yeni olustu, 40-60 satir arasi olmali

**Commit:** `feat(core): SeenNotificationStore eklendi (bildirim deduplication)`

---

### T2 — Panel okundu persistence (Sorun 2)

**Dosya:** `lib/features/dashboard/screens/dashboard_screen.dart`

**Detaylar:**
- `_DashboardScreenState.initState()` icinde async olarak `SeenNotificationStore.instance.getAll()` cagir
  ```dart
  @override
  void initState() {
    super.initState();
    _loadReadNotifIds();
  }

  Future<void> _loadReadNotifIds() async {
    final seen = await SeenNotificationStore.instance.getAll();
    // panel_ prefix'li olanlari filtrele (critical ve sys key'lerini karistirma)
    final panelIds = seen.where((id) => id.startsWith('panel_')).toSet();
    if (mounted) setState(() => _readNotifIds.addAll(panelIds));
  }
  ```
- `_openNotifications` icindeki `onMarkRead` callback'ini guncelle:
  ```dart
  onMarkRead: (id) async {
    await SeenNotificationStore.instance.markSeen(id);
    if (mounted) setState(() => _readNotifIds.add(id));
  },
  ```

**ONEMLI — ID pattern:**
Mevcut `onMarkRead(id)` cagrisinda `id` ne gelmis? Envanterden anlasiliyor ki NotificationPanel'deki tile'larda ID uretimi var. Onu degistirmek ZORUNLU DEGIL — panel.dart icindeki mevcut `id` pattern'i ne ise onunla calisacak. Claude Code bunu once dogrulamali:

1. `notification_panel.dart` icinde `onMarkRead(...)` cagrilari nasil? (muhtemelen `widget.onMarkRead('w_${device.id}')` veya benzer)
2. Panel icindeki ID pattern'ine `panel_` prefix'i ekle (veya zaten uygunsa dokunma)
3. Kritik: eski ID'ler ve yeni ID'ler ayni olmali, yoksa okundu kayit degil okuma gerceklesmez

**Kabul kriteri:**
- `flutter analyze` temiz
- App acilinca okundu durum korunuyor (emulator'de test: bir bildirimi oku, app'i tamamen kapat ve tekrar ac, hala okundu gorunmeli)

**Commit:** `fix(dashboard): panel okundu durumu SharedPreferences'a kaydediliyor`

---

### T3 — Kritik popup gunluk persistence (Sorun 1)

**Dosya:** `lib/features/dashboard/screens/dashboard_screen.dart`

**Detaylar:**
- `_alertShown` field'ini SIL
- `ref.listen` callback'i yeniden yaz:
  ```dart
  ref.listen<AsyncValue<DashboardData>>(dashboardProvider, (prev, next) {
    if (next is! AsyncData<DashboardData>) return;
    _maybeShowCriticalAlert(next.value);
  });

  Future<void> _maybeShowCriticalAlert(DashboardData data) async {
    final key = 'critical_alert_${SeenNotificationStore.todayKey()}';
    final seen = await SeenNotificationStore.instance.isSeen(key);
    if (seen) return;
    await SeenNotificationStore.instance.markSeen(key);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showCriticalAlert(context, data);
    });
  }
  ```

**Dikkat:** `ref.listen` senkronise calistigi icin `_maybeShowCriticalAlert` async olsa bile "fire and forget" yapiyoruz. Bu sorun olusturmaz, sadece popup bir frame sonra cikar.

**Kabul kriteri:**
- `flutter analyze` temiz
- Emulator'de test:
  - Login ol → popup cikar → kapat
  - App'i tamamen kapat, yeniden ac → popup CIKMAZ (aym gun)
  - Sistem tarihini degistirmeden dogrula (test icin workaround: SeenNotificationStore.clearAll() cagir)

**Commit:** `fix(dashboard): kritik uyari popup gunluk bir kez gosteriliyor`

---

### T4 — Garanti sistem bildirimi gunluk persistence (Sorun 3)

**Dosya:** `lib/features/dashboard/providers/dashboard_provider.dart`

**Detaylar:**
- `dashboardProvider` icinde `NotificationService.instance.checkWarrantyAlerts(...)` cagrisini wrap et:
  ```dart
  // Once mevcut cagriyi bul — satir 26 civari
  // Eskisi (envantere gore):
  //   await NotificationService.instance.checkWarrantyAlerts(data.upcomingWarrantyExpirations);
  
  // Yeni:
  final key = 'sys_warranty_${SeenNotificationStore.todayKey()}';
  final alreadySent = await SeenNotificationStore.instance.isSeen(key);
  if (!alreadySent && data.upcomingWarrantyExpirations.isNotEmpty) {
    await NotificationService.instance.checkWarrantyAlerts(data.upcomingWarrantyExpirations);
    await SeenNotificationStore.instance.markSeen(key);
  }
  ```
- Import ekle: `import '../../../core/utils/seen_notification_store.dart';`

**Kabul kriteri:**
- `flutter analyze` temiz
- Emulator'de test:
  - App ac → telefon bildirimi gelir (eger garanti biten cihaz varsa)
  - App'i kapat, 5 sn bekle, tekrar ac → bildirim **TEKRAR GELMEZ**
  - SeenNotificationStore.clearAll() cagir (veya uygulama verisini sifirla) → tekrar ac → bildirim gelir

**Commit:** `fix(dashboard): garanti sistem bildirimi gunluk bir kez atiliyor`

---

### T5 — Profile ekrani "onbellek temizle" entegrasyonu

**Dosya:** `lib/features/profile/screens/profile_screen.dart`

**Detaylar:**
- Mevcut "onbellek temizle" button'unun `onPressed` callback'ini bul (`CacheManager.clearAll()` cagriliyor olmali)
- Yanina `SeenNotificationStore.instance.clearAll()` ekle:
  ```dart
  await CacheManager.instance.clearAll();
  await SeenNotificationStore.instance.clearAll();  // YENI
  ```
- Import ekle

**Neden bu adim:** Bir kullanici "onbellek temizle" dediginde sadece cache degil, "bir daha gosterme" kararlari da sifirlanmali. Yoksa cache silinse bile bildirimler yeniden goremeyecek, sinir bozucu olur.

**Kabul kriteri:**
- `flutter analyze` temiz
- Profil → "Onbellek temizle" → bildirimler tekrar gorunur olmali (test etme zamani olmasa bile Claude Code kod seviyesinde emin olmali)

**Commit:** `feat(profile): onbellek temizleme SeenNotificationStore'u da temizliyor`

---

### T6 — Son dogrulama

**Detaylar:**
1. `flutter analyze` → 0 hata/uyari
2. `dart run custom_lint` → 0 issue
3. `dart format lib/core/utils/ lib/features/dashboard/ lib/features/profile/`
4. Git log'da 5 commit goruluyor mu
5. Manuel test senaryosu:

**Test A — Panel okundu persistence:**
- App ac, panel ac, bir bildirime tikla (okundu isaretle)
- App'i tamamen kapat
- Yeniden ac, panel ac → bildirim hala okundu gorunur ✓

**Test B — Kritik popup gunluk:**
- App ac → popup cikarsa kapat
- App'i tamamen kapat, yeniden ac → popup CIKMAZ ✓
- Profil → onbellek temizle
- App'i kapat, yeniden ac → popup tekrar cikar ✓

**Test C — Garanti bildirimi gunluk:**
- (Garanti biten cihaz varsa) App ac → telefon bildirimi gelir
- App'i kapat, 30 sn sonra yeniden ac → bildirim TEKRAR GELMEZ ✓
- Onbellek temizle → yeniden ac → bildirim gelir ✓

**Test D — Diger bildirimler etkilenmedi:**
- Yeni bir zimmet at → `notifyAssignmentCreated` tetiklenir (dokunulmadi) ✓
- SAP sync yap → `notifySapNewEmployee` tetiklenir ✓

**Commit:** (degisiklik varsa) `refactor: notification fix cleanup + format`

---

## Kapsam Disi

- **Event-based bildirimler (`notifyAssignmentCreated`, vb.)** — dokunulmaz, zaten tek sefer tetiklenir
- **Kanal bazli ayarlar** — `NotificationSettings` ayri sistem
- **Bildirim gecmisi arsivi** — bildirilenleri arsivleme/gorme ayri feature
- **Server-side bildirim** — backend push notification bu SPEC'te yok (uzun vadeli is)
- **UI degisikligi** — okundu durumunun gorsel gosterimi ayni kalacak
- **Deep link / bildirim tikinca acilacak sayfa** — mevcut davranis korunuyor

---

## Notlar (Claude Code icin)

- **Her gorev sonrasi**: `flutter analyze` + commit
- **T2 oncesi** `notification_panel.dart` icindeki `onMarkRead` callback ID pattern'ini DOGRULA — eski ID'ler ile yeni `panel_` prefix'i uyumlu olmali, yoksa eski "okundu" kayitlari kaybolur. Eger eski pattern farkliysa, `panel_w_{id}` ve `panel_a_{id}` format'ina GECIS yap ama ELLE eski verileri tasimaya gerek yok (zaten persistent degildi).
- **Plan mode'da basla**, T1 icin plan cikar, onay verince uygula
- **T1 ve T2 manuel onayla** git, T3'ten sonra "kalanlari sirayla yap" diyebilirsin
- **Hata aldiginda DUR**, Emre'ye raporla
- **Hic yeni feature ekleme** — sadece 3 spesifik sorunu cozuyoruz
- **Notification Service'e DOKUNMA** — o sinif sadece bildir, biz "bildirilecek mi?" karari veriyoruz
- Bir widget icin `.dart` dosyasini okurken `Read` tool kullan, satir numaralarina guvenme (refactor sonrasi degismis)
- Test sorumlulugunu Emre ustlenecek (emulator'de), sen kod seviyesinde dogrulama yap

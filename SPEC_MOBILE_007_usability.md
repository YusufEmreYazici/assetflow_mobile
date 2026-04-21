# SPEC_MOBILE_007 — Kullanım Kolaylığı İyileştirmeleri (Faz 1)

**Tarih:** 21-22 Nisan 2026
**Proje:** assetflow_mobile (Flutter)
**Tahmini Süre:** 8-12 saat (2-3 oturum)
**Version Bump:** 2.0.0+20 → 2.1.0+21
**Git Tag:** `v2.1.0-usability`

---

## 📋 Özet

Enterprise Pro redesign'ı bitirdik (SPEC_MOBILE_006). Şimdi **kullanım kolaylığı** odaklı 5 büyük özellik ekleyerek uygulamayı gerçekten "profesyonel bir IT aracı" seviyesine taşıyoruz. Bu faz özellikle **sahada çalışan lojistik personeli** için değerli.

**5 Ana Özellik:**
1. 🔍 QR/Barkod Tarama — demirbaş kodunu kameraya göster, direkt detaya atla
2. ⚡ Gelişmiş Filtre — çoklu filter + kaydedilebilir filter preset'leri
3. 📦 Toplu İşlemler — multi-select mode, bulk actions
4. ⭐ Favoriler & Kısayollar — sık açılan cihazlara yıldız
5. 📴 Offline Mode — cache'lenmiş veri görüntüleme

---

## 🎨 Mimari Karar

- **Mevcut yapı korunacak** — SPEC_MOBILE_006'daki Enterprise Pro tasarımı bozulmayacak
- **Yeni paketler eklenecek:**
  - `mobile_scanner` ^5.0.0 (QR/Barkod için — en güncel, çoklu platform)
  - `shared_preferences` (zaten var) — favoriler ve filter preset'leri için
  - `hive` veya `drift` — offline cache için (karar: Hive, daha basit)
- **Backend:** Şu an için ekstra endpoint gerekmez, mevcut API'lar kullanılacak
- **Her özellik kendi feature klasöründe** — clean architecture korunuyor

---

## 🗂 Dosya Yapısı (Yeni + Değişecek)

```
lib/
├── core/
│   ├── services/
│   │   ├── offline_cache_service.dart        (YENİ - Hive)
│   │   └── barcode_scanner_service.dart      (YENİ)
│   └── widgets/
│       ├── bulk_action_bar.dart              (YENİ - multi-select)
│       ├── filter_sheet.dart                 (YENİ - bottom sheet)
│       └── favorite_star.dart                (YENİ - yıldız ikonu)
├── features/
│   ├── devices/
│   │   ├── device_list_screen.dart           (GÜNCELLENDİ)
│   │   ├── widgets/
│   │   │   ├── device_row.dart               (GÜNCELLENDİ - favori + select)
│   │   │   └── advanced_filter_sheet.dart    (YENİ)
│   │   ├── providers/
│   │   │   ├── device_filter_provider.dart   (YENİ)
│   │   │   ├── favorites_provider.dart       (YENİ)
│   │   │   └── bulk_selection_provider.dart  (YENİ)
│   │   └── models/
│   │       └── device_filter.dart            (YENİ - filter model)
│   ├── scanner/
│   │   ├── scanner_screen.dart               (YENİ - kamera ekranı)
│   │   └── widgets/
│   │       └── scan_overlay.dart             (YENİ)
│   └── dashboard/
│       └── widgets/
│           └── favorites_section.dart        (YENİ)
```

---

## 🚧 Görev Listesi

**KRİTİK KURAL:** Her T# görevinden sonra:
1. `flutter analyze` (0 hata)
2. `git add -A && git commit -m "Task T#: [başlık]"`
3. Emulator'de ekran testi
4. Hata varsa dur ve raporla

---

### 🎯 Özellik 1 — QR/Barkod Tarama (Tahmini 2 saat)

#### T1: mobile_scanner Paketi + İzinler 📱
**Süre:** 20 dk
**Dosyalar:**
- `pubspec.yaml` (paket ekle)
- `android/app/src/main/AndroidManifest.xml` (kamera izni)
- `ios/Runner/Info.plist` (NSCameraUsageDescription)

**Yapılacak:**
1. `flutter pub add mobile_scanner:^5.0.0`
2. Android manifest'e:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-feature android:name="android.hardware.camera" android:required="true" />
   ```
3. iOS Info.plist'e:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Demirbaş kodu taraması için kamera izni gerekli</string>
   ```
4. `pubspec.yaml` version: 2.1.0+21

**Test:** `flutter build apk` başarılı olmalı

**Commit:** `feat: add mobile_scanner package and camera permissions`

---

#### T2: Scanner Service + Screen 📷
**Süre:** 60 dk
**Dosyalar:**
- `lib/core/services/barcode_scanner_service.dart` (yeni)
- `lib/features/scanner/scanner_screen.dart` (yeni)
- `lib/features/scanner/widgets/scan_overlay.dart` (yeni)

**Yapılacak:**
1. **BarcodeScannerService:**
   ```dart
   class BarcodeScannerService {
     static Future<String?> scanBarcode(BuildContext context) async {
       final result = await Navigator.push<String>(
         context,
         MaterialPageRoute(builder: (_) => const ScannerScreen()),
       );
       return result;
     }

     static bool isAssetCode(String code) {
       // GVN-LPT-0142, GVN-MON-0045, ZMT-20260421-0142 pattern'ı
       return RegExp(r'^(GVN|ZMT)-').hasMatch(code);
     }
   }
   ```

2. **ScannerScreen** — mobile_scanner ile canlı kamera:
   - Navy header: "Kod Tara" + back butonu + flash toggle
   - Kamera preview (full screen)
   - Ortada **scan overlay**: 250x250 alan, 4 köşede beyaz L-şekiller (kadraj), ortada yatay scan line animasyonu
   - Alt yazı: "Demirbaş kodunu kadrajla hizalayın"
   - Alt bilgi: "GVN-XXX-NNNN veya ZMT-YYYYMMDD-NNNN formatında"
   - Kod okunduğunda:
     - Haptic feedback (`HapticFeedback.mediumImpact()`)
     - 500ms yeşil overlay flash
     - Kodu validate et (isAssetCode)
     - Geçerliyse `Navigator.pop(context, code)` ile geri dön
     - Geçersizse snackbar: "Geçersiz kod: $code"

3. **ScanOverlay widget** — CustomPainter ile 4 köşe + scan line:
   ```dart
   class ScanOverlay extends StatefulWidget {
     @override
     _ScanOverlayState createState() => _ScanOverlayState();
   }

   // AnimationController ile scan line yukarı-aşağı animasyonu
   // Stack ile: 4 köşe (Positioned'larla), ortada AnimatedBuilder scan line
   ```

**Test:** Scanner açılıyor mu, kamera çalışıyor mu, QR kodu okuyor mu (herhangi bir QR ile test et)

**Commit:** `feat: add QR/barcode scanner screen with overlay`

---

#### T3: Scanner Entegrasyonu — 3 Yerden Erişim 🔍
**Süre:** 40 dk
**Dosyalar:**
- `lib/features/devices/device_list_screen.dart` (güncelle)
- `lib/features/dashboard/widgets/dashboard_a_view.dart` (güncelle)
- `lib/features/dashboard/widgets/dashboard_b_view.dart` (güncelle)
- `lib/features/assignments/assign_wizard_screen.dart` (güncelle — Step 2'de cihaz seç kısmı)
- `lib/core/navigation/app_router.dart` (rota ekle)

**Yapılacak:**

1. **Rota ekle:** `/scanner` → ScannerScreen

2. **Cihaz Listesi search bar'ına QR ikonu:**
   ```dart
   // Search bar'ın sağında QR butonu
   IconButton(
     icon: const Icon(Icons.qr_code_scanner),
     onPressed: () async {
       final code = await BarcodeScannerService.scanBarcode(context);
       if (code != null && context.mounted) {
         // Kod → cihaz ID bulma
         final device = devices.firstWhereOrNull((d) => d.code == code);
         if (device != null) {
           Navigator.pushNamed(context, '/device/${device.id}');
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Cihaz bulunamadı: $code')),
           );
         }
       }
     },
   )
   ```

3. **Dashboard A+B Hızlı İşlemler'e "QR Tara" butonu ekle:**
   ```dart
   QuickAction(
     icon: "qr",  // veya qr_code_scanner
     label: "QR Tara",
     onPressed: () async {
       final code = await BarcodeScannerService.scanBarcode(context);
       // Aynı lookup mantığı
     },
   ),
   ```
   Dashboard A 2x2 iken, "İade" yerine "QR Tara" mı olsun, yoksa 3x2 mi? → 2x2 kalsın, ama "Hızlı İşlemler" üstünde küçük bir FAB veya banner ile "📷 QR Tara" shortcut olsun.

4. **Zimmet Wizard Step 2 (Cihaz seçimi):**
   - Search bar'ın yanında QR butonu
   - Kod okunduğunda listeden cihazı bul, otomatik select et, highlight + scroll to item

5. **Kısayol:** Cihaz detay sayfasında sağ üst more menu'de "Bu cihazın QR kodunu göster" (QR kodu üretme feature'ı — **opsiyonel, başka task'a bırak**)

**Test:**
- Dashboard'dan "QR Tara" → Bir cihaz kodunun QR'ını göster (Google'dan herhangi bir QR generator'da "GVN-LPT-0142" yaz, QR üret, ekranda göster, telefonun kamerasına göster)
- Cihaz listesinden QR ikonu → aynı test
- Zimmet wizard step 2'den QR → depoda cihazı otomatik seçsin

**Commit:** `feat: integrate QR scanner in device list, dashboard, and assign wizard`

---

### 🎯 Özellik 2 — Gelişmiş Filtre + Presets (Tahmini 2.5 saat)

#### T4: DeviceFilter Model + Provider 🔍
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/devices/models/device_filter.dart` (yeni)
- `lib/features/devices/providers/device_filter_provider.dart` (yeni)

**Yapılacak:**

1. **DeviceFilter model** (immutable, `copyWith`):
   ```dart
   class DeviceFilter {
     final List<String> types;         // ['Laptop', 'Monitor']
     final List<String> statuses;      // ['Zimmetli', 'Depoda']
     final List<String> locations;     // ['Mersin Limanı', 'İzmit Terminal']
     final List<String> brands;        // ['Dell', 'HP']
     final String? assigneeQuery;      // personel adı araması
     final DateRange? purchaseDateRange; // satın alma tarihi aralığı
     final DateRange? warrantyEndRange;  // garanti bitiş tarihi aralığı
     final bool? onlyFavorites;

     DeviceFilter({
       this.types = const [],
       this.statuses = const [],
       this.locations = const [],
       this.brands = const [],
       this.assigneeQuery,
       this.purchaseDateRange,
       this.warrantyEndRange,
       this.onlyFavorites = false,
     });

     bool get isEmpty => types.isEmpty && statuses.isEmpty && /*...*/;

     int get activeCount => types.length + statuses.length + /*...*/;

     DeviceFilter copyWith({...}) => DeviceFilter(...);

     Map<String, dynamic> toJson() => {...};
     factory DeviceFilter.fromJson(Map<String, dynamic> json) => DeviceFilter(...);
   }
   ```

2. **DeviceFilterProvider** (Riverpod):
   ```dart
   final deviceFilterProvider = StateProvider<DeviceFilter>((ref) {
     return DeviceFilter();
   });

   // Preset'ler için:
   final filterPresetsProvider = StateNotifierProvider<FilterPresetsNotifier, List<FilterPreset>>((ref) {
     return FilterPresetsNotifier();
   });

   class FilterPreset {
     final String name;         // "Mersin Laptopları"
     final DeviceFilter filter;
     final DateTime createdAt;
   }

   class FilterPresetsNotifier extends StateNotifier<List<FilterPreset>> {
     // SharedPreferences'tan load/save
   }
   ```

3. **Filter uygulama:**
   ```dart
   final filteredDevicesProvider = Provider<List<Device>>((ref) {
     final devices = ref.watch(deviceListProvider);
     final filter = ref.watch(deviceFilterProvider);
     return devices.where((d) => filter.matches(d)).toList();
   });

   extension on DeviceFilter {
     bool matches(Device d) {
       if (types.isNotEmpty && !types.contains(d.type)) return false;
       if (statuses.isNotEmpty && !statuses.contains(d.status)) return false;
       // ... diğer kriterler
       return true;
     }
   }
   ```

**Test:** Provider'lar çalışıyor, filter değişince filteredDevices güncelleniyor

**Commit:** `feat: add DeviceFilter model and providers with preset support`

---

#### T5: Advanced Filter Bottom Sheet 🎛
**Süre:** 70 dk
**Dosyalar:**
- `lib/features/devices/widgets/advanced_filter_sheet.dart` (yeni)
- `lib/features/devices/device_list_screen.dart` (güncelle — filter ikonu AdvancedFilterSheet'i açsın)

**Yapılacak:**

1. **AdvancedFilterSheet** — `showModalBottomSheet` ile açılan full-height sheet:
   - Üstte handle bar + başlık "Filtre" + sağda "Sıfırla" butonu
   - Sections (ExpansionTile'larla):
     - **CİHAZ TİPİ** (multi-select chip'ler: Laptop, Masaüstü, Monitor, Yazıcı, Telefon, Tablet, Sunucu, Ağ, Diğer)
     - **DURUM** (multi-select chip: Zimmetli, Depoda, Bakımda, Emekli, Kayıp)
     - **LOKASYON** (multi-select, 22 lokasyon scroll listesi)
     - **MARKA** (multi-select, dinamik: cihazlardan unique brand'ler)
     - **ZİMMETLİ KİŞİ** (search input)
     - **SATIN ALMA TARİHİ** (date range picker)
     - **GARANTİ BİTİŞ** (date range picker + "90 gün içinde bitenler" shortcut)
     - **SADECE FAVORİLER** (switch)

2. **Alt bar:**
   - "Preset Olarak Kaydet" (secondary)
   - "Filtre Uygula (N kriter)" (primary, N = activeCount)

3. **Preset Olarak Kaydet** tıklanınca:
   - Dialog aç: "Preset adı?" (örn. "Mersin Laptopları")
   - Kaydet → SharedPreferences
   - Üstte "Preset'ler" sekmesinde görünsün (kullanıcı hızlıca seçebilsin)

4. **Filter ikonunun yanında aktif filter sayısı badge:**
   ```dart
   if (filter.activeCount > 0)
     Badge(
       label: Text('${filter.activeCount}'),
       child: Icon(Icons.filter_list),
     ),
   ```

**Test:**
- Filter ikonu → sheet aç
- Birkaç filter seç → Uygula → liste daralıyor mu?
- Preset kaydet → kapat-aç → preset görünüyor mu?

**Commit:** `feat: add advanced filter sheet with multi-select and presets`

---

#### T6: Quick Filter Presets Üstte Görünsün 🎯
**Süre:** 20 dk
**Dosyalar:**
- `lib/features/devices/device_list_screen.dart` (güncelle)

**Yapılacak:**

1. Mevcut yatay filter chips (Tümü/Zimmetli/Depoda/Bakımda/Emekli) kalacak
2. Onun altında **ikinci bir chip satırı** — kaydedilmiş preset'ler:
   ```
   [📌 Mersin Laptopları]  [📌 Garanti Bitenler]  [📌 Ayşe'nin Cihazları]
   ```
3. Preset chip'e tıkla → o filter aktif olur
4. Long-press → preset'i sil menüsü

**Test:** Preset kaydet → liste üstünde chip görünüyor mu, tıklayınca filter uygulanıyor mu

**Commit:** `feat: show filter presets as quick access chips`

---

### 🎯 Özellik 3 — Toplu İşlemler (Tahmini 2 saat)

#### T7: BulkSelectionProvider + Selection Mode 📦
**Süre:** 40 dk
**Dosyalar:**
- `lib/features/devices/providers/bulk_selection_provider.dart` (yeni)
- `lib/features/devices/device_list_screen.dart` (güncelle)
- `lib/features/devices/widgets/device_row.dart` (güncelle)

**Yapılacak:**

1. **BulkSelectionProvider:**
   ```dart
   class BulkSelectionState {
     final bool isActive;
     final Set<String> selectedIds;

     bool get isNotEmpty => selectedIds.isNotEmpty;
     int get count => selectedIds.length;
   }

   class BulkSelectionNotifier extends StateNotifier<BulkSelectionState> {
     void enter() => state = state.copyWith(isActive: true);
     void exit() => state = BulkSelectionState(isActive: false, selectedIds: {});
     void toggle(String id) {
       final selected = {...state.selectedIds};
       if (selected.contains(id)) selected.remove(id);
       else selected.add(id);
       state = state.copyWith(selectedIds: selected);
     }
     void selectAll(List<String> ids) { ... }
     void clearAll() { ... }
   }
   ```

2. **DeviceRow güncelleme:**
   - Normalde: tıklama → detay
   - Selection mode aktif: tıklama → toggle selection (checkbox görünür)
   - **Long-press** → selection mode başlat + item'ı seç
   - Seçili ise: sol tarafta checkmark, arka plan hafif navy tint

3. **Device list:**
   - Long-press ile selection mode'a gir
   - AppBar değişir: "N seçili" + sağda X (kapat) + ... (more menu)

**Test:** Bir item'a long press → seçim modu aktif, diğerlerine tap → seçildi mi?

**Commit:** `feat: add bulk selection mode for device list`

---

#### T8: Bulk Action Bar (Alt Menü) 📋
**Süre:** 60 dk
**Dosyalar:**
- `lib/core/widgets/bulk_action_bar.dart` (yeni)
- `lib/features/devices/device_list_screen.dart` (güncelle)

**Yapılacak:**

1. **BulkActionBar** — Selection mode aktifken alt'ta slide-up animasyonla gelen bar:
   ```dart
   Container(
     background: AppColors.navy,
     padding: EdgeInsets.all(12),
     child: Row(
       children: [
         // Sol: seçili sayı
         Text('${count} seçili', style: white),
         Spacer(),
         // Sağ: 4 aksiyon ikonu
         IconButton(icon: Icons.swap_horiz, tooltip: 'Durum Değiştir', onPressed: _changeStatus),
         IconButton(icon: Icons.place, tooltip: 'Lokasyon Değiştir', onPressed: _changeLocation),
         IconButton(icon: Icons.download, tooltip: 'Excel İndir', onPressed: _exportExcel),
         IconButton(icon: Icons.more_vert, tooltip: 'Daha Fazla', onPressed: _showMoreMenu),
       ],
     ),
   )
   ```

2. **Aksiyonlar:**

   **a) Durum Değiştir:**
   - Bottom sheet: 5 durum listesi (Aktif/Depoda/Bakımda/Emekli/Kayıp)
   - Seçilen durumla bulk update
   - API: Her cihaz için `PUT /api/devices/{id}` (loop)
   - Progress: "5/20 güncellendi..."
   - Sonuç: snackbar "20 cihazın durumu 'Bakımda' yapıldı"

   **b) Lokasyon Değiştir:**
   - Bottom sheet: 22 lokasyon listesi
   - Aynı bulk update logic

   **c) Excel İndir:**
   - Seçili cihazları Excel'e export
   - Zaten excel_export_screen.dart'ta altyapı var, onu çağır
   - File download snackbar

   **d) Daha Fazla menu:**
   - "Tümünü Seç" → filtered listedeki tüm cihazları selection'a al
   - "Favorilere Ekle" → seçili cihazları favorite yap
   - "Sil" → confirmation dialog (kritik işlem, tehlikeli)
     - Dialog: "N cihazı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."
     - Onayla → bulk delete, sonra selection exit

**Test:**
- 5 cihaz seç → durumu Bakımda yap → liste güncellendi mi, her cihaz için PUT gitti mi?
- 3 cihaz seç → Excel indir → dosya kaydedildi mi?
- 2 cihaz seç → sil → dialog → onay → silindi mi?

**Commit:** `feat: add bulk action bar with status/location change, export, and delete`

---

### 🎯 Özellik 4 — Favoriler & Kısayollar (Tahmini 1 saat)

#### T9: FavoritesProvider + Star Icon ⭐
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/devices/providers/favorites_provider.dart` (yeni)
- `lib/core/widgets/favorite_star.dart` (yeni)
- `lib/features/devices/widgets/device_row.dart` (güncelle)
- `lib/features/devices/device_detail_screen.dart` (güncelle — header'a star ekle)

**Yapılacak:**

1. **FavoritesProvider:**
   ```dart
   class FavoritesNotifier extends StateNotifier<Set<String>> {
     FavoritesNotifier() : super({}) {
       _load();
     }

     void toggle(String deviceId) {
       final next = {...state};
       if (next.contains(deviceId)) next.remove(deviceId);
       else next.add(deviceId);
       state = next;
       _save();
     }

     bool isFavorite(String id) => state.contains(id);

     Future<void> _load() async {
       final prefs = await SharedPreferences.getInstance();
       final list = prefs.getStringList('favorite_devices') ?? [];
       state = list.toSet();
     }

     Future<void> _save() async { ... }
   }
   ```

2. **FavoriteStar widget:**
   ```dart
   class FavoriteStar extends ConsumerWidget {
     final String deviceId;
     final double size;
     final Color inactiveColor;

     @override
     Widget build(context, ref) {
       final isFav = ref.watch(favoritesProvider).contains(deviceId);
       return IconButton(
         icon: Icon(
           isFav ? Icons.star : Icons.star_border,
           color: isFav ? AppColors.warning : inactiveColor,
           size: size,
         ),
         onPressed: () {
           ref.read(favoritesProvider.notifier).toggle(deviceId);
           HapticFeedback.lightImpact();
         },
       );
     }
   }
   ```

3. **DeviceRow'da** — sağdaki chevron'un yerine veya yanına star butonu (küçük, 20x20)

4. **DeviceDetailHeader'da** — sağ üstteki edit ikonunun yanına star (beyaz renkli)

**Test:** Bir cihaza star tıkla → sarı oldu mu, uygulamayı kapat-aç → hala sarı mı (persistence)

**Commit:** `feat: add favorites with star icon and SharedPreferences persistence`

---

#### T10: Dashboard "Favori Cihazlarım" Section 🌟
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/dashboard/widgets/favorites_section.dart` (yeni)
- `lib/features/dashboard/widgets/dashboard_a_view.dart` (güncelle)
- `lib/features/dashboard/widgets/dashboard_b_view.dart` (güncelle)

**Yapılacak:**

1. **FavoritesSection:**
   - Üstte: SectionHeader "⭐ FAVORİ CİHAZLARIM" + "Tümü →" linki
   - Liste: max 5 favori cihaz (horizontal scroll veya vertical list)
   - Her item: mini device row (icon + name + status chip)
   - Boş durumda: "Favori cihazınız yok. Cihaz detayında ⭐ ikonuna tıklayarak ekleyin."
   - Favori yok ise section'ı hiç gösterme

2. **Dashboard A güncellemesi:**
   - Mevcut sıralama: ÖZET → HIZLI İŞLEMLER → AKTİVİTE → GARANTİ
   - Yeni: ÖZET → **FAVORİLER (varsa)** → HIZLI İŞLEMLER → AKTİVİTE → GARANTİ

3. **Dashboard B güncellemesi:**
   - Aynı mantık, Hero KPI'dan sonra favoriler gelsin

**Test:** 3 cihazı favori yap → Dashboard'da FAVORİLER section görünüyor mu, tıklayınca cihaz detayına gidiyor mu

**Commit:** `feat: add favorites section to dashboard A and B`

---

### 🎯 Özellik 5 — Offline Mode (Tahmini 2.5 saat)

#### T11: Hive Kurulum + OfflineCacheService 💾
**Süre:** 45 dk
**Dosyalar:**
- `pubspec.yaml` (paketler ekle)
- `lib/core/services/offline_cache_service.dart` (yeni)
- `lib/main.dart` (Hive init)

**Yapılacak:**

1. **Paketler:**
   ```bash
   flutter pub add hive hive_flutter connectivity_plus
   flutter pub add --dev hive_generator build_runner
   ```

2. **OfflineCacheService:**
   ```dart
   class OfflineCacheService {
     static const _deviceBox = 'devices_cache';
     static const _peopleBox = 'people_cache';
     static const _assignmentBox = 'assignments_cache';
     static const _metaBox = 'cache_meta';

     static Future<void> init() async {
       await Hive.initFlutter();
       await Hive.openBox(_deviceBox);
       await Hive.openBox(_peopleBox);
       await Hive.openBox(_assignmentBox);
       await Hive.openBox(_metaBox);
     }

     // Save
     static Future<void> cacheDevices(List<Device> devices) async {
       final box = Hive.box(_deviceBox);
       await box.clear();
       for (final d in devices) {
         await box.put(d.id, d.toJson());
       }
       await Hive.box(_metaBox).put('devices_last_sync', DateTime.now().toIso8601String());
     }

     // Load
     static List<Device> getCachedDevices() {
       final box = Hive.box(_deviceBox);
       return box.values.map((json) => Device.fromJson(json)).toList();
     }

     static DateTime? getLastSync(String key) {
       final iso = Hive.box(_metaBox).get('${key}_last_sync');
       return iso != null ? DateTime.parse(iso) : null;
     }

     static bool get hasCache {
       return Hive.box(_deviceBox).isNotEmpty;
     }
   }
   ```

3. **main.dart:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await OfflineCacheService.init();
     runApp(const ProviderScope(child: MyApp()));
   }
   ```

**Test:** Uygulama açılıyor mu, Hive hatasız init oluyor mu

**Commit:** `feat: add Hive offline cache infrastructure`

---

#### T12: ConnectivityProvider + Offline Banner 📡
**Süre:** 30 dk
**Dosyalar:**
- `lib/core/providers/connectivity_provider.dart` (yeni)
- `lib/core/widgets/offline_banner.dart` (SPEC_MOBILE_006'daki `states.jsx`'ten zaten portladık, kontrol et)
- `lib/core/navigation/app_shell.dart` (banner ekle)

**Yapılacak:**

1. **ConnectivityProvider:**
   ```dart
   final connectivityProvider = StreamProvider<bool>((ref) async* {
     yield await _checkConnection();
     await for (final result in Connectivity().onConnectivityChanged) {
       yield result != ConnectivityResult.none;
     }
   });

   Future<bool> _checkConnection() async {
     final result = await Connectivity().checkConnectivity();
     return result != ConnectivityResult.none;
   }
   ```

2. **AppShell güncelleme:**
   - Scaffold body'nin üstüne ConnectivityProvider watch et
   - Offline ise: warning renkli banner: "📵 Çevrimdışı mod · son senkronizasyon: X saat önce"
   - Banner tıklanınca: "Yeniden Bağlan" butonu

3. **Online olunca banner otomatik kaybolsun** (animated)

**Test:**
- Emulator'de wifi kapat → banner göründü mü?
- Wifi aç → banner kayboldu mu?

**Commit:** `feat: add connectivity provider and offline banner`

---

#### T13: Repository Pattern + Cache Fallback 🗄
**Süre:** 70 dk
**Dosyalar:**
- `lib/features/devices/providers/device_provider.dart` (güncelle — repository pattern)
- `lib/features/people/providers/person_provider.dart` (güncelle, varsa)
- `lib/features/assignments/providers/assignment_provider.dart` (güncelle)

**Yapılacak:**

1. **Mevcut device_provider'ı refactor:**

   Önce:
   ```dart
   final deviceListProvider = FutureProvider<List<Device>>((ref) async {
     final response = await ref.read(apiClientProvider).get('/api/devices');
     return (response.data as List).map((j) => Device.fromJson(j)).toList();
   });
   ```

   Sonra:
   ```dart
   final deviceListProvider = FutureProvider<List<Device>>((ref) async {
     final online = ref.watch(connectivityProvider).valueOrNull ?? true;

     if (online) {
       try {
         final response = await ref.read(apiClientProvider).get('/api/devices');
         final devices = (response.data as List).map((j) => Device.fromJson(j)).toList();
         // Cache'e yaz
         await OfflineCacheService.cacheDevices(devices);
         return devices;
       } catch (e) {
         // Network error → cache'e fallback
         if (OfflineCacheService.hasCache) {
           return OfflineCacheService.getCachedDevices();
         }
         rethrow;
       }
     } else {
       // Offline → direkt cache
       if (OfflineCacheService.hasCache) {
         return OfflineCacheService.getCachedDevices();
       }
       throw OfflineException('Çevrimdışı ve cache boş');
     }
   });
   ```

2. **Aynı pattern personel ve zimmet için de uygulanacak**

3. **UI'da offline durumu göster:**
   - Device list'in üstünde küçük bilgi: "Son senkronizasyon: 2 saat önce (çevrimdışı)"
   - Sadece offline mode'da göster

4. **Write işlemleri offline mode'da disable:**
   - Yeni cihaz ekle → FAB disabled + tooltip "Çevrimiçi olduğunuzda yapabilirsiniz"
   - Zimmet oluştur → aynı
   - (Gelişmiş: offline queue yazı ama şu an scope dışı)

**Test:**
- Online'ken cihaz listesi yükle → cache'e yazıldı mı?
- Wifi kapat, uygulamayı yeniden aç → cihaz listesi görünüyor mu (cache'den)?
- Offline iken cihaz eklemeyi dene → disable görünüyor mu?

**Commit:** `feat: add offline fallback with Hive cache for device, person, and assignment lists`

---

### 🎯 Final

#### T14: Tam Test Turu + Version Bump ✅
**Süre:** 30 dk

**Yapılacak:**

1. **Test senaryoları:**
   - QR scan (test QR kodu ile)
   - Gelişmiş filter (3 kriter seç + preset kaydet)
   - Bulk select (5 cihaz → durum değiştir)
   - Favori ekle → Dashboard'da görünüyor mu
   - Offline test (wifi kapat → hala çalışıyor mu)

2. **`flutter analyze`** → 0 hata

3. **`pubspec.yaml` version:** 2.1.0+21

4. **Git tag:** `git tag -a v2.1.0-usability -m "Usability improvements: QR scan, advanced filter, bulk actions, favorites, offline mode"`

**Commit:** `chore: v2.1.0-usability release`

---

## 🎯 Kabul Kriterleri

Faz 1 bitince:
- [ ] QR/Barkod tarama 3 yerden çalışıyor (dashboard, liste, wizard)
- [ ] Gelişmiş filter sheet açılıyor, 8+ kriter var, preset kaydediliyor
- [ ] Toplu işlem: long-press ile selection, bulk status/location change, Excel export, silme
- [ ] Favoriler ekleniyor, Dashboard'da section görünüyor
- [ ] Offline mode: cache var, wifi olmayınca uygulama yine çalışıyor
- [ ] `flutter analyze` 0 hata
- [ ] Emulator'de tam test başarılı

---

## ⚠️ Bilinen Riskler

1. **mobile_scanner iOS/Android uyumluluğu:** Gerçek cihazda test şart, emulator'de kamera simülasyonu yetersiz olabilir
2. **Hive model annotations:** Eğer Device modelinde Hive annotations yoksa, JSON serialization ile çalışalım (daha basit ama yavaş)
3. **Connectivity false positive:** Wifi var ama internet yoksa (kafeterya portal) `connectivity_plus` yine "bağlı" der. Gerçek ping testi eklemek SPEC dışı, şimdilik basit kabul
4. **Bulk operations transactional değil:** 20 cihazdan 15'i güncellendikten sonra network error olursa inconsistent state. İdeali server-side batch endpoint, şu an client-side loop. Backlog'a: "SPEC_BACKEND — Bulk update endpoint"
5. **Offline write queue yok:** Offline iken yazma işlemleri disabled. Tam offline-first için queue lazım (Redux-style action log). Sonraki fazda ele alınabilir

---

## 📦 Claude Code Başlatma Promptu

```
C:\Workspace\Personal_Projects\assetflow_mobile dizininde çalışıyorsun.

Bu SPEC'i uygula: specs/SPEC_MOBILE_007_usability.md

5 özellik, 14 task, tahmini 8-12 saat:
1. QR/Barkod tarama (T1-T3)
2. Gelişmiş filtre + presets (T4-T6)
3. Toplu işlemler (T7-T8)
4. Favoriler (T9-T10)
5. Offline mode (T11-T13)
Final: T14

Her task sonunda:
1. flutter analyze (0 hata)
2. git commit

5 özellik bağımsız, aralarında dependency az. Sıralı git.

Sorun olursa dur, rapor ver. T1'den başla.
```

---

## 🎬 Sonraki Fazlar (Bilgi)

- **SPEC_MOBILE_008 (Faz 2):** UX Cila — empty states, haptic feedback, animations, a11y, skeletons, dark mode toggle
- **SPEC_MOBILE_009 (Faz 3):** Test & Kalite — xUnit backend, Flutter widget tests, performance, i18n, analytics

---

**Hazırlayan:** Claude + Emre
**Versiyon:** 1.0
**Güncelleme:** 21 Nisan 2026

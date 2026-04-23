# SPEC_MOBILE_009 — Fix & Complete & Quality (Faz 3)

**Tarih:** 23 Nisan 2026
**Proje:** assetflow_mobile (Flutter)
**Tahmini Süre:** 10-14 saat (2-3 oturum)
**Version Bump:** 2.2.0 → 2.3.0 (major, çünkü yeni feature'lar)
**Git Tag:** `v2.3.0-complete`

---

## 📋 Özet

v2.2.0'da UX cila yapıldı ama **gerçek cihaz testinde 3 bug ve 4 eksik feature** tespit edildi. Bunları düzeltip, **backend + mobile test altyapısı** eklediğimiz kapsamlı bir faz.

**3 Bölüm:**
1. 🐛 **KRİTİK BUG FIX** (haptic, dark mode, gizli sorunlar) — 2 saat
2. ✨ **EKSİK FEATURES** (düzenle, sil, yeniden aktifleştir, lokasyon CRUD) — 4-5 saat
3. 🧪 **TEST & KALİTE** (xUnit, widget test, i18n, monitoring) — 4-6 saat

---

## 🎨 Çalışma Felsefesi

Bu SPEC **bir bug sprint + feature sprint + kalite sprint'i** birleştiriyor. Bu yüzden **sıra ÇOK ÖNEMLİ**:

```
ÖNCE: Kritik bug'lar (uygulamayı kullanılır hale getir)
SONRA: Eksik feature'lar (tamamla)
EN SON: Test & kalite (güvenli hale getir)
```

Backend değişiklikleri de olacak (yeni endpoint'ler). Backend + Mobile senkron ilerleyecek.

---

## 📂 BÖLÜM 1 — KRİTİK BUG FIX (2 saat)

### 🐛 FIX 1: Haptic Feedback Hiç Çalışmıyor

**Sorun:** SPEC_MOBILE_008'de HapticService eklendi, 10 yere entegre edildi. Ama **tetiklenmeyenler.**

**Olası 4 neden (sırayla kontrol et):**

#### T1.1: Android VIBRATE Permission
**Süre:** 5 dk
**Dosya:** `android/app/src/main/AndroidManifest.xml`

Kontrol et, yoksa ekle:
```xml
<manifest ...>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <!-- diğer permission'lar -->
</manifest>
```

#### T1.2: HapticService.init() çağrısı
**Süre:** 5 dk
**Dosya:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineCacheService.init();
  await HapticService.init();  // ← BU VAR MI?
  runApp(const ProviderScope(child: MyApp()));
}
```

Yoksa ekle.

#### T1.3: `_enabled` default değeri
**Süre:** 5 dk
**Dosya:** `lib/core/services/haptic_service.dart`

```dart
class HapticService {
  static bool _enabled = true;  // ← DEFAULT TRUE OLMALI
  
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;  // ← DEFAULT TRUE
  }
  // ...
}
```

Eğer default `false` ise titreşim hiç çalışmaz.

#### T1.4: Debug — Log ekle
**Süre:** 10 dk

Haptic service metodlarına debug print ekle:

```dart
static void light() {
  debugPrint('[HapticService] light() called, enabled: $_enabled');
  if (!_enabled) return;
  HapticFeedback.lightImpact();
}
```

Test et: Cihaza tıkla, terminal'de `[HapticService] light() called, enabled: true` görüyor musun?

- **Görünüyor + titreşim yok** → Telefon ayarı kapalı (Ayarlar → Ses/titreşim → Dokunsal geri bildirim AÇ)
- **Görünmüyor** → Kod trigger etmiyor, widget'ta entegrasyon eksik. Kontrol et:
  ```dart
  // Örnek: FavoriteStar
  onPressed: () {
    HapticService.medium();  // ← BU SATIR VAR MI?
    ref.read(favoritesProvider.notifier).toggle(deviceId);
  }
  ```

**Commit:** `fix: add VIBRATE permission, ensure HapticService initialization`

---

### 🐛 FIX 2: Dark Mode Yarım Çalışıyor

**Sorun:** Toggle çalışıyor ama arka planlar beyaz kalıyor. Bazı kutular siyah, arka plan beyaz → "karışık" görünüm.

**Kök neden:** **Hardcoded renkler.** Aşağıdaki örnekler gibi yerler var:

```dart
// YANLIŞ (dark mode'da beyaz kalır):
Container(color: Colors.white, ...)
Container(decoration: BoxDecoration(color: const Color(0xFFFFFFFF)))
Scaffold(backgroundColor: Colors.white)
Card(color: Colors.white)
Text('...', style: TextStyle(color: Colors.black))
```

Bu hepsi **theme'den alınmalı:**

```dart
// DOĞRU:
Container(color: Theme.of(context).colorScheme.surface)
Scaffold()  // default theme bg kullanır
Card()  // default theme card rengi
Text('...')  // default onSurface rengi
```

#### T2.1: Hardcoded Renk Taraması
**Süre:** 30 dk
**Yöntem:** grep ile proje tara

```bash
# Tüm hardcoded white/black/hex renk kullanımları
grep -rn "Colors.white" lib/
grep -rn "Colors.black" lib/
grep -rn "Color(0xFFFFFFFF)" lib/
grep -rn "Color(0xFF000000)" lib/

# Surface, background ile ilgili
grep -rn "backgroundColor:" lib/
grep -rn "color: Colors" lib/
```

Her match'i **elle incele**. Bazıları özellikle `Colors.white` olmalı (örn. navy arka plana beyaz text). Diğerleri theme'den almalı.

#### T2.2: Ekran Ekran Dark Mode Test
**Süre:** 45 dk

Dark mode açıkken **her ekranı aç ve bak**:

```
☐ Login ekranı
  ├── Arka plan dark mı?
  ├── Input field dark mı?
  └── Buton navy + beyaz metin?

☐ Dashboard (A ve B)
  ├── Arka plan dark?
  ├── KPI kartları dark?
  ├── Activity tile dark?
  └── Quick action butonları?

☐ Cihaz Listesi
  ├── Search bar dark?
  ├── Filter chip'leri dark?
  ├── Device row'lar dark?
  └── FAB dark?

☐ Cihaz Detay
  ├── Tab bar dark?
  ├── Card'lar dark?
  ├── KV row'lar dark?
  └── Assignment history dark?

☐ Personel Listesi
☐ Personel Detay
☐ Lokasyon Listesi
☐ Zimmet Wizard (4 step)
☐ Profil
☐ Ayarlar
☐ Scanner
☐ Filter Sheet
☐ Bulk Action Bar
☐ Notifications
☐ Audit Log
☐ SAP Sync
☐ Excel Export
☐ Drawer
```

Her bozuk ekranda **hangi renk hardcoded** bul ve düzelt.

#### T2.3: Özel Renk Adapter
**Süre:** 20 dk
**Dosya:** `lib/core/theme/app_colors.dart`

Bazı renkler `Theme.of(context)`'a bakarak dinamik olmalı. Helper ekle:

```dart
class AppColors {
  // Mevcut static renkler kalır (light/dark ayrı)
  
  // Dinamik erişim için helper'lar:
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceWhite
        : surfaceWhite;
  }
  
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceLight
        : surfaceLight;
  }
  
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : Color(0xFF1A3A5C);
  }
  
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : Color(0xFF6B7A8C);
  }
  
  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceDivider
        : Color(0xFFE1E7ED);
  }
}
```

Kullanım:
```dart
// ÖNCE (static, dark'a uyumsuz):
color: AppColors.surfaceWhite

// SONRA (dinamik):
color: AppColors.surface(context)
```

Tüm `Container`, `Card`, `Scaffold` kullanımlarında geçiş yap.

**Özel durum:** Navy (brand rengi) değişmemeli — hem light hem dark'ta aynı. Sadece textTertiary, surface, background değişir.

**Commit:** `fix: complete dark mode coverage, replace hardcoded colors with theme-aware ones`

---

### 🐛 FIX 3: Container color+decoration (varsa)

**Yeni eklenen widget'larda bu hata tekrar olmuş olabilir.** Proje geneli tara:

```bash
grep -rn "Container(" lib/ -A 10 | grep -B 5 "decoration:"
```

Her yerde kontrol:
```dart
// YANLIŞ (crash):
Container(
  color: ...,
  decoration: BoxDecoration(...),
)

// DOĞRU:
Container(
  decoration: BoxDecoration(color: ..., ...),
)
```

**Commit:** `fix: resolve remaining Container color+decoration conflicts`

---

## 📂 BÖLÜM 2 — EKSİK FEATURES (4-5 saat)

### ✨ FEATURE 1: Cihaz Düzenle Ekranı

**Mevcut:** Cihaz detay → sağ üst düzenle → "yakında aktif olacak"
**Hedef:** Tam çalışan form ekran

#### T3.1: DeviceEditScreen
**Süre:** 60 dk
**Dosyalar:**
- `lib/features/devices/device_edit_screen.dart` (yeni, veya `device_form_screen.dart` mevcut ise onu genişlet)
- `lib/core/navigation/app_router.dart` (rota)

**Yapılacak:**

`device_form_screen.dart` zaten var (cihaz ekleme için 4-step wizard). Ya onu **hem ekleme hem düzenleme modunda çalışır yap**, ya da ayrı `device_edit_screen.dart` oluştur.

**Tercih edilen:** Mevcut form'u hem create hem edit modunda kullan:

```dart
class DeviceFormScreen extends ConsumerStatefulWidget {
  final String? deviceId;  // null → ekleme, dolu → düzenleme
  
  const DeviceFormScreen({super.key, this.deviceId});
  
  bool get isEditMode => deviceId != null;
  
  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadExistingDevice();
    }
  }
  
  Future<void> _loadExistingDevice() async {
    final device = await ref.read(deviceProvider(widget.deviceId!).future);
    // Form field'lara pre-fill
    _codeController.text = device.code;
    _brandController.text = device.brand;
    // ... diğer field'lar
  }
  
  Future<void> _save() async {
    if (widget.isEditMode) {
      await ref.read(devicesProvider.notifier).updateDevice(
        widget.deviceId!, 
        _buildDeviceDto(),
      );
    } else {
      await ref.read(devicesProvider.notifier).createDevice(_buildDeviceDto());
    }
    if (mounted) Navigator.pop(context);
  }
  
  // Başlık fark
  String get _title => widget.isEditMode ? 'Cihazı Düzenle' : 'Yeni Cihaz';
  String get _submitLabel => widget.isEditMode ? 'Kaydet' : 'Oluştur';
}
```

**Rota güncelle:**

```dart
// app_router.dart
GoRoute(
  path: '/device/:id/edit',
  builder: (context, state) => DeviceFormScreen(
    deviceId: state.pathParameters['id'],
  ),
),
```

**Device detay'ın düzenle butonu:**

```dart
// device_detail_screen.dart
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () {
    HapticService.light();
    context.push('/device/${device.id}/edit');
  },
),
```

**Backend endpoint'i zaten var** (muhtemelen `PUT /api/devices/{id}`). Yoksa backend'de ekle:

```csharp
[HttpPut("{id}")]
public async Task<IActionResult> Update(string id, [FromBody] UpdateDeviceDto dto)
{
    // ...
}
```

**Commit:** `feat: add device edit screen with form reuse pattern`

---

### ✨ FEATURE 2: Cihaz Silme

#### T3.2: Delete Action + Confirmation
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/devices/device_detail_screen.dart` (more menu'ye ekle)
- `lib/features/devices/providers/device_provider.dart` (delete metodu)

**Yapılacak:**

**Detay ekranı sağ üstte 3 nokta menu:**

```dart
// device_detail_screen.dart — PageHeader action
PageHeader(
  onBack: goBackOrHome(context),
  action: Row(
    children: [
      A11y.iconButton(
        label: 'Düzenle',
        icon: Icons.edit,
        onPressed: () {
          HapticService.light();
          context.push('/device/${device.id}/edit');
        },
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: Colors.white),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Sil', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
          if (device.status == 'Emekli')
            PopupMenuItem(
              value: 'reactivate',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Yeniden Aktifleştir'),
                ],
              ),
            ),
        ],
        onSelected: _handleMenuAction,
      ),
    ],
  ),
)
```

**Delete action:**

```dart
Future<void> _handleMenuAction(String action) async {
  if (action == 'delete') {
    await _confirmAndDelete();
  } else if (action == 'reactivate') {
    await _reactivate();
  }
}

Future<void> _confirmAndDelete() async {
  HapticService.medium();
  
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cihazı Sil?'),
      content: Text(
        '${device.name} (${device.code}) silinecek. '
        'Bu işlem geri alınamaz.\n\n'
        '${device.status == 'Zimmetli' ? 
          "⚠️ Bu cihaz şu an zimmetli. Zimmet kaydı iptal edilecek." : 
          ""}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text('Sil'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    HapticService.heavy();
    try {
      await ref.read(devicesProvider.notifier).deleteDevice(device.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${device.name} silindi.')),
        );
        Navigator.pop(context);  // detay ekranını kapat
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }
}
```

**Provider'a delete metodu:**

```dart
// device_provider.dart
Future<void> deleteDevice(String id) async {
  await _apiClient.delete(ApiConstants.deviceById(id));
  state = state.removeWhere((d) => d.id == id).toList();
  // Cache'i de güncelle
  await OfflineCacheService.cacheDevices(state);
}
```

**Backend endpoint kontrol et:**
```csharp
[HttpDelete("{id}")]
public async Task<IActionResult> Delete(string id)
{
    // Soft delete önerilir (IsDeleted flag)
    // Zimmetli ise → return action auto-trigger
}
```

**Commit:** `feat: add device delete action with confirmation dialog`

---

### ✨ FEATURE 3: Emekli → Envanter (Yeniden Aktifleştir)

#### T3.3: Reactivate Action
**Süre:** 20 dk

Yukarıdaki `_reactivate` fonksiyonu:

```dart
Future<void> _reactivate() async {
  HapticService.medium();
  
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cihazı Yeniden Aktifleştir?'),
      content: Text(
        '${device.name} (${device.code}) tekrar envantere alınacak '
        've "Depoda" statüsüne geçecek.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.success),
          child: Text('Aktifleştir'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    HapticService.medium();
    try {
      await ref.read(devicesProvider.notifier).updateStatus(
        device.id,
        newStatus: 'Depoda',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} envantere alındı.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Detay sayfası refresh olsun
        ref.invalidate(deviceProvider(device.id));
      }
    } catch (e) {
      // error handling
    }
  }
}
```

**Provider güncelle:**

```dart
Future<void> updateStatus(String id, {required String newStatus}) async {
  final response = await _apiClient.patch(
    '${ApiConstants.devices}/$id/status',
    data: {'status': newStatus},
  );
  // ... state güncelle
}
```

**Backend endpoint:**

```csharp
[HttpPatch("{id}/status")]
public async Task<IActionResult> UpdateStatus(string id, [FromBody] UpdateStatusDto dto)
{
    // Status güncelle, audit log ekle
}
```

Audit log'a "Emekli → Depoda (yeniden aktifleştirildi)" kaydı düş.

**Commit:** `feat: add device reactivation for retired items`

---

### ✨ FEATURE 4: Lokasyon CRUD

**Mevcut:** Lokasyon listesi var, ama read-only.
**Hedef:** Ekleme, düzenleme, silme (soft delete) aktif.

#### T3.4: LocationFormScreen
**Süre:** 45 dk
**Dosyalar:**
- `lib/features/locations/location_form_screen.dart` (yeni)
- `lib/features/locations/providers/location_provider.dart` (CRUD metodları)
- `lib/features/locations/location_list_screen.dart` (ekle butonu aktif)
- `lib/features/locations/location_detail_screen.dart` (düzenle butonu)

**LocationFormScreen:**

```dart
class LocationFormScreen extends ConsumerStatefulWidget {
  final String? locationId;  // null → ekleme, dolu → düzenleme
  
  const LocationFormScreen({super.key, this.locationId});
  
  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  String _type = 'Terminal';  // Terminal, Liman, Rafineri, Ofis, Depo
  
  @override
  void initState() {
    super.initState();
    if (widget.locationId != null) {
      _loadExisting();
    }
  }
  
  Future<void> _loadExisting() async {
    final loc = await ref.read(locationProvider(widget.locationId!).future);
    _nameController.text = loc.name;
    _codeController.text = loc.code;
    _addressController.text = loc.address ?? '';
    _type = loc.type;
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.locationId != null;
    
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: isEdit ? 'Lokasyonu Düzenle' : 'Yeni Lokasyon',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Ad *'),
                      validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Kod *',
                        helperText: 'Örn: MRSN-01',
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'Zorunlu' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(labelText: 'Tip'),
                      items: [
                        'Terminal',
                        'Liman',
                        'Rafineri',
                        'Ofis',
                        'Depo',
                      ].map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t),
                      )).toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Adres'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? 'Kaydet' : 'Oluştur'),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticService.medium();
    
    final dto = {
      'name': _nameController.text,
      'code': _codeController.text,
      'type': _type,
      'address': _addressController.text,
    };
    
    try {
      if (widget.locationId != null) {
        await ref.read(locationsProvider.notifier).updateLocation(
          widget.locationId!, 
          dto,
        );
      } else {
        await ref.read(locationsProvider.notifier).createLocation(dto);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedildi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // error handling
    }
  }
}
```

**location_list_screen.dart güncelle:**

```dart
// PageHeader action:
action: A11y.iconButton(
  label: 'Yeni lokasyon ekle',
  icon: Icons.add,
  color: Colors.white,
  onPressed: () {
    HapticService.light();
    context.push('/location/new');
  },
),
```

**location_detail_screen.dart — düzenle + sil butonları:**

```dart
PageHeader(
  action: PopupMenuButton<String>(
    icon: Icon(Icons.more_vert, color: Colors.white),
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'edit',
        child: Row(children: [
          Icon(Icons.edit), 
          SizedBox(width: 8), 
          Text('Düzenle'),
        ]),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(children: [
          Icon(Icons.delete_outline, color: AppColors.error),
          SizedBox(width: 8),
          Text('Sil', style: TextStyle(color: AppColors.error)),
        ]),
      ),
    ],
    onSelected: _handleAction,
  ),
)
```

**Rota:**
```dart
GoRoute(path: '/location/new', builder: (_, __) => LocationFormScreen()),
GoRoute(
  path: '/location/:id/edit',
  builder: (_, s) => LocationFormScreen(locationId: s.pathParameters['id']),
),
```

**Backend endpoint'leri** (varsa skip, yoksa ekle):
```csharp
[HttpPost] public async Task<IActionResult> Create([FromBody] CreateLocationDto dto);
[HttpPut("{id}")] public async Task<IActionResult> Update(string id, [FromBody] UpdateLocationDto dto);
[HttpDelete("{id}")] public async Task<IActionResult> Delete(string id);
```

**Önemli:** Lokasyonda cihaz varsa silinememeli:

```csharp
if (await _db.Devices.AnyAsync(d => d.LocationId == id))
    return BadRequest("Bu lokasyonda cihaz var, önce cihazları başka lokasyona taşıyın.");
```

**Commit:** `feat: add complete location CRUD (create, edit, delete)`

---

## 📂 BÖLÜM 3 — TEST & KALİTE (4-6 saat)

### 🧪 FAZ 3A: Backend xUnit Tests (2 saat)

#### T4.1: Test Project Setup
**Süre:** 20 dk
**Dosyalar:**
- `tests/AssetFlow.Tests/` (yeni proje)

```bash
cd C:\Workspace\Personal_Projects\ITAssetManager
dotnet new xunit -o tests/AssetFlow.Tests
cd tests/AssetFlow.Tests
dotnet add reference ../../src/AssetFlow.API/AssetFlow.API.csproj
dotnet add package Microsoft.AspNetCore.Mvc.Testing
dotnet add package Moq
dotnet add package FluentAssertions
dotnet add package Microsoft.EntityFrameworkCore.InMemory
```

#### T4.2: Controller Tests
**Süre:** 60 dk

**Örnek — DeviceControllerTests:**

```csharp
// tests/AssetFlow.Tests/Controllers/DeviceControllerTests.cs
using AssetFlow.API.Controllers;
using FluentAssertions;
using Moq;
using Xunit;

public class DeviceControllerTests
{
    private readonly Mock<IDeviceService> _mockService;
    private readonly DeviceController _controller;
    
    public DeviceControllerTests()
    {
        _mockService = new Mock<IDeviceService>();
        _controller = new DeviceController(_mockService.Object);
    }
    
    [Fact]
    public async Task GetAll_ReturnsOk_WithDeviceList()
    {
        // Arrange
        var devices = new List<Device> {
            new() { Id = "1", Code = "GVN-LPT-0001" },
            new() { Id = "2", Code = "GVN-LPT-0002" },
        };
        _mockService.Setup(s => s.GetAllAsync(It.IsAny<string>()))
            .ReturnsAsync(devices);
        
        // Act
        var result = await _controller.GetAll();
        
        // Assert
        result.Should().BeOfType<OkObjectResult>();
        var okResult = result as OkObjectResult;
        okResult!.Value.Should().BeAssignableTo<IEnumerable<Device>>();
    }
    
    [Fact]
    public async Task Delete_WithValidId_ReturnsNoContent()
    {
        // Arrange
        _mockService.Setup(s => s.DeleteAsync("1"))
            .ReturnsAsync(true);
        
        // Act
        var result = await _controller.Delete("1");
        
        // Assert
        result.Should().BeOfType<NoContentResult>();
    }
    
    [Fact]
    public async Task Delete_WithInvalidId_ReturnsNotFound()
    {
        _mockService.Setup(s => s.DeleteAsync("999"))
            .ReturnsAsync(false);
        
        var result = await _controller.Delete("999");
        
        result.Should().BeOfType<NotFoundResult>();
    }
    
    // Benzer testler: Create, Update, GetById, UpdateStatus
}
```

**Hedef coverage:** Her controller için **en az 5 test** (CRUD + edge case).

Controller'lar: Device, Employee, Assignment, Location, AuditLog, Auth, Sap, Dashboard.

#### T4.3: Service Tests
**Süre:** 40 dk

**Örnek — DeviceServiceTests:**

```csharp
// Business logic testleri
[Fact]
public async Task CreateDevice_WithDuplicateCode_ThrowsException()
{
    // Arrange
    var existing = new Device { Code = "GVN-LPT-0001" };
    _mockRepo.Setup(r => r.GetByCodeAsync("GVN-LPT-0001"))
        .ReturnsAsync(existing);
    
    // Act & Assert
    await FluentActions.Invoking(() => 
        _service.CreateAsync(new CreateDeviceDto { Code = "GVN-LPT-0001" })
    ).Should().ThrowAsync<DuplicateCodeException>();
}

[Fact]
public async Task DeleteDevice_WhenAssigned_AutoReturns()
{
    // Arrange - cihaz zimmetli
    var device = new Device { Id = "1", Status = "Zimmetli" };
    _mockRepo.Setup(r => r.GetByIdAsync("1")).ReturnsAsync(device);
    
    // Act
    await _service.DeleteAsync("1");
    
    // Assert - önce return sonra delete
    _mockAssignmentService.Verify(a => 
        a.ReturnActiveAsync(device.Id), Times.Once);
    _mockRepo.Verify(r => r.DeleteAsync(device), Times.Once);
}
```

**Commit:** `test: add backend xUnit tests for controllers and services`

---

### 🧪 FAZ 3B: Flutter Widget Tests (1.5 saat)

#### T4.4: Test Setup + Critical Flow Tests
**Süre:** 90 dk
**Dosyalar:**
- `test/` klasörü (zaten var)

**Örnek — DeviceRow widget test:**

```dart
// test/widgets/device_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_row.dart';

void main() {
  group('DeviceRow Widget', () {
    testWidgets('shows device name and code', (tester) async {
      final device = Device(
        id: '1',
        name: 'Samsung S27',
        code: 'GVN-MON-0001',
        status: 'Depoda',
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: DeviceRow(device: device)),
          ),
        ),
      );
      
      expect(find.text('Samsung S27'), findsOneWidget);
      expect(find.text('GVN-MON-0001'), findsOneWidget);
      expect(find.text('DEPODA'), findsOneWidget);
    });
    
    testWidgets('tapping navigates to detail', (tester) async {
      // ... navigation test
    });
    
    testWidgets('long press enters bulk selection', (tester) async {
      // ... bulk mode test
    });
  });
}
```

**Kritik flow'lar için test:**

1. **Login flow** — credential'ları gir, API çağır, dashboard'a git
2. **Cihaz ekle flow** — 4-step form, submit, listede göster
3. **Zimmet ver** — device → person → start date → confirm
4. **İade et** — assignment → return action → success
5. **Bulk delete** — select 3, delete, confirm, removed

```bash
# Çalıştır
flutter test
```

**Commit:** `test: add Flutter widget tests for critical flows`

---

### 🌍 FAZ 3C: i18n (1.5 saat)

#### T4.5: Flutter Localization Setup
**Süre:** 30 dk
**Dosyalar:**
- `pubspec.yaml` (flutter_localizations)
- `lib/l10n/` (yeni klasör)

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true  # l10n aktif
```

```yaml
# l10n.yaml (kök dizinde)
arb-dir: lib/l10n
template-arb-file: app_tr.arb
output-localization-file: app_localizations.dart
```

#### T4.6: Metin Ayıklama
**Süre:** 60 dk
**Dosyalar:**
- `lib/l10n/app_tr.arb` (Türkçe, template)
- `lib/l10n/app_en.arb` (İngilizce)

**app_tr.arb:**
```json
{
  "@@locale": "tr",
  "appTitle": "AssetFlow",
  "loginEmail": "E-posta",
  "loginPassword": "Şifre",
  "loginButton": "Giriş Yap",
  "loginError": "E-posta veya şifre hatalı",
  "dashboardTotalDevices": "Toplam Cihaz",
  "dashboardActiveAssignments": "Aktif Zimmet",
  "deviceListTitle": "Cihazlar",
  "deviceAddButton": "Yeni Cihaz",
  "deviceDeleteConfirm": "{deviceName} silinecek. Bu işlem geri alınamaz.",
  "@deviceDeleteConfirm": {
    "placeholders": {
      "deviceName": {"type": "String"}
    }
  },
  "filterClearAll": "Filtreyi Temizle",
  "emptyStateNoDevices": "Henüz cihaz yok",
  "emptyStateNoDevicesDesc": "İlk cihazını ekleyerek başla.",
  "settingsTheme": "Tema",
  "settingsThemeLight": "Açık",
  "settingsThemeDark": "Koyu",
  "settingsThemeSystem": "Sistem"
}
```

**app_en.arb:**
```json
{
  "@@locale": "en",
  "appTitle": "AssetFlow",
  "loginEmail": "Email",
  "loginPassword": "Password",
  "loginButton": "Sign In",
  "loginError": "Email or password incorrect",
  "dashboardTotalDevices": "Total Devices",
  "dashboardActiveAssignments": "Active Assignments",
  "deviceListTitle": "Devices",
  "deviceAddButton": "New Device",
  "deviceDeleteConfirm": "{deviceName} will be deleted. This action cannot be undone.",
  "filterClearAll": "Clear Filter",
  "emptyStateNoDevices": "No devices yet",
  "emptyStateNoDevicesDesc": "Start by adding your first device.",
  "settingsTheme": "Theme",
  "settingsThemeLight": "Light",
  "settingsThemeDark": "Dark",
  "settingsThemeSystem": "System"
}
```

**Uygulama entegrasyonu:**

```dart
// lib/app.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: ref.watch(localeProvider),  // kullanıcı seçimi
  // ...
)
```

**LocaleProvider (SharedPreferences):**

```dart
// lib/core/locale/locale_provider.dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
```

**Settings'te dil seçimi:**

```dart
ListTile(
  title: Text('Dil / Language'),
  trailing: DropdownButton<String>(
    value: Localizations.localeOf(context).languageCode,
    items: [
      DropdownMenuItem(value: 'tr', child: Text('🇹🇷 Türkçe')),
      DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
    ],
    onChanged: (code) {
      if (code != null) {
        ref.read(localeProvider.notifier).setLocale(Locale(code));
      }
    },
  ),
),
```

**Önemli:** Tüm hardcoded Türkçe metinleri `AppLocalizations.of(context)!.xxx` ile değiştir. Bu **çok zaman alır** — şimdilik **kritik ekranlar** (login, dashboard, cihaz listesi, ayarlar) için yeter. Gerisi yavaş yavaş.

**Commit:** `feat: add internationalization (TR/EN)`

---

### 📊 FAZ 3D: Error Monitoring (30 dk)

#### T4.7: Sentry veya Crashlytics
**Süre:** 30 dk

**Tercih:** Sentry (vendor-agnostic, free tier cömert)

```bash
flutter pub add sentry_flutter
```

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://YOUR_DSN@sentry.io/PROJECT_ID';
      options.tracesSampleRate = 0.1;  // %10 sampling
      options.environment = kReleaseMode ? 'production' : 'development';
    },
    appRunner: () => runApp(ProviderScope(child: MyApp())),
  );
}
```

Sentry hesabı: [sentry.io](https://sentry.io) — ücretsiz 5K event/ay. Proje oluştur, DSN al.

**Commit:** `feat: add Sentry error monitoring`

---

## 🎯 Final

### T5: Tam Test Turu + Version Bump ✅
**Süre:** 30 dk

**Test senaryoları:**

```
✅ Bug Fix Tests
├── Haptic her yerde çalışıyor (toggle hem açık hem kapalı)
├── Dark mode tüm ekranlarda eksiksiz
└── Container crash yok

✅ Feature Tests
├── Cihaz düzenle ekranı açılır, alanlar dolu, kaydedilir
├── Cihaz sil → onay → silinir, listeden kalkar
├── Emekli cihaza "Yeniden aktifleştir" → statü "Depoda"
└── Lokasyon CRUD tam (ekle, düzenle, sil)

✅ Quality Tests
├── Backend xUnit: dotnet test → hepsi geçiyor
├── Flutter widget: flutter test → hepsi geçiyor
├── İngilizce dil: Settings → English → tüm çevrilmiş ekranlar EN
└── Sentry: kasten hata at, dashboard'da görün
```

**flutter analyze:** 0 hata
**pubspec.yaml:** 2.2.0+23 → 2.3.0+24
**Git tag:** `git tag -a v2.3.0 -m "Complete: bug fixes, missing features, tests, i18n, monitoring"`

**Commit:** `chore: v2.3.0 release`

---

## 🎯 Kabul Kriterleri

- [ ] Haptic her yerde çalışıyor (telefon titreşim ayarı açıkken)
- [ ] Dark mode tam (hiçbir ekranda karışık renk yok)
- [ ] Container crash'i yok
- [ ] Cihaz düzenle ekranı tam çalışıyor
- [ ] Cihaz silme confirmation ile çalışıyor
- [ ] Emekli cihaz yeniden aktifleştirilebilir
- [ ] Lokasyon ekle/düzenle/sil çalışıyor
- [ ] Backend xUnit test'leri var (minimum 20 test)
- [ ] Flutter widget test'leri var (minimum 10 test)
- [ ] i18n (TR/EN) çalışıyor
- [ ] Sentry error monitoring aktif
- [ ] flutter analyze 0 hata
- [ ] v2.3.0 git tag

---

## ⚠️ Bilinen Riskler

1. **Dark mode tarama çok uzun sürebilir** — her dosyaya bakmak gerek
2. **Backend endpoint'leri eksik** — delete/update/reactivate için backend değişikliği lazım
3. **i18n büyük iş** — tüm metinleri çevirmek 1.5 saatten fazla sürebilir, MVP için kritik ekranlar yeter
4. **Sentry DSN** — ücretsiz hesap açman lazım, 5 dk

---

## 📦 Claude Code Başlatma Promptu

```
AssetFlow Mobile — SPEC_MOBILE_009 Fix & Complete & Quality.

Bu SPEC'i uygula: specs/SPEC_MOBILE_009_fix_complete_quality.md

3 bölüm, 15 task, ~10-14 saat:

BÖLÜM 1 — KRİTİK BUG FIX (T1-T2.3, ~2 saat):
  - Haptic neden çalışmıyor: 4 check (permission, init, default, log)
  - Dark mode tam: hardcoded renk avı + AppColors helper'ları
  - Container color+decoration taraması

BÖLÜM 2 — EKSİK FEATURES (T3.1-T3.4, ~4-5 saat):
  - Cihaz düzenle ekranı (form reuse pattern)
  - Cihaz silme (confirmation + auto-return assignment)
  - Emekli → envanter (status: Depoda)
  - Lokasyon CRUD (ekle, düzenle, sil)

BÖLÜM 3 — TEST & KALİTE (T4.1-T4.7, ~4-6 saat):
  - Backend xUnit setup + controller/service tests
  - Flutter widget test setup + critical flows
  - i18n (TR/EN) kritik ekranlar
  - Sentry error monitoring

FİNAL (T5): Test turu + v2.3.0 tag

KURALLAR:
- Her task sonrası flutter analyze (0 hata) + git commit
- SIRA KRİTİK: önce bug, sonra feature, en son test
- Backend'e dokunacak task'larda ITAssetManager proje yolunu kullan
- Bug fix sırasında FEATURE EKLEME, sadece düzelt

DOĞAL BREAKPOINTS:
- T2.3 sonrası: Bug'lar bitti?
- T3.4 sonrası: Feature'lar bitti?
- T4.3 sonrası: Backend tests bitti?
- T4.6 sonrası: i18n bitti?
- T5 sonrası: FİNAL

BAŞLANGIÇ:
BÖLÜM 1'den başla. İlk T1.1 — AndroidManifest.xml'e 
VIBRATE permission var mı kontrol et.

Sorun olursa dur, rapor ver.
```

---

**Hazırlayan:** Claude + Emre
**Versiyon:** 1.0
**Güncelleme:** 23 Nisan 2026

# SPEC_MOBILE_004 — Cihaz Formuna Donanım Alanları

**Hedef proje:** `C:\Workspace\Personal_Projects\assetflow_mobile`
**Tip:** Feature — cihaz ekleme/düzenleme formuna 10 donanım alanı + 4 section yapısı
**Tahmini süre:** 30-40 dakika
**Referans envanter:** `FORMS_HARDWARE_FIELDS_INVENTORY.md`

---

## Amaç

Mobile tarafında cihaz ekleme/düzenleme formuna 10 donanım alanı eklemek. Böylece Excel zimmet formundaki "-" görünen alanlar artık gerçek değerlerle dolacak. Form, section yapısıyla organize edilecek.

**Kapsamdaki 10 alan:**
- Temel Donanım: CPU, RAM, SSD (Storage), GPU
- Sistem: Hostname, OS
- Ağ: MAC, IP
- Teknik: BIOS, Motherboard

---

## Mimari Kararlar

### 1) Tek dosya, tek ekran (isEdit mode)

Envanter Adım 1: `device_form_screen.dart` zaten hem ekleme hem düzenleme için kullanılıyor (`DeviceFormScreen({Device? device})`). Aynı pattern'i koruyacağız.

### 2) Section yapısı — 4 grup

Envanter Adım 5'teki önerilen yerleşim uygulanacak:

```
── MEVCUT ALANLAR ─────────────────────── (dokunulmayacak)
  Ad, Marka, Model, Seri, Demirbaş Kodu,
  Tip, Durum, Tarih, Fiyat, Tedarikçi, Garanti, Notlar

── [YENİ] TEMEL DONANIM ───────────────── (4 alan)
  CPU, RAM, Depolama, GPU

── [YENİ] SİSTEM BİLGİLERİ ──────────────── (2 alan)
  Hostname, OS

── [YENİ] AĞ BİLGİLERİ ─────────────────── (2 alan)
  MAC, IP (validasyonlu)

── [YENİ] TEKNİK DETAYLAR ──────────────── (2 alan)
  BIOS, Motherboard
```

### 3) `_SectionHeader` — dosya içi private widget

Reusable section başlığı için. Başka dosyaya çıkarmaya gerek yok (envanter Adım 7).

```dart
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4) Model güncellemesi — 2 eksik alan

`device_model.dart`'a `biosVersion` ve `motherboardInfo` eklenecek:
- Constructor parametresi (nullable)
- `fromJson` mapping: `json['biosVersion'] as String?`
- `toJson` mapping: `'biosVersion': biosVersion`
- `copyWith` varsa oraya da eklenecek

### 5) Validasyon — sadece MAC ve IP

Envanter Adım 6 uyarınca:
- **MAC** opsiyonel ama girilmişse format kontrolü: `XX:XX:XX:XX:XX:XX` veya `XX-XX-XX-XX-XX-XX`
- **IP** opsiyonel ama girilmişse IPv4 format kontrolü
- Diğer 8 alan serbest metin, validation yok

### 6) `_onSave` data map güncellemesi

10 yeni alan data map'ine manuel eklenecek. Boş metin → null dönüşümü mevcut pattern'e uygun.

### 7) Backend dokunma

Backend Device entity'si **tüm 10 alanı destekliyor** (envanterden teyit). Mobile → Backend JSON geçişi otomatik. Backend SPEC gerekmez.

### 8) Mevcut kodu koru

- Mevcut 12 alan ve sırasına DOKUNMAYACAĞIZ
- Mevcut validator pattern, keyboardType kullanım şekli korunacak
- `_onSave` içindeki pattern (trim().isEmpty ? null : trim()) aynen devam

---

## Veri / Tipler

### Device Modeli'ne Eklenecek

```dart
class Device {
  // ... mevcut alanlar ...
  final String? biosVersion;        // YENİ
  final String? motherboardInfo;    // YENİ

  Device({
    // ... mevcut parametreler ...
    this.biosVersion,
    this.motherboardInfo,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      // ... mevcut mapping ...
      biosVersion: json['biosVersion'] as String?,
      motherboardInfo: json['motherboardInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ... mevcut ...
      'biosVersion': biosVersion,
      'motherboardInfo': motherboardInfo,
    };
  }
}
```

### DeviceFormScreen'de Eklenecek Controller'lar

```dart
// State'e eklenecek 10 controller:
final _cpuController = TextEditingController();
final _ramController = TextEditingController();
final _storageController = TextEditingController();
final _gpuController = TextEditingController();
final _hostNameController = TextEditingController();
final _osController = TextEditingController();
final _macController = TextEditingController();
final _ipController = TextEditingController();
final _biosController = TextEditingController();
final _motherboardController = TextEditingController();
```

### Validator Regex

```dart
String? _validateMac(String? value) {
  if (value == null || value.trim().isEmpty) return null; // opsiyonel
  final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
  return regex.hasMatch(value.trim())
    ? null
    : 'Geçerli bir MAC adresi girin (örn: AA:BB:CC:DD:EE:FF)';
}

String? _validateIp(String? value) {
  if (value == null || value.trim().isEmpty) return null; // opsiyonel
  final regex = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
  return regex.hasMatch(value.trim())
    ? null
    : 'Geçerli bir IP adresi girin (örn: 192.168.1.1)';
}
```

---

## Dokunulacak Dosyalar

### Değiştirilecek Dosyalar

- `lib/data/models/device_model.dart` — 2 alan eklenecek (biosVersion, motherboardInfo)
- `lib/features/devices/screens/device_form_screen.dart` — 10 controller + section header widget + 4 section + 10 AppTextField + validator + _onSave map + initState populate + dispose

### Dokunulmayan Dosyalar

- `lib/data/services/device_service.dart` — raw Map pattern, kendiliğinden geçiriyor
- Backend — Device entity tüm alanları destekliyor
- `lib/core/widgets/app_text_field.dart` — mevcut widget yeterli

### Yeni Dosyalar

- YOK — `_SectionHeader` private widget olarak form dosyasının içinde tanımlanacak

---

## Görevler

### T1 — Device model güncellemesi

**Dosya:** `lib/data/models/device_model.dart`

**Detaylar:**
- `biosVersion` ve `motherboardInfo` alanlarını ekle:
  - Class field (final String?)
  - Constructor parametresi
  - `fromJson` mapping
  - `toJson` mapping
  - `copyWith` varsa ekleme

**Kabul kriteri:**
- `flutter analyze` temiz
- Model serializable

**Commit:** `feat(devices): Device modeline biosVersion ve motherboardInfo alanlari eklendi`

---

### T2 — _SectionHeader widget ekleme

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
- Dosyanın sonuna (build metodundan sonra, state class'ının dışında) `_SectionHeader` private StatelessWidget ekle
- Constructor: `{required String title, required IconData icon}`
- Build: Icon + bold başlık metin (mimari kararlar §3'teki kod aynen)

**Kabul kriteri:**
- `flutter analyze` temiz
- Widget henüz kullanılmıyor, sadece tanımlı

**Commit:** `feat(devices): _SectionHeader widget eklendi`

---

### T3 — Controller'ları ve validator'ları ekle

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
- State class'ına 10 yeni controller ekle (veri tipleri §bölümünde)
- `_validateMac` ve `_validateIp` methodlarını ekle (regex §bölümünde)
- `initState` içinde, eğer düzenleme modundaysa (`widget.device != null`) her controller'ı ilgili değerle doldur:
  ```dart
  _cpuController.text = widget.device?.cpuInfo ?? '';
  _ramController.text = widget.device?.ramInfo ?? '';
  _storageController.text = widget.device?.storageInfo ?? '';
  _gpuController.text = widget.device?.gpuInfo ?? '';
  _hostNameController.text = widget.device?.hostName ?? '';
  _osController.text = widget.device?.osInfo ?? '';
  _macController.text = widget.device?.macAddress ?? '';
  _ipController.text = widget.device?.ipAddress ?? '';
  _biosController.text = widget.device?.biosVersion ?? '';
  _motherboardController.text = widget.device?.motherboardInfo ?? '';
  ```
- `dispose` içinde 10 controller'ın `.dispose()`'unu ekle

**Kabul kriteri:**
- `flutter analyze` temiz
- Henüz UI'da kullanılmıyor, sadece hazırlık

**Commit:** `feat(devices): 10 donanim controller + MAC/IP validatorlari eklendi`

---

### T4 — Form UI — 4 section + 10 AppTextField

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
Build method'u içinde, mevcut son alandan (muhtemelen Notlar) **SONRA**, submit butondan **ÖNCE** şu yapıyı ekle:

```dart
const _SectionHeader(title: 'TEMEL DONANIM', icon: Icons.memory),
const SizedBox(height: 8),
AppTextField(
  label: 'CPU Bilgisi',
  hint: 'Örn: Intel Core i7-1355U',
  controller: _cpuController,
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),
AppTextField(
  label: 'RAM Bilgisi',
  hint: 'Örn: 16 GB DDR4',
  controller: _ramController,
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),
AppTextField(
  label: 'Depolama Bilgisi',
  hint: 'Örn: 512 GB NVMe SSD',
  controller: _storageController,
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),
AppTextField(
  label: 'GPU Bilgisi',
  hint: 'Örn: NVIDIA RTX 3060',
  controller: _gpuController,
  textInputAction: TextInputAction.next,
),

const _SectionHeader(title: 'SİSTEM BİLGİLERİ', icon: Icons.computer),
const SizedBox(height: 8),
AppTextField(
  label: 'Hostname',
  hint: 'Örn: LAPTOP-ABC123',
  controller: _hostNameController,
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),
AppTextField(
  label: 'İşletim Sistemi',
  hint: 'Örn: Windows 11 Pro 23H2',
  controller: _osController,
  textInputAction: TextInputAction.next,
),

const _SectionHeader(title: 'AĞ BİLGİLERİ', icon: Icons.lan),
const SizedBox(height: 8),
AppTextField(
  label: 'MAC Adresi',
  hint: 'AA:BB:CC:DD:EE:FF',
  controller: _macController,
  textInputAction: TextInputAction.next,
  validator: _validateMac,
),
const SizedBox(height: 16),
AppTextField(
  label: 'IP Adresi',
  hint: '192.168.1.100',
  controller: _ipController,
  textInputAction: TextInputAction.next,
  keyboardType: TextInputType.number,
  validator: _validateIp,
),

const _SectionHeader(title: 'TEKNİK DETAYLAR', icon: Icons.settings_input_component),
const SizedBox(height: 8),
AppTextField(
  label: 'BIOS Versiyonu',
  hint: 'Örn: 1.15.0',
  controller: _biosController,
  textInputAction: TextInputAction.next,
),
const SizedBox(height: 16),
AppTextField(
  label: 'Anakart Bilgisi',
  hint: 'Örn: ASUS ROG Strix B650-A',
  controller: _motherboardController,
  textInputAction: TextInputAction.done,
),
```

**Dikkat:**
- Son alan (Anakart) `textInputAction: TextInputAction.done` olmalı
- Diğerleri `TextInputAction.next` (klavye enter tuşu sonraki alana geçer)
- IP için `keyboardType: TextInputType.number` kullanılabilir (rakam + nokta) — ama String olarak kalıyor

**Kabul kriteri:**
- `flutter analyze` temiz
- Form ekranında 4 bölüm görünüyor
- Emulator'de manuel test: yeni cihaz ekleme ekranı açılıyor, section'lar görünüyor (henüz save çalışmıyor, t5'te)

**Commit:** `feat(devices): form UI 4 section (donanim/sistem/ag/teknik) eklendi`

---

### T5 — _onSave data map genişletme

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
`_onSave` method'unda data map'ine 10 yeni alan ekle. Mevcut pattern'e uygun (trim + null check):

```dart
final data = {
  // ... mevcut alanlar ...
  'cpuInfo': _cpuController.text.trim().isEmpty ? null : _cpuController.text.trim(),
  'ramInfo': _ramController.text.trim().isEmpty ? null : _ramController.text.trim(),
  'storageInfo': _storageController.text.trim().isEmpty ? null : _storageController.text.trim(),
  'gpuInfo': _gpuController.text.trim().isEmpty ? null : _gpuController.text.trim(),
  'hostName': _hostNameController.text.trim().isEmpty ? null : _hostNameController.text.trim(),
  'osInfo': _osController.text.trim().isEmpty ? null : _osController.text.trim(),
  'macAddress': _macController.text.trim().isEmpty ? null : _macController.text.trim(),
  'ipAddress': _ipController.text.trim().isEmpty ? null : _ipController.text.trim(),
  'biosVersion': _biosController.text.trim().isEmpty ? null : _biosController.text.trim(),
  'motherboardInfo': _motherboardController.text.trim().isEmpty ? null : _motherboardController.text.trim(),
};
```

**Kabul kriteri:**
- `flutter analyze` temiz
- Manuel test: yeni bir cihazı tam donanım bilgisiyle ekle, kaydet. Sonra aynı cihazı düzenle, değerler doldurulmuş gelsin.

**Commit:** `feat(devices): _onSave data map 10 yeni donanim alani ile genisletildi`

---

### T6 — Son doğrulama ve test

**Detaylar:**
1. `flutter analyze` → 0 yeni hata/uyarı
2. `dart format lib/features/devices/ lib/data/models/`
3. **Emulator'de manuel test:**
   - **a) Yeni cihaz ekleme:**
     - Cihazlar → + (ekle)
     - Mevcut alanları doldur
     - Yeni section'larda tüm 10 alanı doldur
     - MAC: geçersiz format dene → validation uyarısı çıkmalı
     - IP: geçersiz format dene → validation uyarısı çıkmalı
     - Doğru formatla doldur → kaydet başarılı
     - Cihaz listesinde görünür
   - **b) Mevcut cihaz düzenleme:**
     - Bir cihaza tıkla → "Düzenle"
     - Donanım alanları doldurulmuş gelmelidir (eğer varsa)
     - Boş alanlara değer gir
     - Kaydet
     - Tekrar düzenle → değerler korunmuş
   - **c) Backend doğrulama:**
     - API üzerinden (PowerShell) cihaz çek, yeni alanlar dolu mu kontrol
   - **d) Excel form'da doğrulama:**
     - Bir zimmet formu üret
     - İndir, Excel'de aç
     - Donanım bölümünde CPU/RAM/SSD artık "-" yerine GERÇEK değerler görünmeli

4. Git log:
   ```bash
   git log --oneline | Select-Object -First 10
   ```

**Kabul kriteri:**
- Tüm yeni alanlar form'da çalışıyor
- Edit mode'da değerler doldurulmuş geliyor
- Validation çalışıyor (MAC/IP)
- Backend'e gidiyor, kaydediliyor
- Excel form'da görünüyor

**Commit:** (değişiklik varsa) `refactor: format + cleanup`

---

## Kapsam Dışı

- **Agent ile otomatik tespit** — WMI/PowerShell ile Windows cihazından otomatik çekme (ayrı SPEC)
- **Toplu düzenleme** — birden fazla cihazın alanlarını aynı anda güncelleme (ayrı feature)
- **Alan validasyonu zorlaması** — şu an tüm 10 alan opsiyonel, zorunlu hale getirme yok
- **Hostname formatı kontrolü** — sadece ASCII, boşluksuz gibi kurallar yok
- **OS dropdown** — OS için predefined list değil, serbest metin

---

## Notlar (Claude Code için)

- **Her görev sonrası:** `flutter analyze` + commit
- **Mevcut 12 alana DOKUNMA** — sadece yeni alanlar ekle
- **Hot reload yetmez** — state değişiyor, her test için **hot restart** (R)
- **Emulator testi zorunlu** — UI değişikliği var, `flutter analyze` yetmiyor
- **Backend dokunma** — entity zaten hazır
- **Pattern sadakatı** — AppTextField, trim + null, _SectionHeader hepsi tutarlı olmalı
- **Plan mode** her görev öncesi — özellikle T3 ve T4'te (çok iş var)
- **Hata alırsan DUR**, raporla

---

## Özet Beklenen Sonuç

Bugün cihaz ekleme/düzenleme ekranı:
- 12 mevcut alan korunur
- 4 yeni section görünür
- 10 yeni donanım alanı doldurulabilir
- MAC/IP doğrulaması çalışır
- Edit'te mevcut veriler doldurulmuş gelir
- Kaydet backend'e tüm 10 alanı gönderir
- Excel zimmet formunda "-" yerine gerçek değerler görünür

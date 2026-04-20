# Donanim Alanlari Envanter Raporu
Tarih: 2026-04-20

---

## ADIM 1 — Mevcut Cihaz Form Ekrani

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

- **Tek ekran, `isEdit` mode:** `DeviceFormScreen({Device? device})` — `device != null` ise düzenleme, değilse ekleme.
- **`ConsumerStatefulWidget`** kullanılıyor.
- **Flat form** — section yapısı YOK, tüm alanlar düz sırayla `Column` içinde.
- **Section başlık widget'ı YOK** (`_SectionTitle` gibi bir şey mevcut değil).

### Mevcut Alanlar (sırayla)
| # | Label | Controller | Klavye Tipi | Validator |
|---|---|---|---|---|
| 1 | Cihaz Adı * | `_nameController` | text | zorunlu |
| 2 | Marka | `_brandController` | text | yok |
| 3 | Model | `_modelController` | text | yok |
| 4 | Seri Numarası | `_serialController` | text | yok |
| 5 | Demirbaş Kodu | `_assetCodeController` | text | yok |
| 6 | Cihaz Tipi | `_selectedType` (int) | DropdownButtonFormField | yok |
| 7 | Durum | `_selectedStatus` (int) | DropdownButtonFormField | yok (sadece edit) |
| 8 | Satın Alma Tarihi | `_purchaseDate` (DateTime?) | GestureDetector + DatePicker | yok |
| 9 | Satın Alma Fiyatı (TL) | `_priceController` | number | yok |
| 10 | Tedarikçi | `_supplierController` | text | yok |
| 11 | Garanti Süresi (Ay) | `_warrantyMonthsController` | number | yok |
| 12 | Notlar | `_notesController` | text (maxLines:3) | yok |

---

## ADIM 2 — Device Modeli

**Dosya:** `lib/data/models/device_model.dart`

### Mevcut 10 Donanım Alanı — TAMAMI VAR ✅
| Alan | Tip | Nullable | fromJson | toJson |
|---|---|---|---|---|
| `hostName` | String? | ✅ | ✅ | ✅ |
| `cpuInfo` | String? | ✅ | ✅ | ✅ |
| `ramInfo` | String? | ✅ | ✅ | ✅ |
| `storageInfo` | String? | ✅ | ✅ | ✅ |
| `gpuInfo` | String? | ✅ | ✅ | ✅ |
| `osInfo` | String? | ✅ | ✅ | ✅ |
| `ipAddress` | String? | ✅ | ✅ | ✅ |
| `macAddress` | String? | ✅ | ✅ | ✅ |

### EKSİK ALANLAR ⚠️
| Alan | Durum |
|---|---|
| `biosVersion` | **YOK** — modelde tanımlı değil |
| `motherboardInfo` | **YOK** — modelde tanımlı değil |

> `biosVersion` ve `motherboardInfo` hem `Device` class'ına, hem `fromJson`, hem `toJson`'a eklenmelidir.

---

## ADIM 3 — Device Service

**Dosya:** `lib/data/services/device_service.dart`

- `create(Map<String, dynamic> data)` ve `update(String id, Map<String, dynamic> data)` methodları **raw Map** alıyor.
- Form ekranındaki `_onSave()` içinde `data` map'i manuel doldurulup servise gönderiliyor.
- **Otomatik aktarım YOK** — 10 yeni alan `_onSave()` içindeki `data` map'ine manuel olarak eklenmelidir.
- Service katmanında değişiklik gerekmez; sadece form ekranındaki `data` map'i genişletilecek.

---

## ADIM 4 — Mevcut Form UI Pattern'leri

**AppTextField** (`lib/core/widgets/app_text_field.dart`):
```dart
AppTextField(
  label: 'Alan Adı',
  hint: 'İpucu metni',
  controller: _controller,
  keyboardType: TextInputType.text, // veya number, emailAddress vb.
  textInputAction: TextInputAction.next,
  validator: (value) { ... }, // opsiyonel
)
```

- **Zorunlu alan:** `validator` parametresi ile, label sonuna `*` ekleniyor (ör. `'Cihaz Adı *'`).
- **Opsiyonel alan:** `validator` verilmiyor.
- **Sayısal alan:** `keyboardType: TextInputType.number`.
- **Section başlık:** Mevcut formda YOK — eklenmesi gerekiyor.
- **Boş metin → null:** `trim().isEmpty ? null : trim()` pattern'i tutarlı kullanılıyor.

---

## ADIM 5 — Önerilen Yerleşim

Mevcut form flat ve bölümsüz. 10 yeni alan 4 section altında gruplandırılmalı:

```
── MEVCUT ALANLAR (değişmez) ──────────────────────────
  Cihaz Adı *, Marka, Model, Seri No, Demirbaş Kodu
  Cihaz Tipi, Durum, Satın Alma Tarihi, Fiyat, Tedarikçi
  Garanti Süresi, Notlar

── [YENİ] TEMEL DONANIM ───────────────────────────────
  CPU Bilgisi        (cpuInfo)      → serbest metin
  RAM Bilgisi        (ramInfo)      → serbest metin
  Depolama Bilgisi   (storageInfo)  → serbest metin
  GPU Bilgisi        (gpuInfo)      → serbest metin

── [YENİ] SİSTEM BİLGİLERİ ───────────────────────────
  Hostname           (hostName)     → serbest metin
  İşletim Sistemi    (osInfo)       → serbest metin

── [YENİ] AĞ BİLGİLERİ ───────────────────────────────
  MAC Adresi         (macAddress)   → format validasyonu
  IP Adresi          (ipAddress)    → format validasyonu

── [YENİ] TEKNİK DETAYLAR ─────────────────────────────
  BIOS Versiyonu     (biosVersion)  → serbest metin
  Anakart Bilgisi    (motherboardInfo) → serbest metin
```

**Neden 4 section?** Form zaten 12 alanlık ve uzun; yeni 10 alan bölümlenmeden eklenirse kullanılamaz hale gelir. Section'lar hem görsel hiyerarşi kurar hem de donanım/sistem/ağ/teknik ayrımını yansıtır.

---

## ADIM 6 — Validasyon

| Alan | Validasyon | Kural |
|---|---|---|
| `macAddress` | Opsiyonel ama girilmişse format kontrolü | `XX:XX:XX:XX:XX:XX` veya `XX-XX-XX-XX-XX-XX` (12 hex + ayraç) |
| `ipAddress` | Opsiyonel ama girilmişse format kontrolü | IPv4: `0-255.0-255.0-255.0-255` |
| Diğer 8 alan | Validasyon YOK | Serbest metin, opsiyonel |

**MAC Regex:** `^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$`  
**IPv4 Regex:** `^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$`

---

## ADIM 7 — Tahmini Etki

### Değişecek Dosyalar

| Dosya | Değişiklik |
|---|---|
| `lib/data/models/device_model.dart` | `biosVersion` ve `motherboardInfo` alanları eklenir (field, constructor, fromJson, toJson) |
| `lib/features/devices/screens/device_form_screen.dart` | 10 controller eklenir; initState doldurulur; dispose temizler; `_onSave` data map'i genişler; `build` içine 4 section + 10 AppTextField eklenir |

### Yeni Dosya Gerekiyor mu?

**`_HardwareFieldsSection`** gibi bir widget oluşturmak anlamlı **DEĞİL**:
- Section'ların ortak state (controller'lar) ile bağlantısı var — parent widget'tan geçirilmesi gerekir.
- Form ekranı zaten tek dosya; private `_SectionHeader` widget'ı yeterli.
- Ekstra dosya = ekstra bağımlılık, bu boyuttaki bir değişiklik için gereksiz soyutlama.

**Önerilen:** `device_form_screen.dart` içinde `_SectionHeader` private widget'ı tanımlanır.

### pubspec.yaml Kontrolü ✅
Yeni paket gerekmez. Tüm gerekli bileşenler mevcut:
- `AppTextField` → var
- `AppButton` → var
- Regex validasyon → dart:core içinde

---

## Özet Kontrol Listesi

- [x] Form: tek ekran, isEdit mode, flat yapı, section YOK
- [x] Model: 8/10 alan var (`biosVersion` ve `motherboardInfo` EKSİK)
- [x] Service: raw Map pattern, manual ekleme gerekli, servis değişmez
- [x] AppTextField: label/hint/controller/keyboardType/validator pattern
- [x] pubspec.yaml: ekstra paket gerekmez
- [ ] **Yapılacak:** `device_model.dart`'a 2 eksik alan ekle
- [ ] **Yapılacak:** `device_form_screen.dart`'a 10 controller + 4 section + validasyon ekle

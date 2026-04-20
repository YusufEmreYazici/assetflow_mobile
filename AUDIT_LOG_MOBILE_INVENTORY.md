# Audit Log UI — Mobile Envanter Raporu
Tarih: 2026-04-20

---

## ADIM 1 — Cihaz Detay Sayfası

**Dosya:** `lib/features/devices/screens/device_detail_screen.dart`

### Yapı

Tek bir `ListView` içinde sıralı `_SectionCard` widget'larından oluşan **tam scroll yapısı**. Tab bar yok.

### Mevcut Section Sırası

| # | Section | Koşul | Icon |
|---|---|---|---|
| 1 | Genel Bilgi | her zaman | `Icons.info_outline` |
| 2 | Satın Alma | purchaseDate/price/supplier varsa | `Icons.shopping_cart_outlined` |
| 3 | Garanti | warrantyDurationMonths/EndDate varsa | `Icons.shield_outlined` |
| 4 | Lokasyon | locationName varsa | `Icons.location_on_outlined` |
| 5 | Zimmet/İade Formu | activeAssignmentId varsa | `Icons.description` (özel widget) |
| 6 | Donanım | herhangi bir hw alanı varsa | `Icons.memory` |
| 7 | Notlar | notes varsa | `Icons.notes` |

### Audit Log İçin En Uygun Konum

**Notlar section'ından hemen SONRA**, sayfanın en altı. Gerekçe:
- Genel/Satın/Garanti/Donanım → statik bilgi → üstte
- Zimmet Formu → aktif işlem → ortada
- Audit Log → geçmiş aktivite → kronolojik sıra, en alta
- "Notlar" zaten sayfa sonu içeriği; audit log onun altına doğal yerleşir
- Her zaman görünür (koşulsuz section) veya kayıt varsa görünür

### Widget Pattern

`_SectionCard` yeniden kullanılabilir. Başlık + icon + border + içerik pattern'i standartlaştırılmış. Audit Log için yeni bir `_AuditLogSectionCard` veya mevcut `_SectionCard`'ın altına özel içerik widget'ı yeterli.

---

## ADIM 2 — Zimmet Detay Sayfası

**Mevcut zimmet ekranları:**
```
lib/features/assignments/screens/assignments_screen.dart
lib/features/assignments/screens/assign_device_screen.dart
lib/features/assignments/screens/return_device_screen.dart
```

**Zimmet DETAY sayfası YOK.** `assignments_screen.dart` bir liste görünümü. Zimmet satırına tıklanınca herhangi bir detay push edilmiyor.

### Karar

Audit log **cihaz detay sayfasında** gösterilmeli. Gerekçe:
- Zimmet detay sayfası yok, oluşturmak kapsam dışı
- Kullanıcı bir cihaza bakınca "bu cihaza ne oldu?" sorusuna cevap almalı
- Cihaz bağlamında audit log en anlamlı nokta

İsteğe bağlı gelecek: zimmet detay ekranı açılırsa orada da aynı `AuditLogList` widget kullanılabilir.

---

## ADIM 3 — UI Pattern'leri

### RecentActivitySection (`lib/features/dashboard/widgets/recent_activity_section.dart`)

Dashboard'daki aktivite feed'i pattern'i:
- `Column` + `Container` (dark800 bg, rounded 12, border)
- `List.generate` ile `ListTile` satırları
- Satırlar arası `Divider(indent: 62)`
- Her satır: **leading** (renkli ikon kutusu 36x36) + **title** (bold text) + **subtitle** (ikincil) + **trailing** (chip + tarih)
- `DashboardSectionHeader` üstbaşlık widget'ı

### Audit Log Tile için Önerilen Pattern

`RecentActivitySection` ile birebir aynı `ListTile` yapısı kullanılabilir:

```
Leading:  Renkli ikon kutusu (aksiyon tipine göre renk)
Title:    Aksiyon açıklaması ("Zimmet atandı", "Donanım güncellendi" vb.)
Subtitle: Kullanıcı adı (kimin yaptığı)
Trailing: Tarih (dd MMM, tr_TR)
```

Fark: timeline için solda ince çizgi (`Container(width:2, color:...)`) eklenebilir ama opsiyonel.

### Shimmer Loading

`device_detail_screen.dart`'taki `_buildShimmer()` metodu `List.generate(4, ...)` ile `Container(height:120)` blokları üretiyor. Aynı Shimmer pattern audit log yükleme sırasında kullanılır.

---

## ADIM 4 — Gerekli Yeni Dosyalar

### Kesinlikle Gerekli (5 dosya)

```
lib/data/models/audit_log_model.dart
lib/data/services/audit_log_service.dart
lib/features/audit/providers/audit_log_provider.dart
lib/features/audit/widgets/audit_log_tile.dart
lib/features/audit/widgets/audit_log_section.dart
```

### İsteğe Bağlı (oluşturulmayabilir)

```
lib/features/audit/           ← yeni feature klasörü
```
`lib/features/devices/widgets/` altında da tutulabilir ama `audit/` kendi klasörü daha temiz.

### Dokunulmayan Dosyalar

- `api_constants.dart` — audit log endpoint'i eklenecek (`static String deviceAuditLogs(String id) => '/api/audit-logs/device/$id'`)
- `device_detail_screen.dart` — sadece son bölüme widget çağrısı eklenecek
- Diğer tüm dosyalar

---

## ADIM 5 — Tahmini Model Yapısı

Backend audit log entity'si genellikle şu alanları taşır:

```dart
class AuditLog {
  final String id;
  final String entityType;      // "Device", "Assignment" vb.
  final String entityId;
  final String action;          // "Created", "Updated", "Assigned", "Returned" vb.
  final String? userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? changes;  // önceki/yeni değer farkları
}
```

**Önemli not:** Backend audit log endpoint'inin var olup olmadığı ve hangi alanları döndürdüğü teyit edilmeli. `api_constants.dart`'ta `/api/audit-logs` gibi bir endpoint yok — backend SPEC'i gerekebilir.

---

## ADIM 6 — Backend Endpoint Durumu

`api_constants.dart` incelendi:

| Kategori | Mevcut Endpoint'ler |
|---|---|
| Auth | `/api/auth/*` (5 endpoint) |
| Devices | `/api/devices`, `/api/devices/:id` |
| Employees | `/api/employees`, `/api/employees/:id` |
| Assignments | `/api/assignments`, assign, return, export |
| Locations | `/api/locations`, `/api/locations/:id` |
| Assignment Forms | `/api/assignment-forms/*` (6 endpoint) |
| Dashboard | `/api/dashboard` |
| SAP | `/api/sap/*` (4 endpoint) |
| **Audit Logs** | **YOK** ⚠️ |

**Audit log backend endpoint'i henüz tanımlanmamış.** Mobile'dan önce backend SPEC gerekli.

---

## Özet — Uygulama Öncesi Kontrol Listesi

| Madde | Durum |
|---|---|
| Cihaz detay sayfasında ekleme noktası belli | ✅ Notlar'ın altı |
| Zimmet detay sayfası | ❌ Yok (şimdilik cihaz sayfasında göster) |
| UI pattern referansı | ✅ RecentActivitySection + _SectionCard |
| Shimmer pattern | ✅ _buildShimmer() |
| AppColors/theme | ✅ Hazır |
| Backend endpoint | ⚠️ **Tanımlanmamış** — önce backend SPEC lazım |
| Model alanları | ⚠️ Backend schema'ya göre belirlenecek |
| Yeni dosya sayısı | 5 dosya + 1 klasör |
| Mevcut koda dokunma | Minimal (device_detail_screen.dart + api_constants.dart) |

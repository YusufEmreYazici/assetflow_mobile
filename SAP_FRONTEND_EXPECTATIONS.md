# SAP Backend Beklentileri

**Hazırlanma tarihi:** 2026-04-17
**İncelenen dosyalar:**
- `lib/data/services/sap_service.dart`
- `lib/data/models/sap_models.dart`
- `lib/features/sap/providers/sap_provider.dart`
- `lib/features/sap/screens/sap_screen.dart`
- `lib/core/constants/api_constants.dart`

---

## Endpoint'ler

### 1. GET /api/sap/status

**Amaç:** SAP sisteminin yapılandırılıp yapılandırılmadığını ve bağlantı durumunu öğrenmek.

**Request:**
- Body: Yok
- Query params: Yok
- Headers: `Authorization: Bearer {token}`

**Başarılı Response (200):**
```json
{
  "isConfigured": true,
  "isConnected": true,
  "version": "SAP ERP 6.0 EHP8",
  "lastChecked": "2026-04-17T10:30:00Z"
}
```

| Field | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `isConfigured` | `bool` | Hayır (default: `false`) | SAP bağlantısı backend'de tanımlı mı |
| `isConnected` | `bool` | Hayır (default: `false`) | Anlık bağlantı sağlıklı mı |
| `version` | `string` | Hayır (nullable) | SAP versiyon string'i — UI'da gösterilir |
| `lastChecked` | `string` (ISO 8601) | Hayır (nullable) | Son kontrol zamanı |

**Özel HTTP Durumları:**
- `404` veya `501` → Frontend `SapConnectionStatus.notConfigured` döner (hata fırlatmaz). UI "Yapılandırılmadı" gösterir.
- Diğer hatalar → `rethrow` — provider `catch` bloğunda `notConfigured` fallback uygular.

**UI Yansıması:**
- `isConfigured: false` → gri ikon + "Yapılandırılmadı" yazısı
- `isConfigured: true, isConnected: true` → yeşil + "Bağlı"
- `isConfigured: true, isConnected: false` → kırmızı + "Bağlantı Yok"
- `version` varsa → "Sürüm: {version}" alt satırda gösterilir

---

### 2. POST /api/sap/sync/employees

**Amaç:** SAP HR modülünden personeli içe aktarmak / güncellemek.

**Request:**
- Body: Yok (boş POST)
- Query params: Yok
- Headers: `Authorization: Bearer {token}`

**Başarılı Response (200):**
```json
{
  "newCount": 5,
  "updatedCount": 12,
  "errorCount": 0,
  "syncTime": "2026-04-17T11:00:00Z",
  "success": true,
  "errorMessage": null
}
```

| Field | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `newCount` | `int` | Hayır (default: `0`) | Yeni oluşturulan personel sayısı |
| `updatedCount` | `int` | Hayır (default: `0`) | Güncellenen personel sayısı |
| `errorCount` | `int` | Hayır (default: `0`) | İşlenemeyen kayıt sayısı |
| `syncTime` | `string` (ISO 8601) | Hayır (default: şimdiki zaman) | Sync tamamlanma zamanı |
| `success` | `bool` | Hayır (default: `true`) | Genel başarı bayrağı |
| `errorMessage` | `string` | Hayır (nullable) | Hata varsa açıklama |

**Hata Durumları:**
- `404` / `501` → "SAP entegrasyonu henüz yapılandırılmadı" mesajı, UI'da hata kutusu
- Backend `error` veya `message` field'lı JSON → direkt gösterilir
- Network/timeout → "SAP bağlantısı kurulamadı"

**Yan Etki (Bildirim):**
- `newCount > 0` ise `notifySapNewEmployee(employeeName: '{N} personel', department: 'SAP aktarımı')` tetiklenir

**UI Yansıması:**
- Button "Aktarılıyor..." + spinner (disabled)
- Sonuç: 3 badge — Yeni Personel (yeşil), Güncellenen (mavi), Hata (kırmızı/gri)
- Son satır: "Son aktarım: GG.AA.YYYY SS:DD"

---

### 3. POST /api/sap/sync/assets

**Amaç:** SAP Asset Management modülünden varlık envanterini içe aktarmak.

**Request:**
- Body: Yok (boş POST)
- Query params: Yok
- Headers: `Authorization: Bearer {token}`

**Başarılı Response (200):** *(SapSyncResult — employees ile aynı yapı)*
```json
{
  "newCount": 8,
  "updatedCount": 3,
  "errorCount": 1,
  "syncTime": "2026-04-17T11:05:00Z",
  "success": true,
  "errorMessage": null
}
```

**Hata Durumları:** employees ile aynı.

**Yan Etki (Bildirim):**
- `newCount > 0` ise `notifySapAssetsImported(count: newCount)` tetiklenir

**UI Yansıması:**
- Aynı `_SyncCard` widget'ı, label'lar: "Yeni Varlık", "Güncellenen", "Hata"

---

### 4. GET /api/sap/budgets

**Amaç:** SAP'tan gelen bütçe onay taleplerini listelemek.

**Request:**
- Body: Yok
- Query params: Yok
- Headers: `Authorization: Bearer {token}`

**Başarılı Response (200):** *(Array)*
```json
[
  {
    "id": "42",
    "amount": 15000.00,
    "description": "Laptop alımı - IT departmanı",
    "status": "pending",
    "createdAt": "2026-04-10T08:00:00Z",
    "requestedBy": "Ahmet Yılmaz",
    "department": "Bilgi İşlem"
  },
  {
    "id": "43",
    "amount": 3500.50,
    "description": "Yazıcı sarf malzemesi",
    "status": "approved",
    "createdAt": "2026-04-08T14:30:00Z",
    "requestedBy": "Fatma Demir",
    "department": null
  }
]
```

| Field | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `id` | `string` (int veya string kabul) | Hayır (default: `''`) | Backend int dönebilir, `.toString()` ile alınır |
| `amount` | `number` (double) | Hayır (default: `0.0`) | Tutar — `₺` sembolüyle `#,##0.00 tr_TR` formatında gösterilir |
| `description` | `string` | Hayır (default: `''`) | Bütçe açıklaması |
| `status` | `string` | Hayır (default: `'pending'`) | **Enum değerleri:** `'pending'`, `'approved'`, `'rejected'` |
| `createdAt` | `string` (ISO 8601) | Hayır (default: şimdiki zaman) | Oluşturma tarihi |
| `requestedBy` | `string` | Hayır (default: `''`) | Talep eden kişi adı |
| `department` | `string` | Hayır (nullable) | Bölüm — opsiyonel, varsa " · {department}" olarak gösterilir |

**Status Değerleri ve UI Karşılıkları:**
| Değer | Renk | Etiket | İkon |
|---|---|---|---|
| `'pending'` | Sarı (warning) | "Bekliyor" | `schedule` |
| `'approved'` | Yeşil (success) | "Onaylandı" | `check_circle_outline` |
| `'rejected'` | Kırmızı (error) | "Reddedildi" | `cancel_outlined` |

**Yan Etki (Bildirim):**
- Listede `status == 'pending'` olan bütçe varsa, ilk `pending` item için `notifySapBudgetApproved(amount, description)` tetiklenir *(dikkat: fonksiyon adı "approved" olmasına rağmen "pending" kontrolüyle tetikleniyor — muhtemelen bildirim adı yanlış)*

**Hata Durumları:**
- `404` / `501` → "SAP entegrasyonu henüz yapılandırılmadı" — gri bilgi kutusu
- Network/timeout → "SAP bağlantısı kurulamadı"
- Boş array `[]` → "Bekleyen bütçe onayı yok" boş state

---

## DTO'lar

### SapConnectionStatus

| Field | Dart Tipi | Nullable | Default | Örnek Değer |
|---|---|---|---|---|
| `isConfigured` | `bool` | Hayır | `false` | `true` |
| `isConnected` | `bool` | Hayır | `false` | `true` |
| `version` | `String?` | Evet | `null` | `"SAP ERP 6.0 EHP8"` |
| `lastChecked` | `DateTime?` | Evet | `null` | `"2026-04-17T10:30:00Z"` |

Özel static getter: `SapConnectionStatus.notConfigured` → `isConfigured: false, isConnected: false`

---

### SapSyncResult

| Field | Dart Tipi | Nullable | Default | Örnek Değer |
|---|---|---|---|---|
| `newCount` | `int` | Hayır | `0` | `5` |
| `updatedCount` | `int` | Hayır | `0` | `12` |
| `errorCount` | `int` | Hayır | `0` | `1` |
| `syncTime` | `DateTime` | Hayır | `DateTime.now()` | `"2026-04-17T11:00:00Z"` |
| `success` | `bool` | Hayır | `true` | `true` |
| `errorMessage` | `String?` | Evet | `null` | `"3 kayıt işlenemedi"` |

---

### SapBudgetItem

| Field | Dart Tipi | Nullable | Default | Örnek Değer |
|---|---|---|---|---|
| `id` | `String` | Hayır | `''` | `"42"` (int da olabilir) |
| `amount` | `double` | Hayır | `0.0` | `15000.00` |
| `description` | `String` | Hayır | `''` | `"Laptop alımı"` |
| `status` | `String` | Hayır | `'pending'` | `"pending"` / `"approved"` / `"rejected"` |
| `createdAt` | `DateTime` | Hayır | `DateTime.now()` | `"2026-04-10T08:00:00Z"` |
| `requestedBy` | `String` | Hayır | `''` | `"Ahmet Yılmaz"` |
| `department` | `String?` | Evet | `null` | `"Bilgi İşlem"` |

---

## UI Akışı

### Sayfa Açılışı (`SapNotifier` constructor)

```
SapScreen açılır
  └─ sapProvider (StateNotifierProvider.autoDispose) oluşturulur
       ├─ _loadStatus() çalışır
       │    └─ GET /api/sap/status
       │         ├─ 200 → ConnectionCard güncellenir
       │         └─ 404/501/hata → notConfigured fallback
       └─ _loadBudgets() çalışır (paralel)
            └─ GET /api/sap/budgets
                 ├─ 200 → BudgetTile'lar render edilir
                 │    └─ pending varsa → bildirim tetiklenir
                 └─ hata → "SAP entegrasyonu henüz yapılandırılmadı"
```

### AppBar Yenile Butonu / Pull-to-Refresh

```
Yenile tetiklenir
  └─ refresh() → Future.wait([_loadStatus(), _loadBudgets()])
```

> **Not:** `syncEmployees()` ve `syncAssets()` `refresh()` tarafından **çağrılmıyor**. Yalnızca "Senkronize Et" butonlarıyla manuel tetiklenir.

### Personel Senkronize Et Butonu

```
Tıklandığında:
  ├─ isSyncingEmployees == true → işlem yok (guard)
  ├─ state: isSyncingEmployees=true, employeeSyncError=null
  ├─ POST /api/sap/sync/employees
  │    ├─ Başarılı → lastEmployeeSync güncellenir
  │    │    └─ newCount > 0 → notifySapNewEmployee() tetiklenir
  │    └─ Hata → employeeSyncError set edilir
  └─ state: isSyncingEmployees=false
```

### Varlık Senkronize Et Butonu

```
Tıklandığında: (employees ile aynı akış)
  └─ POST /api/sap/sync/assets
       └─ newCount > 0 → notifySapAssetsImported() tetiklenir
```

### Error State Gösterimi

- **Sync hataları:** Her `_SyncCard` içinde kırmızı border'lı inlined hata kutusu (warning ikonu + metin)
- **Bütçe hataları:** Gri bilgi kutusu (info ikonu + metin) — daha az agresif tasarım
- **Bağlantı durumu hatası:** `_loadStatus` catch'i sessizce `notConfigured` döner, UI'da hata kutusu yok (gri "Yapılandırılmadı" durumu)
- **SnackBar yok:** SAP hataları SnackBar göstermez, inline widget'larla gösterilir

---

## Önemli Notlar

1. **Tüm field'lar optional parse edilmiş:** Backend eksik field dönse bile uygulama çökmez — `?? defaultValue` pattern kullanılmış.

2. **id field'ı:** `SapBudgetItem.id` backend'den `int` gelebilir, `.toString()` ile `String`'e çevrilir.

3. **DateTime parse:** `DateTime.tryParse()` kullanıldığından format bozuksa `DateTime.now()` fallback devreye girer.

4. **404/501 özel handling:** Sadece `getStatus()` içinde explicit yakalanıyor. `syncEmployees`, `syncAssets`, `getBudgets` endpoint'lerinde 404/501 `_parseError()` içinde yakalanıyor.

5. **Bildirim bug'ı:** `_loadBudgets()` içindeki bildirim `notifySapBudgetApproved` adını taşıyor fakat `status == 'pending'` kontrolüyle tetikleniyor. Backend "onaylandı" → "rejected"'den "approved"'a geçen bütçeleri ayrı bir event ile döndürmüyorsa bu bildirim her sayfa açılışında tekrar tetiklenebilir.

6. **autoDispose:** `sapProvider` `.autoDispose` — ekrandan çıkıldığında state sıfırlanır, geri gelindiğinde status + budgets yeniden fetch edilir.

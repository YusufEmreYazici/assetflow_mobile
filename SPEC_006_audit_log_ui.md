# SPEC_006 — Audit Log UI (Backend + Mobile)

**Hedef projeler:**
- Backend: `C:\Workspace\Personal_Projects\ITAssetManager`
- Mobile: `C:\Workspace\Personal_Projects\assetflow_mobile`

**Tip:** Yeni feature — backend API + mobile UI
**Tahmini süre:** 1-1.5 saat
**Referans envanterler:** `AUDIT_LOG_BACKEND_INVENTORY.md`, `AUDIT_LOG_MOBILE_INVENTORY.md`

---

## Amaç

Bir cihazın tüm değişiklik geçmişini mobile cihaz detay sayfasında göstermek. Backend `AuditLogs` tablosu zaten otomatik olarak her Create/Update/Delete kaydı tutuyor — şimdi bu veriyi API ile sunacak ve mobile'da görünür kılacağız.

## Kullanıcı Kararları

1. **Görünürlük:** Audit log section her zaman görünür, kayıt yoksa "Henüz değişiklik yok" mesajı
2. **Tile içeriği:** 3 nokta menü → "Detayları Göster" pop-up
3. **Kapsam:** Cihaz + ona ait zimmetler + zimmet formları (3 kategori)

---

## Bölüm A — Backend

### Mimari Kararlar (Backend)

#### A1) Tek endpoint, 3 entity union

```
GET /api/audit-logs/device/{deviceId}?page=1&pageSize=20
```

Backend bu endpoint'te:
1. O deviceId ile audit log'ları çek (`EntityName = Device AND EntityId = {deviceId}`)
2. Bu cihazın tüm assignment'larını bul (`Assignments WHERE DeviceId = {deviceId}`)
3. Her assignment'ın audit log'larını çek (`EntityName = Assignment AND EntityId IN (...)`)
4. Her assignment'ın form'larını bul (`AssignmentForms WHERE AssignmentId IN (...)`)
5. Her form'un audit log'larını çek (`EntityName = AssignmentForm AND EntityId IN (...)`)
6. Hepsini union et, Timestamp DESC sırala, page/pageSize uygula

Performance notu: EntityName+EntityId composite index hazır, sorgular hızlı olur. 

#### A2) Parse edilmiş değerler

`OldValues` ve `NewValues` JSON string olarak DB'de duruyor — service'te parse edilip `Dictionary<string, object?>` olarak DTO'ya konulur. Mobile'da tekrar deserialize gerek yok.

`AffectedColumns` virgülle ayrılmış string — `List<string>`'e çevrilir.

#### A3) Authorization + CompanyId izolasyonu

Mevcut pattern: `[Authorize]` + `_currentUser.CompanyId`. Her audit log zaten CompanyId field'ına sahip, filter otomatik uygulanır.

#### A4) DTO şekli

```csharp
public class AuditLogResponse
{
    public Guid Id { get; set; }
    public string Action { get; set; }                        // "Create" | "Update" | "Delete"
    public string EntityName { get; set; }                    // "Device" | "Assignment" | "AssignmentForm"
    public string EntityId { get; set; }
    public string? UserEmail { get; set; }
    public string? IpAddress { get; set; }
    public DateTime Timestamp { get; set; }
    public Dictionary<string, object?>? OldValues { get; set; }
    public Dictionary<string, object?>? NewValues { get; set; }
    public List<string>? AffectedColumns { get; set; }
}
```

---

### Backend Görevleri

#### T1 — AuditLogResponse DTO

**Yeni dosya:** `src/AssetFlow.Application/DTOs/AuditLog/AuditLogResponse.cs`

**Detaylar:**
- Yukarıdaki DTO şeklini oluştur
- `namespace AssetFlow.Application.DTOs.AuditLog`

**Kabul kriteri:**
- `dotnet build` 0 hata

**Commit:** `feat(audit): AuditLogResponse DTO eklendi`

---

#### T2 — IAuditLogService interface

**Yeni dosya:** `src/AssetFlow.Application/Interfaces/IAuditLogService.cs`

**Detaylar:**
```csharp
public interface IAuditLogService
{
    Task<PagedResult<AuditLogResponse>> GetForDeviceAsync(
        Guid deviceId,
        Guid companyId,
        int page,
        int pageSize,
        CancellationToken ct);
}
```

Tek method yeterli şimdilik. Sonra `GetForAssignmentAsync`, `GetRecentAsync` eklenebilir (ayrı SPEC).

**Kabul kriteri:**
- `dotnet build` 0 hata

**Commit:** `feat(audit): IAuditLogService interface eklendi`

---

#### T3 — AuditLogService implementasyon

**Yeni dosya:** `src/AssetFlow.Application/Services/AuditLogs/AuditLogService.cs`

**Detaylar:**

```csharp
public class AuditLogService : IAuditLogService
{
    private readonly IRepository<AuditLog> _auditLogRepo;
    private readonly IRepository<Assignment> _assignmentRepo;
    private readonly IRepository<AssignmentForm> _formRepo;

    public AuditLogService(
        IRepository<AuditLog> auditLogRepo,
        IRepository<Assignment> assignmentRepo,
        IRepository<AssignmentForm> formRepo)
    {
        _auditLogRepo = auditLogRepo;
        _assignmentRepo = assignmentRepo;
        _formRepo = formRepo;
    }

    public async Task<PagedResult<AuditLogResponse>> GetForDeviceAsync(
        Guid deviceId,
        Guid companyId,
        int page,
        int pageSize,
        CancellationToken ct)
    {
        var deviceIdStr = deviceId.ToString();

        // 1. O cihaza ait assignment'ları bul
        var assignments = await _assignmentRepo.FindAsync(
            a => a.DeviceId == deviceId, ct);
        var assignmentIds = assignments.Select(a => a.Id.ToString()).ToList();

        // 2. Bu assignment'lara ait form'ları bul
        var forms = await _formRepo.FindAsync(
            f => assignmentIds.Contains(f.AssignmentId.ToString()), ct);
        var formIds = forms.Select(f => f.Id.ToString()).ToList();

        // 3. Tüm entity ID listesi
        var allEntityIds = new List<(string name, string id)>();
        allEntityIds.Add(("Device", deviceIdStr));
        allEntityIds.AddRange(assignmentIds.Select(id => ("Assignment", id)));
        allEntityIds.AddRange(formIds.Select(id => ("AssignmentForm", id)));

        // 4. Tek sorgu ile tüm log'ları al
        // Note: LINQ-to-SQL tuple match desteği sınırlı, pragmatik çözüm:
        var logs = await _auditLogRepo.FindAsync(
            l => l.CompanyId == companyId &&
                 ((l.EntityName == "Device" && l.EntityId == deviceIdStr) ||
                  (l.EntityName == "Assignment" && assignmentIds.Contains(l.EntityId)) ||
                  (l.EntityName == "AssignmentForm" && formIds.Contains(l.EntityId))),
            ct);

        // 5. Order by Timestamp DESC
        var ordered = logs.OrderByDescending(l => l.Timestamp).ToList();

        // 6. Paging
        var total = ordered.Count;
        var items = ordered
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(MapToResponse)
            .ToList();

        return new PagedResult<AuditLogResponse>
        {
            Items = items,
            TotalCount = total,
            Page = page,
            PageSize = pageSize
        };
    }

    private static AuditLogResponse MapToResponse(AuditLog log)
    {
        return new AuditLogResponse
        {
            Id = log.Id,
            Action = log.Action,
            EntityName = log.EntityName,
            EntityId = log.EntityId,
            UserEmail = log.UserEmail,
            IpAddress = log.IpAddress,
            Timestamp = log.Timestamp,
            OldValues = ParseJson(log.OldValues),
            NewValues = ParseJson(log.NewValues),
            AffectedColumns = string.IsNullOrEmpty(log.AffectedColumns)
                ? null
                : log.AffectedColumns.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList()
        };
    }

    private static Dictionary<string, object?>? ParseJson(string? json)
    {
        if (string.IsNullOrEmpty(json)) return null;
        try
        {
            return JsonSerializer.Deserialize<Dictionary<string, object?>>(json);
        }
        catch
        {
            return null;
        }
    }
}
```

**Kabul kriteri:**
- `dotnet build` 0 hata
- Service testi API üzerinden (T5'te)

**Commit:** `feat(audit): AuditLogService implementasyon`

---

#### T4 — DI kaydı

**Değişecek dosya:** `src/AssetFlow.Application/DependencyInjection.cs`

**Detaylar:**
```csharp
services.AddScoped<IAuditLogService, AuditLogService>();
```

**Kabul kriteri:**
- `dotnet build` 0 hata

**Commit:** `feat(audit): AuditLogService DI kaydi`

---

#### T5 — AuditLogsController

**Yeni dosya:** `src/AssetFlow.API/Controllers/AuditLogsController.cs`

**Detaylar:**
```csharp
[ApiController]
[Route("api/audit-logs")]
[Authorize]
public class AuditLogsController : ControllerBase
{
    private readonly IAuditLogService _auditLogService;
    private readonly ICurrentUserService _currentUser;

    public AuditLogsController(
        IAuditLogService auditLogService,
        ICurrentUserService currentUser)
    {
        _auditLogService = auditLogService;
        _currentUser = currentUser;
    }

    [HttpGet("device/{deviceId:guid}")]
    public async Task<IActionResult> GetForDevice(
        Guid deviceId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        CancellationToken ct = default)
    {
        var result = await _auditLogService.GetForDeviceAsync(
            deviceId,
            _currentUser.CompanyId,
            page,
            pageSize,
            ct);
        return Ok(result);
    }
}
```

**Kabul kriteri:**
- `dotnet build` 0 hata
- API başlatıldığında `/api/audit-logs/device/{id}` route'u var
- PowerShell ile test (aşağıda)

**Manuel test (PowerShell):**
```powershell
$deviceId = "3eb9ad6a-0555-4179-a715-bb882e364a22"  # Samsung'un ID'si
$logs = Invoke-RestMethod `
  -Uri "http://localhost:5160/api/audit-logs/device/$deviceId?page=1&pageSize=20" `
  -Headers $headers

Write-Host "Toplam: $($logs.totalCount)"
$logs.items | Select-Object action, entityName, userEmail, timestamp | Format-Table -AutoSize
```

**Commit:** `feat(audit): AuditLogsController + device endpoint`

---

## Bölüm B — Mobile

### Mimari Kararlar (Mobile)

#### B1) Ayrı feature klasörü

```
lib/features/audit/
  ├── providers/
  │     └── audit_log_provider.dart
  ├── widgets/
  │     ├── audit_log_section.dart      (container widget)
  │     ├── audit_log_tile.dart         (tek satır)
  │     └── audit_log_detail_sheet.dart (pop-up)
```

#### B2) 3 nokta menü seçimi

Her `audit_log_tile.dart` satırında sağ tarafta `PopupMenuButton` olacak. Tek seçenek: "Detayları Göster". Tıklanınca `showModalBottomSheet` ile detay açılır.

**Detay pop-up içeriği:**
- Aksiyon özet
- Kullanıcı email + IP
- Tam tarih (gün + saat)
- **Değişiklik varsa:** "Değişen alanlar" listesi, her biri "Field: Eski → Yeni" şeklinde
- **Delete ise:** "Silinen değerler" listesi
- **Create ise:** "Oluşturulan değerler" listesi

#### B3) Aksiyon → Türkçe label mapping

Backend'de Action string'i İngilizce ("Create", "Update", "Delete"). Mobile'da Türkçe'leştireceğiz:

```dart
String _actionLabel(String action, String entityName) {
  final entity = _entityLabel(entityName);
  return switch (action) {
    'Create' => '$entity oluşturuldu',
    'Update' => '$entity güncellendi',
    'Delete' => '$entity silindi',
    _ => '$entity: $action',
  };
}

String _entityLabel(String entityName) => switch (entityName) {
  'Device' => 'Cihaz',
  'Assignment' => 'Zimmet',
  'AssignmentForm' => 'Form',
  _ => entityName,
};
```

#### B4) Aksiyon ikon + renk

```dart
(IconData, Color) _iconColorFor(String action) => switch (action) {
  'Create' => (Icons.add_circle_outline, Colors.green),
  'Update' => (Icons.edit_outlined, Colors.blue),
  'Delete' => (Icons.delete_outline, Colors.red),
  _ => (Icons.history, Colors.grey),
};
```

#### B5) Tarih formatı

Son 24 saat → "2 saat önce" (relative).
24 saat öncesi → "20 Nis, 14:32" (absolute).

`timeago` paketi yoksa basit if-else ile manuel yap.

#### B6) Pagination

İlk yükleme 20 kayıt. Kullanıcı "Daha fazla göster" butonuna basar → sonraki 20. 3+ sayfa için infinite scroll ayrı SPEC. Şimdilik manuel buton.

---

### Mobile Görevleri

#### T6 — AuditLog model

**Yeni dosya:** `lib/data/models/audit_log_model.dart`

**Detaylar:**
```dart
class AuditLog {
  final String id;
  final String action;
  final String entityName;
  final String entityId;
  final String? userEmail;
  final String? ipAddress;
  final DateTime timestamp;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final List<String>? affectedColumns;

  AuditLog({
    required this.id,
    required this.action,
    required this.entityName,
    required this.entityId,
    this.userEmail,
    this.ipAddress,
    required this.timestamp,
    this.oldValues,
    this.newValues,
    this.affectedColumns,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: json['action'] as String,
      entityName: json['entityName'] as String,
      entityId: json['entityId'] as String,
      userEmail: json['userEmail'] as String?,
      ipAddress: json['ipAddress'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      oldValues: json['oldValues'] as Map<String, dynamic>?,
      newValues: json['newValues'] as Map<String, dynamic>?,
      affectedColumns: (json['affectedColumns'] as List?)?.cast<String>(),
    );
  }
}
```

**Commit:** `feat(audit): AuditLog model`

---

#### T7 — AuditLogService (data layer)

**Yeni dosya:** `lib/data/services/audit_log_service.dart`

**Detaylar:**
```dart
class AuditLogService {
  final Dio _dio;

  AuditLogService() : _dio = ApiClient.instance.dio;

  Future<PaginatedResult<AuditLog>> getForDevice(
    String deviceId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.auditLogsForDevice(deviceId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: (data['items'] as List)
          .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }
}
```

**api_constants.dart'a eklenecek:**
```dart
static String auditLogsForDevice(String deviceId) => '/api/audit-logs/device/$deviceId';
```

**Commit:** `feat(audit): AuditLogService + api_constants`

---

#### T8 — AuditLogProvider (Riverpod)

**Yeni dosya:** `lib/features/audit/providers/audit_log_provider.dart`

**Detaylar:**
```dart
final auditLogServiceProvider = Provider((ref) => AuditLogService());

final deviceAuditLogsProvider = FutureProvider.family<
    PaginatedResult<AuditLog>, String>((ref, deviceId) async {
  final service = ref.read(auditLogServiceProvider);
  return service.getForDevice(deviceId, page: 1, pageSize: 20);
});
```

**Commit:** `feat(audit): AuditLogProvider`

---

#### T9 — AuditLogTile widget

**Yeni dosya:** `lib/features/audit/widgets/audit_log_tile.dart`

**Detaylar:**
- ListTile yapısı
- Leading: renkli ikon (aksiyon tipine göre)
- Title: "{Entity} {aksiyon}" (Türkçe)
- Subtitle: userEmail + relative tarih
- Trailing: PopupMenuButton → "Detayları Göster"
- Tıklayınca `showModalBottomSheet` → `AuditLogDetailSheet`

**Commit:** `feat(audit): AuditLogTile widget`

---

#### T10 — AuditLogDetailSheet

**Yeni dosya:** `lib/features/audit/widgets/audit_log_detail_sheet.dart`

**Detaylar:**
- ModalBottomSheet, dynamic height
- Header: Aksiyon başlığı + kapat butonu
- Info rows:
  - Kullanıcı email
  - IP adresi
  - Tam tarih (dd MMM yyyy HH:mm)
  - Entity tipi + ID
- Values section:
  - **Create:** newValues'u list olarak göster
  - **Update:** affectedColumns varsa her field için "Eski → Yeni" satırı
  - **Delete:** oldValues'u list olarak göster
- Sonunda kapat butonu

**Commit:** `feat(audit): AuditLogDetailSheet`

---

#### T11 — AuditLogSection widget

**Yeni dosya:** `lib/features/audit/widgets/audit_log_section.dart`

**Detaylar:**
- ConsumerWidget
- `ref.watch(deviceAuditLogsProvider(deviceId))`
- 3 state:
  - **Loading:** shimmer
  - **Error:** "Yüklenemedi" mesajı + retry butonu
  - **Success:**
    - Kayıt yoksa: "Henüz değişiklik yok" mesajı
    - Varsa: `ListView.separated` + `AuditLogTile`
    - Alt kısımda "Daha fazla" butonu (totalCount > pageSize ise)

**Commit:** `feat(audit): AuditLogSection widget`

---

#### T12 — device_detail_screen'e entegrasyon

**Değişecek dosya:** `lib/features/devices/screens/device_detail_screen.dart`

**Detaylar:**
- Import ekle: `../../audit/widgets/audit_log_section.dart`
- Mevcut "Notlar" section'ının hemen SONRASINDA:

```dart
// Audit Log Section (her zaman görünür)
_SectionCard(
  title: 'Değişiklik Geçmişi',
  icon: Icons.history,
  child: AuditLogSection(deviceId: device.id),
),
```

**Dikkat:** `_SectionCard`'ın child alması gerekiyor. Eğer rows yapısı kullanıyorsa, `AuditLogSection`'ı doğrudan ListView'e ekle.

**Kabul kriteri:**
- `flutter analyze` 0 hata
- Emulator testi (T13'te)

**Commit:** `feat(devices): cihaz detayda audit log section eklendi`

---

#### T13 — Son test

**Detaylar:**

1. `flutter analyze` → 0 hata
2. `dart format lib/features/audit/ lib/features/devices/screens/`

3. **Emulator 3 senaryo:**

**Senaryo A — Yeni cihaz:**
- Yeni bir cihaz ekle
- Cihaz detayına gir
- "Değişiklik Geçmişi" section'ında 1 kayıt: "Cihaz oluşturuldu"
- 3 nokta → Detaylar → Create'de oluşturulan tüm field'lar görünür

**Senaryo B — Zimmetli cihaz (Samsung gibi):**
- Cihaz detayına gir
- En az 2 kayıt:
  - "Cihaz oluşturuldu" (eski)
  - "Zimmet oluşturuldu" (Assignment)
  - Belki "Cihaz güncellendi" (status değişikliği)
- 3 nokta → Detaylar → Update'de affectedColumns ile "Eski → Yeni"

**Senaryo C — İade edilmiş cihaz:**
- İade edilmiş bir cihazın detayına gir
- "Zimmet oluşturuldu" + "Zimmet güncellendi" (ReturnedAt dolduğunda)
- "Form oluşturuldu" (ZF-XXXX üretildi)
- "Form güncellendi" (SignedFilePath dolduğunda upload)

**Kabul kriteri:**
- Section her senaryoda görünür
- Boş cihazda "Henüz değişiklik yok" mesajı (pek olmaz çünkü her cihazda Create log'u var)
- Pop-up açılır, detay doğru
- Türkçe label'lar doğru

**Commit:** (değişiklik varsa) `refactor: final cleanup`

---

## Dokunulmayan Dosyalar (Önemli)

**Backend:**
- `AuditLog.cs` entity — zaten var
- `AppDbContext.cs` — otomatik audit mantığı zaten çalışıyor
- Diğer controller'lar, servisler

**Mobile:**
- `device_model.dart`
- `dashboard/*`
- Diğer audit olmayan feature'lar

---

## Kapsam Dışı

- **Filter seçenekleri** (tarih aralığı, action tipi) — ayrı SPEC
- **Infinite scroll** — şimdilik "Daha fazla" butonu
- **Zimmet detay sayfası** — yok, kapsam dışı
- **Global audit log ekranı** ("Tüm şirket aktivitesi") — ayrı SPEC
- **Audit log export** (PDF/Excel) — ayrı SPEC
- **Real-time updates** (SignalR) — ayrı SPEC

---

## Notlar (Claude Code için)

- **Backend önce, mobile sonra:** T1-T5 (backend) tamamen bitmeden T6-T13 (mobile) başlatma
- **Her görev sonrası:** build/analyze + commit
- **T5 sonrası PowerShell testi zorunlu** — endpoint çalışıyor mu doğrula, sonra mobile'a geç
- **T12'de dikkat:** device_detail_screen'in yapısına bak, `_SectionCard` child alıyor mu yoksa rows mu alıyor — ona göre entegre et
- **Plan mode her görev** — kısa plan çıkar, uygula
- **Hata olursa DUR**, raporla

---

## Özet Beklenen Sonuç

Cihaz detay sayfasının en altında "Değişiklik Geçmişi" bölümü görünür. Bu bölümde:
- Cihaz üzerinde yapılan tüm Create/Update/Delete işlemleri
- Bu cihaza ait zimmetlerin (Assignment) tüm işlemleri
- Bu zimmetlerin formlarının (AssignmentForm) tüm işlemleri

Her satırda aksiyon özeti + kullanıcı + zaman. 3 nokta menüye basınca detay pop-up açılır: kim, ne zaman, ne değiştirdi — eski/yeni değerler görünür.

IT departmanı için tam şeffaflık ve denetim izi.

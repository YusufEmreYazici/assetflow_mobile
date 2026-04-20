# SPEC_007 — Audit Log Değer Zenginleştirme + UI Refactor

**Hedef projeler:**
- Backend: `C:\Workspace\Personal_Projects\ITAssetManager`
- Mobile: `C:\Workspace\Personal_Projects\assetflow_mobile`

**Tip:** Refactor + feature iyileştirme
**Tahmini süre:** 1-1.5 saat
**Bağımlılık:** SPEC_006 tamamlanmış olmalı (backend endpoint + mobile UI mevcut)

---

## Amaç

Audit log'ların insan okunabilir hale getirilmesi:
1. **Backend:** GUID → gerçek ad lookup + enum → Türkçe çeviri + tarih format + gereksiz alan filtreleme
2. **Mobile:** Pop-up yerine ExpansionTile (inline) + temiz diff görünümü

## Bağlam — Mevcut Sorunlar

Şu an cihaz detayında audit log pop-up'ında görünüyor:
```
Id: 49f09342-18ac-4ac6a7-...        (GUID - anlamsız)
AssignedByUserId: 87bc0224-43fc-...  (GUID - anlamsız)
DeviceId: a0489313-a75f-...           (GUID - anlamsız)
EmployeeId: e30ec122-b18f-...         (GUID - anlamsız)
Type: 0                               (enum number - anlamsız)
AssignedAt: 2026-04-12T16:02:02.7326567Z  (ISO - çirkin)
CreatedAt: ... (gereksiz alan)
UpdatedAt: ... (gereksiz alan)
```

Hedef:
```
Zimmet No: ZMT-20260412-0002
Atayan: test@assetflow.com
Cihaz: ASUS Zenbook 14 UX3405CA
Personel: Burak Şahin
Tip: Zimmet
Atama Tarihi: 12 Nis 2026, 16:02
```

---

## Bölüm A — Backend

### Mimari Kararlar (Backend)

#### A1) In-endpoint lookup cache

Service içinde endpoint başlangıcında tüm ID'leri toplayıp **tek seferde** fetch edeceğiz. Tüm endpoint ömrü boyunca Dictionary'de tutacağız.

```csharp
var userIds = new HashSet<string>();
var deviceIds = new HashSet<string>();
var employeeIds = new HashSet<string>();

// Her log'un OldValues ve NewValues'undan ID topla
foreach (var log in logs)
{
    CollectIds(log.OldValues, userIds, deviceIds, employeeIds);
    CollectIds(log.NewValues, userIds, deviceIds, employeeIds);
}

// Tek sorguda çek
var users = await _userRepo.FindAsync(u => userIds.Contains(u.Id.ToString()), ct);
var devices = await _deviceRepo.FindAsync(d => deviceIds.Contains(d.Id.ToString()), ct);
var employees = await _employeeRepo.FindAsync(e => employeeIds.Contains(e.Id.ToString()), ct);

// Dictionary'e çevir
var userDict = users.ToDictionary(u => u.Id.ToString(), u => u.Email);
var deviceDict = devices.ToDictionary(d => d.Id.ToString(), d => d.Name);
var empDict = employees.ToDictionary(e => e.Id.ToString(), e => e.FullName);
```

#### A2) Dönüşüm kuralları

**Hangi alan hangi tipte?** Her entity'deki field isimlerine göre:

```csharp
// Kullanıcı ID'leri (Guid → email veya FullName)
// Bunlar GUID olarak gelir
static readonly HashSet<string> _userIdFields = new()
{
    "AssignedByUserId", "UserId", "CreatedByUserId", 
    "GeneratedByUserId", "SignedUploadedByUserId"
};

// Cihaz ID'leri (Guid → Device.Name)
static readonly HashSet<string> _deviceIdFields = new() { "DeviceId" };

// Personel ID'leri (Guid → Employee.FullName)
static readonly HashSet<string> _employeeIdFields = new() { "EmployeeId" };

// Lokasyon ID'leri (Guid → Location.Name)
static readonly HashSet<string> _locationIdFields = new() { "LocationId" };

// Enum alanları (int → Türkçe string)
// Device.Type, Device.Status, Assignment.Type, Assignment.ReturnCondition, AssignmentForm.Type
static readonly Dictionary<string, Func<int, string>> _enumConverters = new()
{
    ["Type"] = (val) => { /* context'e göre - Device.Type mi Assignment.Type mi? */ },
    ["Status"] = (val) => ConvertDeviceStatus(val),
    ["ReturnCondition"] = (val) => ConvertReturnCondition(val)
};
```

**Önemli not:** `Type` alanı hem `Device.Type` hem de `Assignment.Type` için kullanılıyor. Context lazım — log'un `EntityName`'inden bakılır:

```csharp
if (log.EntityName == "Device" && fieldName == "Type")
    return ConvertDeviceType(intValue);  // 0=Laptop, 1=Desktop, ...
if (log.EntityName == "Assignment" && fieldName == "Type")
    return ConvertAssignmentType(intValue);  // 0=Zimmet, 1=İade
if (log.EntityName == "AssignmentForm" && fieldName == "Type")
    return ConvertFormType(intValue);  // 0=Assignment, 1=Return
```

#### A3) Gizlenecek alanlar

Audit log'da **hiç gösterme** (hem OldValues hem NewValues hem AffectedColumns'tan):

```csharp
static readonly HashSet<string> _hiddenFields = new()
{
    "Id",           // Entity kendi ID'si (zaten log'da EntityId var)
    "CompanyId",    // Multi-tenant, her zaman aynı
    "CreatedAt",    // Otomatik, kullanıcı ilgisi yok
    "UpdatedAt",    // Otomatik
    "DeletedAt",    // Soft delete, teknik
};
```

#### A4) Field display name mapping

Backend'de döneceğimiz alanlar Türkçe label alacak. Yeni DTO field'ı: `FieldDisplayName`. Ama bu **mobile tarafında** daha iyi, değişmez data zaten.

**Karar:** Field name mapping **mobile'da** kalacak (SPEC_006 v2 B8'deki gibi). Backend sadece **değerleri** zenginleştirir.

#### A5) Tarih formatı

Backend DateTime değerlerini **ISO string olarak bırakacak**. Mobile formatlayacak:
```dart
"2026-04-12T16:02:02.7326567Z" → "12 Nis 2026, 16:02"
```

Bu daha esnek — aynı veri farklı context'lerde farklı formatlanabilir.

#### A6) Decimal ve null

- `PurchasePrice: 9800.00` → aynen kalır (sayısal, mobile format edebilir)
- `null` değerler → `null` döner (mobile'da "-" veya "yok" gösterir)

#### A7) DTO değişikliği

`AuditLogResponse`'ta dönüşüm yapılmış olan **aynı `OldValues`/`NewValues`** field'ları olacak — sadece içerik zenginleştirilmiş. Yeni field eklenmeyecek.

Mobile kodu zaten `Map<String, dynamic>` bekliyor, değerler string olacak, sorun yok.

---

### Backend Görevleri

#### T1 — AuditLogEnricher helper service

**Yeni dosya:** `src/AssetFlow.Application/Services/AuditLogs/AuditLogEnricher.cs`

**Detaylar:**

```csharp
public class AuditLogEnricher
{
    private readonly Dictionary<string, string> _userLookup;
    private readonly Dictionary<string, string> _deviceLookup;
    private readonly Dictionary<string, string> _employeeLookup;
    private readonly Dictionary<string, string> _locationLookup;

    private static readonly HashSet<string> _userIdFields = new()
    {
        "AssignedByUserId", "UserId", "CreatedByUserId",
        "GeneratedByUserId", "SignedUploadedByUserId"
    };

    private static readonly HashSet<string> _deviceIdFields = new() { "DeviceId" };
    private static readonly HashSet<string> _employeeIdFields = new() { "EmployeeId" };
    private static readonly HashSet<string> _locationIdFields = new() { "LocationId" };

    private static readonly HashSet<string> _hiddenFields = new()
    {
        "Id", "CompanyId", "CreatedAt", "UpdatedAt", "DeletedAt"
    };

    public AuditLogEnricher(
        Dictionary<string, string> userLookup,
        Dictionary<string, string> deviceLookup,
        Dictionary<string, string> employeeLookup,
        Dictionary<string, string> locationLookup)
    {
        _userLookup = userLookup;
        _deviceLookup = deviceLookup;
        _employeeLookup = employeeLookup;
        _locationLookup = locationLookup;
    }

    public Dictionary<string, object?>? EnrichValues(
        Dictionary<string, object?>? values, 
        string entityName)
    {
        if (values == null) return null;
        
        var result = new Dictionary<string, object?>();
        foreach (var kvp in values)
        {
            if (_hiddenFields.Contains(kvp.Key)) continue;
            
            result[kvp.Key] = ConvertValue(kvp.Key, kvp.Value, entityName);
        }
        return result;
    }

    public List<string>? EnrichAffectedColumns(List<string>? columns)
    {
        if (columns == null) return null;
        return columns.Where(c => !_hiddenFields.Contains(c)).ToList();
    }

    private object? ConvertValue(string fieldName, object? value, string entityName)
    {
        if (value == null) return null;

        // User ID lookup
        if (_userIdFields.Contains(fieldName))
        {
            var id = value.ToString() ?? "";
            return _userLookup.TryGetValue(id, out var name) ? name : id;
        }

        // Device ID lookup
        if (_deviceIdFields.Contains(fieldName))
        {
            var id = value.ToString() ?? "";
            return _deviceLookup.TryGetValue(id, out var name) ? name : id;
        }

        // Employee ID lookup
        if (_employeeIdFields.Contains(fieldName))
        {
            var id = value.ToString() ?? "";
            return _employeeLookup.TryGetValue(id, out var name) ? name : id;
        }

        // Location ID lookup
        if (_locationIdFields.Contains(fieldName))
        {
            var id = value.ToString() ?? "";
            return _locationLookup.TryGetValue(id, out var name) ? name : id;
        }

        // Enum converstion — context'e göre (entityName)
        if (fieldName == "Type" && value is JsonElement je && je.TryGetInt32(out var typeVal))
        {
            return entityName switch
            {
                "Device" => ConvertDeviceType(typeVal),
                "Assignment" => ConvertAssignmentType(typeVal),
                "AssignmentForm" => ConvertFormType(typeVal),
                _ => value
            };
        }

        if (fieldName == "Status" && value is JsonElement sje && sje.TryGetInt32(out var statusVal))
        {
            return entityName == "Device" ? ConvertDeviceStatus(statusVal) : value;
        }

        if (fieldName == "ReturnCondition" && value is JsonElement rje && rje.TryGetInt32(out var condVal))
        {
            return ConvertReturnCondition(condVal);
        }

        return value;
    }

    private static string ConvertDeviceType(int val) => val switch
    {
        0 => "Dizüstü",
        1 => "Masaüstü",
        2 => "Monitör",
        3 => "Yazıcı",
        4 => "Telefon",
        5 => "Tablet",
        6 => "Sunucu",
        7 => "Ağ Cihazı",
        8 => "Diğer",
        _ => val.ToString()
    };

    private static string ConvertDeviceStatus(int val) => val switch
    {
        0 => "Aktif",
        1 => "Depoda",
        2 => "Bakımda",
        3 => "Emekli",
        4 => "Kayıp",
        _ => val.ToString()
    };

    private static string ConvertAssignmentType(int val) => val switch
    {
        0 => "Zimmet",
        1 => "İade",
        _ => val.ToString()
    };

    private static string ConvertFormType(int val) => val switch
    {
        0 => "Zimmet Formu",
        1 => "İade Formu",
        _ => val.ToString()
    };

    private static string ConvertReturnCondition(int val) => val switch
    {
        0 => "İyi",
        1 => "Hasarlı",
        2 => "Arızalı",
        3 => "Kayıp",
        _ => val.ToString()
    };
}
```

**Önemli:** `JsonElement` kontrolü çünkü `JsonSerializer.Deserialize<Dictionary<string, object?>>` değerleri `JsonElement` olarak parse eder, `int` olarak değil.

**Kabul kriteri:**
- `dotnet build` 0 hata

**Commit:** `feat(audit): AuditLogEnricher helper service`

---

#### T2 — AuditLogService güncellemesi

**Değişecek dosya:** `src/AssetFlow.Application/Services/AuditLogs/AuditLogService.cs`

**Detaylar:**

```csharp
public class AuditLogService : IAuditLogService
{
    private readonly IRepository<AuditLog> _auditLogRepo;
    private readonly IRepository<Assignment> _assignmentRepo;
    // YENİ:
    private readonly IRepository<User> _userRepo;
    private readonly IRepository<Device> _deviceRepo;
    private readonly IRepository<Employee> _employeeRepo;
    private readonly IRepository<Location> _locationRepo;

    public AuditLogService(
        IRepository<AuditLog> auditLogRepo,
        IRepository<Assignment> assignmentRepo,
        IRepository<User> userRepo,
        IRepository<Device> deviceRepo,
        IRepository<Employee> employeeRepo,
        IRepository<Location> locationRepo)
    {
        _auditLogRepo = auditLogRepo;
        _assignmentRepo = assignmentRepo;
        _userRepo = userRepo;
        _deviceRepo = deviceRepo;
        _employeeRepo = employeeRepo;
        _locationRepo = locationRepo;
    }

    public async Task<PagedResult<AuditLogResponse>> GetForDeviceAsync(...)
    {
        // ... mevcut kod: log'ları al ...

        // YENİ: ID'leri topla (sayfadaki tüm log'lardan)
        var paged = ordered.Skip(...).Take(...).ToList();
        
        var userIds = new HashSet<string>();
        var deviceIds = new HashSet<string>();
        var employeeIds = new HashSet<string>();
        var locationIds = new HashSet<string>();
        
        foreach (var log in paged)
        {
            CollectIds(log.OldValues, userIds, deviceIds, employeeIds, locationIds);
            CollectIds(log.NewValues, userIds, deviceIds, employeeIds, locationIds);
        }

        // Tek sorguda lookup
        var users = await _userRepo.FindAsync(u => userIds.Contains(u.Id.ToString()), ct);
        var devices = await _deviceRepo.FindAsync(d => deviceIds.Contains(d.Id.ToString()), ct);
        var employees = await _employeeRepo.FindAsync(e => employeeIds.Contains(e.Id.ToString()), ct);
        var locations = await _locationRepo.FindAsync(l => locationIds.Contains(l.Id.ToString()), ct);

        var enricher = new AuditLogEnricher(
            users.ToDictionary(u => u.Id.ToString(), u => u.Email ?? u.FullName ?? "?"),
            devices.ToDictionary(d => d.Id.ToString(), d => d.Name ?? "?"),
            employees.ToDictionary(e => e.Id.ToString(), e => e.FullName ?? "?"),
            locations.ToDictionary(l => l.Id.ToString(), l => l.Name ?? "?")
        );

        var items = paged.Select(log => MapToResponse(log, enricher)).ToList();

        return new PagedResult<AuditLogResponse> { ... };
    }

    private static void CollectIds(
        string? jsonValues,
        HashSet<string> userIds,
        HashSet<string> deviceIds,
        HashSet<string> employeeIds,
        HashSet<string> locationIds)
    {
        if (string.IsNullOrEmpty(jsonValues)) return;
        
        try
        {
            var dict = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(jsonValues);
            if (dict == null) return;

            foreach (var kvp in dict)
            {
                if (kvp.Value.ValueKind != JsonValueKind.String) continue;
                var idStr = kvp.Value.GetString();
                if (string.IsNullOrEmpty(idStr)) continue;

                if (kvp.Key is "AssignedByUserId" or "UserId" or "CreatedByUserId" 
                    or "GeneratedByUserId" or "SignedUploadedByUserId")
                    userIds.Add(idStr);
                else if (kvp.Key == "DeviceId")
                    deviceIds.Add(idStr);
                else if (kvp.Key == "EmployeeId")
                    employeeIds.Add(idStr);
                else if (kvp.Key == "LocationId")
                    locationIds.Add(idStr);
            }
        }
        catch { /* ignore parse errors */ }
    }

    private static AuditLogResponse MapToResponse(AuditLog log, AuditLogEnricher enricher)
    {
        var oldValues = ParseJson(log.OldValues);
        var newValues = ParseJson(log.NewValues);
        var affected = string.IsNullOrEmpty(log.AffectedColumns)
            ? null
            : log.AffectedColumns.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList();

        return new AuditLogResponse
        {
            Id = log.Id,
            Action = log.Action,
            EntityName = log.EntityName,
            EntityId = log.EntityId,
            UserEmail = log.UserEmail,
            IpAddress = log.IpAddress,
            Timestamp = log.Timestamp,
            OldValues = enricher.EnrichValues(oldValues, log.EntityName),
            NewValues = enricher.EnrichValues(newValues, log.EntityName),
            AffectedColumns = enricher.EnrichAffectedColumns(affected)
        };
    }
}
```

**Not:** CollectIds ve MapToResponse değiştirildi, Enricher parametresi alıyor.

**Kabul kriteri:**
- `dotnet build` 0 hata
- PowerShell ile test (T3'te)

**Commit:** `feat(audit): service lookup + enrichment entegrasyonu`

---

#### T3 — Backend test

**Detaylar:**

```powershell
# Token tazele
$loginBody = @{ email = "test@assetflow.com"; password = "Test1234." } | ConvertTo-Json
$resp = Invoke-RestMethod -Uri "http://localhost:5160/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $resp.token
$headers = @{ Authorization = "Bearer $token" }

# Samsung'un log'larini al
$deviceId = "3eb9ad6a-0555-4179-a715-bb882e364a22"
$logs = Invoke-RestMethod -Uri "http://localhost:5160/api/audit-logs/device/$deviceId" -Headers $headers

Write-Host "=== En son Update log ===" -ForegroundColor Cyan
$update = $logs.items | Where-Object { $_.action -eq "Update" -and $_.entityName -eq "Device" } | Select-Object -First 1
$update.newValues | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "=== En son Assignment Create log ===" -ForegroundColor Cyan
$assign = $logs.items | Where-Object { $_.action -eq "Create" -and $_.entityName -eq "Assignment" } | Select-Object -First 1
$assign.newValues | ConvertTo-Json -Depth 3
```

**Beklenen sonuç:**
```json
{
  "AssetTag": "ZMT-20260412-0002",
  "AssignedAt": "2026-04-12T16:02:02Z",
  "AssignedByUserId": "test@assetflow.com",     // ✅ email oldu
  "DeviceId": "ASUS Zenbook 14 UX3405CA",       // ✅ device name oldu
  "EmployeeId": "Burak Sahin",                  // ✅ employee name oldu
  "Notes": "Geici verildi",
  "Type": "Zimmet"                               // ✅ enum çevrildi
}

// Gizli alanlar YOK: Id, CreatedAt, UpdatedAt, CompanyId
```

**Kabul kriteri:**
- Tüm GUID alanları ad/email'e dönmüş
- Type, Status, ReturnCondition Türkçe string
- Id, CreatedAt, UpdatedAt, CompanyId yok

**Commit:** (değişiklik varsa) T2'de yakalanmayan hatalar

---

## Bölüm B — Mobile Refactor

### Mimari Kararlar (Mobile)

#### B1) Pop-up SİL → ExpansionTile

`audit_log_detail_sheet.dart` silinecek. `audit_log_tile.dart` **ExpansionTile** olacak.

#### B2) Detay var mı kontrolü

```dart
bool get hasDetails {
  if (action == 'Create' && newValues != null && newValues!.isNotEmpty) return true;
  if (action == 'Delete' && oldValues != null && oldValues!.isNotEmpty) return true;
  if (action == 'Update' && affectedColumns != null && affectedColumns!.isNotEmpty) return true;
  return false;
}
```

Detay yoksa `ExpansionTile` yerine düz `ListTile` göster (chevron görünmesin).

#### B3) Field display name mapping

SPEC_006 v2 B8'deki mapping korunur. Ek olarak yeni field'lar:
```dart
'AssignedByUserId' => 'Atayan',
'UserId' => 'Kullanıcı',
'CreatedByUserId' => 'Oluşturan',
'GeneratedByUserId' => 'Form Üreten',
'SignedUploadedByUserId' => 'İmza Yükleyen',
'GeneratedFilePath' => 'Form Dosyası',
'SignedFilePath' => 'İmzalı Dosya',
'FormNumber' => 'Form No',
'AssignmentId' => 'Zimmet',
```

#### B4) Değer formatlama (mobile)

Backend'den gelen değerler zaten enriched, ama bazı mobile formatlamaları:

```dart
String _formatValue(dynamic value) {
  if (value == null) return '-';
  
  // DateTime string (ISO format)
  if (value is String && _isIsoDate(value)) {
    final dt = DateTime.parse(value).toLocal();
    return DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(dt);
  }
  
  // Number (fiyat vb.)
  if (value is num) return value.toString();
  
  // Boolean
  if (value is bool) return value ? 'Evet' : 'Hayır';
  
  return value.toString();
}

bool _isIsoDate(String s) {
  return RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(s);
}
```

#### B5) Diff görünümü (Update için)

```
[Ad]      Eski → Yeni
          ↑red    ↑green

Örnek:
[Durum]   Aktif → Depoda
[İşlemci] i5-1240U → i7-1355U
```

---

### Mobile Görevleri

#### T4 — audit_log_detail_sheet.dart SİL

**Silinecek dosya:** `lib/features/audit/widgets/audit_log_detail_sheet.dart`

**Ek iş:** `audit_log_tile.dart`'ta import varsa kaldır.

**Commit:** `refactor(audit): detail sheet silindi, inline'a geciliyor`

---

#### T5 — audit_log_tile.dart → ExpansionTile

**Değişecek dosya:** `lib/features/audit/widgets/audit_log_tile.dart`

**Detaylar:**

```dart
class AuditLogTile extends StatelessWidget {
  final AuditLog log;
  const AuditLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconColorFor(log.action);
    
    // Detay yoksa düz ListTile
    if (!log.hasDetails) {
      return ListTile(
        leading: _buildIcon(icon, color),
        title: Text(
          _actionLabel(log.action, log.entityName),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${log.userEmail ?? 'Bilinmiyor'} · ${_relativeTime(log.timestamp)}',
          style: const TextStyle(fontSize: 12),
        ),
      );
    }

    // Detay varsa ExpansionTile
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: _buildIcon(icon, color),
        title: Text(
          _actionLabel(log.action, log.entityName),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${log.userEmail ?? 'Bilinmiyor'} · ${_relativeTime(log.timestamp)}',
          style: const TextStyle(fontSize: 12),
        ),
        children: _buildDetailRows(),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      );

  List<Widget> _buildDetailRows() {
    if (log.action == 'Update' && log.affectedColumns != null) {
      return log.affectedColumns!.map((field) {
        final oldVal = _formatValue(log.oldValues?[field]);
        final newVal = _formatValue(log.newValues?[field]);
        return _buildDiffRow(_fieldLabel(field), oldVal, newVal);
      }).toList();
    }

    if (log.action == 'Create' && log.newValues != null) {
      return log.newValues!.entries
          .map((e) => _buildValueRow(_fieldLabel(e.key), _formatValue(e.value)))
          .toList();
    }

    if (log.action == 'Delete' && log.oldValues != null) {
      return log.oldValues!.entries
          .map((e) => _buildValueRow(_fieldLabel(e.key), _formatValue(e.value)))
          .toList();
    }

    return const [];
  }

  Widget _buildDiffRow(String label, String oldVal, String newVal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  oldVal,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade300,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                ),
                Text(
                  newVal,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Helper methods
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
    _ => entityName,
  };

  (IconData, Color) _iconColorFor(String action) => switch (action) {
    'Create' => (Icons.add_circle_outline, Colors.green),
    'Update' => (Icons.edit_outlined, Colors.blue),
    'Delete' => (Icons.delete_outline, Colors.red),
    _ => (Icons.history, Colors.grey),
  };

  String _relativeTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM, HH:mm', 'tr_TR').format(t);
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is String && RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(value)) {
      try {
        return DateFormat('d MMM yyyy, HH:mm', 'tr_TR')
            .format(DateTime.parse(value).toLocal());
      } catch (_) {
        return value;
      }
    }
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Evet' : 'Hayır';
    return value.toString();
  }

  String _fieldLabel(String field) => switch (field) {
    'Name' => 'Ad',
    'Brand' => 'Marka',
    'Model' => 'Model',
    'SerialNumber' => 'Seri No',
    'AssetCode' => 'Demirbaş Kodu',
    'Status' => 'Durum',
    'Type' => 'Tip',
    'Notes' => 'Notlar',
    'PurchaseDate' => 'Satın Alma Tarihi',
    'PurchasePrice' => 'Satın Alma Fiyatı',
    'Supplier' => 'Tedarikçi',
    'WarrantyEndDate' => 'Garanti Bitiş',
    'WarrantyDurationMonths' => 'Garanti (Ay)',
    'LocationId' => 'Lokasyon',
    'CpuInfo' => 'İşlemci',
    'RamInfo' => 'RAM',
    'StorageInfo' => 'Depolama',
    'GpuInfo' => 'Ekran Kartı',
    'HostName' => 'Hostname',
    'OsInfo' => 'İşletim Sistemi',
    'MacAddress' => 'MAC Adresi',
    'IpAddress' => 'IP Adresi',
    'BiosVersion' => 'BIOS',
    'MotherboardInfo' => 'Anakart',
    'AssignedAt' => 'Atama Tarihi',
    'ReturnedAt' => 'İade Tarihi',
    'ReturnCondition' => 'İade Durumu',
    'ReturnNotes' => 'İade Notları',
    'EmployeeId' => 'Personel',
    'DeviceId' => 'Cihaz',
    'AssetTag' => 'Zimmet No',
    'ExpectedReturnDate' => 'Beklenen İade',
    'AssignedByUserId' => 'Atayan',
    'UserId' => 'Kullanıcı',
    'CreatedByUserId' => 'Oluşturan',
    'GeneratedByUserId' => 'Form Üreten',
    'SignedUploadedByUserId' => 'İmza Yükleyen',
    'GeneratedFilePath' => 'Form Dosyası',
    'SignedFilePath' => 'İmzalı Dosya',
    'FormNumber' => 'Form No',
    'AssignmentId' => 'Zimmet',
    _ => field,
  };
}
```

**Kabul kriteri:**
- `flutter analyze` 0 hata
- Detail sheet referansı kalmamış

**Commit:** `refactor(audit): ExpansionTile + zenginlestirilmis deger formatlamasi`

---

#### T6 — Emulator testi

**Detaylar:**

1. `flutter analyze` → 0 hata
2. `dart format lib/features/audit/`

3. **Emulator hot restart**, sonra 4 senaryo:

**Senaryo A — Samsung (Update log):**
- Samsung detay → Değişiklik Geçmişi
- "Cihaz güncellendi" satırı → tıkla → expand
- Sadece "Ad: Samsung S27A600N 27inch → Samsung S27A600N Test" görünmeli (ya da ne değiştiğin bağlı)
- Eski değer kırmızı üstü çizili, yeni değer yeşil

**Senaryo B — Samsung (Zimmet Create log):**
- "Zimmet oluşturuldu" satırı → tıkla → expand
- **Atayan:** test@assetflow.com (GUID DEĞİL)
- **Cihaz:** Samsung S27A600N
- **Personel:** Burak Şahin (GUID DEĞİL)
- **Tip:** Zimmet (0 DEĞİL)
- **Zimmet No:** ZMT-...
- Id, CreatedAt, UpdatedAt **yok**

**Senaryo C — Yeni cihaz:**
- Yeni bir Laptop ekle
- Detayına gir → "Cihaz oluşturuldu" satırı → expand
- Tüm doldurduğun alanlar Türkçe ile görünmeli
- Type: Dizüstü (0 DEĞİL)
- Status: Aktif (0 DEĞİL)

**Senaryo D — Detay yok durumu:**
- Eğer bir log'un detayı yoksa (boş), expansion chevron görünmemeli
- Pratikte her log'un detayı var, bu senaryo simüle etmek zor. Pas geç.

**Kabul kriteri:**
- Tüm senaryolarda GUID yok
- Enum değerler Türkçe
- Tarihler Türkçe format
- Gereksiz alanlar (Id, CreatedAt vb.) gizli
- Update'de sadece gerçekten değişen alan + diff görünüyor

**Commit:** (değişiklik varsa) `refactor: cleanup`

---

## Dokunulmayan Dosyalar

**Backend:**
- `AuditLog.cs`, `AppDbContext.cs` — dokunulmadı
- `AuditLogsController.cs` — dokunulmadı
- Diğer servisler

**Mobile:**
- `audit_log_model.dart`, `audit_log_service.dart`, `audit_log_provider.dart`, `audit_log_section.dart`
- `api_constants.dart`
- `device_detail_screen.dart`

---

## Kapsam Dışı

- **Başka entity'ler için audit log UI** — şu an sadece Device detay sayfasında
- **Filter UI** (tarih/action) — ayrı SPEC
- **Export** — ayrı SPEC
- **User FullName vs Email seçimi** — şimdilik Email (daha kısa, net)
- **Avatar göstermek** — kullanıcı icon'u yerine avatar — ayrı iş

---

## Notlar (Claude Code için)

- **Backend önce tamamen bitsin** (T1-T3), mobile'a geç (T4-T6)
- **Her görev sonrası:** build/analyze + commit
- **T2'de JsonElement'e dikkat** — `JsonSerializer.Deserialize<Dictionary<string, object?>>` değerleri `JsonElement` olarak gelir, int olarak değil
- **T3 sonrası PowerShell testi zorunlu** — GUID'ler çevrildi mi, enum'lar Türkçe mi doğrula
- **T4'te dosya silmeden önce** diğer dosyalarda import'unu kontrol et
- **intl paketi import gerekli olabilir** T5'te — pubspec'te var mı kontrol et, `DateFormat` için
- **Plan mode her görev** — özellikle T1 ve T2 büyük, kısa plan çıkar, onayla, uygula
- **Hata olursa DUR**, raporla

---

## Özet Beklenen Sonuç

**Öncesi (ekran görüntüsünden):**
```
Id: 49f09342-18ac-ac6a7-...
AssignedByUserId: 87bc0224-...
DeviceId: a0489313-a75f-...
EmployeeId: e30ec122-...
Type: 0
AssignedAt: 2026-04-12T16:02:02.7326567Z
CreatedAt: 2026-04-12T...
UpdatedAt: 2026-04-12T...
```

**Sonrası:**
```
[ExpansionTile açık]
├── Zimmet No:       ZMT-20260412-0002
├── Atayan:          test@assetflow.com
├── Atama Tarihi:    12 Nis 2026, 16:02
├── Cihaz:           ASUS Zenbook 14
├── Personel:        Burak Şahin
├── Notlar:          Geici verildi
└── Tip:             Zimmet
```

Temiz, anlaşılır, IT yöneticisi için anlamlı.

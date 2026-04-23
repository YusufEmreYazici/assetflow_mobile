# AssetFlow Bug Fix — Critical User Experience Fixes

**Tarih:** 24 Nisan 2026
**Öncelik:** YÜKSEK — kullanıcı deneyimini ciddi bozuyor
**Version:** 2.3.0 → 2.3.1 (patch)
**Tahmini Süre:** 2-3 saat

---

## 📋 5 KRİTİK SORUN

1. 🔔 Bildirimler her login'de SIFIRLANIYOR (okunmuş durumu kaybolur)
2. 🔔 Bildirime tıkla → beyaz ekran (yönlendirme çalışmıyor)
3. 🌓 Dark mode yarım çalışıyor → **KOMPLE KALDIR**
4. 📊 Dashboard "Aktivite Akışı" tıklanamaz → tıklanabilir yap
5. 🧭 Bottom nav "Cihazlar" / "Personel" butonları çalışmıyor

---

## 🐛 FIX 1: Bildirim Persistence — Database'e Taşı

### Sorun Analizi

Şu an bildirimler **SharedPreferences** veya **in-memory** tutuluyor. Kullanıcı logout/login yapınca state kayboluyor, tüm bildirimler tekrar "okunmamış" görünüyor.

### Çözüm — Backend + Database

Bildirim state'i **backend'de, kullanıcı bazlı** tutulmalı.

**Backend tarafı:**

#### Notification tablosu (yoksa ekle)

`src/AssetFlow.Domain/Entities/Notification.cs`:

```csharp
public class Notification : BaseEntity
{
    public string UserId { get; set; }      // kimin bildirimi
    public string CompanyId { get; set; }   // hangi şirket
    public string Type { get; set; }        // warranty, assignment, return, system, audit
    public string Title { get; set; }
    public string Message { get; set; }
    public string? RelatedEntityType { get; set; }  // Device, Assignment, etc.
    public string? RelatedEntityId { get; set; }
    public bool IsRead { get; set; } = false;
    public DateTime? ReadAt { get; set; }
    public string Severity { get; set; }    // info, warning, critical
}
```

**Migration:**
```bash
cd src/AssetFlow.Infrastructure
dotnet ef migrations add AddNotifications --startup-project ../AssetFlow.API
dotnet ef database update --startup-project ../AssetFlow.API
```

#### NotificationsController

`src/AssetFlow.API/Controllers/NotificationsController.cs`:

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _service;

    public NotificationsController(INotificationService service)
    {
        _service = service;
    }

    /// <summary>
    /// Kullanıcının tüm bildirimlerini getir (okunmuş + okunmamış)
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = User.FindFirst("sub")?.Value 
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var items = await _service.GetForUserAsync(userId);
        return Ok(items);
    }

    /// <summary>
    /// Bir bildirimi okundu işaretle
    /// </summary>
    [HttpPatch("{id}/read")]
    public async Task<IActionResult> MarkAsRead(string id)
    {
        var userId = User.FindFirst("sub")?.Value 
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        await _service.MarkAsReadAsync(id, userId);
        return NoContent();
    }

    /// <summary>
    /// Tümünü okundu işaretle
    /// </summary>
    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = User.FindFirst("sub")?.Value 
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        await _service.MarkAllAsReadAsync(userId);
        return NoContent();
    }

    /// <summary>
    /// Bildirimi sil
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        var userId = User.FindFirst("sub")?.Value 
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        await _service.DeleteAsync(id, userId);
        return NoContent();
    }

    /// <summary>
    /// Okunmamış sayısı (badge için)
    /// </summary>
    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var userId = User.FindFirst("sub")?.Value 
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var count = await _service.GetUnreadCountAsync(userId);
        return Ok(new { count });
    }
}
```

#### NotificationService

`src/AssetFlow.Application/Services/NotificationService.cs`:

```csharp
public interface INotificationService
{
    Task<List<Notification>> GetForUserAsync(string userId);
    Task MarkAsReadAsync(string notificationId, string userId);
    Task MarkAllAsReadAsync(string userId);
    Task DeleteAsync(string notificationId, string userId);
    Task<int> GetUnreadCountAsync(string userId);
    Task CreateAsync(string userId, string type, string title, string message, 
        string? relatedEntityType = null, string? relatedEntityId = null, 
        string severity = "info");
}

public class NotificationService : INotificationService
{
    private readonly IApplicationDbContext _db;

    public NotificationService(IApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<List<Notification>> GetForUserAsync(string userId)
    {
        return await _db.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(100)  // Son 100
            .ToListAsync();
    }

    public async Task MarkAsReadAsync(string notificationId, string userId)
    {
        var n = await _db.Notifications
            .FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId);
        if (n != null && !n.IsRead)
        {
            n.IsRead = true;
            n.ReadAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsReadAsync(string userId)
    {
        var unread = await _db.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync();
        
        foreach (var n in unread)
        {
            n.IsRead = true;
            n.ReadAt = DateTime.UtcNow;
        }
        await _db.SaveChangesAsync();
    }

    public async Task DeleteAsync(string notificationId, string userId)
    {
        var n = await _db.Notifications
            .FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId);
        if (n != null)
        {
            _db.Notifications.Remove(n);
            await _db.SaveChangesAsync();
        }
    }

    public async Task<int> GetUnreadCountAsync(string userId)
    {
        return await _db.Notifications
            .CountAsync(n => n.UserId == userId && !n.IsRead);
    }

    public async Task CreateAsync(string userId, string type, string title, 
        string message, string? relatedEntityType = null, string? relatedEntityId = null, 
        string severity = "info")
    {
        _db.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid().ToString(),
            UserId = userId,
            Type = type,
            Title = title,
            Message = message,
            RelatedEntityType = relatedEntityType,
            RelatedEntityId = relatedEntityId,
            Severity = severity,
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
        });
        await _db.SaveChangesAsync();
    }
}
```

**DI kayıt** `Program.cs`:
```csharp
services.AddScoped<INotificationService, NotificationService>();
```

### Mobile Tarafı

#### ApiConstants'a ekle

`lib/core/constants/api_constants.dart`:

```dart
// Notifications
static const String notifications = '/api/notifications';
static String notificationMarkRead(String id) => '/api/notifications/$id/read';
static const String notificationsMarkAllRead = '/api/notifications/read-all';
static String notificationDelete(String id) => '/api/notifications/$id';
static const String notificationsUnreadCount = '/api/notifications/unread-count';
```

#### NotificationProvider güncelle

`lib/features/notifications/providers/notification_provider.dart`:

**ÖNCE:** SharedPreferences'tan okuyordu  
**SONRA:** API'dan çekmeli

```dart
class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final ApiClient _api;

  NotificationNotifier(this._api) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final response = await _api.get(ApiConstants.notifications);
      final items = (response.data as List)
          .map((j) => NotificationItem.fromJson(j))
          .toList();
      if (!mounted) return;
      state = AsyncValue.data(items);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.patch(ApiConstants.notificationMarkRead(id));
      // Local state güncelle (optimistic)
      state.whenData((items) {
        final updated = items.map((n) {
          if (n.id == id) return n.copyWith(isRead: true);
          return n;
        }).toList();
        if (mounted) state = AsyncValue.data(updated);
      });
    } catch (e) {
      debugPrint('markAsRead failed: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post(ApiConstants.notificationsMarkAllRead);
      state.whenData((items) {
        final updated = items.map((n) => n.copyWith(isRead: true)).toList();
        if (mounted) state = AsyncValue.data(updated);
      });
    } catch (e) {
      debugPrint('markAllAsRead failed: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _api.delete(ApiConstants.notificationDelete(id));
      state.whenData((items) {
        final filtered = items.where((n) => n.id != id).toList();
        if (mounted) state = AsyncValue.data(filtered);
      });
    } catch (e) {
      debugPrint('delete failed: $e');
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, 
    AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationNotifier(ApiClient.instance);
});

// Unread count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).when(
    data: (items) => items.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
```

#### SharedPreferences notification cache'ini SİL

Artık local'de tutmuyoruz. Aşağıdaki kodu SİL:

```dart
// BUNLAR SİLİNECEK:
// - _saveToLocal()
// - _loadFromLocal()
// - SharedPreferences.getInstance() ile notification_state keys
```

**Offline cache kalabilir** (Hive'da notification cache var) ama state değil sadece görüntüleme için son çekilen veri.

### Test

1. Login yap
2. Birkaç bildirimi okundu işaretle
3. Logout yap
4. Tekrar aynı kullanıcıyla login yap
5. Bildirimler **hala okunmuş olmalı** ✅

**Commit:** `fix(notifications): persist read state to backend database, not SharedPreferences`

---

## 🐛 FIX 2: Bildirim Navigation — Beyaz Ekran Sorunu

### Sorun

Bildirime tıklayınca boş bir route açılıyor, beyaz ekran kalıyor.

### Çözüm

Bildirim tipine göre doğru ekrana yönlendir.

**Dosya:** `lib/features/notifications/notifications_screen.dart`

```dart
void _handleNotificationTap(NotificationItem notification) async {
  if (_isNavigating) return;  // double-tap guard
  _isNavigating = true;

  try {
    // 1) Okunmamışsa ilk tık = sadece okundu işaretle
    if (!notification.isRead) {
      HapticService.light();
      await ref.read(notificationProvider.notifier).markAsRead(notification.id);
      _isNavigating = false;
      return;
    }

    // 2) Okunmuş + tekrar tık = ilgili ekrana git
    HapticService.medium();

    // 3) State rebuild bekle
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // 4) relatedEntityId yoksa navigate etme
    if (notification.relatedEntityId == null || 
        notification.relatedEntityId!.isEmpty) {
      // İlgili kayıt yok, snackbar göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notification.type == 'system' 
              ? 'Sistem bildirimi, detay sayfası yok.'
              : 'Bu bildirime bağlı bir kayıt bulunamadı.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 5) Type'a göre route
    String? targetRoute;
    Map<String, dynamic>? extra;

    switch (notification.type) {
      case 'warranty':
      case 'assignment_created':
      case 'device_status_changed':
        targetRoute = '/device/${notification.relatedEntityId}';
        break;
      
      case 'return':
      case 'assignment_ended':
        targetRoute = '/assignment/${notification.relatedEntityId}';
        break;
      
      case 'audit':
        targetRoute = '/audit-log';
        break;
      
      case 'employee_added':
      case 'employee_updated':
        targetRoute = '/person/${notification.relatedEntityId}';
        break;
      
      case 'location_changed':
        targetRoute = '/location/${notification.relatedEntityId}';
        break;
      
      case 'system':
        targetRoute = '/settings';
        break;
      
      default:
        // Bilinmeyen type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bu bildirim tipi için detay sayfası yok.')),
        );
        return;
    }

    // 6) Route var mı kontrol et ve navigate
    try {
      context.push(targetRoute);
    } catch (e) {
      debugPrint('Notification navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ekran açılamadı: ${notification.type}'),
          ),
        );
      }
    }
  } catch (e, stack) {
    debugPrint('Notification tap error: $e\n$stack');
  } finally {
    if (mounted) _isNavigating = false;
  }
}
```

**ÖNEMLİ kontrol:** Router tanımlarında şu rotalar var mı:
- `/device/:id` ✅ (muhtemelen var)
- `/assignment/:id` ⚠️ (kontrol et, yoksa ekle)
- `/person/:id` ✅
- `/location/:id` ⚠️ (kontrol et)
- `/audit-log` ✅
- `/settings` ✅

Eksik olanları `app_router.dart`'a ekle.

**Commit:** `fix(notifications): proper navigation routing, no more white screen`

---

## 🐛 FIX 3: Dark Mode KOMPLE KALDIR

Kanka dark mode yarım kaldı, komple kaldıralım. Uygulama **sadece light theme** olacak.

### Adım 1: ThemeProvider'ı Kaldır

**Dosya:** `lib/core/theme/theme_provider.dart` → **SİL**

### Adım 2: main.dart Güncelle

```dart
@override
Widget build(BuildContext context) {
  final router = ref.watch(routerProvider);
  // final themeMode = ref.watch(themeProvider);  // ← SİL
  final locale = ref.watch(localeProvider);

  return MaterialApp.router(
    title: 'AssetFlow',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,  // ← SADECE LIGHT
    // darkTheme: AppTheme.darkTheme,  // ← SİL
    // themeMode: toFlutterThemeMode(themeMode),  // ← SİL
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('tr'),
      Locale('en'),
    ],
    routerConfig: router,
  );
}
```

### Adım 3: app_theme.dart — darkTheme Kaldır

```dart
class AppTheme {
  static ThemeData get lightTheme { ... }
  
  // static ThemeData get darkTheme { ... }  // ← TAMAMEN SİL
}
```

### Adım 4: AppColors — Dark Renkleri Kaldır

**Dosya:** `lib/core/theme/app_colors.dart`

Tüm `darkXxx` prefix'li renkleri sil:
- `darkNavy`, `darkNavyDark`, `darkNavyLight`
- `darkSurfaceLight`, `darkSurfaceWhite`, `darkSurfaceDivider`
- `darkTextPrimary`, `darkTextSecondary`, `darkTextTertiary`
- `darkSuccess`, `darkWarning`, `darkError`, `darkInfo`
- Ve helper fonksiyonlar: `surface(context)`, `background(context)` vs. (dark'a bakıyorduysa)

### Adım 5: Settings Ekranından Dark Mode Toggle'ı Kaldır

**Dosya:** `lib/features/profile/settings_screen.dart`

"Görünüm" bölümünü tamamen sil:
```dart
// BUNLARI SİL:
// - "GÖRÜNÜM" section header
// - Açık/Koyu/Sistem Radio'lar
// - Tema ile ilgili her şey
```

**Ama "Titreşim" toggle'ını KORU** — o ayrı bir şey.

### Adım 6: Hardcoded Renkleri Temizle

`Theme.of(context).brightness == Brightness.dark` gibi conditional check varsa, onları da sil:

```dart
// BÖYLE BIR ŞEY VARSA SİL:
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? Colors.white : Colors.black,

// SADECE LIGHT KOD BIRAK:
color: Colors.black,
```

### Adım 7: i18n'den Dark Mode String'lerini Kaldır

`lib/l10n/app_tr.arb` ve `app_en.arb`:
- `settingsTheme` → sil
- `settingsThemeLight` → sil
- `settingsThemeDark` → sil
- `settingsThemeSystem` → sil

### Adım 8: pubspec.yaml versionu artır
```yaml
version: 2.3.1+26
```

### Test

- Uygulamayı aç → light theme
- Settings → "Görünüm" bölümü **YOK**
- Titreşim toggle var ✅
- Hiçbir ekran beyaz arka planda siyah kutu göstermiyor ✅

**Commit:** `refactor: remove dark mode entirely, light theme only`

---

## 🐛 FIX 4: Dashboard Aktivite Akışı Tıklanabilir

### Sorun

Dashboard'daki "Aktivite Akışı" satırları sadece görüntü, tıklanınca bir şey olmuyor.

### Çözüm

Her aktivite satırını `GestureDetector` ile sarıp, ilgili ekrana yönlendir.

**Dosya:** `lib/features/dashboard/widgets/activity_feed.dart` (veya benzeri)

Activity item modelinde **navigate info** var mı bak. Yoksa ekle:

```dart
class ActivityItem {
  final String id;
  final String type;  // assignment_created, device_added, return, warranty_warning
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? relatedEntityType;  // Device, Assignment, Employee
  final String? relatedEntityId;
  // ...
}
```

Backend'de de `GET /api/dashboard/activity` endpoint'i relatedEntityId dönüyor mu kontrol et. Dönmüyorsa ekle.

**Activity tile widget güncelle:**

```dart
class ActivityTile extends ConsumerWidget {
  final ActivityItem activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _getColorForType(activity.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIconForType(activity.type), 
                color: _getColorForType(activity.type), size: 18),
            ),
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, 
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(activity.subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            // Timestamp + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(activity.timestamp),
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                if (activity.relatedEntityId != null)
                  Icon(Icons.chevron_right, size: 16, 
                    color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticService.light();
    
    if (activity.relatedEntityId == null || activity.relatedEntityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu etkinliğin detay sayfası yok.')),
      );
      return;
    }

    try {
      switch (activity.relatedEntityType) {
        case 'Device':
          context.push('/device/${activity.relatedEntityId}');
          break;
        case 'Assignment':
          context.push('/assignment/${activity.relatedEntityId}');
          break;
        case 'Employee':
          context.push('/person/${activity.relatedEntityId}');
          break;
        case 'Location':
          context.push('/location/${activity.relatedEntityId}');
          break;
        case 'AuditLog':
          context.push('/audit-log');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bilinmeyen etkinlik tipi.')),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ekran açılamadı: ${e.toString()}')),
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'assignment_created': return Icons.assignment;
      case 'device_added': return Icons.add_circle_outline;
      case 'device_updated': return Icons.edit;
      case 'device_deleted': return Icons.delete_outline;
      case 'return': return Icons.assignment_return;
      case 'warranty_warning': return Icons.warning_amber;
      case 'status_changed': return Icons.swap_horiz;
      default: return Icons.info_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'warranty_warning': return AppColors.warning;
      case 'device_deleted': return AppColors.error;
      case 'assignment_created':
      case 'device_added': return AppColors.success;
      case 'return': return AppColors.info;
      default: return AppColors.navy;
    }
  }
}
```

### Backend: Activity endpoint relatedEntity dönüyor mu?

`GET /api/dashboard/activity` response kontrol et:

```json
[
  {
    "id": "...",
    "type": "assignment_created",
    "title": "Yeni zimmet oluşturuldu",
    "subtitle": "Samsung S27 → Ayşe Yılmaz",
    "timestamp": "2026-04-24T10:30:00Z",
    "relatedEntityType": "Assignment",
    "relatedEntityId": "zmt-12345"
  }
]
```

Yoksa `DashboardService.GetActivityAsync()`'da dön:

```csharp
public async Task<List<ActivityDto>> GetActivityAsync(string companyId, int take = 20)
{
    var auditLogs = await _db.AuditLogs
        .Where(a => a.CompanyId == companyId)
        .OrderByDescending(a => a.CreatedAt)
        .Take(take)
        .Select(a => new ActivityDto
        {
            Id = a.Id,
            Type = MapAuditActionToType(a.Action),
            Title = GenerateTitle(a),
            Subtitle = a.Detail,
            Timestamp = a.CreatedAt,
            RelatedEntityType = a.EntityType,   // ← BU
            RelatedEntityId = a.EntityId,       // ← BU
        })
        .ToListAsync();
    
    return auditLogs;
}
```

**Commit:** `feat(dashboard): make activity feed items tappable, navigate to related entity`

---

## 🐛 FIX 5: Bottom Nav "Cihazlar" / "Personel" Çalışmıyor

### Sorun

İlk giriş sonrası Cihazlar/Personel tab'ları açılıyor. Ama bir ekrana (cihaz detay, form vs) girip geri döndükten sonra bottom nav'daki butonlar **ana sayfaya** yönlendiriyor.

### Kök Neden — GoRouter Navigation Stack

Bu **GoRouter + StatefulShellRoute** ile ilgili yaygın bir bug. Olan şey:

```
1. Login → /shell (bottom nav ile 4 tab)
2. Cihazlar tab'ına bas → /shell/devices  ✅ açılır
3. Bir cihaza tıkla → /device/123 (push)
4. Geri bas → /shell/devices ✅
5. Tekrar Cihazlar tab'ına bas → /shell (ana sayfa) ❌
```

**Neden?** GoRouter `context.go()` ile yönlendirme navigation stack'i **resetliyor**. Veya bottom nav handler `Navigator.pop()` yerine `go('/shell')` kullanıyor.

### Çözüm

**Dosya:** `lib/core/navigation/app_shell.dart` veya `shell_screen.dart`

Bottom nav'ın **doğru şekilde** çalışması için **StatefulShellRoute** pattern'ı kullan:

```dart
// lib/app_router.dart

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    
    // Bottom nav ile 4 tab - StatefulShellRoute!
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Anasayfa
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ],
        ),
        // Branch 2: Cihazlar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/devices',
              builder: (_, __) => const DevicesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => DeviceDetailScreen(
                    deviceId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branch 3: Personel
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/people',
              builder: (_, __) => const PersonListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (_, state) => PersonDetailScreen(
                    personId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branch 4: Daha Fazla (drawer yerine, ama şu an drawer kullanıyoruz)
        // Bu branch opsiyonel - eğer drawer kullanıyorsan gerek yok
      ],
    ),
    
    // Shell dışı route'lar (detay, form vs ama yukarıda tanımlı olanlar branch altında)
    GoRoute(path: '/assignment/:id', builder: ...),
    GoRoute(path: '/location/:id', builder: ...),
    // vs...
  ],
);
```

**AppShell widget:**

```dart
// lib/core/navigation/app_shell.dart

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      body: navigationShell,  // ← Seçili branch'in içeriği
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          HapticService.light();
          navigationShell.goBranch(
            index,
            // Aynı tab'a tekrar bas = stack'i başa resetle
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer_outlined),
            activeIcon: Icon(Icons.computer),
            label: 'Cihazlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Personel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Daha Fazla',
          ),
        ],
      ),
    );
  }
}
```

**KRİTİK:** `bottomNavigationBar`'daki 4. buton "Daha Fazla" drawer açmalı, branch değiştirmemeli:

```dart
onTap: (index) {
  HapticService.light();
  
  if (index == 3) {
    // Daha Fazla = drawer aç
    Scaffold.of(context).openEndDrawer();
    return;
  }
  
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
},
```

### Alternatif Basit Çözüm (StatefulShellRoute yoksa)

Eğer StatefulShellRoute refactor etmek istemiyorsan (daha büyük değişiklik), **basit fix**:

```dart
// AppShell içinde bottom nav handler:
onTap: (index) {
  HapticService.light();
  
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;
    case 1:
      context.go('/devices');
      break;
    case 2:
      context.go('/people');
      break;
    case 3:
      Scaffold.of(context).openEndDrawer();
      break;
  }
},
```

**ÖNEMLİ:** `context.push()` değil, `context.go()` kullan. Push stack ekler, go replace eder.

**Ve router'da** `/dashboard`, `/devices`, `/people` rotalarının **aynı shell altında** olduğundan emin ol, yoksa go her seferinde shell'i yeniden yaratır.

### Router Log'u İle Teşhis

Bu tür navigation bug'larda debug için GoRouter log'u aç:

```dart
final router = GoRouter(
  debugLogDiagnostics: true,  // ← konsola route geçişlerini yazar
  // ...
);
```

Sonra "Cihazlar" tab'a bas → logda ne route'a gittiğini gör. Muhtemelen şunu göreceksin:
```
GoRouter: matching /
GoRouter: found AppShell + DashboardScreen
```

Yani cihazlara değil ana sayfaya gidiyor. Bu bottom nav handler'ın bug'lı olduğunu gösterir.

### Test

1. Login yap → dashboard açılır
2. Bottom nav'dan "Cihazlar" → cihaz listesi açılır ✅
3. Bir cihaza tıkla → detay
4. Geri dön → liste
5. Bottom nav "Personel" → personel listesi ✅
6. Bottom nav "Cihazlar" → cihaz listesi ✅ (ANA SAYFA DEĞİL!)
7. Tekrar "Cihazlar" basınca → listede en başa scroll (optional, ama iyi UX)

**Commit:** `fix(nav): bottom nav tabs properly navigate between sections with state preservation`

---

## 🎯 Sıra

Task'ları **bu sırayla** yap:

```
1. FIX 5 — Bottom nav (önce bu çünkü test etmek için lazım, ~45 dk)
2. FIX 1 — Bildirim persistence (backend + mobile, ~1.5 saat)
3. FIX 3 — Dark mode kaldır (hızlı, ~30 dk)
4. FIX 2 — Bildirim navigation (~30 dk)
5. FIX 4 — Activity feed navigation (~30 dk)
```

Her FIX sonunda:
- `flutter analyze` → 0 hata
- `git add -A && git commit`
- Gerçek cihazda test

## 🧪 Final Test

```
✅ FIX 5 Test: Bottom nav → Cihazlar → detay → geri → tekrar Cihazlar tab ✅
✅ FIX 1 Test: Login → bildirim oku → logout → login → hala okunmuş
✅ FIX 2 Test: Bildirime tıkla → beyaz ekran değil, ilgili sayfa
✅ FIX 3 Test: Ayarlar → tema bölümü YOK, uygulama her yerde light
✅ FIX 4 Test: Dashboard → aktivite tıkla → ilgili cihaz/zimmet detayı
```

## 📝 Final

- `flutter analyze` → 0 hata
- Version: `2.3.1+26`
- Git tag: `git tag -a v2.3.1 -m "Fix notifications persistence, remove dark mode, activity navigation"`

---

## 📦 Claude Code Başlatma Promptu

```
AssetFlow — 5 kritik bug fix:

1. Bottom nav Cihazlar/Personel tab'ları ana sayfa açıyor (navigation stack bug)
2. Bildirim okunmuş durumu login/logout'ta sıfırlanıyor
3. Bildirime tıklayınca beyaz ekran
4. Dark mode yarım çalışıyor - KOMPLE KALDIR
5. Dashboard aktivite akışı tıklanabilir değil

Bu SPEC'i uygula: specs/BUG_FIX_v2_3_1.md

SIRA (önemli):
1. FIX 5 (bottom nav) - ~45 dk — ÖNCE BU, test için lazım
2. FIX 1 (notifications DB persistence) - ~1.5 saat
3. FIX 3 (dark mode kaldır) - ~30 dk
4. FIX 2 (notification navigation) - ~30 dk
5. FIX 4 (activity feed navigation) - ~30 dk

KURALLAR:
- FIX 5: GoRouter StatefulShellRoute pattern'ı kullan veya basit context.go() fix
- FIX 1: Backend Notification tablosu + migration (AddNotifications), mobile SharedPreferences'ı SİL
- FIX 3: themeProvider, darkTheme, dark colors, settings toggle KOMPLE SİL
- FIX 2: Bildirim type → route mapping, null safety
- FIX 4: Activity item → relatedEntityType + relatedEntityId ile navigate

Her FIX sonrası:
- flutter analyze (0 hata)
- git commit

Final: v2.3.1 tag

BAŞLA, FIX 5'ten.
```

---

**Hazırlayan:** Claude + Emre
**Versiyon:** 1.0

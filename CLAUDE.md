# AssetFlow Mobile — CLAUDE.md

IT varlık yönetimi için Flutter mobil uygulaması. Backend: .NET (localhost:5160).

---

## Görmezden Gelinecek Dizinler

Aşağıdaki dizinleri **asla okuma**, token israfı yaratır:

```
.dart_tool/
build/
.flutter-plugins
.flutter-plugins-dependencies
android/.gradle/
android/app/build/
ios/Pods/
ios/.symlinks/
linux/flutter/
macos/Flutter/
windows/flutter/
.specify/
```

---

## Teknoloji Yığını

| Katman | Kütüphane | Versiyon |
|---|---|---|
| State Management | `flutter_riverpod` | ^2.5.1 |
| Routing | `go_router` | ^14.2.0 |
| HTTP Client | `dio` | ^5.4.0 |
| Local Storage | `shared_preferences` | ^2.2.3 |
| Font | `google_fonts` (Inter) | ^6.2.1 |
| Tarihleme | `intl` | ^0.19.0 |
| Skeleton Loading | `shimmer` | ^3.0.0 |
| Grafik | `fl_chart` | ^0.68.0 |
| Dosya Açma | `open_file` | ^3.5.10 |
| Bildirimler | `flutter_local_notifications` | ^18.0.1 |
| Flutter SDK | `^3.11.1` | — |

---

## Mimari

```
lib/
├── main.dart                     # ProviderScope, GoogleFonts, Notif init, ApiClient.onLogout
├── app_router.dart               # GoRouter provider, StatefulShellRoute (5 branch)
├── core/
│   ├── constants/
│   │   └── api_constants.dart    # Tüm API endpoint sabitleri (static const/getter)
│   ├── theme/
│   │   └── app_theme.dart        # AppColors + AppTheme.darkTheme (sadece dark mode)
│   ├── utils/
│   │   ├── api_client.dart       # Dio singleton, JWT interceptor, token refresh + retry queue
│   │   ├── token_manager.dart    # SharedPreferences: access/refresh token + user bilgisi
│   │   ├── cache_manager.dart    # SharedPreferences TTL-based cache (15dk default, getStale offline)
│   │   └── notification_service.dart # flutter_local_notifications singleton, kanal bazlı
│   └── widgets/
│       ├── app_text_field.dart   # Tekrar kullanılabilir text field
│       ├── app_button.dart       # AppButton (primary/danger/outline, isLoading, isFullWidth)
│       ├── loading_overlay.dart  # Yükleme overlay
│       └── connectivity_wrapper.dart # ConnectivityNotifier (10sn polling) + OfflineBanner
├── data/
│   ├── models/
│   │   ├── auth_models.dart      # LoginRequest, RegisterRequest, AuthResponse
│   │   ├── dashboard_model.dart  # DashboardData, WarrantyAlertItem
│   │   ├── device_model.dart     # Device, DeviceTypeLabels, DeviceStatusLabels
│   │   ├── employee_model.dart   # Employee
│   │   ├── assignment_model.dart # Assignment, AssignmentTypeLabels, ReturnConditionLabels
│   │   ├── location_model.dart   # Location
│   │   └── paged_result.dart     # PagedResult<T>
│   └── services/
│       ├── auth_service.dart     # login, register, refresh, revoke, changePassword, logout
│       ├── device_service.dart   # CRUD + getAll(page, pageSize)
│       ├── employee_service.dart # CRUD + getAll
│       ├── assignment_service.dart # assign, return, export (PDF)
│       ├── location_service.dart # CRUD
│       └── dashboard_service.dart # getDashboard
└── features/
    ├── auth/
    │   ├── providers/auth_provider.dart   # AuthState + AuthNotifier (StateNotifier)
    │   └── screens/                       # login_screen, register_screen
    ├── dashboard/
    │   ├── providers/dashboard_provider.dart  # FutureProvider (dashboardProvider)
    │   ├── screens/dashboard_screen.dart
    │   └── widgets/stat_card.dart
    ├── devices/
    │   ├── providers/device_provider.dart  # DeviceListState + DeviceNotifier (pagination + cache)
    │   └── screens/                        # devices_screen, device_detail_screen, device_form_screen
    │   └── widgets/device_list_item.dart
    ├── employees/
    │   ├── providers/employee_provider.dart
    │   └── screens/                        # employees_screen, employee_form_screen
    ├── assignments/
    │   ├── providers/assignment_provider.dart
    │   └── screens/                        # assignments_screen, assign_device_screen
    ├── locations/
    │   ├── providers/location_provider.dart
    │   └── screens/                        # locations_screen, location_form_screen
    └── profile/
        └── screens/profile_screen.dart     # Şifre değiştirme + önbellek temizleme + çıkış
```

---

## Navigasyon

`StatefulShellRoute.indexedStack` ile 5 branch:

| Index | Path | Ekran |
|---|---|---|
| 0 | `/` | DashboardScreen |
| 1 | `/devices` | DevicesScreen (alt: `/devices/:id`) |
| 2 | `/employees` | EmployeesScreen |
| 3 | `/assignments` | AssignmentsScreen |
| 4 | `/more` | _MoreScreen (Lokasyonlar + Profil → `Navigator.push`) |

Auth rotaları (`/login`, `/register`) shell dışındadır. `GoRouter.redirect` ile guard yapılır.

---

## State Management Kuralları

- **Tüm provider'lar `StateNotifierProvider` veya `FutureProvider`** olarak tanımlanır.
- `StateNotifier` içinde `copyWith` pattern kullanılır; state immutable'dır.
- `autoDispose` eklendiğinde provider ekrandan çıkınca temizlenir — liste provider'larında kullanılır.
- Provider dosyasında hem state sınıfı, hem notifier, hem de `final xyzProvider = ...` tek dosyada bulunur.
- `riverpod_annotation` (code-gen) **kullanılmıyor** — manuel provider tanımı tercih edilir.

---

## HTTP / API Katmanı

### ApiClient (Singleton)
- `ApiClient.instance.dio` — tüm servisler bunu kullanır.
- **JWT Interceptor**: her isteğe `Authorization: Bearer <token>` ekler.
- **401 → Token Refresh**: refresh başarısızsa `onLogout` callback'i çağrılır → `authProvider.logout()`.
- Refresh sırasında gelen istekler `_pendingRequests` kuyruğuna alınır.

### Hata Yönetimi
- `DioException` yakalanır; `response.data['error']` veya `response.data['message']` okunur.
- Bağlantı hatalarında Türkçe kullanıcı mesajı gösterilir.
- Yalnızca servis sınırlarında (provider'larda) try/catch bulunur; widget'larda try/catch olmaz.

---

## Cache Sistemi

`CacheManager` (SharedPreferences tabanlı):
- `set(key, data, ttl)` — 15 dakika default TTL.
- `get(key)` — süresi dolmuşsa `null` döner.
- `getStale(key)` — offline modda TTL'den bağımsız veri döner.
- Cache anahtarları: `devices_page1`, `employees_page1`, `assignments_page1`, `dashboard` vb.
- Cache `cache_` prefix'i ile SharedPreferences'a yazılır.

---

## Tema & Renk Sistemi

Tek tema: **dark only** (`AppTheme.darkTheme`). Renk değişkenleri `AppColors` sınıfındadır:

| Grup | Değişkenler |
|---|---|
| Primary (mavi) | `primary50..primary900` |
| Dark backgrounds | `dark700, dark800, dark900, dark950` |
| Status | `success, warning, error, info` (ve `*Light` varyantları) |
| Text | `textPrimary, textSecondary, textTertiary, textOnPrimary` |
| Surface | `surface, surfaceLight, background, cardBackground` |
| Border | `border, borderLight` |
| Device status | `statusActive, statusInStorage, statusMaintenance, statusRetired` |

Font: **Inter** (Google Fonts). `AppTheme.darkTheme` içinde tüm Material bileşenleri özelleştirilmiştir.

---

## Domain Sabitler

```dart
// Cihaz Tipleri (Device.type: int)
DeviceTypeLabels = { 0:'Dizüstü', 1:'Masaüstü', 2:'Monitör', ... 8:'Diğer' }

// Cihaz Durumları (Device.status: int)
DeviceStatusLabels = { 0:'Aktif', 1:'Depoda', 2:'Bakımda', 3:'Emekli' }

// Zimmet Tipleri (Assignment.type: int)
AssignmentTypeLabels = { 0:'Zimmet', 1:'Ödünç', 2:'Geçici' }

// İade Durumu (Assignment.returnCondition: int)
ReturnConditionLabels = { 0:'İyi', 1:'Hasarlı', 2:'Arızalı', 3:'Kayıp' }

// Kullanıcı Rolleri (AuthState.role: String)
'Admin' → 'Yönetici', 'Manager' → 'Müdür', 'ITAdmin' → 'IT Yönetici'
```

---

## Bildirim Sistemi

`NotificationService` singleton, `flutter_local_notifications` kullanır:

| Kanal | ID | Kullanım |
|---|---|---|
| `assetflow_assignments` | 1000–1003 | Zimmet atama/iade/gecikme |
| `assetflow_warranty` | 1100–1102 | Garanti uyarıları (dashboard tetikler) |
| `assetflow_devices` | 1200–1202 | Cihaz durum değişiklikleri |
| `assetflow_sap` | 1300–1303 | SAP entegrasyon (gelecek faz) |
| `assetflow_system` | 1400–1401 | Haftalık/aylık raporlar |

Init `main.dart`'ta `Future.microtask` içinde çağrılır. Bildirim izni Android 13+ için istenir.

---

## API Endpoint Haritası

```
Backend: http://localhost:5160

Auth:
  POST /api/auth/login
  POST /api/auth/register
  POST /api/auth/refresh
  POST /api/auth/revoke
  POST /api/auth/change-password

Cihazlar:
  GET/POST      /api/devices
  GET/PUT/DELETE /api/devices/:id

Personel:
  GET/POST      /api/employees
  GET/PUT/DELETE /api/employees/:id

Zimmetler:
  GET           /api/assignments
  POST          /api/assignments/assign
  POST          /api/assignments/:id/return
  GET           /api/assignments/:id/export   ← PDF indir

Lokasyonlar:
  GET/POST      /api/locations
  GET/PUT/DELETE /api/locations/:id

Dashboard:
  GET           /api/dashboard
```

---

## Kodlama Standartları

1. **Singleton pattern**: `Class._()` private constructor + `static final instance = Class._()`.
2. **Model sınıfları**: `fromJson` factory + `toJson` method. ID'ler `.toString()` ile string'e çevrilir (backend int döndürebilir).
3. **Widget mimarisi**: Büyük screen'ler `ConsumerStatefulWidget`; salt okunur olanlar `ConsumerWidget`.
4. **Private helper widget'lar**: Aynı dosya içinde `_PrivateWidget` olarak tanımlanır; ayrı dosya açılmaz.
5. **Shimmer loading**: Veri yükleme sırasında skeleton gösterilir — basit `CircularProgressIndicator` yerine.
6. **Hata gösterimi**: `SnackBar` (floating) kullanılır. Kritik hatalar için tam ekran hata widget'ı.
7. **Dil**: UI tamamen Türkçedir. Tüm etiket, mesaj ve label'lar Türkçe yazılır.
8. **`print()` debug**: Prod'a gitmeden önce `[AUTH]` prefix'li debug print'ler temizlenmelidir.
9. **`withValues(alpha:)`**: `withOpacity` yerine `withValues(alpha: 0.x)` kullanılır (Flutter 3.x deprecation).
10. **Pagination**: Liste provider'larında `page=1, pageSize=15` pattern kullanılır. `loadMore()` ile infinite scroll.

---

## Gelecek Fazlar (Planlanan)

- **SAP Entegrasyonu**: Personel ve varlık aktarımı (bildirim altyapısı hazır: `_Channels.sap`).
- **fl_chart**: Dashboard'a cihaz tipi dağılımı grafiği (`devicesByType` verisi mevcut).
- **PDF Export**: Zimmet belgesi — `open_file` + `/api/assignments/:id/export` hazır.
- **Lokasyon hiyerarşisi**: Bina → Kat → Oda yapısı (model mevcut).

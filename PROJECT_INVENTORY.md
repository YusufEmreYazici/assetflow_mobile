# AssetFlow Mobile — Proje Envanteri

**Hazırlanma tarihi:** 2026-04-17
**İncelenen .md dosyaları:** CLAUDE.md, progress.md, README.md
**Toplam feature sayısı:** 8 (Auth, Dashboard, Devices, Employees, Assignments, Locations, Profile, SAP)
**Toplam ekran sayısı:** 16
**Toplam servis sayısı:** 7
**Toplam model sayısı:** 8
**Toplam Dart dosyası:** ~55

---

## ADIM 0: .md Dosyaları

### CLAUDE.md
Proje mimarisi, teknoloji yığını ve standartları tanımlayan ana dokümantasyon dosyası. State management (Riverpod, manuel provider), routing (GoRouter 5-tab), API (Dio + JWT interceptor), cache sistemi (TTL-based), notification sistemi (5 kanal), tema (dark-only, AppColors) ve kodlama standartlarını kapsar. Önemli kararlar: code-gen yok, `withValues(alpha:)` deprecation fix, pagination 15 items/page.

### progress.md
Faz bazlı ilerleme takibi (son güncelleme: 2026-04-12). Tüm fazlar tamamlanmış olarak işaretlenmiş:
- **Faz 1:** Altyapı & Auth ✅
- **Faz 2:** CRUD & Dashboard ✅
- **Faz 3:** QR Scanner, CSV Import, Notification Settings ✅
- **Faz 4:** SAP Entegrasyonu ✅
- **Faz 5:** Polishing (debug print temizleme, splash screen, release build) ✅

### README.md
Generic Flutter template README — içerik proje spesifik değil, bilgi içermiyor.

---

## ADIM 1: Klasör Yapısı

```
lib/
├── main.dart
├── app_router.dart
├── core/ (16 dosya)
│   ├── constants/api_constants.dart
│   ├── theme/app_theme.dart
│   ├── utils/
│   │   ├── api_client.dart
│   │   ├── token_manager.dart
│   │   ├── cache_manager.dart
│   │   ├── notification_service.dart
│   │   └── notification_settings.dart
│   └── widgets/
│       ├── app_text_field.dart
│       ├── app_button.dart
│       ├── loading_overlay.dart
│       ├── connectivity_wrapper.dart
│       └── qr_scanner_screen.dart
├── data/ (13 dosya)
│   ├── models/
│   │   ├── auth_models.dart
│   │   ├── device_model.dart
│   │   ├── employee_model.dart
│   │   ├── assignment_model.dart
│   │   ├── location_model.dart
│   │   ├── dashboard_model.dart
│   │   ├── sap_models.dart
│   │   └── paged_result.dart
│   └── services/
│       ├── auth_service.dart
│       ├── device_service.dart
│       ├── employee_service.dart
│       ├── assignment_service.dart
│       ├── location_service.dart
│       ├── dashboard_service.dart
│       └── sap_service.dart
└── features/ (~28 dosya)
    ├── auth/ (3 dosya: provider + 2 screen)
    ├── dashboard/ (4 dosya: provider + screen + 2 widget)
    ├── devices/ (6 dosya: provider + 4 screen + widget)
    ├── employees/ (3 dosya: provider + 2 screen)
    ├── assignments/ (3 dosya: provider + 2 screen)
    ├── locations/ (3 dosya: provider + 2 screen)
    ├── profile/ (2 dosya: 2 screen)
    └── sap/ (2 dosya: provider + screen)
```

---

## ADIM 2: Feature Detayları

### Auth

**Ekranlar:**
- `login_screen.dart` → Email/Password form, error SnackBar, "Kayıt Ol" link → **TAMAM ✅**
- `register_screen.dart` → Email/Password/FullName/CompanyName form, validation → **TAMAM ✅**

**Provider'lar:**
- `auth_provider.dart` → AuthState (isAuthenticated, isLoading, email, fullName, role, companyId, error) + AuthNotifier (checkAuth, login, register, logout, clearError). StateNotifierProvider.

**Service/API bağlantısı:**
- POST `/api/auth/login` → LoginRequest
- POST `/api/auth/register` → RegisterRequest
- POST `/api/auth/refresh` → interceptor tarafından otomatik
- POST `/api/auth/revoke` → logout sırasında
- POST `/api/auth/change-password` → ProfileScreen'den

**Bariz eksikler/TODO'lar:**
- Yok. Tüm metodlar implemente.

**.md dosyalarında:**
- CLAUDE.md: Tüm auth endpoint'leri belgelenmiş, token flow açıklanmış.

---

### Dashboard

**Ekranlar:**
- `dashboard_screen.dart` (1521 satır) → SliverAppBar, StatCard grid (6 kart), garanti uyarı listesi, hızlı işlem satırı, son aktiviteler, bildirim paneli (bottom sheet), CriticalAlert popup → **TAMAM ✅**

**Provider'lar:**
- `dashboard_provider.dart` → `dashboardProvider` (FutureProvider.autoDispose, 30dk cache + offline fallback) + `recentAssignmentsProvider` (son 5 aktif zimmet)

**Widget'lar:**
- `stat_card.dart` → üst renk şeridi, büyük rakam, opsiyonel badge
- `device_type_chart.dart` → fl_chart donut grafiği, dokunuş ile % gösterimi

**Service/API bağlantısı:**
- GET `/api/dashboard` → DashboardData (stats, warranties, activityFeed, devicesByType)

**Bariz eksikler/TODO'lar:**
- 1521 satırlık screen widget'lara split edilebilir (refactor fırsatı ama işlevsel).

**.md dosyalarında:**
- CLAUDE.md: `devicesByType` verisi mevcut, fl_chart "gelecek faz" olarak belirtilmiş. Kodda aktif.
- progress.md: Faz 2'de tamamlandı.

---

### Devices

**Ekranlar:**
- `devices_screen.dart` → Cihaz listesi, pagination + infinite scroll + pull-refresh → **TAMAM ✅**
- `device_detail_screen.dart` → Tam teknik detay (CPU, RAM, storage, GPU, OS, IP, MAC, garanti tarihi, lokasyon, son zimmet) → **TAMAM ✅**
- `device_form_screen.dart` → Ekleme/Düzenleme formu (14 alan) → **TAMAM ✅**
- `device_import_screen.dart` → CSV file_picker + preview + batch import + hata sayacı → **TAMAM ✅**

**Provider'lar:**
- `device_provider.dart` → DeviceListState (devices, isLoading, isLoadingMore, hasMore, page, error) + DeviceNotifier (loadDevices, loadMore, deleteDevice, refresh). StateNotifierProvider.autoDispose. Cache: `devices_page1` (15dk TTL).

**Service/API bağlantısı:**
- GET `/api/devices?page=X&pageSize=15`
- GET/PUT/DELETE `/api/devices/:id`
- POST `/api/devices`

**Bariz eksikler/TODO'lar:**
- CSV import partial fail senaryosunda detaylı error recovery yok.

**.md dosyalarında:**
- CLAUDE.md: Pagination pattern (page=1, pageSize=15) belgelenmiş.
- progress.md: CSV import Faz 3'te tamamlandı.

---

### Employees

**Ekranlar:**
- `employees_screen.dart` → Personel listesi, pagination, pull-refresh, arama → **TAMAM ✅**
- `employee_form_screen.dart` → Ekleme/Düzenleme → **TAMAM ✅**

**Provider'lar:**
- `employee_provider.dart` → EmployeeListState (employees, isLoading, isLoadingMore, page, hasMore, error) + EmployeeNotifier. StateNotifierProvider.autoDispose. Cache: `employees_page1`.

**Service/API bağlantısı:**
- GET `/api/employees?page=X&pageSize=15`
- POST/PUT/DELETE `/api/employees/:id`

**Bariz eksikler/TODO'lar:**
- Yok.

**.md dosyalarında:**
- CLAUDE.md: employee_model.dart belgelenmiş.

---

### Assignments (Zimmet)

**Ekranlar:**
- `assignments_screen.dart` → Liste, 3 filter chip (Tümü/Aktif/Tamamlanan), arama, pagination → **TAMAM ✅**
- `assign_device_screen.dart` → Cihaz seçimi (dropdown/QR), personel seçimi, zimmet ata, iade formu (iade tarihi, durum, notlar) → **TAMAM ✅**

**Provider'lar:**
- `assignment_provider.dart` → AssignmentListState (assignments, isLoading, hasMore, page, searchQuery, filter) + AssignmentNotifier (loadAssignments, loadMore, search, setFilter, returnDevice). Cache: `assignments_{filter}_page1`. Search sırasında cache bypass.

**Service/API bağlantısı:**
- GET `/api/assignments?page=X&pageSize=15&search=&isActive=bool`
- POST `/api/assignments/assign`
- POST `/api/assignments/:id/return`
- GET `/api/assignments/:id/export` (PDF, open_file)

**Bariz eksikler/TODO'lar:**
- Yok. PDF export aktif.

**.md dosyalarında:**
- CLAUDE.md: PDF export endpoint belgelenmiş, "Gelecek Faz" olarak belirtilmişti ama kodda aktif.

---

### Locations

**Ekranlar:**
- `locations_screen.dart` → Lokasyon listesi, ExpansionTile hiyerarşi (Bina > Kat > Oda), liste/hiyerarşi toggle, cihaz sayısı badge → **TAMAM ✅**
- `location_form_screen.dart` → Ekleme/Düzenleme → **TAMAM ✅**

**Provider'lar:**
- `location_provider.dart` → LocationListState + LocationNotifier. pageSize=50 (tümü tek sayfada). StateNotifierProvider.autoDispose.

**Service/API bağlantısı:**
- GET/POST `/api/locations`
- PUT/DELETE `/api/locations/:id`

**Bariz eksikler/TODO'lar:**
- Yok.

**.md dosyalarında:**
- CLAUDE.md: "Lokasyon hiyerarşisi: Bina → Kat → Oda yapısı (model mevcut)" → Gelecek Faz olarak belirtilmişti, kodda aktif.

---

### Profile

**Ekranlar:**
- `profile_screen.dart` (420 satır) → Avatar initials, user bilgisi, rol badge, şifre değiştirme formu, bildirim ayarları link, cache temizle, uygulama hakkında, güvenli çıkış (confirm dialog) → **TAMAM ✅**
- `notification_settings_screen.dart` → 5 kanal toggle (assignments, warranty, devices, sap, system) + açıklama → **TAMAM ✅**

**Provider'lar:**
- AuthProvider üzerinden çalışır (logout, changePassword).
- NotificationSettings (SharedPreferences) → per-channel toggles.

**Service/API bağlantısı:**
- POST `/api/auth/change-password`
- POST `/api/auth/revoke` (logout)

**Bariz eksikler/TODO'lar:**
- Yok.

**.md dosyalarında:**
- CLAUDE.md: Profil ekranı kısaca belgelenmiş.
- progress.md: Faz 3'te bildirim ayarları tamamlandı.

---

### SAP Entegrasyonu

**Ekranlar:**
- `sap_screen.dart` → SAP bağlantı durumu kartı (yapılandırılmadı/bağlı/bağlantı yok), personel sync butonu + son sync zamanı + sonuç sayaçları, varlık sync butonu + sonuç, beklenen bütçeler listesi (tutar, açıklama, durum badge) → **TAMAM ✅**

**Provider'lar:**
- `sap_provider.dart` → SapState (connectionStatus, lastEmployeeSync, lastAssetSync, budgets, loading flags, errors) + SapNotifier (_loadStatus, syncEmployees, syncAssets, _loadBudgets, refresh). StateNotifierProvider.autoDispose. 404/501 graceful fallback ("yapılandırılmadı").

**Model'lar:**
- `sap_models.dart` → SapSyncResult (synced, created, updated, errors, duration), SapBudgetItem (id, amount, description, requestedBy, status, date), SapConnectionStatus (isConnected, lastSync, version, company)

**Service/API bağlantısı:**
- GET `/api/sap/status`
- POST `/api/sap/sync/employees`
- POST `/api/sap/sync/assets`
- GET `/api/sap/budgets`

**Bildirim entegrasyonu:**
- `notifySapNewEmployee()` → sync sonrası
- `notifySapAssetsImported()` → asset sync sonrası
- `notifySapBudgetApproved()` → budget onayı

**Bariz eksikler/TODO'lar:**
- Backend SAP endpoint'leri henüz canlı olmayabilir (404/501 fallback bunu yönetiyor).

**.md dosyalarında:**
- CLAUDE.md: "SAP Entegrasyonu (gelecek faz)" → progress.md'ye göre Faz 4'te tamamlandı.

---

## ADIM 3: Auth Akışı

**Login Ekranı:** `lib/features/auth/screens/login_screen.dart`
- Email + Password → `authProvider.notifier.login(email, password)`
- AuthService.login() → POST `/api/auth/login`
- AuthResponse → TokenManager.saveTokens() + saveUser()
- GoRouter redirect → `/`

**Token Saklama:**
- SharedPreferences (TokenManager singleton)
- Anahtarlar: `access_token`, `refresh_token`, `user_email`, `user_full_name`, `user_role`, `user_company_id`

**Token Refresh:**
- 401 → ApiClient interceptor
- `_pendingRequests` queue
- Yeni Dio instance ile POST `/api/auth/refresh`
- Başarılı → TokenManager.saveTokens() + queue retry
- Başarısız → TokenManager.clearTokens() + onLogout() → authProvider.logout()

**Logout Akışı:**
- ProfileScreen "Güvenli Çıkış" → confirm dialog → authProvider.notifier.logout()
- AuthService.logout() → revoke() + clearTokens()
- AuthState → isAuthenticated=false → GoRouter → `/login`

**Register:**
- `register_screen.dart` → Router'da `/register` route mevcut, LoginScreen'den link ile erişiliyor. Aktif.

---

## ADIM 4: Router Haritası

```
GoRouter (initialLocation: '/')
│
├── /login → LoginScreen
├── /register → RegisterScreen
│
└── StatefulShellRoute.indexedStack (5 Branch)
    ├── Branch 0: /
    │   └── DashboardScreen
    ├── Branch 1: /devices
    │   ├── DevicesScreen
    │   └── /devices/:id → DeviceDetailScreen
    ├── Branch 2: /employees
    │   └── EmployeesScreen
    ├── Branch 3: /assignments
    │   └── AssignmentsScreen
    └── Branch 4: /more
        └── _MoreScreen
            ├── → LocationsScreen (Navigator.push)
            ├── → SapScreen (Navigator.push)
            └── → ProfileScreen (Navigator.push)
```

**Auth Guard:**
- `GoRouter.redirect`: authState.isLoading → null (bekle); !isAuthenticated → `/login`; isAuthenticated + auth route → `/`

**Başlangıç Ekranı:** DashboardScreen (`/`)

**Not:** DeviceFormScreen, EmployeeFormScreen, AssignDeviceScreen, LocationFormScreen → feature ekranlarından `Navigator.push` ile açılıyor (GoRouter alt route değil).

---

## ADIM 5: API Entegrasyonu

**Base URL:**
```dart
String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5160')
```
- Emülatör: `10.0.2.2:5160` (default)
- Fiziksel cihaz: `--dart-define=API_BASE_URL=http://192.168.X.X:5160`
- Production: `--dart-define=API_BASE_URL=https://api.assetflow.io`

**ApiClient:**
- Singleton Dio instance
- BaseOptions: connectTimeout=15s, receiveTimeout=15s, `Content-Type: application/json`
- JWT Interceptor: `Authorization: Bearer {token}` (her isteğe eklenir)
- 401 Handler: token refresh + pending queue + retry
- `onLogout` callback: main.dart'ta `authProvider.notifier.logout()` bağlanmış

**Error Handling:**
- `DioException` catch bloğu
- Backend response: `data['error']` / `data['message']` / `data['errors'][field][0]`
- ConnectionError → "Sunucuya bağlanılamadı"
- Timeout → "İstek zaman aşımı"
- Try/catch yalnızca servis + provider'da, widget'larda yok

**Servisler (7 adet):**
1. AuthService → login, register, refresh, revoke, changePassword, logout
2. DeviceService → getAll(page, pageSize), getById, create, update, delete
3. EmployeeService → getAll, getById, create, update, delete
4. AssignmentService → getAll(page, pageSize, search, isActive), assign, returnDevice, exportForm
5. LocationService → getAll, getById, create, update, delete
6. DashboardService → get()
7. SapService → getStatus, syncEmployees, syncAssets, getBudgets

**Toplam Endpoint: 20**

---

## ADIM 6: State Management

**Kütüphane:** `flutter_riverpod ^2.5.1`

**Code-gen kullanımı:** `riverpod_annotation` dependency'de ama aktif kullanılmıyor. Manuel provider tanımı.

**Provider Organizasyonu:**
- **StateNotifierProvider** → mutation gerektiren state'ler: Auth, DeviceList, EmployeeList, AssignmentList, LocationList, SapState
- **FutureProvider.autoDispose** → veri fetch: dashboardProvider, recentAssignmentsProvider
- **autoDispose** → tüm liste provider'larında aktif (ekrandan çıkınca clean up)

**Immutable State:**
- Tüm state sınıfları `final` field + `copyWith()` pattern
- `const` constructor yok (List field'lar nedeniyle)

---

## ADIM 7: Özel Sistemler

### Notification Service
- **Kütüphane:** `flutter_local_notifications ^18.0.1`
- **5 Kanal, 15 Bildirim Tipi:**

| Kanal | Bildirim Tipleri |
|---|---|
| `assetflow_assignments` | new, returned, expiring, overdue |
| `assetflow_warranty` | critical, warning, expired |
| `assetflow_devices` | maintenance, new_stock, retired |
| `assetflow_sap` | new_employee, employee_leaving, budget_approved, assets_imported |
| `assetflow_system` | weekly_report, monthly_summary |

- **Per-Channel Toggle:** `NotificationSettings` (SharedPreferences), `NotificationSettingsScreen` ile yönetilir
- **Init:** `main.dart → Future.microtask() → NotificationService.instance.init()`
- **Android 13+ Permission:** `requestNotificationsPermission()`
- **Entegrasyon Noktaları:** Dashboard (warranty check), AssignmentReturn, SAP sync

### Cache Manager
- **TTL:** 15dk default, override mümkün
- **Offline Fallback:** `getStale()` → TTL'den bağımsız
- **Cache Anahtarları:** `cache_devices_page1`, `cache_employees_page1`, `cache_assignments_all_page1`, `cache_dashboard`, `cache_recent_assignments`
- **ProfileScreen:** "Önbelleği Temizle" butonu → `CacheManager.instance.clearAll()`

### QR Scanner
- **Kütüphane:** `mobile_scanner ^6.0.0`
- **Screen:** `lib/core/widgets/qr_scanner_screen.dart`
- **Özellikler:** Overlay, el feneri toggle, kamera flip
- **Entegrasyon:** Zimmet ekranında "QR Tara" → serial/assetCode eşleştirme

### CSV Import
- **Kütüphaneler:** `file_picker ^8.1.2`, `csv ^6.0.0`
- **Screen:** `lib/features/devices/screens/device_import_screen.dart`
- **Flow:** Dosya seç → parse → preview → sıralı import → success/error sayacı

### Connectivity Wrapper
- **Mekanizma:** `Socket.connect()` TCP check (10sn polling)
- **Görünüm:** `OfflineBanner` (kırmızı bar, en üstte)
- **Entegrasyon:** `app_router.dart → _ShellScaffold → Column` üst kısım

---

## ADIM 8: Bariz Eksikler

**TODO/FIXME/UnimplementedError:**
- Tarama sonucu: **Hiçbiri bulunamadı** ✅
- Debug print'ler temizlenmiş (progress.md Faz 5 "debug print cleanup" ✅)

**Boş Metodlar:** Yok.

**Erişilmez Route'lar:** Yok. Tüm route'lar navigation'a bağlı.

**Potansiyel İyileştirme Alanları (kritik değil):**
- `dashboard_screen.dart`: 1521 satır → private widget'lara bölünebilir
- CSV import partial fail: bazı satırlar başarısız olduğunda recovery mekanizması basit
- Unit test coverage: yalnızca 25 test (CacheManager, TokenManager, Auth, SAP models, Dashboard) — widget test yok
- SAP backend: frontend hazır ama backend 404/501 dönüyor (graceful fallback var)

---

## ADIM 9: Dokümantasyon vs Kod Karşılaştırması

### CLAUDE.md "Gelecek Fazlar" → Kodda Aktif Olanlar
| CLAUDE.md'de "Planlanmış" | Kodda Durum |
|---|---|
| SAP Entegrasyonu | ✅ Tam implement (sap_screen, sap_provider, sap_service, sap_models) |
| fl_chart: dashboard grafiği | ✅ `device_type_chart.dart` aktif |
| PDF Export (open_file) | ✅ `exportForm()` + `OpenFile.open()` aktif |
| Lokasyon hiyerarşisi | ✅ ExpansionTile (Bina > Kat > Oda) aktif |

### Kodda Var, CLAUDE.md'de Bahsedilmeyen
- `notification_settings.dart` (core/utils) — per-channel toggle storage
- `notification_settings_screen.dart` — UI ekranı
- `qr_scanner_screen.dart` (core/widgets) — QR scanner entegrasyonu
- `device_import_screen.dart` — CSV import
- `sap_models.dart` — SAP veri modelleri

### Planlanmış Ama Hiç Başlanmamış
- **Yok.** progress.md'ye göre tüm fazlar tamamlanmış.

---

## ADIM 10: Tamamlanmışlık Puanları

| Feature | Puan | Notlar |
|---|---|---|
| **Auth** | %100 | Login, Register, Token Refresh, Logout — eksiksiz |
| **Dashboard** | %100 | Stats, Warranty Alerts, Activity Feed, Donut Chart, Bildirim Paneli — eksiksiz |
| **Devices** | %95 | CRUD, Pagination, Offline Cache, CSV Import — partial fail handling iyileştirilebilir |
| **Employees** | %95 | CRUD, Pagination, Offline Cache — temel işlevler tam |
| **Assignments** | %100 | CRUD, Filter, Search, PDF Export, Bildirim — eksiksiz |
| **Locations** | %100 | CRUD, Hiyerarşi View — eksiksiz |
| **Profile** | %100 | User Info, Şifre Değiştirme, Bildirim Ayarları, Logout — eksiksiz |
| **SAP** | %90 | Frontend hazır, backend 404/501 fallback aktif — backend entegrasyon bekliyor |
| **Notifications** | %100 | 5 Kanal, 15 Tip, Per-Channel Toggle, Tüm Entegrasyon Noktaları — eksiksiz |
| **Infrastructure** | %100 | Theme, Cache, API Client, Router, Error Handling — eksiksiz |
| **Testing** | %50 | 25 unit test var, widget test yok, coverage sınırlı |

**Genel Proje Tamamlanmışlığı: ~97%**

---

## Genel Değerlendirme

**Güçlü Yönler:**
- Tutarlı mimari (Riverpod StateNotifier, autoDispose, copyWith)
- Sağlam altyapı (JWT refresh, pending queue, TTL cache, offline fallback)
- Kapsamlı bildirim sistemi (5 kanal, per-channel toggle, entegrasyon noktaları)
- Temiz kod (TODO/FIXME/UnimplementedError yok)
- Dark theme tam tutarlı, tüm bileşenler özelleştirilmiş

**İyileştirme Fırsatları:**
- `dashboard_screen.dart` (1521 satır) widget'lara split edilebilir
- Unit test coverage artırılabilir
- SAP backend entegrasyon canlıya alınabilir

**Production Hazırlığı:** ✅ Yüksek. Splash screen, release build config, debug print temizliği, offline mode, graceful error handling mevcut.

# Dashboard Refactor Planı

Dosya: `lib/features/dashboard/screens/dashboard_screen.dart`  
Toplam satır: 1521  
Analiz tarihi: 2026-04-18

---

## 1) Üst Düzey Yapı

**Ana sınıf:** `DashboardScreen extends ConsumerStatefulWidget` (satır 14–225)  
**State sınıfı:** `_DashboardScreenState` (satır 21–225)  
**Genel mimari:** `ConsumerStatefulWidget` — `ref.listen`, `ref.watch` ve callback zinciri gerektirdiği için StatefulWidget kullanılmış.

### build() hiyerarşisi
```
Scaffold
└── RefreshIndicator
    └── CustomScrollView
        ├── _DashboardAppBar          (SliverAppBar)
        └── dashboardAsync.when()
            ├── data → _DashboardContent  (SliverToBoxAdapter)
            ├── loading → _DashboardShimmer
            └── error → _DashboardError
```

### Dosyadaki sınıf ve private method sayısı
| Tür | Sayı |
|---|---|
| ConsumerStatefulWidget + State | 1 çift |
| StatefulWidget + State | 1 çift (`_NotificationPanel`) |
| StatelessWidget | 10 adet |
| Private method (State içinde) | 2 (`_showCriticalAlert`, `_openNotifications`) |
| Private method (widget içinde) | 2 (`_greeting` in AppBar, `_recentShimmer` in Content) |

**Toplam class: 13**

---

## 2) Mantıksal Bloklar (Satır Aralıkları)

### 2.1 — Critical Alert Dialog
- **Satır:** 26–127
- **Ne yapar:** Garanti süresi dolmuş/yaklaşan cihazlar için session başına bir kez popup dialog gösterir. "İncele" tıklanınca notification panel'i açar.
- **Bağımlılıklar:** `ref.read(dashboardProvider)`, `ref.read(recentAssignmentsProvider)`, `_openNotifications()` callback'i
- **Tipi:** Private method (`_showCriticalAlert`)
- **Satır sayısı:** ~102

### 2.2 — Notification Panel Açıcı
- **Satır:** 129–142
- **Ne yapar:** `showModalBottomSheet` ile `_NotificationPanel`'i açar, `_panelSeen = true` yapar.
- **Bağımlılıklar:** `_readNotifIds`, `setState`
- **Tipi:** Private method (`_openNotifications`)
- **Satır sayısı:** ~14

### 2.3 — DashboardScreen build()
- **Satır:** 144–225
- **Ne yapar:** 3 provider izler, `ref.listen` ile kritik uyarı tetikler, `notifCount` hesaplar, Scaffold+CustomScrollView oluşturur.
- **Bağımlılıklar:** `dashboardProvider`, `recentAssignmentsProvider`, `authProvider`
- **Tipi:** `build()` içi
- **Satır sayısı:** ~81

### 2.4 — DashboardAppBar
- **Satır:** 229–408
- **Ne yapar:** SliverAppBar ile selamlama metni, tarih, bildirim zili (badge + okundu işareti), avatar gösterir.
- **Bağımlılıklar:** `AuthState` constructor param, `notifCount`, `panelSeen`, `onNotifTap` callback
- **Tipi:** Ayrı class (`_DashboardAppBar`)
- **Satır sayısı:** ~180

### 2.5 — DashboardContent (Orchestrator)
- **Satır:** 412–601
- **Ne yapar:** Tüm içerik bloklarını (KPI, hızlı işlemler, grafik, aktiviteler, garanti) sıralayan Column.
- **Bağımlılıklar:** `DashboardData`, `AsyncValue<List<Assignment>>` — constructor param, provider yok
- **Tipi:** Ayrı class (`_DashboardContent`)
- **Satır sayısı:** ~190

### 2.6 — KPI Grid (Genel Bakış)
- **Satır:** 431–489 (DashboardContent içinde)
- **Ne yapar:** 6 adet `StatCard` ile 2x3 GridView oluşturur.
- **Bağımlılıklar:** `DashboardData` alanları
- **Tipi:** Inline (DashboardContent.build içinde)
- **Satır sayısı:** ~59

### 2.7 — Hızlı İşlemler (Quick Actions)
- **Satır:** 493–533 (DashboardContent içinde)
- **Ne yapar:** Yatay scroll'lu 4 aksiyon butonu (`_QuickAction`).
- **Bağımlılıklar:** `context.go()` — sadece routing
- **Tipi:** Inline + `_QuickAction` class (1129–1180)
- **Satır sayısı:** ~41 inline + 52 class = 93

### 2.8 — Cihaz Dağılımı Grafiği
- **Satır:** 537–547 (DashboardContent içinde)
- **Ne yapar:** `DeviceTypeChart` widget'ını çağırır (ayrı dosyada).
- **Bağımlılıklar:** `data.devicesByType`
- **Tipi:** Inline çağrı
- **Satır sayısı:** ~10

### 2.9 — Son Aktiviteler
- **Satır:** 550–562 inline + 1184–1276 class
- **Ne yapar:** Son zimmetleri liste olarak gösterir, `recentAsync` shimmer/error durumlarını yönetir.
- **Bağımlılıklar:** `List<Assignment>`, `_recentShimmer()` helper, routing
- **Tipi:** Inline çağrı + `_RecentActivitySection` class
- **Satır sayısı:** ~13 inline + 93 class = 106

### 2.10 — Garanti Uyarı Listesi
- **Satır:** 565–574 inline + 1280–1395 class
- **Ne yapar:** `upcomingWarrantyExpirations` listesini kart olarak gösterir, renk/aciliyet hesaplar.
- **Bağımlılıklar:** `List<WarrantyAlertItem>`, routing (`/devices/:id`)
- **Tipi:** Inline çağrı + `_WarrantySection` class
- **Satır sayısı:** ~10 inline + 116 class = 126

### 2.11 — Notification Panel
- **Satır:** 606–836
- **Ne yapar:** Modal bottom sheet içeriği: garanti uyarı ve son zimmet bildirimleri, okundu/okunmadı yönetimi.
- **Bağımlılıklar:** `DashboardData`, `List<Assignment>`, `Set<String> readNotifIds`, `onMarkRead` callback
- **Tipi:** Ayrı StatefulWidget (`_NotificationPanel` + `_NotificationPanelState`)
- **Satır sayısı:** ~231

### 2.12 — Panel Section Header
- **Satır:** 838–921
- **Ne yapar:** Notification panel'deki "GARANTİ UYARILARI" / "SON ZİMMETLER" başlık satırları.
- **Bağımlılıklar:** constructor param — bağımsız
- **Tipi:** Ayrı class (`_PanelSectionHeader`)
- **Satır sayısı:** ~84

### 2.13 — Warranty Notif Tile
- **Satır:** 923–1004
- **Ne yapar:** Notification panel'deki garanti uyarı satırı.
- **Bağımlılıklar:** `WarrantyAlertItem`, `isRead`, `onTap`
- **Tipi:** Ayrı class
- **Satır sayısı:** ~82

### 2.14 — Assignment Notif Tile
- **Satır:** 1006–1089
- **Ne yapar:** Notification panel'deki zimmet satırı.
- **Bağımlılıklar:** `Assignment`, `isRead`, `onTap`
- **Tipi:** Ayrı class
- **Satır sayısı:** ~84

### 2.15 — Section Header (Genel)
- **Satır:** 1093–1125
- **Ne yapar:** Tüm bölüm başlıkları (mavi çubuk + büyük harf metin).
- **Bağımlılıklar:** Yok — tamamen bağımsız
- **Tipi:** Ayrı class (`_SectionHeader`)
- **Satır sayısı:** ~33

### 2.16 — Dashboard Shimmer
- **Satır:** 1399–1458
- **Ne yapar:** Yükleme sırasında skeleton (2x3 grid + 4 hızlı işlem + 1 dikdörtgen).
- **Bağımlılıklar:** Yok — tamamen bağımsız
- **Tipi:** Ayrı class (`_DashboardShimmer`)
- **Satır sayısı:** ~60

### 2.17 — Dashboard Error
- **Satır:** 1462–1521
- **Ne yapar:** Hata durumunda tam ekran "Veriler yüklenemedi" widget'ı.
- **Bağımlılıklar:** `error` object, `onRetry` callback
- **Tipi:** Ayrı class (`_DashboardError`)
- **Satır sayısı:** ~60

---

## 3) Paylaşımlı State ve Callback'ler

### State Variables (_DashboardScreenState)
| Değişken | Tipi | Amacı |
|---|---|---|
| `_panelSeen` | `bool` | AppBar bildirim ikonunun "görüldü" durumu |
| `_alertShown` | `bool` | Kritik popup session başına bir kez gösterilsin |
| `_readNotifIds` | `Set<String>` | Okundu işaretlenen bildirim ID'leri |

### Parent-Child İletişim
- `_DashboardScreenState` → `_NotificationPanel`: `readNotifIds` (Set kopyası), `onMarkRead(id)` callback
- `_NotificationPanelState` → Parent: `widget.onMarkRead(id)` ile `setState(() => _readNotifIds.add(id))` tetiklenir → AppBar badge güncellenir
- `_NotificationPanelState._localRead`: parent'ın `_readNotifIds`'inin lokal kopyası — panel açıkken hem local hem parent güncellenir

### Provider Kullanımı
| Provider | Kullanıldığı Yer |
|---|---|
| `dashboardProvider` | `_DashboardScreenState.build()` (watch) + `_showCriticalAlert` (ref.read) |
| `recentAssignmentsProvider` | `_DashboardScreenState.build()` (watch) + `_showCriticalAlert` (ref.read) |
| `authProvider` | `_DashboardScreenState.build()` (watch) — AppBar'a aktarılır |

### Diğer Notlar
- `mounted` kontrolü: `addPostFrameCallback` içinde — ekran lifecycle'ı için kritik
- `WidgetsBinding.instance.addPostFrameCallback`: hem `_alertShown` tetiklemesinde hem de "İncele" butonunda kullanılıyor
- `GoRouter.of(context)`: `_NotificationPanel` içinde doğrudan kullanılıyor

---

## 4) Ayrıştırılabilir Widget Adayları

### 4.1 DashboardAppBar
- **Dosya:** `lib/features/dashboard/widgets/dashboard_app_bar.dart`
- **Widget adı:** `DashboardAppBar`
- **Constructor:** `DashboardAppBar({AuthState authState, int notifCount, bool panelSeen, VoidCallback onNotifTap})`
- **Bağımsızlık:** TAM BAĞIMSIZ — tüm veri constructor'dan geliyor, provider yok

### 4.2 NotificationPanel
- **Dosya:** `lib/features/dashboard/widgets/notification_panel.dart`
- **Widget adı:** `NotificationPanel` (public hale getirilir)
- **Constructor:** `NotificationPanel({DashboardData data, List<Assignment> recentAssignments, Set<String> readNotifIds, void Function(String) onMarkRead})`
- **İçinde kalacak:** `_PanelSectionHeader`, `_WarrantyNotifTile`, `_AssignmentNotifTile`
- **Bağımsızlık:** ORTA — callback ile parent state'i güncelliyor, GoRouter kullanıyor

### 4.3 DashboardKpiGrid
- **Dosya:** `lib/features/dashboard/widgets/dashboard_kpi_grid.dart`
- **Widget adı:** `DashboardKpiGrid`
- **Constructor:** `DashboardKpiGrid({required DashboardData data})`
- **Bağımsızlık:** TAM BAĞIMSIZ

### 4.4 QuickActionsRow
- **Dosya:** `lib/features/dashboard/widgets/quick_actions_row.dart`
- **Widget adı:** `QuickActionsRow`
- **Constructor:** `const QuickActionsRow()` — routing için sadece `context` gerekli
- **İçinde kalacak:** `_QuickAction`
- **Bağımsızlık:** TAM BAĞIMSIZ (sadece `context.go()` kullanıyor)

### 4.5 RecentActivitySection
- **Dosya:** `lib/features/dashboard/widgets/recent_activity_section.dart`
- **Widget adı:** `RecentActivitySection` (public)
- **Constructor:** `RecentActivitySection({required List<Assignment> items})`
- **Bağımsızlık:** TAM BAĞIMSIZ

### 4.6 WarrantyAlertsSection
- **Dosya:** `lib/features/dashboard/widgets/warranty_alerts_section.dart`
- **Widget adı:** `WarrantyAlertsSection` (public)
- **Constructor:** `WarrantyAlertsSection({required List<WarrantyAlertItem> items})`
- **Bağımsızlık:** TAM BAĞIMSIZ

### 4.7 DashboardShimmer
- **Dosya:** `lib/features/dashboard/widgets/dashboard_shimmer.dart`
- **Widget adı:** `DashboardShimmer` (public const)
- **Constructor:** `const DashboardShimmer()`
- **Bağımsızlık:** TAM BAĞIMSIZ

### 4.8 DashboardError
- **Dosya:** `lib/features/dashboard/widgets/dashboard_error.dart`
- **Widget adı:** `DashboardError`
- **Constructor:** `DashboardError({required Object error, required VoidCallback onRetry})`
- **Bağımsızlık:** TAM BAĞIMSIZ

### 4.9 SectionHeader
- **Dosya:** `lib/features/dashboard/widgets/section_header.dart`
- **Widget adı:** `DashboardSectionHeader`
- **Constructor:** `DashboardSectionHeader({required String title})`
- **Bağımsızlık:** TAM BAĞIMSIZ — tüm widgetlar paylaşabilir

---

## 5) Zor Olabilecek Yerler

### 5.1 _showCriticalAlert → _openNotifications zinciri
`_showCriticalAlert` dialog içindeki "İncele" butonu, kapandıktan sonra `_openNotifications`'ı `addPostFrameCallback` içinde çağırıyor. Bu iki method birbirini biliyor; `_DashboardScreenState` içinde kalmak zorundalar. Ayrı dosyaya taşınamaz.

### 5.2 _readNotifIds çift yönlü senkronizasyonu
`_readNotifIds` (parent) ↔ `_localRead` (NotificationPanel) arasında callback zinciri var. `NotificationPanel` ayrı dosyaya taşındığında `onMarkRead` callback imzası korunmalı; yoksa badge sayısı güncellenmez.

### 5.3 _recentShimmer() helper
`_DashboardContent` içindeki `_recentShimmer()` metodu shimmer kodu üretiyor. `RecentActivitySection` ayrı dosyaya çıkarılırsa bu shimmer ya `RecentActivitySection`'a taşınmalı ya da `_DashboardContent` içinde kalmalıdır. En temizi: `RecentActivitySection` kendi yükleme shimmer'ını içersin.

### 5.4 Dynamic type kullanımı (_WarrantySection)
`_WarrantySection.items` şu an `List<dynamic>` tipinde. Ayrı dosyaya taşırken `List<WarrantyAlertItem>` ile güçlü tiplendirme yapılabilir.

### 5.5 _greeting() ve DateFormat
`_DashboardAppBar._greeting()` metoduna bağımlılık yok, kolayca taşınır. `intl` import'u hedef dosyaya eklenmelidir.

### 5.6 GoRouter.of(context) — _NotificationPanel içinde
`_NotificationPanelState` içinde `Navigator.pop + router.go` kombinasyonu kullanılıyor. Ayrı dosyaya taşınca `go_router` import'u eklenmelidir — sorun değil.

---

## 6) Önerilen Split Planı

### Kaç dosya?
Ana dosya (`dashboard_screen.dart`) + 9 widget dosyası = **10 dosya toplam**

### Hangi widget'lar aynı dosyada kalsın?
- `NotificationPanel` + `_PanelSectionHeader` + `_WarrantyNotifTile` + `_AssignmentNotifTile` → `notification_panel.dart` (sıkı sıkıya birbirini kullanıyor)
- `QuickActionsRow` + `_QuickAction` → `quick_actions_row.dart` (QuickAction sadece buradan kullanılıyor)

### Split sırası (bağımlılığı azdan çoğa)

| Sıra | Dosya | Widget(ler) | Neden önce? |
|---|---|---|---|
| 1 | `section_header.dart` | `DashboardSectionHeader` | Hiç bağımlılık yok, diğerleri kullanıyor |
| 2 | `dashboard_shimmer.dart` | `DashboardShimmer` | Tamamen bağımsız, const |
| 3 | `dashboard_error.dart` | `DashboardError` | Sadece callback alıyor |
| 4 | `dashboard_kpi_grid.dart` | `DashboardKpiGrid` | StatCard'a bağımlı (zaten ayrı dosyada) |
| 5 | `warranty_alerts_section.dart` | `WarrantyAlertsSection` | Sadece model ve routing |
| 6 | `recent_activity_section.dart` | `RecentActivitySection` | Sadece model ve routing |
| 7 | `quick_actions_row.dart` | `QuickActionsRow` + `_QuickAction` | Sadece routing |
| 8 | `dashboard_app_bar.dart` | `DashboardAppBar` | Constructor params, bağımsız |
| 9 | `notification_panel.dart` | `NotificationPanel` + tile'lar | Callback zinciri var, en son |

### dashboard_screen.dart son hali (~220 satır)
Yalnızca şunları içerecek:
- `DashboardScreen` + `_DashboardScreenState`
- `_showCriticalAlert()` ve `_openNotifications()` metodları
- `_DashboardContent` (orchestrator — import listesi uzar ama sınıf kalır)
- **Alternatif:** `_DashboardContent` de `dashboard_content.dart`'a taşınabilir, o zaman screen sadece ~100 satır olur.

---

## Özet

| Metrik | Değer |
|---|---|
| Mevcut satır | 1521 |
| Hedef: screen dosyası | ~150–220 satır |
| Çıkarılacak widget dosyası | 9 |
| Tamamen bağımsız widget | 7 |
| Callback bağımlılığı olan | 2 (NotificationPanel, DashboardError) |
| State paylaşımı gerektiren | 1 (_readNotifIds ↔ NotificationPanel) |

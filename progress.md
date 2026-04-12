# AssetFlow Mobile — İlerleme Takibi

Son güncelleme: 2026-04-12 (Bildirim paneli + kapatılabilir uyarı banner'ları)

---

## Tamamlanan Özellikler

### Altyapı / Core
- [x] Flutter projesi kurulumu (Riverpod, GoRouter, Dio)
- [x] Dark tema (AppTheme, AppColors — tam renk paleti)
- [x] Google Fonts (Inter) entegrasyonu
- [x] ApiClient singleton — JWT interceptor, 401 → token refresh, pending request queue
- [x] TokenManager — access/refresh token + kullanıcı bilgisi (SharedPreferences)
- [x] CacheManager — TTL-based cache, offline `getStale` desteği
- [x] ConnectivityNotifier + OfflineBanner (10sn polling ile)
- [x] NotificationService — 5 kanal, 15 bildirim tipi (zimmet, garanti, cihaz, SAP, sistem)

### Auth
- [x] Login ekranı
- [x] Register ekranı (şirket adı dahil)
- [x] Auth guard (GoRouter redirect)
- [x] Şifre değiştirme (ProfileScreen)
- [x] Logout (token revoke + clearTokens)

### Dashboard
- [x] Stat kartları (Toplam Cihaz, Zimmetli, Depoda, Garanti Biten, Personel, Garanti Uyarı)
- [x] Garanti yaklaşanlar listesi (renk kodlu: kırmızı < 30gün, sarı < 90gün)
- [x] Shimmer loading skeleton
- [x] Pull-to-refresh

### Cihazlar
- [x] Cihaz listesi (pagination: 15/sayfa, infinite scroll)
- [x] Offline cache (sayfa 1, 15dk TTL)
- [x] Cihaz detay ekranı
- [x] Cihaz ekleme/düzenleme formu
- [x] Cihaz silme

### Personel
- [x] Personel listesi
- [x] Personel ekleme/düzenleme formu

### Zimmet
- [x] Zimmet listesi
- [x] Zimmet atama ekranı (cihaz + personel seçimi)
- [x] Zimmet iade
- [x] PDF export (open_file ile)

### Lokasyonlar
- [x] Lokasyon listesi
- [x] Lokasyon ekleme/düzenleme formu

### Profil
- [x] Kullanıcı bilgileri (ad, email, rol badge)
- [x] Şifre değiştirme (inline form)
- [x] Önbellek temizleme
- [x] Uygulama hakkında dialog
- [x] Güvenli çıkış (onay dialog)

---

## Sonraki Adımlar (Backlog)

### Faz 2 — Görselleştirme & Raporlama ✅
- [x] Dashboard — cihaz tipi dağılımı donut grafiği (`fl_chart`, `DeviceTypeChart` widget, dokunuş ile yüzde gösterimi)
- [x] Dashboard — son 5 aktif zimmet feed'i (`recentAssignmentsProvider`, offline cache destekli)
- [x] Zimmet geçmişi — Tümü / Aktif / Tamamlanan filtre chip'leri (`AssignmentFilter` enum, `isActive` query param)

### Faz 3 — Gelişmiş Özellikler ✅
- [x] Cihaz QR/barkod okuma — `QrScannerScreen` (mobile_scanner, overlay, el feneri/kamera flip), zimmet ekranında "QR Tara" butonu ile seri no/assetCode eşleştirme
- [x] Toplu cihaz import (CSV) — `DeviceImportScreen` (file_picker + csv, satır önizleme, sıralı import, başarı/hata sayacı), cihazlar AppBar'ına eklendi
- [x] Bildirim ayarları — `NotificationSettingsScreen` (5 kanal toggle, SharedPreferences), NotificationService kanal bazında kontrol ediyor, Profil ekranına eklendi
- [x] Lokasyon hiyerarşi görünümü — Bina > Kat > Lokasyon ExpansionTile ağacı, hiyerarşi/liste modu geçiş butonu, cihaz sayısı badge'leri

### Faz 4 — SAP Entegrasyonu ✅
- [x] SAP personel aktarımı — `SapScreen` + `SapNotifier.syncEmployees()`, yeni personel gelince `notifySapNewEmployee` tetikleniyor
- [x] SAP varlık import — `SapNotifier.syncAssets()`, `notifySapAssetsImported` entegreli
- [x] Bütçe onay bildirimleri — bekleyen bütçeler listesi, `notifySapBudgetApproved` entegreli
- [x] SAP bağlantı durumu kartı (yapılandırılmadı/bağlı/bağlantı yok)
- [x] "Daha Fazla" menüsüne SAP kartı eklendi
- [x] Backend 404/501 → graceful fallback mesajı

### Dashboard Redesign ✅
- [x] AppBar yenilendi — kullanıcı baş harfleri avatar (→ More ekranına yönlendirir), tarih göstergesi, logout kaldırıldı
- [x] SliverAppBar + CustomScrollView — scroll'da küçülen başlık
- [x] StatCard redesign — üst renk şeridi, büyük rakam, opsiyonel sublabel badge (%, KRİTİK, DİKKAT)
- [x] Kritik uyarı banner — garanti bitmiş = kırmızı, yaklaşan = sarı, akıllı koşullu gösterim
- [x] Hızlı İşlemler satırı — yatay scroll: Zimmet Ata, Cihaz Ekle, Personel Ekle, QR Tara
- [x] Bölüm başlıkları — sol mavi şerit + uppercase küçük metin, tüm bölümlerde tutarlı
- [x] Son Aktiviteler — tip bazlı renk (yeşil/mavi/turuncu), tip etiketi badge
- [x] Garanti Uyarıları — BİTTİ/KRİTİK/UYARI/NORMAL etiketleri, renk yoğunluğu urgency'ye göre
- [x] Hata ekranı — bulut ikon, net mesaj, Tekrar Dene butonu
- [x] Shimmer — grid + quick actions + activity için ayrı iskeletler
- [x] Kapatılabilir uyarı banner'ları — X butonu ile dismiss, "Gör" ile ilgili ekrana git, pull-to-refresh ile sıfırlanır
- [x] Bildirim paneli (bottom sheet) — AppBar'da çan ikonu + kırmızı rozet (expired+expiring sayısı), garanti uyarıları → cihaz detayı, son zimmetler → zimmetler ekranı

### Faz 5 — Polishing ✅
- [x] `print()` debug satırları temizlendi — auth_provider.dart'tan 4 print kaldırıldı, catch bloğu da temizlendi
- [x] Android splash screen — koyu arka plan (#111827), merkezi vektörel "AF" shield logosu, tüm API seviyeleri kapsandı
- [x] iOS build konfigürasyonu — NSCameraUsageDescription (QR), NSPhotoLibraryUsageDescription (CSV), DarwinInitializationSettings + DarwinNotificationDetails, portrait-only, CFBundleDisplayName "AssetFlow"
- [x] Release build API URL — `String.fromEnvironment('API_BASE_URL')` ile `--dart-define` desteği, default localhost:5160

---

## Teknik Borç ✅

- [x] Connectivity check — `google.com` DNS yerine API server TCP socket (`Socket.connect(host, port)`) ile kontrol; app-specific anlamı olan, DNS'e bağımlı olmayan yaklaşım
- [x] Test coverage — 25 birim + widget testi: CacheManager (5), TokenManager (4), AuthState (4), SapModels (6), DashboardData (3), OfflineBanner (2)
- [x] Android adaptive icon — `mipmap-anydpi-v26/ic_launcher.xml` (API 26+), koyu mavi arka plan + kalkan+envanter çizgileri foreground vektörü
- [x] iOS splash screen — `LaunchScreen.storyboard` güncellendi: koyu arka plan (#111827), AF rozeti, "AssetFlow" başlık, "IT Varlık Yönetimi" alt yazı

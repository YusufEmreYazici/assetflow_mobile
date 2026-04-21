# SPEC_MOBILE_006 — Full UI Redesign (Enterprise Pro)

**Tarih:** 21 Nisan 2026
**Proje:** assetflow_mobile (Flutter)
**Tahmini Süre:** 4-6 saat (3 faz halinde işaretli)
**Mimari Karar:** Üzerine yaz (eski ekranlar silinir)
**Claude Code Uygulama Stili:** Her task sonunda `flutter analyze` + git commit

---

## 📋 Özet

Mevcut mobile UI'ı **Enterprise Pro** (SAP Fiori / Salesforce Lightning havası) tasarım dili ile baştan yazıyoruz. Web AI (Claude.ai) ile üretilen 20 React mockup dosyası referans. Bu mockup'ları Flutter widget kodu olarak implement edeceğiz.

**Önemli:**
- Eski ekranlar **silinecek** (git revert ile geri alınabilir)
- Dashboard **iki varyasyon** (A: klasik 2x2, B: analytics), kullanıcı Ayarlar'dan toggle ile seçer
- Sol **Drawer** (hamburger menü) eklendi — çoğu ekrandan erişilebilir
- Bottom Navigation **4 sekmeye düşürüldü** (son sekme drawer açar)
- **16+ ekran** tasarlandı

---

## 🗂 Referans Dosyalar

Mockup kaynakları `/mnt/user-data/uploads/` dizininde:
- `tokens.css` — Design system (renk, tipografi)
- `ui.jsx` — Shared components (Header, Nav, TabBar, Chip, KV)
- `icons.jsx` — 40+ SVG icon
- `data.jsx` — Mock veriler
- `drawer.jsx` — AppDrawer
- `login.jsx` — Login
- `password-reset.jsx` — 3 şifre ekranı
- `dashboard-a.jsx` + `dashboard-b.jsx` — Dashboard varyasyonları
- `device-list.jsx` + `device-detail.jsx` + `device-form.jsx` — Cihaz ekranları
- `assign-wizard.jsx` — Zimmet wizard (4 step + dijital imza)
- `person.jsx` — Personel liste + detay
- `audit-log.jsx` — Merkezi audit log
- `profile-sap-export.jsx` — Profil, SAP sync, Excel export
- `location-notif.jsx` — Lokasyonlar, bildirim merkezi
- `states.jsx` — Empty/Loading/Error/Offline states
- `AssetFlow.html` — Tüm ekranları birleştiren ana sayfa

---

## 🎨 Design System (tokens.css'ten Flutter'a)

### Renk Paleti

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand / Primary
  static const Color navy = Color(0xFF1A3A5C);
  static const Color navyDark = Color(0xFF0F2845);
  static const Color navyLight = Color(0xFF4670A8);

  // Surface
  static const Color surfaceLight = Color(0xFFF0F4F8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceDivider = Color(0xFFE5EBF0);
  static const Color surfaceInputBorder = Color(0xFFD1DAE5);

  // Text
  static const Color textPrimary = Color(0xFF1A3A5C);
  static const Color textSecondary = Color(0xFF6B7A8C);
  static const Color textTertiary = Color(0xFF9CA8B8);

  // Semantic
  static const Color success = Color(0xFF2D8659);
  static const Color successBg = Color(0xFFE8F4ED);
  static const Color warning = Color(0xFFB85423);
  static const Color warningBg = Color(0xFFFDF3E7);
  static const Color error = Color(0xFFC53030);
  static const Color errorBg = Color(0xFFFDECEC);
  static const Color info = Color(0xFF4670A8);
  static const Color infoBg = Color(0xFFEAF0F8);

  // Dark theme (opsiyonel, şimdilik light)
  static const Color darkNavy = Color(0xFF4670A8);
  static const Color darkSurfaceLight = Color(0xFF0B1622);
  static const Color darkSurfaceWhite = Color(0xFF152235);
  static const Color darkTextPrimary = Color(0xFFE5EBF0);
}
```

### Tipografi

```dart
// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings (weight 500, ASLA 700)
  static TextStyle h1 = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: -0.2);
  static TextStyle h2 = GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: -0.1);
  static TextStyle h3 = GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  // Body
  static TextStyle body = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  // Label (UPPERCASE, letter-spacing)
  static TextStyle label = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 1);
  static TextStyle labelSmall = GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 1);

  // Caption
  static TextStyle caption = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle captionSmall = GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  // Mono (seri no, kod için)
  static TextStyle mono = GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
}
```

### Spacing & Radii

```dart
// lib/core/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class AppRadius {
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
}
```

---

## 🏗 Mimari Kararlar

### Klasör Yapısı

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   └── app_theme.dart
│   ├── widgets/
│   │   ├── app_drawer.dart           (YENİ)
│   │   ├── app_header.dart           (YENİ - navy header)
│   │   ├── page_header.dart          (YENİ)
│   │   ├── app_bottom_nav.dart       (YENİ - 4 sekme + more)
│   │   ├── app_chip.dart             (YENİ - status chip)
│   │   ├── kv_row.dart               (YENİ - key-value row)
│   │   ├── section_header.dart       (YENİ - UPPERCASE section label)
│   │   ├── app_button.dart           (YENİ - primary/secondary)
│   │   ├── app_input.dart            (YENİ - input field)
│   │   ├── app_tab_bar.dart          (YENİ - detay sayfası tab'ı)
│   │   └── empty_state.dart          (YENİ)
│   └── navigation/
│       ├── app_router.dart           (GÜNCELLENDİ - yeni rotalar)
│       └── app_shell.dart            (YENİ - bottom nav shell)
├── features/
│   ├── auth/
│   │   ├── login_screen.dart         (ÜZERİNE YAZILDI)
│   │   ├── forgot_password_screen.dart         (YENİ)
│   │   ├── password_email_sent_screen.dart     (YENİ)
│   │   └── reset_password_screen.dart          (YENİ)
│   ├── dashboard/
│   │   ├── dashboard_screen.dart     (YENİDEN YAZILDI - variant A/B toggle)
│   │   ├── widgets/
│   │   │   ├── dashboard_a_view.dart
│   │   │   ├── dashboard_b_view.dart
│   │   │   ├── kpi_card.dart
│   │   │   ├── activity_tile.dart
│   │   │   ├── quick_action.dart
│   │   │   ├── mini_bar_chart.dart
│   │   │   ├── status_bar.dart
│   │   │   └── metric_strip.dart
│   ├── devices/
│   │   ├── device_list_screen.dart          (ÜZERİNE YAZILDI)
│   │   ├── device_detail_screen.dart        (YENİDEN YAZILDI - 4 tab)
│   │   ├── device_form_screen.dart          (ÜZERİNE YAZILDI - 4 step wizard)
│   │   └── widgets/
│   │       ├── device_row.dart
│   │       ├── device_detail_header.dart
│   │       ├── device_general_tab.dart
│   │       ├── device_hardware_tab.dart
│   │       ├── device_assignments_tab.dart
│   │       └── device_history_tab.dart
│   ├── people/
│   │   ├── person_list_screen.dart          (YENİ)
│   │   ├── person_detail_screen.dart        (YENİ)
│   ├── assignments/
│   │   ├── assign_wizard_screen.dart        (ÜZERİNE YAZILDI - 4 step)
│   │   └── widgets/
│   │       ├── step_indicator.dart
│   │       ├── person_pick_row.dart
│   │       ├── device_pick_row.dart
│   │       └── signature_pad.dart
│   ├── locations/
│   │   ├── location_list_screen.dart        (YENİ)
│   │   └── location_detail_screen.dart      (YENİ)
│   ├── notifications/
│   │   └── notifications_screen.dart        (ÜZERİNE YAZILDI)
│   ├── audit_log/
│   │   └── audit_log_screen.dart            (YENİ - merkezi audit log)
│   ├── profile/
│   │   ├── profile_screen.dart              (YENİ)
│   │   └── settings_screen.dart             (YENİ - dashboard variant toggle burada)
│   ├── sap/
│   │   └── sap_sync_screen.dart             (YENİ)
│   └── export/
│       └── excel_export_screen.dart         (YENİ)
└── ...
```

### State Management (Riverpod)

- Mevcut provider'lar **korunacak** (auth, device, assignment, form, audit_log)
- Yeni provider'lar eklenecek:
  - `dashboardVariantProvider` — StateProvider<DashboardVariant> (a/b toggle)
  - `darkModeProvider` — StateProvider<bool> (ayarlar)
  - `peopleListProvider` — personel listesi
  - `locationsProvider` — lokasyon listesi

### Backend Entegrasyonu

- **Yeni ekranlar için backend endpoint kontrolü gereksinimi:**
  - Personel listesi: `/api/employees` (mevcut olduğunu varsayıyoruz, kontrol edilecek)
  - Lokasyonlar: `/api/locations` (muhtemelen yok, mock data ile başlayacak)
  - Merkezi audit log: `/api/audit-logs` (cihaz bazlı var, genel yok — mock ile başla)
- **Mock data fallback:** Yeni ekranlar için gerçek API yoksa `data.jsx`'teki mock veriler Flutter model'larına çevrilip sabit listeler olarak konacak
- **SharedPreferences:** Dashboard variant, dark mode, bildirim tercihleri için

---

## 🚧 Görev Listesi (Faz 1-2-3)

**KRİTİK KURAL:** Her T# görevinden sonra:
1. `flutter analyze` (0 hata, 0 warning)
2. `git add -A && git commit -m "Task T#: [görev başlığı]"`
3. Eğer görev bir ekran içeriyorsa, emulator'de ekranın açıldığını doğrula
4. Hata varsa durdur, Emre'ye raporla, çözmeden devam etme

---

### 🎯 FAZ 1 — Temel Altyapı (Tahmini 1.5 saat)

Bu faz bitmeden Faz 2 başlayamaz. Tema ve ortak component'lar her ekranda kullanılacak.

#### T1: Design System — Theme Dosyaları ✨
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/theme/app_colors.dart` (yeni)
- `lib/core/theme/app_text_styles.dart` (yeni)
- `lib/core/theme/app_spacing.dart` (yeni)
- `lib/core/theme/app_theme.dart` (güncelle)
- `pubspec.yaml` (google_fonts varsa kontrol, yoksa ekle)

**Yapılacak:**
1. Yukarıdaki kod bloklarını (`app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`) oluştur
2. `app_theme.dart`'ı güncelle:
   ```dart
   ThemeData lightTheme = ThemeData(
     scaffoldBackgroundColor: AppColors.surfaceLight,
     primaryColor: AppColors.navy,
     fontFamily: GoogleFonts.inter().fontFamily,
     appBarTheme: AppBarTheme(
       backgroundColor: AppColors.navy,
       foregroundColor: Colors.white,
       elevation: 0,
     ),
     // ... diğer theme ayarları
   );
   ```
3. `main.dart` / `app.dart` içinde `theme: AppTheme.lightTheme` kullanıldığından emin ol
4. Eski renk tanımlamaları (eğer varsa `lib/core/constants/colors.dart` gibi) **silme**, sadece yeni `AppColors`'ı kullan; eski constants dosyası kalırsa clash olmasın

**Test:** `flutter analyze` ✓ + uygulama açılıyor mu

**Commit:** `feat: add Enterprise Pro design system (colors, typography, spacing)`

---

#### T2: Shared Widget'lar — Core (1/2) ✨
**Süre:** 25 dk
**Dosyalar:**
- `lib/core/widgets/app_chip.dart` (yeni)
- `lib/core/widgets/kv_row.dart` (yeni)
- `lib/core/widgets/section_header.dart` (yeni)
- `lib/core/widgets/app_button.dart` (yeni)
- `lib/core/widgets/app_input.dart` (yeni)

**Referans:** `ui.jsx` içindeki `Chip`, `KV`, `SectionHeader` + `tokens.css` input/button class'ları

**Yapılacak:**
1. **AppChip** — status chip (`success`, `info`, `warning`, `error`, `neutral` tone'larda)
2. **KvRow** — detay sayfalarında anahtar-değer satırı (mono opsiyonu ile)
3. **SectionHeader** — UPPERCASE section başlığı + opsiyonel sağ widget
4. **AppButton** — primary (navy bg) ve secondary (beyaz bg, navy border) varyantları
5. **AppInput** — focus'ta navy border olan input field

Her widget için `const` constructor, Key parameter, doğru tipografi.

**Test:** `flutter analyze` ✓ + widget'ları örnek bir sayfada render et

**Commit:** `feat: add core shared widgets (chip, kv, section_header, button, input)`

---

#### T3: Shared Widget'lar — Navigation (2/2) ✨
**Süre:** 30 dk
**Dosyalar:**
- `lib/core/widgets/app_header.dart` (yeni)
- `lib/core/widgets/page_header.dart` (yeni)
- `lib/core/widgets/app_bottom_nav.dart` (yeni)
- `lib/core/widgets/app_tab_bar.dart` (yeni)
- `lib/core/widgets/app_drawer.dart` (yeni)

**Referans:** `ui.jsx` (`AppHeader`, `PageHeader`, `BottomNav`, `TabBar`) + `drawer.jsx`

**Yapılacak:**
1. **AppHeader** — Dashboard için navy header (kullanıcı bilgisi, bildirim ikonu, menü ikonu)
2. **PageHeader** — Diğer ekranlar için compact navy header (back + title + subtitle + action)
3. **AppBottomNav** — 4 sekme: Anasayfa, Cihazlar, Personel, Daha Fazla (drawer açar)
4. **AppTabBar** — Detay sayfalarında kullanılan sub-tab bar
5. **AppDrawer** — Sol kayar menü, `drawer.jsx`'deki 4 section (YÖNETİM/RAPORLAR/SİSTEM/YARDIM)
   - Üst kısım: profil header (navy, avatar + ad + rol badge)
   - Her menü item'da badge desteği (rakam veya "N aktif")
   - Aktif sayfa: sol border + background
   - Alt: Çıkış Yap (error color) + versiyon

Navigation callback'leri için `onTap`, `onChange`, `onMore` parameter'ları al. Drawer kapanması `Navigator.pop(context)` ile.

**Test:** `flutter analyze` ✓ + emulator'de bir ekrana drawer ekle, açıl/kapan

**Commit:** `feat: add navigation widgets (app_header, page_header, bottom_nav, tab_bar, drawer)`

---

#### T4: Login Ekranı (Üzerine Yazılıyor) 🔐
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/auth/login_screen.dart` (ÜZERİNE YAZ, mevcut silinir)

**Referans:** `login.jsx`

**Yapılacak:**
1. Mevcut `login_screen.dart`'ı sil, yerine yenisini yaz
2. Ekran yapısı:
   - Büyük "Asset" (weight 500) + "Flow" (weight 300) wordmark (navy)
   - Tagline: "IT VARLIK YÖNETİM SİSTEMİ" (UPPERCASE, letter-spacing)
   - İnce dikey divider (32px navy)
   - Açıklama metni: "Kurumsal hesabınızla giriş yaparak..."
   - E-posta input (mail icon prefix)
   - Şifre input (lock icon prefix, eye toggle suffix)
   - "Şifremi unuttum" link (sağa hizalı)
   - Primary button: "Giriş Yap" (loading state'li, navy→navyDark)
   - Divider: "veya" metni
   - Secondary button: "SSO ile giriş (Active Directory)"
   - Footer: versiyon + copyright
3. **API entegrasyonu:** Mevcut `authProvider` kullanılacak, değiştirilmesin
4. **"Şifremi unuttum":** `Navigator.pushNamed(context, '/forgot-password')` (T5'te tanımlanacak)
5. **SSO butonu:** Şu an için `ScaffoldMessenger` snackbar "Yakında" göstersin

**Test:** Login çalışıyor mu, eski kullanıcıyla giriş yap (test@assetflow.com / Test1234.)

**Commit:** `feat: redesign login screen (Enterprise Pro)`

---

#### T5: Şifre Sıfırlama Akışı (3 Ekran, Yeni) 🔐
**Süre:** 35 dk
**Dosyalar:**
- `lib/features/auth/forgot_password_screen.dart` (yeni)
- `lib/features/auth/password_email_sent_screen.dart` (yeni)
- `lib/features/auth/reset_password_screen.dart` (yeni)
- `lib/core/navigation/app_router.dart` (rotaları ekle)

**Referans:** `password-reset.jsx`

**Yapılacak:**
1. **ForgotPasswordScreen:** Email input + validation + "Sıfırlama Linki Gönder" butonu + geri dönüş
2. **PasswordEmailSentScreen:** Yeşil checkmark icon + email gösterimi + "Yeniden gönder" (60sn cooldown timer) + "Giriş'e dön"
3. **ResetPasswordScreen:** Yeni şifre + tekrar şifre + şifre güçlülük göstergesi (4 segment, renk-kodlu) + validation + "Şifreyi Güncelle" butonu + başarı ekranı
4. Rotalar: `/forgot-password`, `/password-sent`, `/reset-password`
5. **Backend:** Şu an için gerçek API olmadığından mock davran (setTimeout simulate), backend endpoint'i yoksa todo ekle

**Test:** Tüm 3 ekran navigate ediliyor, validation çalışıyor

**Commit:** `feat: add password reset flow (3 screens)`

---

#### T6: App Shell + Router Güncellemesi 🧭
**Süre:** 30 dk
**Dosyalar:**
- `lib/core/navigation/app_shell.dart` (yeni)
- `lib/core/navigation/app_router.dart` (büyük update)
- `lib/main.dart` veya `lib/app.dart` (shell'e yönlendir)

**Yapılacak:**
1. **AppShell** — Scaffold + `AppBottomNav` + `AppDrawer` sarmalayıcı
   - IndexedStack ile 4 tab child'ı (home, devices, people, more)
   - `scaffoldKey.currentState?.openDrawer()` için ref
   - "Daha Fazla" sekmesi drawer açar
2. **Router güncellemesi** — tüm yeni rotalar eklensin:
   ```dart
   '/': const LoginScreen(),
   '/forgot-password': const ForgotPasswordScreen(),
   '/password-sent': const PasswordEmailSentScreen(),
   '/reset-password': const ResetPasswordScreen(),
   '/shell': const AppShell(),  // login sonrası buraya
   '/device/:id': (context) => DeviceDetailScreen(...),
   '/device/new': const DeviceFormScreen(),
   '/assign/new': const AssignWizardScreen(),
   '/person/:id': (context) => PersonDetailScreen(...),
   '/location/:id': (context) => LocationDetailScreen(...),
   '/audit-log': const AuditLogScreen(),
   '/profile': const ProfileScreen(),
   '/settings': const SettingsScreen(),
   '/sap-sync': const SapSyncScreen(),
   '/excel-export': const ExcelExportScreen(),
   '/notifications': const NotificationsScreen(),
   ```
3. Login sonrası **`/shell`'e push replacement** (mevcut `/dashboard` yerine)
4. Drawer item'lar tıklanınca `Navigator.pushNamed(context, item.route)` + drawer kapatma

**Test:** Login → Shell → Drawer aç → Her menu item'a tıklayıp navigate et (boş ekranlar olabilir, önemli değil)

**Commit:** `feat: add app shell with bottom nav and drawer navigation`

---

### 🎯 FAZ 2 — Ana Ekranlar (Tahmini 2.5 saat)

Faz 1'in bittiğini doğrula (tema, drawer, shell, login akışı çalışıyor). Sonra başla.

#### T7: Dashboard Variant Toggle Altyapısı 🎛
**Süre:** 15 dk
**Dosyalar:**
- `lib/features/dashboard/providers/dashboard_variant_provider.dart` (yeni)
- `lib/features/dashboard/providers/dashboard_variant_provider.g.dart` (codegen, opsiyonel)

**Yapılacak:**
1. Riverpod provider:
   ```dart
   enum DashboardVariant { a, b }

   final dashboardVariantProvider = StateProvider<DashboardVariant>((ref) {
     // SharedPreferences'tan oku, default: a
     return DashboardVariant.a;
   });
   ```
2. SharedPreferences entegrasyonu (read on init, write on change)
3. Ayarlar ekranında (T20) toggle eklenecek

**Commit:** `feat: add dashboard variant provider (A/B toggle)`

---

#### T8: Dashboard Varyasyon A — Klasik 2×2 📊
**Süre:** 45 dk
**Dosyalar:**
- `lib/features/dashboard/dashboard_screen.dart` (YENİDEN YAZ)
- `lib/features/dashboard/widgets/dashboard_a_view.dart` (yeni)
- `lib/features/dashboard/widgets/kpi_card.dart` (yeni)
- `lib/features/dashboard/widgets/activity_tile.dart` (yeni)
- `lib/features/dashboard/widgets/quick_action.dart` (yeni)

**Referans:** `dashboard-a.jsx`

**Yapılacak:**
1. **DashboardScreen** — Consumer widget, variant provider'a göre A veya B view render eder
2. **DashboardAView** yapısı:
   - AppHeader (kullanıcı, bildirim, menü)
   - SectionHeader "ÖZET" + 2x2 KpiCard grid:
     - Toplam Cihaz (navy accent)
     - Aktif Zimmet (success accent)
     - Personel (gri accent)
     - Uyarılar (warning accent + warningBg)
   - SectionHeader "HIZLI İŞLEMLER" + 2 QuickAction (Yeni Cihaz primary, Zimmetle secondary)
   - SectionHeader "AKTİVİTE AKIŞI" + card + 5 ActivityTile
   - SectionHeader "GARANTİ UYARILARI" + warning card (7 cihaz 60 gün içinde)
3. **KpiCard**: sol kenar 3px accent border, label (UPPERCASE) + value (24px navy) + delta (caption)
4. **ActivityTile**: sol renkli nokta, üst bilgi (ENTITY uppercase + zaman), ana satır (weight 500), alt satır (secondary)
5. **QuickAction**: ikon + label, primary/secondary varyantlı
6. **API:** Mevcut `dashboardProvider`'a bağla (eğer yoksa mock data ile başla)

**Test:** Dashboard A görünüyor, KPI'lar gerçek veri gösteriyor

**Commit:** `feat: add dashboard variant A (classic 2x2 KPI)`

---

#### T9: Dashboard Varyasyon B — Analytics 📊
**Süre:** 40 dk
**Dosyalar:**
- `lib/features/dashboard/widgets/dashboard_b_view.dart` (yeni)
- `lib/features/dashboard/widgets/mini_bar_chart.dart` (yeni)
- `lib/features/dashboard/widgets/status_bar.dart` (yeni)
- `lib/features/dashboard/widgets/metric_strip.dart` (yeni)

**Referans:** `dashboard-b.jsx`

**Yapılacak:**
1. **DashboardBView** yapısı:
   - AppHeader (aynı)
   - Hero KPI kartı: büyük "158 toplam cihaz" + "▲ 3 BU AY" badge + MiniBarChart (son 6 ay) + StatusBar (Zimmetli/Depoda/Bakımda/Emekli segmentleri)
   - 3'lü MetricStrip: Aktif Zimmet, Personel, Uyarı
   - 3'lü QuickAction: Cihaz, Zimmet, İade
   - SectionHeader "SON HAREKETLER" + 4 ActivityTile
   - SectionHeader "LOKASYON DAĞILIMI" + 5 satır (lokasyon + sayı + progress bar)
2. **MiniBarChart**: basit CustomPainter veya Container array ile 6 bar (son ay vurgulu)
3. **StatusBar**: horizontal segment bar + legend (2x2 grid)
4. **MetricStrip**: üst border-top 2px accent, label + value + trend

**Test:** Dashboard B görünüyor, toggle değiştirince arasında geçiş oluyor (Ayarlar'dan T20'de bağlanacak, şimdilik hardcode test)

**Commit:** `feat: add dashboard variant B (analytics)`

---

#### T10: Cihaz Listesi Ekranı (Üzerine Yaz) 💻
**Süre:** 35 dk
**Dosyalar:**
- `lib/features/devices/device_list_screen.dart` (ÜZERİNE YAZ)
- `lib/features/devices/widgets/device_row.dart` (yeni)

**Referans:** `device-list.jsx`

**Yapılacak:**
1. Mevcut `device_list_screen.dart`'ı sil, yeniden yaz
2. Yapı:
   - PageHeader (title: "Cihazlar", subtitle: "N CİHAZ", back=drawer, action=plus button)
   - Search field (navy focus, ikon prefix, filter ikonu suffix)
   - Filter chips scroll: Tümü / Zimmetli / Depoda / Bakımda / Emekli
   - ListView: DeviceRow'lar (navy backgrounded type icon + name + AppChip status + kod + zimmetli kişi + chevron)
   - FAB: plus button (navy, shadow)
   - BottomNav + AppDrawer
3. **API:** Mevcut `deviceProvider` + `AssignmentService.isActive` filter bug'ı düzeltilmiş hali (bu bugün çalışıyor)
4. Tıklayınca `Navigator.pushNamed('/device/${d.id}')`

**Test:** 158 cihaz listeleniyor, filter çalışıyor, search çalışıyor

**Commit:** `feat: redesign device list screen (Enterprise Pro)`

---

#### T11: Cihaz Detay Ekranı (Yeniden Yaz, 4 Tab) 💻
**Süre:** 60 dk
**Dosyalar:**
- `lib/features/devices/device_detail_screen.dart` (YENİDEN YAZ)
- `lib/features/devices/widgets/device_detail_header.dart` (yeni)
- `lib/features/devices/widgets/device_general_tab.dart` (yeni)
- `lib/features/devices/widgets/device_hardware_tab.dart` (yeni)
- `lib/features/devices/widgets/device_assignments_tab.dart` (yeni)
- `lib/features/devices/widgets/device_history_tab.dart` (yeni — audit log!)

**Referans:** `device-detail.jsx`

**Yapılacak:**
1. Mevcut `device_detail_screen.dart`'ı sil
2. **DeviceDetailHeader** — navy header, back/edit/more butonları, cihaz adı, tip+kod (subtitle), status chip veya 3'lü strip (variant)
3. **TabBar** 4 sekme: Genel / Donanım / Zimmetler / Geçmiş
4. **GenelTab** — Marka/Model/Seri/Demirbaş/AssetTag/Lokasyon/Durum + SatınAlma/Garanti section
5. **DonanımTab** — CPU/RAM/Storage/GPU/Hostname/OS/MAC/IP/BIOS/Motherboard (KvRow'lar)
6. **ZimmetlerTab** — Mevcut zimmet card (success border-left, AKTİF chip) + geçmiş zimmetler listesi
7. **GeçmişTab** — Audit log timeline (SOL vertical line + renkli dot + card), ExpansionTile ile detay (kırmızı üstü çizili → yeşil bold). **Mevcut `auditLogProvider` kullanılacak!**
8. FloatingActionButton (BottomSheet altında): aktifse "İade Et" (warning), değilse "Zimmetle" (navy)

**Test:** Samsung S27A600N cihazına tıklayıp tüm 4 tab'ı gez, audit log expand çalışıyor

**Commit:** `feat: redesign device detail screen with 4 tabs`

---

#### T12: Cihaz Form (4 Step Wizard) 💻
**Süre:** 40 dk
**Dosyalar:**
- `lib/features/devices/device_form_screen.dart` (ÜZERİNE YAZ)
- `lib/features/assignments/widgets/step_indicator.dart` (yeni, assign wizard için de kullanılacak)

**Referans:** `device-form.jsx`

**Yapılacak:**
1. Mevcut cihaz ekleme/düzenleme formunu sil, yeniden yaz
2. **StepIndicator** widget (4 step: Temel/Donanım/Alım/Lokasyon, aktif/tamam/pasif durumları)
3. 4 adım:
   - **Temel:** Tip dropdown (9 tip), Marka dropdown, Model, Seri No, Demirbaş Kodu (mono)
   - **Donanım:** CPU, RAM dropdown, Storage dropdown, Hostname (mono), OS dropdown
   - **Alım:** Tarih, Tedarikçi, Fatura No (mono), Garanti Süresi dropdown
   - **Lokasyon:** Lokasyon dropdown, Durum dropdown, Notlar (textarea)
4. Alt barrda: Geri (secondary) + İleri (primary) / Kaydet (success)
5. **Cihaz tipine göre koşullu donanım alanları:** SPEC_MOBILE_005'te eklenmişti, burada da korunacak (Monitor = 0 donanım alanı, Phone = 6 alan vs.)
6. **API:** Mevcut `deviceProvider.create/update` kullanılacak

**Test:** Yeni cihaz ekle, tipi Monitor seç → donanım tab'ı boş görünsün. Tipi Laptop seç → 10 alan görünsün.

**Commit:** `feat: redesign device form with 4-step wizard`

---

#### T13: Zimmet Wizard (4 Step + İmza) 📝
**Süre:** 50 dk
**Dosyalar:**
- `lib/features/assignments/assign_wizard_screen.dart` (ÜZERİNE YAZ)
- `lib/features/assignments/widgets/person_pick_row.dart` (yeni)
- `lib/features/assignments/widgets/device_pick_row.dart` (yeni)
- `lib/features/assignments/widgets/signature_pad.dart` (yeni)

**Referans:** `assign-wizard.jsx`

**Yapılacak:**
1. Mevcut zimmet oluşturma akışını sil, yeniden yaz
2. 4 step:
   - **Step 1 — Kişi:** Search + PersonPickRow listesi (initials avatar + name + title + checkmark)
   - **Step 2 — Cihaz:** Seçilen kişi bilgisi üstte, DevicePickRow listesi (sadece status=Depoda filter!)
   - **Step 3 — Şartlar:** Başlangıç tarihi, Süre dropdown, Kişisel kullanım checkbox, Yurt dışı checkbox, Notlar
   - **Step 4 — Özet + İmza:** 3 card (Özet/Cihaz/Şartlar) + SignaturePad
3. **SignaturePad** — şu an için "tıklayınca imzalanmış görünsün" mock (ileride gerçek signature_pad paketi eklenecek, bu SPEC dışı)
4. Alt bar: Geri + İleri / Onayla ve Gönder (success)
5. **API:** Mevcut `assignmentService.create` kullanılacak, signature metadata eklenirse sonra düşünürüz

**Test:** Yeni zimmet oluştur, tüm 4 step'i geç, imzala, ZMT numarası generate olsun

**Commit:** `feat: redesign assignment wizard (4 steps with signature)`

---

### 🎯 FAZ 3 — Ek Ekranlar (Tahmini 2 saat)

Faz 2 bitince kritik ekranlar tamam. Faz 3 diğerlerini ekler.

#### T14: Personel Liste + Detay 👥
**Süre:** 35 dk
**Dosyalar:**
- `lib/features/people/person_list_screen.dart` (yeni)
- `lib/features/people/person_detail_screen.dart` (yeni)

**Referans:** `person.jsx`

**Yapılacak:**
1. **PersonListScreen:** Alfabetik gruplu (A, B, C...) personel listesi, avatar+name+title+sicil+cihaz sayısı, search
2. **PersonDetailScreen:** Navy header + avatar + 3'lü mini strip (Zimmet/Lokasyon/Başlangıç) + 3 tab (Zimmetler/İletişim/Geçmiş)
3. **API:** Eğer `/api/employees` yoksa mock data'dan oku (data.jsx'teki PEOPLE listesi Flutter model'a çevrilsin)
4. Rotalar: `/person/:id`

**Commit:** `feat: add person list and detail screens`

---

#### T15: Lokasyonlar Liste + Detay 📍
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/locations/location_list_screen.dart` (yeni)
- `lib/features/locations/location_detail_screen.dart` (yeni)

**Referans:** `location-notif.jsx`

**Yapılacak:**
1. **LocationListScreen:** 8-12 lokasyon card'ı (her biri: isim, tip, 3'lü metric grid — cihaz/personel/aktif%)
2. **LocationDetailScreen:** Lokasyon detayı (basit — isim, adres, cihaz sayısı, personel listesi)
3. **Mock data:** `data.jsx` LOCATIONS + LOCATION_DATA'yı Flutter'a çevir

**Commit:** `feat: add location screens`

---

#### T16: Bildirim Merkezi (Üzerine Yaz) 🔔
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/notifications/notifications_screen.dart` (ÜZERİNE YAZ)

**Referans:** `location-notif.jsx` (NotificationCenterScreen kısmı)

**Yapılacak:**
1. Mevcut bildirim ekranını sil, yeniden yaz
2. Üst tab: Tümü / Okunmamış / Garanti Uyarıları / Sistem
3. Bildirim kartı: icon + başlık + detay + zaman + okundu noktası
4. Sağ üst: "Tümünü okundu işaretle" butonu
5. **API:** Mevcut `notificationProvider` + persistent read state (SeenNotificationStore) korunacak

**Commit:** `feat: redesign notifications screen`

---

#### T17: Merkezi Audit Log 📋
**Süre:** 35 dk
**Dosyalar:**
- `lib/features/audit_log/audit_log_screen.dart` (yeni)

**Referans:** `audit-log.jsx`

**Yapılacak:**
1. Tarih grupları (21.04.2026, 20.04.2026 vs.)
2. Filter chips: Tümü / Oluşturma / Güncelleme / Silme / Sistem
3. Log satırı: renkli dot + CREATE/UPDATE/DELETE/SYSTEM badge + user+action+entity+time + expandable diff
4. **Backend:** `/api/audit-logs` (tüm sistem) endpoint'i şu an sadece device-specific. Yeni endpoint gerekli olabilir. Şimdilik **mevcut `/api/audit-logs/device/{id}` endpoint'ini farklı cihazlar için birleştir** veya mock data ile başla. Backend SPEC ayrıca yazılacak.
5. Rotası `/audit-log`, drawer'dan erişilir

**Commit:** `feat: add central audit log screen`

---

#### T18: Profil Ekranı 👤
**Süre:** 25 dk
**Dosyalar:**
- `lib/features/profile/profile_screen.dart` (yeni)

**Referans:** `profile-sap-export.jsx` (ProfileScreen kısmı)

**Yapılacak:**
1. Üst: kullanıcı card'ı (büyük avatar, ad, title, sicil, edit icon)
2. Section'lar: HESAP (email, departman, lokasyon, şifre değiştir) / TERCİHLER (bildirim, email, karanlık mod, dil) / GÜVENLİK (2FA, aktif oturumlar) / HAKKINDA / Çıkış Yap
3. Row widget toggle'lı, chevron'lu, icon'lu
4. **API:** Mevcut `authProvider.user`, şifre değiştir mock

**Commit:** `feat: add profile screen`

---

#### T19: Ayarlar Ekranı + Dashboard Toggle 🎛
**Süre:** 20 dk
**Dosyalar:**
- `lib/features/profile/settings_screen.dart` (yeni)

**Yapılacak:**
1. Dashboard Görünümü section: "Klasik (A)" vs "Analytics (B)" — segmented button veya radio
2. Karanlık mod toggle (UI sadece, dark theme sonra)
3. Dil seçimi (TR only şimdilik)
4. Bildirim tercihleri
5. Cache temizle butonu
6. **Önemli:** Dashboard toggle değiştiğinde `dashboardVariantProvider` güncellenir, SharedPreferences yazılır

**Test:** Ayarlar → Dashboard A→B değiştir, anasayfaya dön, A yerine B görünsün

**Commit:** `feat: add settings screen with dashboard variant toggle`

---

#### T20: SAP Sync + Excel Export 🔄
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/sap/sap_sync_screen.dart` (yeni)
- `lib/features/export/excel_export_screen.dart` (yeni)

**Referans:** `profile-sap-export.jsx`

**Yapılacak:**
1. **SapSyncScreen:** Bağlantı durumu card (yeşil dot) + son sync tarihi + 3 sync butonu (Personel/Cihaz/Bütçe) + sync log listesi. **Backend SPEC_BACKEND_001 (SAP Mock) kullanılacak**
2. **ExcelExportScreen:** Rapor tipleri listesi, her biri card (Tüm cihazlar, Aktif zimmetler, Personel listesi, Garanti uyarıları, Audit log) + filtreler + "Excel İndir" butonu + geçmiş raporlar

**Commit:** `feat: add SAP sync and excel export screens`

---

#### T21: Empty/Loading/Error States (Reusable) 🎭
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/widgets/empty_state.dart` (yeni)
- `lib/core/widgets/loading_state.dart` (yeni)
- `lib/core/widgets/error_state.dart` (yeni)

**Referans:** `states.jsx`

**Yapılacak:**
1. **EmptyState:** icon + title + body + opsiyonel CTA butonu
2. **LoadingState:** Shimmer skeleton (5 satır), `shimmer` paketi yoksa manuel animasyon
3. **ErrorState:** 3 tip (network/403/500), her birinin ikon/renk/mesaj kombinasyonu
4. Liste ekranlarında (cihaz, personel, lokasyon) boş durum için kullan

**Commit:** `feat: add reusable empty/loading/error state widgets`

---

#### T22: Final Temizlik + Test Turu ✅
**Süre:** 20 dk
**Dosyalar:** — (analiz ve temizlik)

**Yapılacak:**
1. `flutter analyze` — 0 hata, 0 warning olmalı
2. Unused import'ları temizle
3. Mevcut silinmesi gereken eski dosyaları kontrol et:
   - Eski dashboard widget'ları
   - Eski theme dosyası (eğer ayrıysa)
   - Eski constants
4. Emulator'de **tam test turu:**
   - Login → Dashboard A görünüyor → Ayarlar → Dashboard B aktif → Geri → Dashboard B
   - Drawer aç → Tüm menu item'lara tıkla, ekranlar açılıyor
   - Cihaz listesi → Cihaz seç → 4 tab gez → Audit log expand et → İade et butonu görünüyor
   - Personel listesi → Detay
   - Zimmet wizard tam tur
5. `pubspec.yaml` version bump: `2.0.0+20`

**Commit:** `chore: final cleanup and v2.0.0 bump`

---

## 🧪 Test Stratejisi

- **Her Faz sonunda:** Emre emulator'de manuel test yapar, regresyon varsa rapor verir
- **Claude Code için:** Her T#'te flutter analyze + commit zorunlu
- **Bug bulunursa:** Yeni task eklemeden önce bug fix, commit, test, sonra devam

---

## ⚠️ Bilinen Riskler

1. **Context overflow:** Claude Code 15+ task sonrası yorgunlaşabilir. Faz 1 → dur → yeni oturum → Faz 2 gibi ayırmak gerekebilir
2. **Google Fonts internet bağlantısı:** İlk run'da font indirilir, offline test için eklenmeden önce `GoogleFonts.config.allowRuntimeFetching = false` ayarla + asset'e göm
3. **Backend endpoint eksikleri:** Merkezi audit log, lokasyonlar için endpoint yok. Mock ile başla, sonra ayrı SPEC
4. **Signature pad:** Mock dijital imza şimdilik, `signature` paketi eklenmedi
5. **Dark mode:** Tokens hazır ama theme switcher UI yok, ileride ayrı SPEC

---

## 🎯 Kabul Kriterleri

Faz 3 bitince:
- [x] Yeni Enterprise Pro tasarımı tüm ekranlarda tutarlı
- [x] Sol drawer çalışıyor, 4 section görünüyor
- [x] Dashboard A/B toggle çalışıyor
- [x] 16+ ekranın tümü navigate edilebilir
- [x] Mevcut backend entegrasyonu kırılmadı (login, device CRUD, assignment, form, audit log)
- [x] `flutter analyze` 0 hata
- [x] Emulator test turu başarılı

---

## 🚀 Claude Code'a Başlatma Promptu

```
C:\Workspace\Personal_Projects\assetflow_mobile dizininde çalışıyorsun.
Bu SPEC'i uygula: specs/SPEC_MOBILE_006_full_redesign.md
Her task sonunda:
1. flutter analyze (0 hata olmalı)
2. git add -A && git commit -m "Task T#: [başlık]"
Sorun olursa dur, rapor ver.
T1'den başla, T22'ye kadar sırayla git.
Referans mockup dosyaları: C:\Workspace\Personal_Projects\assetflow_mobile\mockups\ klasöründe
(Emre: tokens.css, ui.jsx vb. dosyaları bu klasöre kopyalayacak)
```

**Not Emre için:**
- Mockup dosyalarını (tokens.css, login.jsx, dashboard-a.jsx, vs.) `assetflow_mobile/mockups/` klasörüne kopyala ki Claude Code referans olarak okuyabilsin
- SPEC dosyasını `assetflow_mobile/specs/SPEC_MOBILE_006_full_redesign.md` olarak kaydet
- Claude Code'u başlat, yukarıdaki promptu ver

---

**Hazırlayan:** Claude + Emre
**Versiyon:** 1.0
**Güncelleme:** 21 Nisan 2026

# AssetFlow Mobile App — Yeniden Tasarım Promptu

> Bu promptu Claude.ai veya benzer bir AI design tool'a yapıştır.

---

## Sen kimsin?

Sen kıdemli bir **mobile UI/UX designer + Flutter developer**'sın. Enterprise/B2B yazılım deneyimin var. SAP Fiori, Salesforce Lightning, Microsoft Fluent gibi kurumsal tasarım dillerine hakimsin. Aynı zamanda **Material Design 3** ve **Flutter widget mimarisi** konusunda uzmansın.

---

## Proje: AssetFlow

**AssetFlow**, GÜVENOK Lojistik (OPET grup şirketi) için geliştirilen kurumsal bir **IT varlık yönetim sistemi**. IT departmanı çalışanları (admin) ve sahadaki personel kullanıyor.

### Teknik Stack
- **Mobile:** Flutter (Riverpod state management, Dio HTTP client, features/ klasör yapısı)
- **Backend:** .NET 10 Web API (Clean Architecture, EF Core, JWT auth, Service Pattern)
- **DB:** SQL Server, multi-tenant (CompanyId izolasyonu)

### Ana Kullanıcı Rolleri
- **Admin (IT Specialist):** Cihaz/personel/zimmet yönetimi, raporlama
- **Standard User (Employee):** Kendi zimmetli cihazlarını görür, basit işlemler

### Mevcut Feature'lar (Çalışan)
1. **Auth:** Login, JWT token, refresh token
2. **Dashboard:** KPI kartları (toplam cihaz, aktif zimmet, personel, garanti uyarıları), son hareketler feed, hızlı işlemler, bildirimler
3. **Cihaz Yönetimi:** CRUD, 9 cihaz tipi (Laptop, Desktop, Monitor, Printer, Phone, Tablet, Server, Network Device, Other), 5 durum (Aktif/Depoda/Bakımda/Emekli/Kayıp), 22 alan (temel + 10 donanım: CPU, RAM, Storage, GPU, Hostname, OS, MAC, IP, BIOS, Motherboard), cihaz tipine göre koşullu form alanları
4. **Personel Yönetimi:** CRUD, 22 lokasyon, departman, ünvan, sicil no
5. **Zimmet Akışı:** Cihaz → Personel atama, ZMT-YYYYMMDD-NNNN formatında zimmet no, asset tag
6. **İade Akışı:** İade durumu (İyi/Hasarlı/Arızalı/Kayıp), iade notları, cihazı emekli etme seçeneği
7. **Form Sistemi:** Excel zimmet formu (ZF-2026-NNNN) ve iade formu (IF-2026-NNNN) üretme, indirme, paylaşma (WhatsApp/Drive), imzalı dosya yükleme
8. **Audit Log:** Otomatik denetim izi (Create/Update/Delete tüm entity'ler), cihaz detayında "Değişiklik Geçmişi" bölümü, ExpansionTile ile inline detay (Eski → Yeni diff)
9. **Bildirimler:** Garanti uyarıları, bildirim paneli, persistent okundu durumu
10. **SAP Entegrasyonu (Mock):** Personel/cihaz/bütçe sync endpoint'leri

### Sayısal Bağlam
- 158 cihaz, 158 personel, 22 lokasyon
- ~94 aktif zimmet
- Türkçe arayüz (resmi, kurumsal ton)

---

## Tasarım Hedefi

**Mevcut UI sorunu:** Tek scroll halinde her şey alt alta, "tek ekran gibi" hissettiriyor. Profesyonel kurumsal yazılım hissi yok. Modern enterprise app'lere kıyasla amatör görünüyor.

**İstenen:** SAP Fiori / Salesforce Lightning tarzında, kurumsal IT departmanlarının kullanmaktan gurur duyacağı, **Enterprise Pro** havalı bir mobile uygulama.

---

## Tasarım Sistemi (Enterprise Pro)

### Renk Paleti

```dart
// Primary (Brand)
const Color primaryNavy = Color(0xFF1A3A5C);    // Header, navigation, primary buttons
const Color primaryNavyDark = Color(0xFF0F2845); // Hover, pressed states
const Color primaryNavyLight = Color(0xFF4670A8); // Accents, links

// Surface
const Color surfaceLight = Color(0xFFF0F4F8);   // App background
const Color surfaceWhite = Color(0xFFFFFFFF);   // Cards, sheets
const Color surfaceDivider = Color(0xFFE5EBF0); // Dividers, borders

// Text
const Color textPrimary = Color(0xFF1A3A5C);    // Headings, important text
const Color textSecondary = Color(0xFF6B7A8C);  // Body, secondary
const Color textTertiary = Color(0xFF9CA8B8);   // Placeholders, hints

// Semantic
const Color success = Color(0xFF2D8659);        // Active, success, zimmet
const Color warning = Color(0xFFB85423);        // Warnings, garanti uyarısı
const Color error = Color(0xFFC53030);          // Errors, kayıp/arızalı
const Color info = Color(0xFF4670A8);           // Info, updates
const Color warningBg = Color(0xFFFDF3E7);      // Warning card background
const Color successBg = Color(0xFFE8F4ED);      // Success card background
```

### Tipografi

- **Font:** Inter veya SF Pro (Apple sistem fontu) — Flutter'da `GoogleFonts.inter()` kullan
- **Headings:** weight 500 (Medium), asla 700 (Bold) kullanma — kurumsal sade görünüm için
- **Body:** weight 400 (Regular)
- **Sizes:** Heading 17-22px, body 13-14px, caption/label 11-12px (UPPERCASE + letter-spacing)
- **Letter spacing:** Section başlıkları için `letter-spacing: 1px` (UPPERCASE label görünümü)

### Component Sistemi

**1. App Header (Navy Blue)**
- Background: primaryNavy (#1A3A5C)
- Text/icons: white
- Avatar: rounded-square, 32x32, kullanıcı baş harfleri
- Bildirim ikonu: badge nokta ile (kırmızı)
- Üst bilgi: "Hoş geldin, [Ad]" + rol (IT Specialist)
- Alt bilgi: "GÜVENOK LOJİSTİK" (uppercase, letter-spacing) + "IT Varlık Yönetimi" (büyük başlık)

**2. KPI Kartları**
- Background: surfaceLight (#F0F4F8)
- Sol kenar şeridi (border-left: 3px solid): renk durum bazlı
  - Cihaz: primaryNavy
  - Zimmet: success (yeşil)
  - Personel: textSecondary (gri)
  - Uyarı: warning (turuncu, background warningBg)
- Padding: 12px
- Label: 11px, textSecondary, UPPERCASE
- Sayı: 22px, weight 500, primaryNavy

**3. Aktivite Listesi**
- Background: surfaceWhite
- Sol nokta: 8x8 daire, renk durum bazlı (yeşil=zimmet, mavi=update, turuncu=form)
- Üst satır: ENTITY (uppercase, weight 500) + bağlam
- Alt satır: detay (textSecondary, 11px)
- Sağ: timestamp (11px, textSecondary)
- Divider: 1px solid surfaceLight

**4. Bottom Navigation**
- Background: primaryNavy (uygulama header ile aynı renk)
- Aktif: white (full opacity), inactive: white 50% opacity
- 5 sekme: Anasayfa, Envanter, Personel, Raporlar, Ayarlar
- İkon + label (10px)

**5. Buttons**
- **Primary:** background primaryNavy, text white, padding 12px, border-radius 8px
- **Secondary:** background white, border 1px solid #d1dae5, text primaryNavy
- İkon + label kombinasyonu (sol icon, sağ label)

**6. Forms**
- Input field: background white, border 1px solid #d1dae5, focus border primaryNavy
- Label: 12px, textSecondary, UPPERCASE
- Section başlığı: 11px, textSecondary, UPPERCASE, letter-spacing 1px (örn: "TEMEL BİLGİLER", "DONANIM BİLGİLERİ")

**7. Cards (Detay Bölümleri)**
- Background: surfaceWhite
- Border-radius: 8px
- Padding: 16px
- Section başlığı (üstte) + content (altta)
- Bölümler arasında 8px surfaceLight gap

**8. Tabs (Cihaz Detay için)**
- Tab bar background: surfaceWhite
- Active tab: text primaryNavy + border-bottom 2px primaryNavy
- Inactive tab: text textSecondary
- Tab'lar: Genel, Donanım, Zimmetler, Geçmiş

**9. Wizard (Zimmet/İade Akışı)**
- Step indicator üstte (1-2-3-4)
- Aktif step: primaryNavy circle + white text
- Tamamlanmış step: success green + checkmark
- Pasif step: textTertiary
- Progress bar: 2px line, primaryNavy fill

**10. Audit Log Timeline**
- Sol vertical line: 1px solid surfaceLight
- Her log: dot (8x8) + content card
- ExpansionTile: detay olan log'larda aşağı ok
- Eski değer: kırmızı üstü çizili
- Yeni değer: yeşil bold

### Genel Kurallar

- **No gradients** — düz renkler, kurumsal görünüm için
- **No shadows** — düz tasarım, sadece focus için 1px solid border
- **No emojis** — UI'da SVG ikonlar kullan
- **Border radius:** 8px (cards, buttons), 12px (büyük cards, sheets)
- **Spacing:** 8px / 12px / 16px / 20px / 24px (Material spacing scale)
- **Always Turkish UI** — tüm metinler Türkçe
- **Dark mode opsiyonel** — şimdilik light theme öncelikli

---

## İstediğim Çıktılar

Aşağıdaki **6 ana ekranı** Enterprise Pro stilinde tasarla. Her biri için **tam Flutter widget kodu** ver:

### 1. Login / Splash Screen
- Logo: AssetFlow (placeholder, navy renk)
- Şirket adı: "GÜVENOK LOJİSTİK"
- Email/şifre input'ları
- "Giriş Yap" primary button
- "Şifremi unuttum" link
- Alt: versiyon bilgisi

### 2. Dashboard (Ana Sayfa)
- Header: kullanıcı bilgisi + bildirimler + avatar
- 4 KPI kartı (2x2 grid): Cihaz / Zimmet / Personel / Uyarı
- "Aktivite Akışı" listesi (3-5 son hareket)
- "Hızlı İşlemler" (Yeni Cihaz / Zimmetle butonları)
- Bottom navigation

### 3. Cihaz Listesi
- Header: "Cihazlar" başlık + (+) ekle butonu
- Search bar (filter ikonu ile)
- Filter chips: "Tümü / Aktif / Depoda / Bakımda" (üst sırada)
- Cihaz kartları (liste): cihaz adı, tip, durum badge, zimmetli kişi, sağda chevron
- FAB: yeni cihaz ekleme
- Pull-to-refresh

### 4. Cihaz Detay (4 tab'lı)
- Header: cihaz adı + edit/delete iconları
- 4 tab: **Genel** / **Donanım** / **Zimmetler** / **Geçmiş**
- **Genel tab:** Marka, model, seri no, demirbaş kodu, durum, satın alma bilgileri, garanti
- **Donanım tab:** CPU/RAM/Storage/GPU/Hostname/OS/MAC/IP/BIOS/Motherboard (cihaz tipine göre koşullu)
- **Zimmetler tab:** Mevcut + geçmiş zimmetler kart listesi
- **Geçmiş tab:** Audit log timeline (ExpansionTile ile detay)
- Floating action: aktifse "İade Et", değilse "Zimmetle"

### 5. Zimmet Akışı (Wizard - 4 step)
- Step indicator üstte
- **Step 1:** Cihaz seç (search + liste)
- **Step 2:** Personel seç (search + liste)
- **Step 3:** Onay (cihaz + personel özet, notlar)
- **Step 4:** Form üret (Excel indir, paylaş, imzalı yükle butonları)
- Alt buton: "Geri / İleri" (sağda primary, solda secondary)

### 6. Audit Log (Cihaz detay tab veya ayrı sayfa)
- Filter chips: "Tümü / Cihaz / Zimmet"
- Date range picker (üst sağ)
- Timeline görünüm: vertical line + dot + card
- Her card: icon + action label + user + timestamp
- Tıklayınca expand: değişen alanlar listesi (Eski → Yeni)

---

## Çıktı Format Talebi

Her ekran için:

1. **Ekran adı + amaç** (1 paragraf)
2. **Layout açıklaması** (component hierarchy)
3. **Tam Flutter widget kodu** (.dart dosyası, mock data ile çalışır halde)
4. **Kullanılan paketler** (pubspec.yaml additions varsa)
5. **Notlar** (state management, navigation entegrasyonu için)

**Kod kuralları:**
- StatefulWidget veya ConsumerStatefulWidget (Riverpod uyumlu)
- Mock data ile çalışsın (gerçek API entegrasyonunu sonra ben yaparım)
- Türkçe UI metinleri
- Const constructor'lar mümkün olduğunca
- `lib/core/theme/app_colors.dart` dosyasındaki renkleri kullan (yukarıdaki paletten)
- Reusable widget'ları ayrı sınıf olarak çıkar (örn: `_KpiCard`, `_ActivityTile`, `_SectionHeader`)

---

## Bonus İstekler (Vakit Kalırsa)

- **Empty states:** Cihaz yok / personel yok / zimmet yok için tasarımlar
- **Loading states:** Shimmer placeholder'lar
- **Error states:** Network error, retry butonu
- **Dark mode versiyonu:** Aynı palette'in koyu hali

---

## Önemli Notlar

- **Hedef cihazlar:** Android (Galaxy/Pixel sınıfı), opsiyonel iOS
- **Min ekran genişliği:** 360px (küçük telefonlar)
- **Türkçe karakterler:** ı, ğ, ş, ç, ö, ü tam destek
- **Accessibility:** Kontrast yeterli (WCAG AA), font size scaling destekli
- **Çalışma ortamı:** GÜVENOK Lojistik IT departmanı, kurumsal kullanım, sahada da kullanılabilir (lojistik personeli)

---

## Başlangıç

Yukarıdaki 6 ekrandan **Login** ekranıyla başla. Tasarım kararını ver, layout'u açıkla, tam Flutter kodunu yaz. Sonra sırasıyla diğer ekranlara geç. Her ekran sonunda bana sor: "Bir sonraki ekrana geçeyim mi?" — onay verirsem devam et.

İyi tasarımlar! 🎯

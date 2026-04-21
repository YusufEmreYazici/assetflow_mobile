# AssetFlow Bug Fix Sprint — 4 UX Fix

AssetFlow'da 4 tane UX bug'i var. Sırayla düzelt, her birinde commit at.

═══════════════════════════════════════════════════════════════════
FIX 1: Dashboard B Hero KPI 2 pixel overflow
═══════════════════════════════════════════════════════════════════

**Dosya:** `lib/features/dashboard/widgets/dashboard_b_view.dart`

**Problem:** Hero KPI card'ında "BOTTOM OVERFLOWED BY 2.0 PIXELS" hatası var. Sağ üstteki Column (▲ 3 BU AY badge + "Son 6 ay" yazısı + MiniBarChart) card'ın yüksekliğini 2px aşıyor.

**Çözüm:**

1. Sağdaki Column'a `mainAxisSize: MainAxisSize.min` ekle
2. MiniBarChart height'ını 40 → 36'ya düşür
3. İç Column spacing'lerini 4 → 2'ye düşür (gerekirse)
4. Tüm iç Column'ların `mainAxisSize`'ını kontrol et

**Test:** flutter run --release, Dashboard B'ye git, overflow banner kaybolmuş mu?

**Commit:** `fix: dashboard B hero KPI 2px overflow`

═══════════════════════════════════════════════════════════════════
FIX 2: Bildirimde çift tıklama ile detaya gitme
═══════════════════════════════════════════════════════════════════

**Dosya:** `lib/features/notifications/notifications_screen.dart`

**Problem:** Şu anda bildirime 1 kere tıklayınca sadece "okundu" oluyor. Kullanıcı ikinci tıklama ile ilgili işleme gitmeli.

**Davranış:**
- **1. tıklama** (bildirim okunmamışsa): Sadece "okundu" işaretle, hiçbir yere gitme
- **1. tıklama** (zaten okunmuşsa) VEYA **2. tıklama**: İlgili ekrana yönlendir

**Yönlendirme mantığı (notification.type'a göre):**

```dart
void _handleNotificationTap(NotificationItem n) {
  final wasUnread = !n.isRead;

  if (wasUnread) {
    ref.read(notificationProvider.notifier).markAsRead(n.id);
    return; // İlk tık: sadece okundu işaretle, dur
  }

  // İkinci tık VEYA zaten okunmuştu: yönlendir
  switch (n.type) {
    case 'warranty':
      Navigator.pushNamed(context, '/device/${n.relatedEntityId}');
      break;
    case 'assignment':
      Navigator.pushNamed(context, '/device/${n.relatedEntityId}');
      break;
    case 'return':
      // Cihaz detay, Zimmetler tab'ı açık gelsin
      Navigator.pushNamed(
        context,
        '/device/${n.relatedEntityId}',
        arguments: {'initialTab': 'assignments'},
      );
      break;
    case 'system':
      Navigator.pushNamed(context, '/settings');
      break;
    case 'audit':
      Navigator.pushNamed(context, '/audit-log');
      break;
    default:
      // Bilinmeyen type → hiçbir yere gitme
      break;
  }
}
```

**Implementation:**

1. `NotificationItem` modelinde `relatedEntityId` ve `type` alanları var mı kontrol et
   - Yoksa ekle (String? relatedEntityId, String type)
2. Mock data'da bazı bildirimler için relatedEntityId ata (test edebilmek için)
3. Tile'a `GestureDetector(onTap:)` yerine yukarıdaki `_handleNotificationTap` bağla
4. **Görsel ipucu:** Okunmuş bildirimlerde "Tıklayın →" ifadesi veya küçük chevron ikonu göster ki kullanıcı 2. tıklama gerekli olduğunu anlasın

**Commit:** `feat: notification double-tap navigation to related screen`

═══════════════════════════════════════════════════════════════════
FIX 3: Drawer sağdan açılsın (endDrawer'a taşı)
═══════════════════════════════════════════════════════════════════

**Dosya:** `lib/core/navigation/app_shell.dart` ve drawer'ı kullanan tüm Scaffold'lar

**Problem:** Bottom Nav'daki "Daha Fazla" butonu **sağda**, ama drawer **soldan** açılıyor. UX tutarsızlığı var.

**Çözüm:** Drawer'ı `endDrawer`'a taşı — sağdan açılsın.

**Yapılacak:**

1. Tüm `Scaffold(drawer: AppDrawer(...))` kullanımlarını `Scaffold(endDrawer: AppDrawer(...))` yap
2. Drawer açma komutlarını güncelle:
   - `Scaffold.of(context).openDrawer()` → `Scaffold.of(context).openEndDrawer()`
   - `scaffoldKey.currentState?.openDrawer()` → `scaffoldKey.currentState?.openEndDrawer()`
3. AppShell'deki "Daha Fazla" (onMore callback) → `openEndDrawer()` çağırsın
4. Sol üstteki hamburger menü ikonu → SAĞ üste taşı (veya sil, sadece "Daha Fazla" buton kullanılsın)

**Alternatif karar (kullanıcıya sor gerekirse):**
- Sol üstteki hamburger ikonunu tamamen kaldır
- "Daha Fazla" bottom nav butonu tek erişim yolu olsun
- VEYA: Sağ üstte hamburger, bottom nav'da "Daha Fazla" — çift erişim

Tercihen: **Sağ üste hamburger ikonu taşı** (App header'ın sağ üstünde bildirim + avatar arasına). Bottom nav'daki "Daha Fazla" buton da çalışmaya devam etsin.

**Test:** Hamburger veya "Daha Fazla" tıkla → drawer sağdan slideıp açılmalı

**Commit:** `feat: move drawer to right side (endDrawer) for UX consistency`

═══════════════════════════════════════════════════════════════════
FIX 4: Dashboard "Hızlı İşlemler → İade" butonu çalışmıyor
═══════════════════════════════════════════════════════════════════

**Dosya:** `lib/features/dashboard/widgets/dashboard_a_view.dart` VEYA `dashboard_b_view.dart` (hangisinde İade varsa — muhtemelen Dashboard B'de 3'lü QuickAction'da)

**Problem:** "İade" QuickAction tıklandığında hiçbir şey olmuyor.

**Çözüm 1 — Basit:** İade akışı başlatan ekran yok, o zaman **cihaz listesine Zimmetli filter ile yönlendir**, kullanıcı cihaz seçip "İade Et" butonuyla devam etsin.

```dart
QuickAction(
  icon: "upload",
  label: "İade",
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/devices',
      arguments: {
        'filter': 'Zimmetli',
        'action': 'return',
      },
    );
  },
)
```

**`device_list_screen.dart`'ta güncelleme:**

1. Route arguments'ı oku:
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final args = ModalRoute.of(context)?.settings.arguments as Map?;
  if (args != null) {
    if (args['filter'] != null) {
      setState(() => _selectedFilter = args['filter']);
    }
    _actionMode = args['action']; // 'return' ise banner göster
  }
}
```

2. `_actionMode == 'return'` ise sayfanın üstüne bilgi banner ekle:
```dart
if (_actionMode == 'return')
  Container(
    padding: EdgeInsets.all(12),
    color: AppColors.warningBg,
    child: Row(
      children: [
        Icon(Icons.info_outline, color: AppColors.warning),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'İade edilecek cihazı seçin',
            style: TextStyle(color: AppColors.warning),
          ),
        ),
      ],
    ),
  ),
```

3. Cihaz detayına girince eğer action 'return' ise FAB otomatik "İade Et" (varsayılan zaten öyle zimmetli cihazlar için, ama emin ol)

**Commit:** `fix: dashboard quick action "İade" navigates to device list with return mode`

═══════════════════════════════════════════════════════════════════

## Son Adım — Doğrulama

Her fix'ten sonra:
1. `flutter analyze` → 0 hata
2. `flutter run --release` → emulator'de test et
3. Git commit

En sonunda: `git log --oneline -5` ile 4 yeni commit görünmeli.

Hadi başla, sırayla Fix 1'den Fix 4'e git. Sorun çıkarsa dur ve rapor ver.

# SPEC_MOBILE_008 — UX Cila ve Parlatma (Faz 2)

**Tarih:** 22-23 Nisan 2026
**Proje:** assetflow_mobile (Flutter)
**Tahmini Süre:** 4-6 saat (1-2 oturum)
**Version Bump:** 2.1.2 → 2.2.0
**Git Tag:** `v2.2.0-polish`

---

## 📋 Özet

SPEC_MOBILE_006 ile Enterprise Pro redesign, SPEC_MOBILE_007 ile kullanım kolaylığı özellikleri eklendi. Şimdi **uygulamayı gerçekten "profesyonel" hissettirecek ince detaylar** ekliyoruz. Bu faz fonksiyonel yeni özellik getirmiyor, **mevcut özellikleri parlatıyor.**

**6 Ana Alan:**
1. 🎨 Özelleştirilmiş Empty States (her ekran için anlamlı)
2. 📳 Haptic Feedback (tüm etkileşimlerde titreşim)
3. ✨ Smooth Animations & Transitions (sayfa geçişleri, liste animasyonları)
4. ⏳ Loading Skeletons (shimmer placeholder'lar her ekranda)
5. ♿ Accessibility (erişilebilirlik — screen reader, font scaling)
6. 🌙 Dark Mode Toggle (tokens hazır, UI tarafını bağla)

---

## 🎨 Genel Felsefe

Bu SPEC'te **"küçük detayların önemi"** prensibi. İyi bir uygulama ile **harika** bir uygulama arasındaki fark:
- Butona basınca hissedilen hafif titreşim
- Sayfa açılırken zarif fade animasyonu
- Boş liste yerine "hadi ekle" davetini
- Uygulamayı karanlıkta kullanabilmek

Kullanıcı bu detayların her birini **ayrı ayrı farketmeyebilir**, ama bütünü "bu uygulama güzel" hissiyatını yaratır.

---

## 🗂 Dosya Yapısı (Yeni + Değişecek)

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart                       (GÜNCELLENDİ - dark theme)
│   │   └── theme_provider.dart                  (YENİ - light/dark state)
│   ├── widgets/
│   │   ├── empty_state.dart                     (GÜNCELLENDİ - özel variants)
│   │   ├── loading_skeleton.dart                (YENİ - shimmer base)
│   │   ├── animated_list_item.dart              (YENİ - slide-in animasyonu)
│   │   ├── haptic_button.dart                   (YENİ - wrapper widget)
│   │   └── page_transitions.dart                (YENİ - custom transitions)
│   ├── services/
│   │   └── haptic_service.dart                  (YENİ - haptic wrapper)
│   └── utils/
│       └── accessibility_helpers.dart           (YENİ - a11y utilities)
├── features/
│   ├── devices/
│   │   └── widgets/
│   │       └── device_list_skeleton.dart        (YENİ)
│   ├── people/
│   │   └── widgets/
│   │       └── person_list_skeleton.dart        (YENİ)
│   ├── dashboard/
│   │   └── widgets/
│   │       └── dashboard_skeleton.dart          (YENİ)
│   └── profile/
│       └── settings_screen.dart                 (GÜNCELLENDİ - dark toggle)
```

---

## 🚧 Görev Listesi

**KRİTİK KURAL:** Her task sonunda:
1. `flutter analyze` (0 hata)
2. `git commit -m "Task T#: [başlık]"`
3. Emulator'de görsel test
4. Hata varsa dur, raporla

---

### 🎯 Bölüm 1 — Haptic Feedback (Tahmini 45 dk)

#### T1: HapticService Altyapısı 📳
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/services/haptic_service.dart` (yeni)

**Yapılacak:**

```dart
// lib/core/services/haptic_service.dart
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static const String _enabledKey = 'haptic_enabled';
  static bool _enabled = true;

  /// Uygulama başında çağır (main.dart)
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
  }

  /// Kullanıcı ayarlardan açıp kapatabilir
  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  static bool get isEnabled => _enabled;

  /// Hafif titreşim — button tap, chip select gibi
  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Orta titreşim — success action, favorite toggle
  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Güçlü titreşim — important action, delete confirmation
  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection titreşimi — slider drag, picker change
  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Vibration (kısa) — error, warning
  static void vibrate() {
    if (!_enabled) return;
    HapticFeedback.vibrate();
  }
}
```

**main.dart güncelle:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineCacheService.init();
  await HapticService.init();  // ← YENİ
  runApp(const ProviderScope(child: MyApp()));
}
```

**Commit:** `feat: add HapticService infrastructure with user preference`

---

#### T2: Haptic Entegrasyonu — Proje Geneli 📳
**Süre:** 25 dk
**Dosyalar:** Çok sayıda (tarama ile bul)

**Yapılacak:**

Şu yerlere haptic feedback ekle:

**Light (lightImpact) — sık kullanım:**
- Tüm `onTap` butonlarda
- ListTile tıklamalarında (cihaz satırı, personel satırı)
- Chip select/deselect
- Tab değişikliği
- Drawer item tap

**Medium (mediumImpact) — aksiyon onayı:**
- Favorite star toggle
- Save button tıklama
- Form submit
- QR scan başarılı
- Bulk selection enter

**Heavy (heavyImpact) — önemli:**
- Delete confirmation
- Logout
- Login success

**Selection (selectionClick) — seçim:**
- Dropdown değiştirme
- Filter chip aktif/pasif
- Checkbox/switch toggle

**Vibrate — hata:**
- Form validation error
- Network error
- Login failed

**Pattern:**
```dart
// Önce:
onTap: () => _doSomething()

// Sonra:
onTap: () {
  HapticService.light();
  _doSomething();
}
```

**Özel widget'lar (kullanılan her yerde otomatik haptic için):**
```dart
// lib/core/widgets/haptic_button.dart
class HapticButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final HapticType type;
  final Widget child;

  const HapticButton({
    super.key,
    this.onPressed,
    this.type = HapticType.light,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed == null ? null : () {
        switch (type) {
          case HapticType.light: HapticService.light(); break;
          case HapticType.medium: HapticService.medium(); break;
          case HapticType.heavy: HapticService.heavy(); break;
          case HapticType.selection: HapticService.selection(); break;
        }
        onPressed!();
      },
      child: child,
    );
  }
}

enum HapticType { light, medium, heavy, selection }
```

**Önemli:** Her yerde `HapticButton` kullanmak zorunda değilsin, `HapticService.light()` çağrıları yeterli. Widget sadece kolaylık.

**Test:** Gerçek cihazda hisset — çok değil, az değil.

**Commit:** `feat: integrate haptic feedback across all interactions`

---

### 🎯 Bölüm 2 — Empty States (Tahmini 40 dk)

#### T3: Empty State Variants 🎨
**Süre:** 40 dk
**Dosyalar:**
- `lib/core/widgets/empty_state.dart` (güncelle, şu an basit)

**Yapılacak:**

Her liste/ekran için **anlamlı, bağlamsal** empty state:

```dart
// lib/core/widgets/empty_state.dart

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final String? secondaryCtaLabel;
  final VoidCallback? onSecondaryCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCtaPressed,
    this.secondaryCtaLabel,
    this.onSecondaryCtaPressed,
  });

  // Named constructors için yaygın senaryolar

  const EmptyState.noDevices({
    super.key,
    VoidCallback? onAddDevice,
    VoidCallback? onScanQr,
  }) : icon = Icons.computer_outlined,
       title = 'Henüz cihaz yok',
       description = 'İlk cihazını ekleyerek başla veya QR kod tarayarak hızlıca ekle.',
       ctaLabel = 'İlk Cihazı Ekle',
       onCtaPressed = onAddDevice,
       secondaryCtaLabel = 'QR Tara',
       onSecondaryCtaPressed = onScanQr;

  const EmptyState.noAssignments({super.key})
      : icon = Icons.assignment_outlined,
       title = 'Zimmet yok',
       description = 'Henüz oluşturulmuş bir zimmet bulunmuyor. Cihaz detayından zimmet oluşturabilirsin.',
       ctaLabel = null,
       onCtaPressed = null,
       secondaryCtaLabel = null,
       onSecondaryCtaPressed = null;

  const EmptyState.noNotifications({super.key})
      : icon = Icons.notifications_off_outlined,
       title = 'Bildirim yok',
       description = 'Şu an için bir bildirim bulunmuyor. Garanti uyarıları ve sistem bildirimleri buraya gelecek.',
       ctaLabel = null,
       onCtaPressed = null,
       secondaryCtaLabel = null,
       onSecondaryCtaPressed = null;

  const EmptyState.noSearchResults({
    super.key,
    required String query,
  }) : icon = Icons.search_off,
       title = 'Sonuç bulunamadı',
       description = '"$query" için hiçbir kayıt bulunamadı. Farklı bir arama terimi deneyin.',
       ctaLabel = null,
       onCtaPressed = null,
       secondaryCtaLabel = null,
       onSecondaryCtaPressed = null;

  const EmptyState.noFavorites({
    super.key,
    VoidCallback? onBrowse,
  }) : icon = Icons.star_border,
       title = 'Favori yok',
       description = 'Sık erişmek istediğin cihazlara ⭐ tıklayarak buraya ekleyebilirsin.',
       ctaLabel = 'Cihazlara Göz At',
       onCtaPressed = onBrowse,
       secondaryCtaLabel = null,
       onSecondaryCtaPressed = null;

  const EmptyState.filterNoResults({super.key})
      : icon = Icons.filter_alt_off_outlined,
       title = 'Filtreyle eşleşen yok',
       description = 'Aktif filtreler hiçbir sonuç getirmedi. Filtreyi temizle veya değiştir.',
       ctaLabel = 'Filtreyi Temizle',
       onCtaPressed = null, // caller sets this
       secondaryCtaLabel = null,
       onSecondaryCtaPressed = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İllüstrasyon container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.navyLight),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  HapticService.light();
                  onCtaPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(ctaLabel!),
              ),
            ],
            if (secondaryCtaLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  HapticService.light();
                  onSecondaryCtaPressed?.call();
                },
                child: Text(secondaryCtaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Kullanım noktaları:**

- `device_list_screen.dart` — boş liste → `EmptyState.noDevices()` veya filter varsa `EmptyState.filterNoResults()`
- `person_list_screen.dart` — benzer
- `notifications_screen.dart` → `EmptyState.noNotifications()`
- `favorites_section.dart` → `EmptyState.noFavorites()`
- `assignment_list_screen.dart` (varsa) → `EmptyState.noAssignments()`
- Search result ekranlarında → `EmptyState.noSearchResults(query: q)`

**Commit:** `feat: add contextual empty states across all list screens`

---

### 🎯 Bölüm 3 — Loading Skeletons (Tahmini 50 dk)

#### T4: Skeleton Base Widget ⏳
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/widgets/loading_skeleton.dart` (yeni)
- `pubspec.yaml` (shimmer paketi ekle)

**Yapılacak:**

```bash
flutter pub add shimmer
```

```dart
// lib/core/widgets/loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Shimmer effect ile skeleton loading placeholder
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDivider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Dairesel skeleton (avatar, icon placeholder)
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surfaceDivider,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Text line skeleton (farklı genişlikler)
class SkeletonText extends StatelessWidget {
  final double widthFactor; // 0.0 - 1.0
  final double height;

  const SkeletonText({
    super.key,
    this.widthFactor = 1.0,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: SkeletonBox(height: height, borderRadius: 4),
    );
  }
}
```

**Commit:** `feat: add SkeletonBox, SkeletonCircle, SkeletonText widgets with shimmer`

---

#### T5: Ekran Özel Skeleton'lar ⏳
**Süre:** 30 dk
**Dosyalar:**
- `lib/features/devices/widgets/device_list_skeleton.dart` (yeni)
- `lib/features/people/widgets/person_list_skeleton.dart` (yeni)
- `lib/features/dashboard/widgets/dashboard_skeleton.dart` (yeni)
- İlgili ekranlar güncelle (loading state'te skeleton kullansın)

**Örnek — DeviceListSkeleton:**

```dart
class DeviceListSkeleton extends StatelessWidget {
  const DeviceListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (index) => _DeviceRowSkeleton()),
    );
  }
}

class _DeviceRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceDivider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 40, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonText(widthFactor: 0.6, height: 14),
                SizedBox(height: 6),
                SkeletonText(widthFactor: 0.4, height: 11),
              ],
            ),
          ),
          const SkeletonBox(width: 60, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}
```

**DashboardSkeleton** — KPI kartları + activity tile + quick actions placeholder

**PersonListSkeleton** — avatar + 2 text satırı

**Kullanım — device_list_screen.dart güncelle:**

```dart
// ÖNCE
Widget build(context, ref) {
  final devicesAsync = ref.watch(devicesProvider);
  return devicesAsync.when(
    data: (devices) => _buildList(devices),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => ErrorState(kind: 'network'),
  );
}

// SONRA
Widget build(context, ref) {
  final devicesAsync = ref.watch(devicesProvider);
  return devicesAsync.when(
    data: (devices) => _buildList(devices),
    loading: () => const DeviceListSkeleton(),  // ← shimmer
    error: (e, _) => ErrorState(kind: 'network'),
  );
}
```

**Test:** Uygulamayı aç, network yavaşlat (Android emulator: Speed=Edge), skeleton'ları gör.

**Commit:** `feat: add screen-specific loading skeletons with shimmer`

---

### 🎯 Bölüm 4 — Animations & Transitions (Tahmini 60 dk)

#### T6: Custom Page Transitions ✨
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/widgets/page_transitions.dart` (yeni)
- `lib/core/navigation/app_router.dart` (güncelle)

**Yapılacak:**

```dart
// lib/core/widgets/page_transitions.dart
import 'package:flutter/material.dart';

/// Sağdan soldan kayma (native iOS/Android default ama smooth)
class SlideFromRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFromRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// Aşağıdan yukarı (bottom sheet tarzı, modal ekranlar için)
class SlideFromBottomRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFromBottomRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
}

/// Fade (basit, hızlı)
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}
```

**Kullanım:**

```dart
// ÖNCE
Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDetailScreen()));

// SONRA
Navigator.push(context, SlideFromRightRoute(page: DeviceDetailScreen()));
```

**app_router.dart güncelle** — tüm rotalar bu transitions kullansın.

**Modal ekranlar için** `SlideFromBottomRoute` kullan:
- Form ekranları (cihaz ekle, zimmet wizard)
- QR Scanner
- Filter sheet (zaten bottom sheet)

**Commit:** `feat: add custom page transitions (slide, fade) for smoother navigation`

---

#### T7: List Item Animations ✨
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/widgets/animated_list_item.dart` (yeni)
- Device list, person list güncelle

**Yapılacak:**

```dart
// lib/core/widgets/animated_list_item.dart
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? delay;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Her item'a kademeli gecikme
    final delay = widget.delay ?? Duration(milliseconds: widget.index * 50);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _controller.value) * 20),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
```

**Kullanım:**

```dart
// device_list_screen.dart
ListView.builder(
  itemCount: devices.length,
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      child: DeviceRow(device: devices[index]),
    );
  },
)
```

**Not:** İlk açılışta items tek tek kayarak gelir. Sonrasında scroll'da performance için kapat (ilk render'da yeterli). Veya sadece index < 10 için uygula.

**Commit:** `feat: add staggered list item animations (slide + fade)`

---

#### T8: Mikro Animasyonlar ✨
**Süre:** 20 dk
**Dosyalar:** Çeşitli

**Yapılacak:**

**a) Favorite Star Animation:**
```dart
class FavoriteStar extends ConsumerStatefulWidget {
  // ... mevcut kod

  @override
  Widget build(context, ref) {
    final isFav = ref.watch(favoritesProvider).contains(deviceId);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isFav ? Icons.star : Icons.star_border,
          key: ValueKey(isFav),
          color: isFav ? AppColors.warning : AppColors.textTertiary,
        ),
      ),
      onPressed: () {
        HapticService.medium();
        ref.read(favoritesProvider.notifier).toggle(deviceId);
      },
    );
  }
}
```

**b) KPI Card Counter Animation (Dashboard):**

Sayı 0'dan gerçek değere counter animation. `TweenAnimationBuilder` ile:

```dart
TweenAnimationBuilder<int>(
  tween: IntTween(begin: 0, end: 158),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeOutCubic,
  builder: (context, value, _) {
    return Text(
      value.toString(),
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    );
  },
)
```

**c) FAB Scale Animation:**

Device list FAB scroll'a göre kaybol/görün:

```dart
AnimatedScale(
  scale: _isVisible ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 200),
  child: FloatingActionButton(...),
)
```

**d) Tab Bar Indicator Smooth:**

Default TabBar animation OK. Custom gerekirse `AnimatedContainer` ile navy underline smooth geçiş.

**Commit:** `feat: add micro-animations (favorite star, KPI counters, FAB scale)`

---

### 🎯 Bölüm 5 — Accessibility (Tahmini 40 dk)

#### T9: Semantic Labels & Screen Reader ♿
**Süre:** 25 dk
**Dosyalar:** Çeşitli

**Yapılacak:**

Tüm icon-only butonlara `Semantics` label ekle:

```dart
// ÖNCE (screen reader bir şey okumaz)
IconButton(
  icon: Icon(Icons.qr_code_scanner),
  onPressed: _scanQr,
)

// SONRA
Semantics(
  label: 'QR kod tara',
  button: true,
  child: IconButton(
    icon: Icon(Icons.qr_code_scanner),
    onPressed: _scanQr,
  ),
)
```

**Odak alanları:**
- Tüm icon-only butonlar (QR, favori star, filter, menu)
- Status chip'leri — renk + ikon yanında text zaten var ama screen reader için `Semantics(label: 'Durum: ${status}')` ekle
- Image/avatar'lar (baş harfler olsa da `Semantics(label: 'Profil fotoğrafı $userName')`)

**Accessibility helper:**

```dart
// lib/core/utils/accessibility_helpers.dart

class A11y {
  /// Icon button için semantic wrapper
  static Widget iconButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 24,
    Color? color,
  }) {
    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,  // İçindeki icon'un default label'ı override et
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
        tooltip: label,  // Long-press için
      ),
    );
  }

  /// Status chip için semantic
  static Widget statusChip({
    required String statusText,
    required Widget child,
  }) {
    return Semantics(
      label: 'Durum: $statusText',
      child: ExcludeSemantics(child: child),
    );
  }
}
```

**Font Scaling destekle:**

Tüm `TextStyle`'larda `fontSize` absolute pixel yerine `MediaQuery.textScaleFactor` ile uyumlu olsun. Flutter bunu **default olarak yapar**, ama custom Text widget'larda kontrol et. Zorunlu sınır koyma (`textScaler: TextScaler.noScaling` kullanma).

**Minimum touch targets:**

Android guideline: **48x48 dp minimum**. Tüm IconButton'ların varsayılan 48dp. Ama bazı yerlerde `InkWell` ile özel butonlar yapılmış olabilir, kontrol et. `Material Touch Target` kullan.

**Commit:** `feat: add accessibility semantics labels for screen readers`

---

#### T10: Kontrast ve Yazı Boyutu ♿
**Süre:** 15 dk
**Dosyalar:**
- `lib/core/theme/app_colors.dart` (denetle)

**Yapılacak:**

**WCAG AA kontrast testi:**

Şu kombinasyonlar **en az 4.5:1** oranı olmalı (body text için):

- `textPrimary (#1A3A5C)` on `surfaceWhite (#FFFFFF)` → ✅ 11.3:1
- `textSecondary (#6B7A8C)` on `surfaceWhite` → ✅ 4.8:1
- `textTertiary (#9CA8B8)` on `surfaceWhite` → ⚠️ 2.9:1 — **yetersiz!**

**Çözüm:** `textTertiary`'yi daha koyu yap:
```dart
static const Color textTertiary = Color(0xFF7D8899);  // 4.5:1 oldu
```

VEYA sadece büyük font (18px+) veya placeholder'da kullan.

**Font size minimum:**

- Body text ≥ 14px (mevcut OK)
- Caption ≥ 11px (mevcut OK)
- **Label text ≥ 11px** — bazı yerlerde 10px olabilir, kontrol et

**Tool:** Chrome DevTools → Lighthouse Accessibility sekmesi. Flutter için `flutter_accessibility_scanner` paketi de var.

**Commit:** `fix: improve text contrast ratios for WCAG AA compliance`

---

### 🎯 Bölüm 6 — Dark Mode Toggle (Tahmini 45 dk)

#### T11: Dark Theme Definitions 🌙
**Süre:** 20 dk
**Dosyalar:**
- `lib/core/theme/app_colors.dart` (dark variant ekle)
- `lib/core/theme/app_theme.dart` (dark theme)

**Yapılacak:**

`tokens.css`'te `[data-theme="dark"]` bloğu vardı, onu Flutter'a port et:

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Light theme (mevcut)
  static const Color navy = Color(0xFF1A3A5C);
  static const Color navyDark = Color(0xFF0F2845);
  static const Color navyLight = Color(0xFF4670A8);
  // ... mevcut light renkler

  // Dark theme versions
  static const Color darkNavy = Color(0xFF4670A8);
  static const Color darkNavyDark = Color(0xFF2B4C7A);
  static const Color darkNavyLight = Color(0xFF6A8FC4);

  static const Color darkSurfaceLight = Color(0xFF0B1622);  // app bg
  static const Color darkSurfaceWhite = Color(0xFF152235);  // cards
  static const Color darkSurfaceDivider = Color(0xFF1F2E45);
  static const Color darkSurfaceInputBorder = Color(0xFF293B56);

  static const Color darkTextPrimary = Color(0xFFE5EBF0);
  static const Color darkTextSecondary = Color(0xFF9CA8B8);
  static const Color darkTextTertiary = Color(0xFF6B7A8C);

  static const Color darkSuccess = Color(0xFF3FA06B);
  static const Color darkSuccessBg = Color(0xFF1A3428);
  static const Color darkWarning = Color(0xFFD27048);
  static const Color darkWarningBg = Color(0xFF3A2418);
  static const Color darkError = Color(0xFFE04545);
  static const Color darkErrorBg = Color(0xFF3A1C1C);
  static const Color darkInfo = Color(0xFF6A8FC4);
  static const Color darkInfoBg = Color(0xFF1C2A40);
}
```

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    primaryColor: AppColors.navy,
    colorScheme: ColorScheme.light(
      primary: AppColors.navy,
      secondary: AppColors.navyLight,
      surface: AppColors.surfaceWhite,
      background: AppColors.surfaceLight,
      error: AppColors.error,
    ),
    // ... mevcut ayarlar
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkSurfaceLight,
    primaryColor: AppColors.darkNavy,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkNavy,
      secondary: AppColors.darkNavyLight,
      surface: AppColors.darkSurfaceWhite,
      background: AppColors.darkSurfaceLight,
      error: AppColors.darkError,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkNavy,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurfaceWhite,
    ),
    // ... diğer ayarlar
  );
}
```

**Commit:** `feat: add complete dark theme definitions`

---

#### T12: Theme Provider + Toggle 🌙
**Süre:** 25 dk
**Dosyalar:**
- `lib/core/theme/theme_provider.dart` (yeni)
- `lib/main.dart` veya `lib/app.dart` (ThemeMode bağlama)
- `lib/features/profile/settings_screen.dart` (toggle UI)

**Yapılacak:**

```dart
// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(AppThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'light') state = AppThemeMode.light;
    else if (saved == 'dark') state = AppThemeMode.dark;
    else state = AppThemeMode.system;
  }

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

// Helper: Flutter'ın ThemeMode'una çevir
ThemeMode toThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light: return ThemeMode.light;
    case AppThemeMode.dark: return ThemeMode.dark;
    case AppThemeMode.system: return ThemeMode.system;
  }
}
```

**app.dart:**

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(context, ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AssetFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: toThemeMode(themeMode),  // ← BURASI
      // ... diğer ayarlar
    );
  }
}
```

**Settings ekranında toggle:**

```dart
// settings_screen.dart

Widget _buildThemeSection() {
  final themeMode = ref.watch(themeProvider);

  return Column(
    children: [
      SectionHeader(title: 'GÖRÜNÜM'),
      ListTile(
        title: Text('Açık Tema'),
        trailing: Radio<AppThemeMode>(
          value: AppThemeMode.light,
          groupValue: themeMode,
          onChanged: (v) {
            if (v != null) {
              HapticService.selection();
              ref.read(themeProvider.notifier).setMode(v);
            }
          },
        ),
      ),
      ListTile(
        title: Text('Koyu Tema'),
        trailing: Radio<AppThemeMode>(
          value: AppThemeMode.dark,
          groupValue: themeMode,
          onChanged: (v) {
            if (v != null) {
              HapticService.selection();
              ref.read(themeProvider.notifier).setMode(v);
            }
          },
        ),
      ),
      ListTile(
        title: Text('Sistem'),
        subtitle: Text('Telefon ayarına göre otomatik'),
        trailing: Radio<AppThemeMode>(
          value: AppThemeMode.system,
          groupValue: themeMode,
          onChanged: (v) {
            if (v != null) {
              HapticService.selection();
              ref.read(themeProvider.notifier).setMode(v);
            }
          },
        ),
      ),
    ],
  );
}
```

**Haptic ayarı da ekle (aynı section'da):**

```dart
SwitchListTile(
  title: Text('Titreşim'),
  subtitle: Text('Dokunuşlarda hafif titreşim'),
  value: HapticService.isEnabled,
  onChanged: (v) async {
    await HapticService.setEnabled(v);
    setState(() {});
  },
),
```

**Önemli:** Tüm renk referanslarını kontrol et. Hardcoded `Colors.white` veya `Colors.black` varsa, bunları theme'den al:

```dart
// YANLIŞ
Text('Selam', style: TextStyle(color: Colors.black))

// DOĞRU
Text('Selam', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
```

Veya daha basit:
```dart
Text('Selam')  // Theme'den default alır
```

**Test:**
1. Settings → Koyu tema seç → tüm uygulama dark
2. Açık tema seç → light
3. Sistem → telefonun dark mode ayarına uydu mu?
4. Uygulamayı kapat-aç → tercih kaydedildi mi?

**Commit:** `feat: add dark mode toggle with persistent user preference`

---

### 🎯 Bölüm 7 — Final

#### T13: Tam Test Turu + Version Bump ✅
**Süre:** 30 dk

**Test senaryoları:**

1. **Haptic test:** Butonlara bas, star toggle, delete — titreşim var mı?
2. **Empty states:** Filter tümünü sıfırla, arama "xyz" yaz, boş duruma geç
3. **Skeletons:** Network yavaşlat, cihaz listesi skeleton gösteriyor mu?
4. **Animations:** Her yeni ekran smooth slide, liste item'lar kayarak gel
5. **A11y:** TalkBack aç (Android Accessibility), ekranı gez, semantics duyuluyor mu?
6. **Dark mode:** Settings → Koyu → tüm ekranlar doğru renklerde

**`flutter analyze`** → 0 hata

**pubspec.yaml:** 2.1.2+22 → 2.2.0+23

**Git tag:** `git tag -a v2.2.0 -m "UX polish: haptics, empty states, skeletons, animations, a11y, dark mode"`

**Commit:** `chore: v2.2.0-polish release`

---

## 🎯 Kabul Kriterleri

Faz 2 bitince:
- [ ] Tüm etkileşimlerde haptic feedback (kullanıcı ayardan kapatabilir)
- [ ] Her liste ekranında anlamlı empty state (CTA'lı)
- [ ] Her liste ekranında shimmer skeleton loading
- [ ] Sayfa geçişleri smooth (slide/fade)
- [ ] Liste item'lar kademeli gelir (staggered animation)
- [ ] Favori star, KPI counter mikro animasyonları
- [ ] Tüm icon butonlarda semantic label
- [ ] WCAG AA kontrast
- [ ] Dark mode toggle çalışıyor, persist ediyor
- [ ] `flutter analyze` 0 hata
- [ ] v2.2.0 git tag

---

## ⚠️ Bilinen Riskler

1. **Shimmer paket uyumu:** Son Flutter SDK'sı ile paket versiyon çakışması olabilir, `flutter pub add shimmer` gerekirse `shimmer:^3.0.0` specify et
2. **Dark mode hardcoded renkler:** Projede hardcoded `Color(0xFF...)` varsa dark mode'da görünmez kalır. Büyük tarama gerekli
3. **Animation performance:** Düşük-end cihazlarda list item animasyonu janky olabilir, 10+ item için kapalı tut
4. **Accessibility test:** TalkBack olmadan a11y test imkansız, gerçek cihazla test şart
5. **Haptic tutarlılığı:** Aşırı kullanım "kötü hissiyat" yaratır, dozu iyi ayarla

---

## 📦 Claude Code Başlatma Promptu

```
C:\Workspace\Personal_Projects\assetflow_mobile dizininde çalışıyorsun.

Bu SPEC'i uygula: specs/SPEC_MOBILE_008_ux_polish.md

6 alan, 13 task, tahmini 4-6 saat:
1. Haptic Feedback (T1-T2)
2. Empty States (T3)
3. Loading Skeletons (T4-T5)
4. Animations (T6-T8)
5. Accessibility (T9-T10)
6. Dark Mode (T11-T12)
Final: T13

Her task sonunda:
1. flutter analyze (0 hata)
2. git commit

Bu faz fonksiyonel yeni özellik EKLEMEZ, mevcutu parlatır.
Yani backend'e dokunma, sadece UI/UX katmanında çalış.

Sıralı git, sorun olursa dur. Aralar:
- Haptic bitti (T2)?
- Skeletons bitti (T5)?
- Animations bitti (T8)?
- Dark mode bitti (T12)?

Her arada bana rapor ver. T1'den başla.
```

---

## 🎬 Sonraki Faz (Bilgi)

- **SPEC_MOBILE_009 (FAZ 3):** Test & Kalite — xUnit backend, Flutter widget tests, performance, i18n, analytics

---

**Hazırlayan:** Claude + Emre
**Versiyon:** 1.0
**Güncelleme:** 22 Nisan 2026

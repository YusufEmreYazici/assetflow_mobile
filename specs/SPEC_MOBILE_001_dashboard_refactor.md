# SPEC_MOBILE_001 — Dashboard Refactor (Widget Split)

**Hedef proje:** `C:\Workspace\Personal_Projects\assetflow_mobile`
**Hedef dosya:** `lib/features/dashboard/screens/dashboard_screen.dart` (1521 satir)
**Tip:** Refactor — **sifir davranis degisikligi**, sadece dosya organizasyonu
**Tahmini sure:** 60 dakika

---

## Amac

`dashboard_screen.dart` icindeki 9 widget'i ayri dosyalara tasimak. Screen dosyasi ~220 satira inecek, okunurlugu artacak, gelecekte dashboard'a feature eklemek kolaylasacak. **Uygulama gorunumu ve davranisi birebir ayni kalacak.**

---

## Mimari Kararlar

### 1) Sifir davranis degisikligi

Hicbir mantik degisikligi YOK. Sadece `class X { ... }` bloklari **aynen** yeni dosyalara tasinacak. Import'lar duzenlenecek, erisim seviyeleri (`_` underscore kaldirilip public yapilacak) ayarlanacak.

### 2) Dosyalar `lib/features/dashboard/widgets/` altinda

Mevcut `device_type_chart.dart` ve `stat_card.dart` zaten bu klasorde. Yeni widget'lar da aynı klasore gidecek, tutarlilik saglanacak.

### 3) Naming convention

Eski private class isimleri (`_DashboardAppBar`, `_NotificationPanel` vb.) public olacak — underscore kaldirilacak. Cunku artik dosya disindan import edilecekler:
- `_DashboardAppBar` → `DashboardAppBar`
- `_NotificationPanel` → `NotificationPanel`
- `_DashboardShimmer` → `DashboardShimmer`
- vb.

### 4) Bagimli siniflari ayni dosyada tut

Envanter analizine gore:
- `NotificationPanel` ile birlikte `_PanelSectionHeader`, `_WarrantyNotifTile`, `_AssignmentNotifTile` ayni dosyada kalacak (birbirine sıkı bagli)
- `QuickActionsRow` ile `_QuickAction` ayni dosyada (tek kullanim yeri)

### 5) Callback pattern'i koru

`NotificationPanel` icin `onMarkRead(String)` callback'i aynen korunacak. Parent-child iletisimi degismiyor, sadece `StatefulWidget` artik ayri dosyada tanimli.

### 6) Her gorev sonrasi dogrulama

Her widget ayiklandiktan sonra:
1. `flutter analyze` → 0 hata, 0 uyari
2. `flutter run` (veya hot reload) → emulator'de dashboard'i ac, gorsel olarak ayni mi kontrol et
3. `git add . && git commit -m "refactor(dashboard): XxxWidget ayiklandi"`

Bu sira **zorunlu** — adim atla olmaz. Her adim izole ve geri donulebilir olmali.

### 7) Eski kod referansi

Envanterdeki satir numaralari Claude Code icin yol gostericidir, ama dosya refactor sirasinda satir numaralari degisir. Claude Code her gorevde **guncel dosyayi yeniden okumali**, eski satir numarasina guvenmemeli.

---

## Gorevler

### T1 — DashboardSectionHeader ayikla

**Hedef:** `lib/features/dashboard/widgets/section_header.dart`

**Ne yapilacak:**
- Mevcut `_SectionHeader` class'ini oku (envantere gore satir 1093-1125, ~33 satir)
- Yeni dosyaya tasi, adini `DashboardSectionHeader` yap
- `dashboard_screen.dart` icinden `_SectionHeader` class'ini sil
- `dashboard_screen.dart`'ta `_SectionHeader(...)` cagrilarini `DashboardSectionHeader(...)` olarak degistir
- Yeni dosyaya `import 'package:flutter/material.dart';` ekle
- `dashboard_screen.dart`'a `import '../widgets/section_header.dart';` ekle

**Dosya iskeleti:**
```dart
import 'package:flutter/material.dart';

/// Dashboard bolumleri icin standart baslik bileseni.
/// Mavi dikey cubuk + buyuk harf baslik.
class DashboardSectionHeader extends StatelessWidget {
  final String title;
  const DashboardSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // ... eski _SectionHeader.build icerigi aynen
  }
}
```

**Kabul kriteri:**
- `flutter analyze` temiz
- `flutter run` + dashboard'i ac: tum bolum baslıklari eskisi gibi gorunuyor (Hizli Islemler, Son Aktiviteler, Garanti Uyarilari vb.)

**Commit:** `refactor(dashboard): SectionHeader ayri dosyaya tasindi`

---

### T2 — DashboardShimmer ayikla

**Hedef:** `lib/features/dashboard/widgets/dashboard_shimmer.dart`

**Ne yapilacak:**
- `_DashboardShimmer` class'ini (satir 1399-1458) yeni dosyaya tasi
- Public yap: `DashboardShimmer`
- `dashboard_screen.dart`'ta `_DashboardShimmer()` cagrisini `DashboardShimmer()` yap
- `const` constructor koru

**Import'lar:**
- `package:flutter/material.dart`
- `package:shimmer/shimmer.dart` (mevcut kullaniyor)

**Kabul kriteri:**
- `flutter analyze` temiz
- Dashboard loading state'ini test et: manuel olarak `flutter run` sonrasi pull-to-refresh yap → shimmer gorunmeli (kisa sure de olsa)

**Commit:** `refactor(dashboard): DashboardShimmer ayri dosyaya tasindi`

---

### T3 — DashboardError ayikla

**Hedef:** `lib/features/dashboard/widgets/dashboard_error.dart`

**Ne yapilacak:**
- `_DashboardError` class'ini (satir 1462-1521) yeni dosyaya tasi
- Public yap: `DashboardError`
- Constructor: `DashboardError({required Object error, required VoidCallback onRetry})`
- `dashboard_screen.dart` cagrısını guncelle

**Kabul kriteri:**
- `flutter analyze` temiz
- Error state test et: **gecici** olarak API'yi durdurup (Stop AssetFlow veya elle Ctrl+C), sonra dashboard'i refresh et → hata widget'i gorunmeli. Sonra API'yi geri baslat.

**Commit:** `refactor(dashboard): DashboardError ayri dosyaya tasindi`

---

### T4 — DashboardKpiGrid ayikla

**Hedef:** `lib/features/dashboard/widgets/dashboard_kpi_grid.dart`

**Ne yapilacak:**
- `_DashboardContent.build()` icindeki KPI GridView bolumunu (satir 431-489, ~59 satir) al
- Yeni `DashboardKpiGrid` class'ina cevir
- Constructor: `DashboardKpiGrid({required DashboardData data})`
- Import edilecek: `stat_card.dart`, dashboard_model.dart (DashboardData icin)
- `_DashboardContent.build()`'te bu bolumun yerine `DashboardKpiGrid(data: data)` koy

**DIKKAT:** Bu bir inline blok, tamamen yeni class olusturulacak. Mevcut GridView icindeki 6 `StatCard` aynen korunacak.

**Kabul kriteri:**
- `flutter analyze` temiz
- Dashboard'da 6 KPI kart gorunur, rakamlar/renkler eskisi gibi

**Commit:** `refactor(dashboard): DashboardKpiGrid ayri dosyaya tasindi`

---

### T5 — WarrantyAlertsSection ayikla

**Hedef:** `lib/features/dashboard/widgets/warranty_alerts_section.dart`

**Ne yapilacak:**
- `_WarrantySection` class'ini (satir 1280-1395, ~116 satir) yeni dosyaya tasi
- Public yap: `WarrantyAlertsSection`
- Envanter 5.4'e gore: `items` field'ini `List<dynamic>` yerine `List<WarrantyAlertItem>` olarak guclu tiple
- `_DashboardContent.build()`'te cagrisini guncelle

**Constructor:**
```dart
WarrantyAlertsSection({super.key, required List<WarrantyAlertItem> items})
```

**Import'lar:**
- dashboard_model.dart (WarrantyAlertItem icin)
- go_router (routing icin)
- material

**Kabul kriteri:**
- `flutter analyze` temiz
- Garanti uyari listesi gorunur, renkler (kirmizi/sari/turuncu) dogru, bir uyarıya tiklandiginda `/devices/:id`'ye gitmeli

**Commit:** `refactor(dashboard): WarrantyAlertsSection ayri dosyaya tasindi`

---

### T6 — RecentActivitySection ayikla

**Hedef:** `lib/features/dashboard/widgets/recent_activity_section.dart`

**Ne yapilacak:**
- `_RecentActivitySection` class'ini (satir 1184-1276, ~93 satir) yeni dosyaya tasi
- Public yap: `RecentActivitySection`
- `_recentShimmer()` helper'i bu dosyaya icsel bir private method olarak tasi (envanter 5.3'e gore)
- `_DashboardContent.build()`'te cagrisini guncelle

**Constructor:**
```dart
RecentActivitySection({super.key, required List<Assignment> items})
```

**NOT:** `_DashboardContent` bu widget'i `recentAsync.when(data: items → RecentActivitySection(items: items), loading: ..., error: ...)` pattern'i ile cagirmiyorsa, loading/error durumu screen'de kalacak. Envanter gorulene gore shimmer sadece data geldikten sonra `items` icin cagriliyor — inline olarak goster.

**Kabul kriteri:**
- `flutter analyze` temiz
- Son zimmetler listesi gorunur, tiklandiginda dogru yere yonlendirir

**Commit:** `refactor(dashboard): RecentActivitySection ayri dosyaya tasindi`

---

### T7 — QuickActionsRow ayikla

**Hedef:** `lib/features/dashboard/widgets/quick_actions_row.dart`

**Ne yapilacak:**
- `_DashboardContent.build()` icindeki quick actions bolumunu (satir 493-533, ~41 satir) yeni class'a cevir
- `_QuickAction` class'ini (satir 1129-1180, ~52 satir) ayni dosyaya tasi
- `QuickActionsRow` public, `_QuickAction` private kalabilir (ayni dosyada olacak)
- `_DashboardContent.build()`'te `QuickActionsRow()` ile yerine koy

**Constructor:**
```dart
const QuickActionsRow({super.key});
```

**Import'lar:**
- material
- go_router (context.go icin)

**Kabul kriteri:**
- `flutter analyze` temiz
- 4 hizli islem butonu yatay scroll'da gorunur, her biri dogru route'a yonlendirir

**Commit:** `refactor(dashboard): QuickActionsRow ayri dosyaya tasindi`

---

### T8 — DashboardAppBar ayikla

**Hedef:** `lib/features/dashboard/widgets/dashboard_app_bar.dart`

**Ne yapilacak:**
- `_DashboardAppBar` class'ini (satir 229-408, ~180 satir) yeni dosyaya tasi
- Public yap: `DashboardAppBar`
- `_greeting()` helper'ini ayni dosyaya tasi (envanter 5.5'e gore)

**Constructor:**
```dart
DashboardAppBar({
  super.key,
  required AuthState authState,
  required int notifCount,
  required bool panelSeen,
  required VoidCallback onNotifTap,
})
```

**Import'lar:**
- material
- auth_provider (AuthState icin)
- intl (DateFormat icin — envanter 5.5)

**`dashboard_screen.dart`'ta:**
- `_DashboardAppBar(...)` cagrisini `DashboardAppBar(...)` yap

**Kabul kriteri:**
- `flutter analyze` temiz
- AppBar'da selamlama + tarih + bildirim zili + avatar eskisi gibi gorunur
- Bildirim zilindeki badge (sayi) ve kirmizi nokta (okunmayan) dogru calisir

**Commit:** `refactor(dashboard): DashboardAppBar ayri dosyaya tasindi`

---

### T9 — NotificationPanel ayikla (EN HASSAS)

**Hedef:** `lib/features/dashboard/widgets/notification_panel.dart`

**Ne yapilacak:**
- `_NotificationPanel` + `_NotificationPanelState` (satir 606-836, ~231 satir) yeni dosyaya tasi
- `_PanelSectionHeader` (satir 838-921) ayni dosyaya tasi
- `_WarrantyNotifTile` (satir 923-1004) ayni dosyaya tasi
- `_AssignmentNotifTile` (satir 1006-1089) ayni dosyaya tasi
- Ana widget public: `NotificationPanel` + `_NotificationPanelState`
- Ic class'lar dosya icinde private kalabilir

**Constructor:**
```dart
NotificationPanel({
  super.key,
  required DashboardData data,
  required List<Assignment> recentAssignments,
  required Set<String> readNotifIds,
  required void Function(String) onMarkRead,
})
```

**DIKKAT — envanter 5.2:**
Parent-child callback zinciri korunmali. `_DashboardScreenState._openNotifications()` icindeki `showModalBottomSheet` cagrısında:
```dart
builder: (_) => NotificationPanel(
  data: data,
  recentAssignments: recentItems,
  readNotifIds: _readNotifIds,
  onMarkRead: (id) => setState(() => _readNotifIds.add(id)),
)
```
Bu pattern aynen kalmali.

**Import'lar:**
- material
- dashboard_model.dart (DashboardData, WarrantyAlertItem icin)
- assignment_model.dart (Assignment icin)
- go_router (envanter 5.6 — Navigator.pop + router.go icin)

**Kabul kriteri:**
- `flutter analyze` temiz
- AppBar'daki bildirim zilinden panel acilir
- Okundu isaretleme calisir (tile'a tıklandığinda badge sayisi azalir)
- Panel kapat-ac: okundu durumu korunur (parent state'e yaziyor)
- Tile'a tıklayinca dogru route'a gider (garanti → /devices/:id, zimmet → /assignments)

**Commit:** `refactor(dashboard): NotificationPanel ayri dosyaya tasindi`

---

### T10 — Son dogrulama ve temizlik

**Ne yapilacak:**
1. `dashboard_screen.dart` dosyasini son haliyle oku, satir sayisini raporla (~220 olmali)
2. Kullanilmayan import'lari temizle
3. `flutter analyze` → 0 hata/uyari
4. `dart format lib/features/dashboard/` ile format at
5. Son bir `flutter run` ile tum dashboard'i gez:
   - Ana ekran acilir (KPI'lar, grafik, quick actions, son aktiviteler, garanti uyarilari)
   - AppBar'daki bildirim ziline bas, panel acilir
   - Bildirim tile'ina bas, okundu isaretlenir
   - Panel kapat, ac: okundu durumu korunuyor
   - Bir bildirim tile'ına bas, dogru sayfaya gidiyor
   - Pull-to-refresh: yeni data geliyor
   - Critical alert popup: session basina bir kez tetikleniyor (login sonrasi veya ilk acilis)
6. Git log ile 9 commit'i dogrula:
   ```bash
   git log --oneline | Select-Object -First 12
   ```

**Kabul kriteri:**
- `dashboard_screen.dart` ~220 satir (+/- 30)
- `lib/features/dashboard/widgets/` altinda 9 yeni dosya (+ eski stat_card.dart ve device_type_chart.dart = 11 toplam)
- Tum smoke test adimlari gecer
- Hicbir davranis degisikligi yok — refactor oncesi ne yapiyorsa ayni

**Commit:** `refactor(dashboard): kullanilmayan import'lar temizlendi + format`

---

## Kapsam Disi

Bu SPEC'te yapilmayacaklar (sonraki SPEC'lere):

- **_DashboardContent'i ayri dosyaya tasimak** — su an bir Column orchestrator, sadelik icin screen icinde kalsin
- **Bildirim bug'ı fix** (`notifySapBudgetApproved` pending ile tetikleniyor) — ayri SPEC_MOBILE_002 olacak
- **Yeni feature eklemek** — bu SADECE refactor
- **Mantik optimizasyonu** — `_readNotifIds` senkronizasyonunu degistirmek, cache stratejisini iyilestirmek, vb.
- **Testleri eklemek** — widget test yazma, test coverage SPEC_MOBILE_00X'e gider
- **UI degisikligi** — renk, boyut, animasyon degistirmek YOK

---

## Notlar (Claude Code icin)

- **SIFIR DAVRANIŞ DEGISIKLIGI** — bu en kritik kural. Goruldugu gibi calismaya devam etmeli
- Her gorev BITTIGINDE `flutter analyze` ve `flutter run` ile dogrula, commit at, sonraki goreve gec
- Her gorevde **dosyayi yeniden oku** — satir numaralari her refactor sonrasi degisir, eskiye guvenme
- Private class'lari public yaparken **tum cagrılari da guncelle**, yoksa compile error olur
- Import'lari temiz tut — kullanilmayan import varsa sil
- **Yeni feature ekleme**, davranisi degistirme — sadece dosya tasima
- `_DashboardContent` screen dosyasinda kaliyor, ama T4-T7'deki widget cagirilarini icinden yapacak (inline blok → widget cagrisi)
- Emre'nin onayiyla git commit at, her gorev icin ayri commit
- Hata aldiginda dur, Emre'ye raporla, tahmine dayali fix deneme

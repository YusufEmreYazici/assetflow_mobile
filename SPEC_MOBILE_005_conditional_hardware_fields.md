# SPEC_MOBILE_005 — Cihaz Tipine Göre Koşullu Donanım Alanları

**Hedef proje:** `C:\Workspace\Personal_Projects\assetflow_mobile`
**Tip:** UI iyileştirme — frontend-only, backend'e dokunulmaz
**Tahmini süre:** 20 dakika
**Bağımlılık:** `SPEC_MOBILE_004` tamamlanmış olmalı (10 donanım alanı form'a eklenmiş)

---

## Amaç

Cihaz ekleme/düzenleme formunda, **seçilen cihaz tipine göre** ilgili donanım alanlarını göster/gizle. Böylece:
- Kullanıcı gereksiz alanla uğraşmaz (monitor için CPU sormuyoruz)
- Form görsel olarak daha temiz
- Yanlış veri girme riski azalır

---

## Mimari Kararlar

### 1) Frontend-only — backend dokunulmaz

Backend Device entity tüm 10 alanı destekliyor. Kullanıcı o tipteki cihaz için alanı görmedi mi? `null` gider. Zaten backend'de tüm alanlar nullable, sorun yok.

### 2) Matris tek yerde — sabit

Hangi tip hangi alanı görecek? Bir Map'te tutulacak. Değişiklik isteği olursa tek yer değişir.

```dart
// lib/features/devices/screens/device_form_screen.dart icinde
static const Map<int, Set<String>> _hardwareFieldsByType = {
  0: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'}, // Laptop - hepsi
  1: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'}, // Desktop - hepsi
  2: {},                                                                                       // Monitor - hiçbiri
  3: {'hostname', 'mac', 'ip'},                                                                // Printer - 3 alan
  4: {'cpu', 'ram', 'storage', 'os', 'mac', 'ip'},                                            // Phone - 6 alan
  5: {'cpu', 'ram', 'storage', 'os', 'mac', 'ip'},                                            // Tablet - 6 alan
  6: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'}, // Server - hepsi
  7: {'hostname', 'os', 'mac', 'ip'},                                                          // Network Device - 4 alan
  8: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'}, // Other - hepsi
};
```

### 3) Section görünürlük mantığı

Her section'ın içindeki tüm alanlar gizliyse, section başlığı da gizlenecek. Örnek:
- **Monitor** → TEMEL DONANIM section'ında CPU/RAM/Storage/GPU hepsi gizli → section başlığı da gizli
- Aynı şey SİSTEM/AĞ/TEKNİK section'lar için

### 4) Setstate ile reaktif

`_selectedType` değiştiğinde (DropdownButton onChanged) `setState` çağrılır → build yeniden çalışır → yeni alanlar görünür. Zaten mevcut yapıda `_selectedType` setState'te.

### 5) Değer kaybı — kullanıcı uyarısı YOK

Kullanıcı "Desktop" seçti, CPU "i5-12400" girdi. Sonra "Monitor" değiştirdi. CPU alanı gizlendi. Kaydetti.

**Davranış:** CPU değeri backend'e gitmez (hidden controller boş olmasa bile artık kullanıcı seçmedi). Kaydederken **sadece görünür alanlar** data map'e eklenir.

Alternatif: Gizli alanların değerini sakla, Desktop'a dönünce geri gelsin. Daha karmaşık, şimdi gereksiz.

**Karar:** Sadece görünür alanlar kaydedilir. Gizli alanların controller'ı hafızada kalır ama değer gönderilmez.

### 6) Edit mode'da doldurma

Mevcut cihaz düzenlenirken:
- Device'ın type'ı ne ise → o tipin alanları görünür
- Mevcut değerler doldurulmuş gelir
- Kullanıcı tip değiştirirse yeni tipin alanları görünür

### 7) Kullanıcı deneyimi

**İlk açılış:** Form açıldığında default tip "Laptop" seçili olabilir (veya mevcut tip). Kullanıcı tip seçmeden kayda bassa ne olur?
- Mevcut davranış değişmiyor — tip seçmek zorunlu zaten (DropdownButton)
- Seçili tipin alanları görünür

---

## Veri / Tipler

### _hardwareFieldsByType map

Yukarıda mimari 2'de tanımlı. Tek yerde sabit.

### _shouldShowField helper

```dart
bool _shouldShowField(String fieldKey) {
  final allowed = _hardwareFieldsByType[_selectedType] ?? {};
  return allowed.contains(fieldKey);
}
```

### _shouldShowSection helper

```dart
bool _shouldShowSection(Set<String> sectionFields) {
  final allowed = _hardwareFieldsByType[_selectedType] ?? {};
  return sectionFields.any((f) => allowed.contains(f));
}
```

### Section field grupları

```dart
static const _temelDonanimFields = {'cpu', 'ram', 'storage', 'gpu'};
static const _sistemFields = {'hostname', 'os'};
static const _agFields = {'mac', 'ip'};
static const _teknikFields = {'bios', 'motherboard'};
```

---

## Dokunulacak Dosyalar

### Değiştirilecek

- `lib/features/devices/screens/device_form_screen.dart` — tek dosya değişikliği

### Dokunulmayan

- Backend — entity zaten tüm alanları destekliyor
- `device_model.dart` — model değişmez
- `device_service.dart` — raw map, otomatik taşır
- Diğer ekranlar

---

## Görevler

### T1 — Matris ve helper metodları ekle

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
- State class'ının başına (field'lardan önce) `static const` olarak:
  - `_hardwareFieldsByType` map
  - `_temelDonanimFields`, `_sistemFields`, `_agFields`, `_teknikFields` set'leri
- State class'ına `_shouldShowField(String)` ve `_shouldShowSection(Set<String>)` private methodları

**Kabul kriteri:**
- `flutter analyze` temiz
- Map ve set'ler tanımlı, henüz kullanılmıyor

**Commit:** `feat(devices): cihaz tipine gore alan gorunurluk matrisi eklendi`

---

### T2 — Form UI'da conditional rendering

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**

SPEC_MOBILE_004'te eklenen 4 section'ı koşullu hale getir:

**TEMEL DONANIM section:**
```dart
if (_shouldShowSection(_temelDonanimFields)) ...[
  const _SectionHeader(title: 'TEMEL DONANIM', icon: Icons.memory),
  const SizedBox(height: 8),
  if (_shouldShowField('cpu')) ...[
    AppTextField(
      label: 'CPU Bilgisi',
      hint: 'Örn: Intel Core i7-1355U',
      controller: _cpuController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
  ],
  if (_shouldShowField('ram')) ...[
    AppTextField(
      label: 'RAM Bilgisi',
      hint: 'Örn: 16 GB DDR4',
      controller: _ramController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
  ],
  if (_shouldShowField('storage')) ...[
    AppTextField(
      label: 'Depolama Bilgisi',
      hint: 'Örn: 512 GB NVMe SSD',
      controller: _storageController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
  ],
  if (_shouldShowField('gpu')) ...[
    AppTextField(
      label: 'GPU Bilgisi',
      hint: 'Örn: NVIDIA RTX 3060',
      controller: _gpuController,
      textInputAction: TextInputAction.next,
    ),
    const SizedBox(height: 16),
  ],
],
```

Aynı pattern:
- **SİSTEM BİLGİLERİ** → `_sistemFields`, 2 alan (hostname, os)
- **AĞ BİLGİLERİ** → `_agFields`, 2 alan (mac, ip) — validator'lar korunur
- **TEKNİK DETAYLAR** → `_teknikFields`, 2 alan (bios, motherboard)

**Dikkat:**
- Mevcut sıra korunur
- `const SizedBox(height: 16)` her alandan sonra — gizli alanda sizedbox da gizli
- Validator'lar (MAC/IP) sadece ilgili alan görünürken çalışır

**Kabul kriteri:**
- `flutter analyze` temiz
- Monitor seçilince 4 section tamamen kaybolur
- Laptop/Desktop seçilince 10 alan da görünür
- Printer seçilince sadece Hostname + MAC + IP görünür (SİSTEM section'ı "hostname" olur, AĞ section'ı "mac + ip" olur)
- Printer'da TEMEL DONANIM ve TEKNİK section'lar gizli

**NOT:** Printer için SİSTEM section'ında sadece Hostname var, OS yok. Yani section görünür ama içinde tek alan. Bu doğru davranış.

**Commit:** `feat(devices): cihaz tipine gore alanlar ve sectionlar kosullu g\u00f6steriliyor`

---

### T3 — _onSave data map koşullu güncellemesi

**Dosya:** `lib/features/devices/screens/device_form_screen.dart`

**Detaylar:**
`_onSave`'te data map'e 10 alan ekleme kısmını güncelle. Sadece görünür alanlar eklensin:

```dart
// Onceden:
'cpuInfo': _cpuController.text.trim().isEmpty ? null : _cpuController.text.trim(),

// Simdi:
'cpuInfo': _shouldShowField('cpu') && _cpuController.text.trim().isNotEmpty
    ? _cpuController.text.trim()
    : null,
```

10 alan için aynı pattern uygulanacak.

**Sebep:** Kullanıcı Desktop seçti, CPU girdi. Sonra Monitor değiştirdi. CPU alanı gizlendi. Kaydederken CPU değeri gitmesin — null olarak kaydedilsin.

**Kabul kriteri:**
- `flutter analyze` temiz
- Test: Desktop → CPU "test" → Monitor değiştir → kaydet → DB'de cpuInfo null

**Commit:** `feat(devices): _onSave sadece gorunur alanlar\u0131 kaydediyor`

---

### T4 — Son doğrulama

**Detaylar:**
1. `flutter analyze` → 0 hata
2. `dart format lib/features/devices/screens/`
3. **Emulator'de 4 test senaryosu:**

**Senaryo 1 — Laptop:**
- Cihaz ekle → Tip: Laptop
- 4 section görünür (TEMEL/SİSTEM/AĞ/TEKNİK)
- Tüm 10 alan girilebilir
- Kaydet → backend'e 10 alan gider

**Senaryo 2 — Monitor:**
- Cihaz ekle → Tip: Monitor
- 4 section **tamamen gizli**
- Sadece mevcut temel alanlar (ad, marka, model, seri, demirbaş, durum, tarih, fiyat, tedarikçi, garanti, notlar) görünür
- Kaydet → donanım alanlarının hepsi null gider

**Senaryo 3 — Printer:**
- Tip: Printer
- TEMEL DONANIM **gizli**
- SİSTEM BİLGİLERİ section'ında sadece **Hostname** görünür (OS gizli)
- AĞ BİLGİLERİ section'ında **MAC + IP** görünür
- TEKNİK DETAYLAR **gizli**
- Kaydet → sadece 3 alan gider

**Senaryo 4 — Tip değişimi:**
- Yeni cihaz ekle → Tip: Desktop
- CPU alanına "Intel i7" yaz
- Tipi **Monitor** değiştir
- CPU alanı gizlenir
- Tipi tekrar **Desktop** değiştir
- CPU alanı tekrar görünür, **"Intel i7" değeri korunuyor** (controller hafızada)

**Senaryo 5 — Excel formunda:**
- Laptop ekle, tüm alanları doldur
- Zimmet aç → zimmet formu üret → Excel indir
- "CPU / RAM / Depolama" alanları artık "-" değil, gerçek değer görünür

**Kabul kriteri:**
- Tüm senaryolar çalışır
- Backend'de veriler doğru (PowerShell ile kontrol)
- Excel formunda donanım doğru görünür

**Commit:** (değişiklik varsa) `refactor: final cleanup`

---

## Kapsam Dışı

- Monitor, Printer vs. için **özel alanlar** (ekran boyutu, baskı tipi) — ayrı SPEC
- **Tip değiştirince onay sorma** ("Emin misiniz? Bazı alanlar gizlenecek") — kullanıcı dostu değil
- **Gizli alanları formda tutma** (controller hafızada kalır ama backend'e giderken null)
- **Backend validation** — backend zaten tüm alanları nullable kabul ediyor

---

## Notlar (Claude Code için)

- **Her görev sonrası:** `flutter analyze` + commit
- **Mevcut 12 temel alana DOKUNMA** — sadece T4'te eklediğin 10 donanım alanını koşullu hale getir
- **Hot reload yetmez** — tip değiştirince state'i gözleme için **hot restart**
- **Form validation** — gizli bir alanın validator'ı çağrılmaz Flutter'da (Widget tree'de yok), sorun olmaz
- **Pattern sadakatı** — `if (condition) ...[]` spread pattern'i Dart'ta deyim, kullan
- **Plan mode her görev** — kısa plan çıkar, onayla, uygula
- **Hata alırsan DUR**, raporla

---

## Özet Beklenen Sonuç

Kullanıcı cihaz tipi seçince:

| Tip | Görünen donanım alanı |
|---|---|
| Laptop/Desktop/Server/Other | 10 alan (hepsi) |
| Phone/Tablet | 6 alan (CPU, RAM, Storage, OS, MAC, IP) |
| Network Device | 4 alan (Hostname, OS, MAC, IP) |
| Printer | 3 alan (Hostname, MAC, IP) |
| Monitor | 0 alan (donanım section tamamen gizli) |

Form daha akıllı, temiz, kullanıcı dostu. Backend davranışı aynı (kaydedilen veri doğru).

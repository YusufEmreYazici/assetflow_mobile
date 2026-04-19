# Iade + Zimmet Formu Feature — Mobil Envanter

Tarih: 2026-04-19

---

## ADIM 1 — Mevcut İade Flow Analizi

### Ekranlar
- **`lib/features/assignments/screens/assignments_screen.dart`** — Ana zimmet listesi. Aktif zimmetlerde "İade Et" butonu görünür.
- **`lib/features/assignments/screens/assign_device_screen.dart`** — Yeni zimmet oluşturma formu (iade değil).

### İade Butonu ve Akış
- Konum: `assignments_screen.dart:401-419` — satır içi `InkWell` container, `_confirmReturn(a.id)` çağırır.
- `_confirmReturn` (`satır 96-121`): basit `AlertDialog` — **"Emin misiniz?"** onayı. Hiçbir bilgi girişi yok.
- Provider çağrısı: `ref.read(assignmentProvider.notifier).returnDevice(id)` → `AssignmentService.returnDevice(id)`
- API: `POST /api/assignments/{id}/return` — **body geçilmiyor** (returnCondition, notes yok).

### Değerlendirme
İade UI **minimum** düzeyde: tek onay sorusu, veri toplama yok. Backend modeli `returnCondition` ve `notes` destekliyor ama kullanılmıyor.

---

## ADIM 2 — Assignment Service & Provider

### AssignmentService (`lib/data/services/assignment_service.dart`)
| Metot | Endpoint | Not |
|---|---|---|
| `getAll(page, pageSize, search, isActive)` | GET /api/assignments | Filtreleme destekli |
| `getById(id)` | GET /api/assignments/{id} | — |
| `assign(Map data)` | POST /api/assignments | Body: deviceId, employeeId, type, expectedReturnDate, notes |
| `returnDevice(id)` | POST /api/assignments/{id}/return | **Body yok — genişletilmeli** |
| `exportForm(id)` | GET /api/assignments/{id}/export | `ResponseType.bytes` → `Uint8List` döner |

### AssignmentNotifier (`lib/features/assignments/providers/assignment_provider.dart`)
- `returnDevice(id)`: servis çağrısı + `notifyAssignmentReturned` + `loadAssignments` refresh.
- `notifyAssignmentReturned` çağrısında `condition` parametresi **null** geçiliyor (satır 167).

### Assignment Modeli (`lib/data/models/assignment_model.dart`)
Önemli alanlar:
```dart
final int? returnCondition;   // 0=İyi 1=Hasarlı 2=Arızalı 3=Kayıp
final String? notes;          // zimmet notu
final DateTime? returnedAt;   // iade tarihi
final bool isActive;          // aktif/tamamlanan ayrımı
final String? assignedByName; // zimmeti açan kullanıcı
```
`ReturnConditionLabels: { 0:'Iyi', 1:'Hasarli', 2:'Arizali', 3:'Kayip' }` — dropdown için hazır.

---

## ADIM 3 — Cihaz Detay Ekranı

### Dosya
`lib/features/devices/screens/device_detail_screen.dart`

### Ne Gösteriyor
`_SectionCard` ile bölümlenmiş ListView:
1. **Genel Bilgi** — tip, durum, seri no, demirbaş kodu, marka, model, zimmetli kişi
2. **Satın Alma** — tarih, fiyat, tedarikçi (conditional)
3. **Garanti** — süre, bitiş, durum (conditional)
4. **Lokasyon** — lokasyon adı (conditional)
5. **Donanım** — hostname, CPU, RAM, depolama, GPU, OS, IP, MAC (conditional)
6. **Notlar** — serbest metin (conditional)

### Provider
`_deviceDetailProvider` = `FutureProvider.autoDispose.family<Device, String>` (satır 11-13)

### "Son Zimmet Formu" Linki İçin Uygun Yer
Cihazın `assignedTo` bilgisi satır 101-103'te gösteriliyor, ancak zimmet detayı/formu yok.
Ekleme yeri: Lokasyon section'ından sonra (~satır 164), yeni bir section veya action butonu olarak:
```dart
// ~satır 164 — lokasyon SizedBox'ından sonra
_SectionCard(
  title: 'Aktif Zimmet',
  icon: Icons.assignment,
  rows: [...],  // zimmet bilgileri
),
```
Ya da AppBar actions'a Excel ikonu ile.

---

## ADIM 4 — Dosya İndirme / Paylaşma Pattern'i

### Mevcut Kullanım (`assignments_screen.dart:123-138`)
```dart
Future<void> _exportForm(String id, String assetTag) async {
  final bytes = await AssignmentService().exportForm(id);
  final dir = await getTemporaryDirectory();          // path_provider
  final file = File('${dir.path}/Zimmet_$assetTag.xlsx');
  await file.writeAsBytes(bytes);
  await OpenFile.open(file.path);                     // open_file
}
```

### Kullanılan Paketler (pubspec.yaml)
| Paket | Versiyon | Var mı |
|---|---|---|
| `path_provider` | ^2.1.3 | ✅ |
| `open_file` | ^3.5.10 | ✅ |
| `share_plus` | — | ❌ yok |
| `image_picker` | — | ❌ yok |

### Özet
PDF/Excel indirme akışı: `Dio bytes` → `getTemporaryDirectory` → `File.writeAsBytes` → `OpenFile.open`.
Paylaşma (share_plus) gerekiyorsa paket eklenmeli.

---

## ADIM 5 — Dosya Yükleme Pattern'i

### file_picker Kullanımı (`lib/features/devices/screens/device_import_screen.dart`)
```dart
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['csv'],
  withData: true,
);
// bytes veya path üzerinden okuma
final bytes = result.files.first.bytes;            // web/memory
final content = await File(path).readAsString();   // mobile/path
```
- `file_picker: ^8.1.2` mevcut.
- Multipart FormData upload **örneği yok** — CSV parse edilip `_deviceService.create(json)` JSON POST yapılıyor.
- `image_picker` **yok** — imzalı form fotoğrafı için eklenmeli.

---

## ADIM 6 — Mevcut Bildirim Tetikleme

| Bildirim | Nerede tetikleniyor | Dosya |
|---|---|---|
| `notifyAssignmentCreated` | `_assign()` başarısından sonra | `assign_device_screen.dart:145` |
| `notifyAssignmentReturned` | `AssignmentNotifier.returnDevice()` içinde | `assignment_provider.dart:167` |

### Pattern
```dart
await _service.returnDevice(id);           // servis çağrısı
await NotificationService.instance.notifyAssignmentReturned(
  employeeName: assignment.employeeName ?? 'Bilinmiyor',
  deviceName: assignment.deviceName ?? 'Bilinmiyor',
  condition: null,   // ← şu an null, returnCondition string'e çevrilip geçilebilir
);
```

`notifyAssignmentReturned` imzası `condition: String?` parametresi alıyor (`notification_service.dart:156-168`).
`notifyDeviceRetired` de mevcut (`satır 293-305`) — cihaz emekliye alınırsa kullanılabilir.

---

## ADIM 7 — Mevcut Pattern'lar

### Dropdown
`DropdownButtonFormField<T>` — `assign_device_screen.dart:205, 237, 268`. Hazır, yeniden kullanılabilir.

### Multiline TextField
`TextField(maxLines: 3)` — `assign_device_screen.dart:323`. Not girişi için hazır.

### Dialog / BottomSheet
`AlertDialog` — `assignments_screen.dart:97-121`. Sade onay için kullanılıyor.
`showModalBottomSheet` **kullanılmıyor** — tercih edilebilir iade formu için (daha fazla alan).

### LoadingOverlay
- `core/widgets/loading_overlay.dart` — tam ekran overlay.
- `AppButton(isLoading: true)` — inline loading button (`app_button.dart`).
- `bool _saving` + `setState` pattern — `assign_device_screen.dart:28,163`.

### Shimmer
`Shimmer.fromColors` — `assignments_screen.dart:429`, `device_detail_screen.dart:305`. Liste yüklemede kullanılıyor.

---

## ADIM 8 — Tahmini Etki

### Değişecek Dosyalar
| Dosya | Değişiklik |
|---|---|
| `lib/data/services/assignment_service.dart` | `returnDevice(id, {int? returnCondition, String? notes})` — body ekleme |
| `lib/features/assignments/providers/assignment_provider.dart` | `returnDevice(id, condition, notes)` — parametreler + notifikasyona condition geçme |
| `lib/features/assignments/screens/assignments_screen.dart` | `_confirmReturn` → yeni iade ekranına yönlendirme |
| `lib/features/devices/screens/device_detail_screen.dart` | "Son Zimmet Formu" / "Aktif Zimmet" section veya butonu ekleme |

### Yeni Dosyalar
| Dosya | İçerik |
|---|---|
| `lib/features/assignments/screens/return_device_screen.dart` | İade formu: returnCondition dropdown + notes TextField + "İade Et" AppButton. `StatefulWidget`, `Navigator.push` ile açılır, `true` döner. |

### Opsiyonel (Scope'a Bağlı)
| Dosya | İçerik |
|---|---|
| ~~Yoksa~~ Bottom sheet alternatifi | `_ReturnDeviceSheet` private widget — aynı `assignments_screen.dart` içinde |
| Yeni ekran gerekmiyorsa | `showModalBottomSheet` ile inline form — navigasyon azalır |

### Paket Eksikleri
- `share_plus` — PDF/Excel paylaşma gerekiyorsa eklenmeli.
- `image_picker` — imzalı belge fotoğrafı gerekiyorsa eklenmeli.
- Multipart FormData upload için `Dio.FormData` yeterli (ek paket gerekmez).

---

## Özet

```
Mevcut iade: tek "Emin misiniz?" dialog, veri toplamıyor.
returnDevice() body'siz POST → backend returnCondition/notes almıyor.
Assignment modeli returnCondition/notes alanları VAR, kullanılmıyor.
Excel indirme akışı hazır: Dio bytes → path_provider → open_file.
Dropdown, multiline TextField, AlertDialog pattern'ları mevcut.
file_picker var, image_picker yok, share_plus yok.
1 yeni dosya (return_device_screen.dart) + 4 dosya değişikliği yeterli.
```

# SPEC_MOBILE_003 — İade Ekranı + Form Yönetimi

**Hedef proje:** `C:\Workspace\Personal_Projects\assetflow_mobile`
**Tip:** Feature — iade UI geliştirme + AssignmentForm entegrasyonu
**Tahmini süre:** 1.5-2 saat
**Referans envanter:** `FORMS_MOBILE_INVENTORY.md`
**Bağımlılık:** `SPEC_BACKEND_002` tamamlanmış olmalı (backend endpoint'leri hazır olmalı)

---

## Amaç

3 büyük mobile geliştirmesini tek SPEC'te yapmak:

1. **İade ekranı geliştirme** — tek onay dialog'u yerine tam formu (reason, notes, retire)
2. **Form yönetimi** — zimmet ve iade formlarını görüntüle, indir, paylaş, imzalıyı yükle
3. **Cihaz detay sayfasında** son formu gösterme

---

## Mimari Kararlar

### 1) İade ekranı — ayrı sayfa (bottom sheet değil)

Envanter ADIM 1: Mevcut iade tek `AlertDialog` ile onay alıyor. Bunu:
- **Ayrı ekran** (`ReturnDeviceScreen`) — `Navigator.push` ile açılır, `true/false` döner
- Bottom sheet opsiyonu var ama ekran dolusu form için **tam sayfa daha doğal**
- Çünkü içerik: dropdown + 2 TextField + switch + button — bottom sheet'te sıkışır

### 2) Form yönetimi — ayrı widget bileşeni

`AssignmentFormSection` widget'ı oluştur:
- Cihaz detay sayfasında ve zimmet detay sayfasında kullanılabilir
- Formu gösterir, indirme/paylaşma/upload butonları
- Form yoksa "Form üret" butonu

### 3) Paket ekleme — share_plus

Envanter ADIM 4: `share_plus` yok. **Eklenecek** çünkü:
- Kullanıcı form Excel'i üretti → WhatsApp'tan İK'ya göndermek istiyor
- `share_plus` bu için standart çözüm

`image_picker` GEREKLİ DEĞİL — kullanıcı zaten imzalı Excel'i `file_picker` ile yükleyecek.

### 4) Excel download + share pattern — mevcut akışı genişlet

Envanter ADIM 4'te mevcut pattern var:
```dart
Dio bytes → getTemporaryDirectory → File.writeAsBytes → OpenFile.open
```

Buna ek `Share.shareXFiles([XFile(path)])` eklenecek:
- "Aç" butonu → `open_file`
- "Paylaş" butonu → `share_plus`
- "Kaydet" butonu → aynı dosya zaten `getApplicationDocumentsDirectory` altına kopyalanır

### 5) Upload pattern — Dio FormData

Envanter ADIM 5: Multipart upload örneği yok, ama Dio FormData yeterli:
```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(path, filename: name),
});
await _dio.post('/api/assignment-forms/$formId/upload-signed', data: formData);
```

### 6) State management — yeni provider

`AssignmentFormNotifier` + `assignmentFormProvider` ekle:
- `generateAssignmentForm(assignmentId)` → form üret, local state'e ekle
- `generateReturnForm(assignmentId)` → aynı
- `downloadForm(formId)` → byte[] al, cache, dön
- `uploadSigned(formId, filePath)` → upload, state güncelle
- `getFormsByAssignment(assignmentId)` → liste dön

Mevcut `AssignmentNotifier` ile aynı pattern (StateNotifier + service).

### 7) Model

```dart
class AssignmentForm {
  final String id;
  final String assignmentId;
  final int type; // 0=Assignment, 1=Return
  final String formNumber;
  final DateTime generatedAt;
  final String generatedByUserName;
  final bool isSigned;
  final DateTime? signedUploadedAt;

  String get typeLabel => type == 0 ? 'Zimmet Formu' : 'İade Formu';
}
```

### 8) Cihaz detay güncellemesi

Envanter ADIM 3'te belirlenen yer: `_SectionCard` yapısı mevcut, Lokasyon section'ından sonra yeni section eklenecek:
```dart
_SectionCard(
  title: 'Son Zimmet/İade Formu',
  icon: Icons.description,
  // Eğer device zimmetliyse: son form + download/share
  // Değilse: son tamamlanan zimmetin son formu
),
```

### 9) İade akışı navigasyon

Eski akış:
```
AssignmentsScreen → "İade Et" → AlertDialog("Emin misiniz?") → AssignmentService.returnDevice
```

Yeni akış:
```
AssignmentsScreen → "İade Et" → ReturnDeviceScreen(assignment) →
  Kullanıcı formu doldurur →
  "İade Et" butonu →
  AssignmentService.returnDevice(id, condition, notes, ...) →
  Success → Dialog: "İade edildi. İade formu üretilsin mi?" →
    [Evet] → generateReturnForm → Download/Share dialog
    [Hayır] → pop(true)
```

### 10) Zimmet formu otomatik üretimi

Yeni zimmet atandığında otomatik zimmet formu üretilmeli mi?
**EVET** — `AssignDeviceScreen` success sonrası `generateAssignmentForm` otomatik çağrılır, sonuç dialog'da gösterilir.

Bu `assign_device_screen.dart`'a küçük bir ekleme (5 satır), assignment success callback'inde.

---

## Veri / Tipler

### Yeni Model

```dart
// lib/data/models/assignment_form_model.dart
class AssignmentForm {
  final String id;
  final String assignmentId;
  final int type;
  final String formNumber;
  final DateTime generatedAt;
  final String generatedByUserName;
  final bool isSigned;
  final DateTime? signedUploadedAt;

  AssignmentForm({
    required this.id,
    required this.assignmentId,
    required this.type,
    required this.formNumber,
    required this.generatedAt,
    required this.generatedByUserName,
    required this.isSigned,
    this.signedUploadedAt,
  });

  factory AssignmentForm.fromJson(Map<String, dynamic> json) { /* ... */ }

  String get typeLabel => type == 0 ? 'Zimmet Formu' : 'İade Formu';
  String get fileName => '$formNumber.xlsx';
}
```

### Yeni Service

```dart
// lib/data/services/assignment_form_service.dart
class AssignmentFormService {
  final Dio _dio = ApiClient.instance.dio;

  Future<AssignmentForm> generateAssignmentForm(String assignmentId);
  Future<AssignmentForm> generateReturnForm(String assignmentId);
  Future<Uint8List> downloadForm(String formId);
  Future<Uint8List> downloadSigned(String formId);
  Future<AssignmentForm> uploadSigned(String formId, String filePath, String fileName);
  Future<List<AssignmentForm>> getByAssignment(String assignmentId);
  Future<AssignmentForm?> getLatest(String assignmentId);
}
```

### Yeni Provider

```dart
// lib/features/assignments/providers/assignment_form_provider.dart
final assignmentFormProvider = StateNotifierProvider.family<AssignmentFormNotifier, AsyncValue<List<AssignmentForm>>, String>(
  (ref, assignmentId) => AssignmentFormNotifier(assignmentId),
);

class AssignmentFormNotifier extends StateNotifier<AsyncValue<List<AssignmentForm>>> {
  // methods: generateAssignment, generateReturn, uploadSigned, refresh
}
```

### ReturnDeviceRequest

AssignmentService'te mevcut `returnDevice` metodu imzası değişecek:
```dart
// ESKİ:
Future<void> returnDevice(String id);

// YENİ:
Future<void> returnDevice(
  String id, {
  required int returnCondition,  // 0-3
  String? returnNotes,
  String? deviceNotes,
  bool retireDevice = false,
});
```

---

## Dokunulacak Dosyalar

### Yeni Dosyalar

- `lib/data/models/assignment_form_model.dart`
- `lib/data/services/assignment_form_service.dart`
- `lib/features/assignments/providers/assignment_form_provider.dart`
- `lib/features/assignments/screens/return_device_screen.dart`
- `lib/features/assignments/widgets/assignment_form_section.dart`
- `lib/features/assignments/widgets/form_action_sheet.dart` (download/share/upload aksiyonları)

### Değiştirilecek Dosyalar

- `pubspec.yaml` — `share_plus` eklenecek (**ask listesinde**)
- `lib/data/services/assignment_service.dart` — `returnDevice` imza değişikliği
- `lib/features/assignments/providers/assignment_provider.dart` — `returnDevice` parametreleri, condition bildirimle
- `lib/features/assignments/screens/assignments_screen.dart` — `_confirmReturn` yerine `ReturnDeviceScreen`'a push
- `lib/features/assignments/screens/assign_device_screen.dart` — success sonrası otomatik form üretim + dialog
- `lib/features/devices/screens/device_detail_screen.dart` — AssignmentFormSection ekleme

### Dokunulmayan

- `notification_service.dart` — mevcut `notifyAssignmentReturned` kullanılacak
- `api_client.dart`, `token_manager.dart` — network altyapısı (**ask listesinde**, dokunmaya gerek yok)
- `auth_provider.dart`, `auth_service.dart` — auth akışı (dokunulmayacak)

---

## Görevler

### T1 — AssignmentForm model + Service

**Dosyalar:** `assignment_form_model.dart`, `assignment_form_service.dart`

**Detaylar:**
- Model: 8 field + factory fromJson + typeLabel getter
- Service: 7 method, `ApiClient.instance.dio` kullanır
- Download methodları `ResponseType.bytes` kullanır (mevcut `exportForm` pattern'i)
- Upload için `FormData.fromMap` + `MultipartFile.fromFile`

**Kabul kriteri:**
- `flutter analyze` temiz
- 2 yeni dosya, ~150 satır toplam

**Commit:** `feat(forms): AssignmentForm model ve service eklendi`

---

### T2 — AssignmentFormNotifier / Provider

**Dosya:** `assignment_form_provider.dart`

**Detaylar:**
- `StateNotifierProvider.family<AssignmentFormNotifier, AsyncValue<List<AssignmentForm>>, String>`
- Family key: assignmentId
- Constructor: initial fetch + state = `AsyncValue.loading()`
- Methods:
  - `_load()` private — form listesini çeker
  - `refresh()` public — yeniden yükler
  - `generateAssignmentForm()` — üretir + refresh
  - `generateReturnForm()` — üretir + refresh
  - `uploadSigned(formId, filePath, fileName)` — yükler + refresh

Pattern mevcut `AssignmentNotifier` ile aynı.

**Kabul kriteri:**
- `flutter analyze` temiz
- Provider `ref.watch(assignmentFormProvider(id))` ile kullanılabilir

**Commit:** `feat(forms): assignment_form_provider eklendi`

---

### T3 — AssignmentService.returnDevice imza güncellemesi

**Dosyalar:** `assignment_service.dart`, `assignment_provider.dart`

**Detaylar:**

`assignment_service.dart`:
```dart
Future<void> returnDevice(
  String id, {
  required int returnCondition,
  String? returnNotes,
  String? deviceNotes,
  bool retireDevice = false,
}) async {
  await _dio.post(
    '/api/assignments/$id/return',
    data: {
      'returnCondition': returnCondition,
      'returnNotes': returnNotes,
      'deviceNotes': deviceNotes,
      'retireDevice': retireDevice,
    },
  );
}
```

`assignment_provider.dart`:
```dart
Future<void> returnDevice(
  String id, {
  required int returnCondition,
  String? returnNotes,
  String? deviceNotes,
  bool retireDevice = false,
}) async {
  final assignment = state.value?.items.firstWhere((a) => a.id == id);
  await _service.returnDevice(
    id,
    returnCondition: returnCondition,
    returnNotes: returnNotes,
    deviceNotes: deviceNotes,
    retireDevice: retireDevice,
  );
  
  // Bildirim: condition artık null değil
  final conditionLabel = ReturnConditionLabels[returnCondition] ?? 'Bilinmiyor';
  await NotificationService.instance.notifyAssignmentReturned(
    employeeName: assignment?.employeeName ?? 'Bilinmiyor',
    deviceName: assignment?.deviceName ?? 'Bilinmiyor',
    condition: conditionLabel,
  );
  
  // Eğer retire edildiyse ek bildirim
  if (retireDevice) {
    await NotificationService.instance.notifyDeviceRetired(
      deviceName: assignment?.deviceName ?? 'Bilinmiyor',
      assetCode: null,
    );
  }
  
  await loadAssignments();
}
```

**Kabul kriteri:**
- `flutter analyze` temiz
- Assignment screen henüz güncellenmedi, compile error olmamalı (çağrı yapan tek yer _confirmReturn, o T4'te güncellenecek)

**NOT:** `_confirmReturn` metodunu geçici olarak bırak, **T4'te** silinecek. O yüzden bu adımda `assignments_screen.dart` compile ediyorsa ama default değerlerle çağırıyorsa kabul.

**Alternatif:** Önce sadece service + provider'ı güncelle, `_confirmReturn` içindeki çağrıyı **default değerlerle** güncelle (returnCondition: 0, retireDevice: false). Böylece compile breaker olmaz, sadece davranış kısıtlı. T4'te de düzgün UI gelir.

**Commit:** `feat(assignments): returnDevice parametreleri eklendi (condition, notes, retire)`

---

### T4 — ReturnDeviceScreen

**Dosya:** `return_device_screen.dart`

**İçerik:**

```dart
class ReturnDeviceScreen extends ConsumerStatefulWidget {
  final Assignment assignment;
  const ReturnDeviceScreen({super.key, required this.assignment});

  @override
  ConsumerState<ReturnDeviceScreen> createState() => _ReturnDeviceScreenState();
}

class _ReturnDeviceScreenState extends ConsumerState<ReturnDeviceScreen> {
  int _condition = 0; // Default: İyi
  final _returnNotesCtrl = TextEditingController();
  final _deviceNotesCtrl = TextEditingController();
  bool _retireDevice = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cihaz İade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cihaz/personel özet kartı
            _InfoCard(
              device: widget.assignment.deviceName,
              employee: widget.assignment.employeeName,
              assetTag: widget.assignment.assetTag,
            ),
            const SizedBox(height: 24),
            
            // İade durumu dropdown
            const Text('İade Durumu *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _condition,
              items: ReturnConditionLabels.entries.map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => setState(() => _condition = v ?? 0),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            // İade notu
            const Text('İade Notu', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _returnNotesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Örnek: Ekran çatladı, servis gerekiyor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cihaza not
            const Text('Cihaza Eklenecek Not (opsiyonel)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _deviceNotesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Cihazın geleceğine dair not (gelecek zimmette görünür)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Retire switch
            Card(
              child: SwitchListTile(
                title: const Text('Cihazı Emekli Et'),
                subtitle: const Text('Envantere geri dönmez, hurda/kayıp/onarılamaz durumda'),
                value: _retireDevice,
                onChanged: (v) => setState(() => _retireDevice = v),
                secondary: const Icon(Icons.delete_outline),
              ),
            ),
            const SizedBox(height: 32),
            
            AppButton(
              text: _retireDevice ? 'Emekli Et ve İade' : 'İade Et',
              icon: Icons.check_circle,
              onPressed: _saving ? null : _submit,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // Onay dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_retireDevice ? 'Emekli Et?' : 'İade Onayı'),
        content: Text(_retireDevice
          ? '${widget.assignment.deviceName} emekli edilecek ve envanterden düşürülecek. Emin misin?'
          : 'İade işlemi tamamlanacak. Onaylıyor musun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Onayla')),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _saving = true);
    try {
      await ref.read(assignmentProvider.notifier).returnDevice(
        widget.assignment.id,
        returnCondition: _condition,
        returnNotes: _returnNotesCtrl.text.trim().isEmpty ? null : _returnNotesCtrl.text.trim(),
        deviceNotes: _deviceNotesCtrl.text.trim().isEmpty ? null : _deviceNotesCtrl.text.trim(),
        retireDevice: _retireDevice,
      );
      
      if (!mounted) return;
      
      // Başarılı — iade formu üret dialog
      final generateForm = await _askGenerateForm();
      
      if (!mounted) return;
      Navigator.pop(context, true);
      
      if (generateForm == true) {
        // Form üret
        final form = await ref.read(assignmentFormProvider(widget.assignment.id).notifier)
          .generateReturnForm();
        if (!mounted) return;
        // Download/share action sheet göster
        await showModalBottomSheet(
          context: context,
          builder: (_) => FormActionSheet(form: form),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İade başarısız: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _askGenerateForm() async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İade Formu'),
        content: const Text('İade formu oluşturulup indirilsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hayır')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet, Üret')),
        ],
      ),
    );
  }
}
```

**Kabul kriteri:**
- `flutter analyze` temiz
- Manuel test: `AssignmentsScreen`'dan "İade Et" → yeni ekran açılır → form doldurur → onay → iade başarılı → form üret dialog → (opsiyonel) üret

**Commit:** `feat(assignments): ReturnDeviceScreen eklendi (reason + notes + retire)`

---

### T5 — AssignmentsScreen güncellemesi

**Dosya:** `assignments_screen.dart`

**Detaylar:**
- `_confirmReturn(id)` method'unu SİL
- "İade Et" butonunun `onTap`'ini değiştir:
  ```dart
  final assignment = /* mevcut a değişkeni */;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => ReturnDeviceScreen(assignment: assignment)),
  );
  // Provider refresh otomatik oluyor zaten (assignment_provider içinde)
  ```
- `_exportForm(id, assetTag)` method'u **DOKUNMAYACAK** — mevcut export pattern kalsın

**Kabul kriteri:**
- `flutter analyze` temiz
- Manuel test: Liste → İade Et → yeni ekran → geri → liste yenilenmiş

**Commit:** `feat(assignments): eski iade dialog'u yerine ReturnDeviceScreen`

---

### T6 — share_plus paketi ekleme + FormActionSheet

**Dosyalar:** `pubspec.yaml`, `form_action_sheet.dart`

**Detaylar:**

`pubspec.yaml`'a (ask listesinde — önce onay):
```yaml
dependencies:
  share_plus: ^10.0.0  # en güncel versiyon
```

`flutter pub get` çalıştırılacak.

`form_action_sheet.dart`:
```dart
class FormActionSheet extends ConsumerStatefulWidget {
  final AssignmentForm form;
  const FormActionSheet({super.key, required this.form});

  @override
  ConsumerState<FormActionSheet> createState() => _FormActionSheetState();
}

class _FormActionSheetState extends ConsumerState<FormActionSheet> {
  File? _localFile;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final bytes = await AssignmentFormService().downloadForm(widget.form.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.form.fileName}');
      await file.writeAsBytes(bytes);
      if (mounted) setState(() => _localFile = file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İndirme hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open() async {
    if (_localFile == null) return;
    await OpenFile.open(_localFile!.path);
  }

  Future<void> _share() async {
    if (_localFile == null) return;
    await Share.shareXFiles(
      [XFile(_localFile!.path)],
      subject: widget.form.fileName,
    );
  }

  Future<void> _uploadSigned() async {
    final picker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'pdf', 'png', 'jpg'],
      withData: false,
    );
    if (picker == null) return;
    final pickedFile = picker.files.first;
    
    setState(() => _loading = true);
    try {
      await ref.read(assignmentFormProvider(widget.form.assignmentId).notifier)
        .uploadSigned(widget.form.id, pickedFile.path!, pickedFile.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İmzalı form yüklendi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yükleme hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.form.typeLabel, style: Theme.of(context).textTheme.titleLarge),
            Text('Form No: ${widget.form.formNumber}'),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator() else const SizedBox(height: 4),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Aç'),
              onTap: _localFile == null ? null : _open,
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Paylaş (WhatsApp, Mail vb.)'),
              onTap: _localFile == null ? null : _share,
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('İmzalı Form Yükle'),
              subtitle: const Text('Imzalandıktan sonra dosyayı seç'),
              onTap: _uploadSigned,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Kabul kriteri:**
- `flutter pub get` başarılı
- `flutter analyze` temiz
- Action sheet açılıyor, download otomatik başlıyor

**Commit:** `feat(forms): FormActionSheet (aç/paylaş/imzalı yükle)`

---

### T7 — AssignmentFormSection widget

**Dosya:** `assignment_form_section.dart`

**İçerik:**
```dart
class AssignmentFormSection extends ConsumerWidget {
  final String assignmentId;
  const AssignmentFormSection({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncForms = ref.watch(assignmentFormProvider(assignmentId));
    
    return asyncForms.when(
      loading: () => const _Shimmer(),
      error: (e, _) => _Error(error: e),
      data: (forms) {
        if (forms.isEmpty) {
          return _EmptyState(
            onGenerate: () => ref.read(assignmentFormProvider(assignmentId).notifier)
              .generateAssignmentForm(),
          );
        }
        // Son form göster
        final latest = forms.first; // assumed sorted desc by generatedAt
        return _FormCard(form: latest);
      },
    );
  }
}

class _FormCard extends StatelessWidget {
  final AssignmentForm form;
  const _FormCard({required this.form});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(form.type == 0 ? Icons.assignment : Icons.assignment_return),
        title: Text(form.typeLabel),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Form No: ${form.formNumber}'),
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(form.generatedAt)}'),
            if (form.isSigned) const Text('✓ İmzalı', style: TextStyle(color: Colors.green)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => FormActionSheet(form: form),
          ),
        ),
      ),
    );
  }
}

// _Shimmer, _Error, _EmptyState widget'ları
```

**Kabul kriteri:**
- `flutter analyze` temiz
- Widget başka yerden kullanılabilir

**Commit:** `feat(forms): AssignmentFormSection reusable widget`

---

### T8 — Cihaz detay sayfası güncelleme

**Dosya:** `device_detail_screen.dart`

**Detaylar:**
- Envanter ADIM 3'te belirlenen yere (Lokasyon section'ından sonra, ~satır 164) yeni section ekle
- Eğer cihaz zimmetliyse (aktif assignment var): **aktif** zimmetin formunu göster
- Değilse: son tamamlanan assignment'ın son formunu göster
- Basit yaklaşım: `_SectionCard(title: 'Son Zimmet/İade Formu', child: AssignmentFormSection(assignmentId: ...))`

**Dikkat:** `device.assignedTo` var ama `assignmentId` alanı var mı? Eğer yoksa, bu T8 scope dışı ve SPEC_BACKEND_002'de device detail response'a eklemek gerekir. Claude Code envantere bakıp karar versin — yoksa bu adımı atla ve rapor et.

**Kabul kriteri:**
- `flutter analyze` temiz
- Cihaz detay açıldığında formlar görünüyor (eğer varsa)

**Commit:** `feat(devices): cihaz detay sayfasında son zimmet/iade formu`

---

### T9 — AssignDeviceScreen otomatik form üretim

**Dosya:** `assign_device_screen.dart`

**Detaylar:**
Envanter ADIM 6: Mevcut `_assign()` success sonrası `notifyAssignmentCreated` çağrılıyor (satır 145). Aynı yere form üretim + dialog ekle:

```dart
// Mevcut notifyAssignmentCreated sonrası:
if (!mounted) return;

// Otomatik zimmet formu üret
final generateForm = await showDialog<bool>(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Zimmet Formu'),
    content: const Text('Zimmet formu oluşturulup indirilsin mi?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Sonra')),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet, Üret')),
    ],
  ),
);

if (generateForm == true && mounted) {
  final form = await ref.read(assignmentFormProvider(newAssignmentId).notifier)
    .generateAssignmentForm();
  if (!mounted) return;
  await showModalBottomSheet(
    context: context,
    builder: (_) => FormActionSheet(form: form),
  );
}
```

**Dikkat:** `newAssignmentId` assign servisinden dönüyor mu? Envanterde `assign(Map data)` metodunun response'u belirtilmemiş. Eğer dönmüyorsa SPEC_BACKEND_002'de `AssignmentResponse` zaten ID içeriyor, response'u kullan.

**Kabul kriteri:**
- `flutter analyze` temiz
- Manuel test: Yeni zimmet → başarılı → form üret dialog → evet → form action sheet açılır

**Commit:** `feat(assignments): atama sonrası otomatik zimmet formu önerisi`

---

### T10 — Son doğrulama ve temizlik

**Detaylar:**
1. `flutter analyze` → 0 hata/uyarı
2. `dart run custom_lint` → 0 issue
3. `dart format lib/features/assignments/ lib/features/devices/screens/`
4. **Manuel test akışı (emulator):**
   - **Zimmet atama:** Yeni zimmet → form üret dialog → evet → form indirilir → **"Paylaş"** → WhatsApp'a gönder → ✓
   - **İade:** Mevcut zimmet → İade Et → yeni ekran → dropdown: Hasarlı → not: "ekran çatladı" → iade → form üret dialog → evet → form indirilir → "İmzalı Yükle" → dosya seç → upload ✓
   - **Retire iade:** İade ekranı → retire switch aç → "Emekli Et ve İade" → onay → ✓
   - **Cihaz detay:** Cihaza gir → Son Zimmet/İade Formu section görünür → dokun → action sheet
5. Git log:
   ```bash
   git log --oneline | Select-Object -First 12
   ```

**Commit:** (değişiklik varsa) `refactor: format + cleanup`

---

## Kapsam Dışı

- **Form geçmişi listesi** — sadece en son form gösteriliyor
- **Form silme / yeniden üretme** — bir kere üretildi, kalıcı
- **Retire stat ekranı** — backend endpoint var ama UI ayrı SPEC
- **Bildirim merkezine form linki eklemek** — mevcut bildirim yeterli
- **Çoklu dosya upload** — bir seferde 1 imzalı dosya
- **Kamera ile imza alma** — çıkarıldı (senin kararın Excel+ıslak)

---

## Notlar (Claude Code için)

- **Her görev sonrası:** `flutter analyze` + commit
- **pubspec.yaml, main.dart, api_client.dart, token_manager.dart, auth_*.dart** → `.claude/settings.json`'da `ask` listesinde, önce sorar
- **Backend hazır olmadan test etme** — SPEC_BACKEND_002 bitmiş olmalı
- **Yeni package** `share_plus` — `flutter pub get` gerekir (ask listesinde)
- **Yeni feature EKLEMEK YOK** — sadece SPEC'te liste
- **Form üretimi opsiyonel** — dialog ile kullanıcıya sor, zorunlu değil
- **Hot restart** — provider family kullandığımız için hot reload yerine restart tercih et
- **Manuel testler** emulator'de, flutter run çalışır durumda olmalı
- **Plan mode** başlat her T1, T2, T4 gibi kritik görevler için

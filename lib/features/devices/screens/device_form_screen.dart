import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_input.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';
import 'package:assetflow_mobile/features/assignments/widgets/step_indicator.dart';

final _locationsProvider = FutureProvider.autoDispose<List<Location>>((ref) async {
  final result = await LocationService().getAll(page: 1, pageSize: 100);
  return result.items;
});

class DeviceFormScreen extends ConsumerStatefulWidget {
  final Device? device;
  const DeviceFormScreen({super.key, this.device});

  bool get isEditing => device != null;

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
  static const _steps = ['Temel', 'Donanım', 'Alım', 'Lokasyon'];

  static const Map<int, Set<String>> _hardwareFieldsByType = {
    0: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'},
    1: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'},
    2: {},
    3: {'hostname', 'mac', 'ip'},
    4: {'cpu', 'ram', 'storage', 'os', 'mac', 'ip'},
    5: {'cpu', 'ram', 'storage', 'os', 'mac', 'ip'},
    6: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'},
    7: {'hostname', 'os', 'mac', 'ip'},
    8: {'cpu', 'ram', 'storage', 'gpu', 'hostname', 'os', 'mac', 'ip', 'bios', 'motherboard'},
  };

  static const _ramOptions = ['2 GB', '4 GB', '8 GB', '16 GB', '32 GB', '64 GB', '128 GB'];
  static const _storageOptions = [
    '128 GB SSD', '256 GB SSD', '512 GB SSD', '1 TB SSD', '2 TB SSD',
    '500 GB HDD', '1 TB HDD', '2 TB HDD',
  ];
  static const _osOptions = [
    'Windows 10', 'Windows 11', 'macOS', 'Ubuntu', 'Debian', 'CentOS',
    'Rocky Linux', 'Android', 'iOS', 'Diğer',
  ];
  static const _warrantyOptions = [
    (3, '3 Ay'), (6, '6 Ay'), (12, '1 Yıl'), (24, '2 Yıl'),
    (36, '3 Yıl'), (48, '4 Yıl'), (60, '5 Yıl'),
  ];

  int _step = 0;
  bool _isSaving = false;

  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _assetCodeCtrl = TextEditingController();
  final _cpuCtrl = TextEditingController();
  final _ramCtrl = TextEditingController();
  final _storageCtrl = TextEditingController();
  final _gpuCtrl = TextEditingController();
  final _hostNameCtrl = TextEditingController();
  final _osCtrl = TextEditingController();
  final _macCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _biosCtrl = TextEditingController();
  final _motherboardCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _invoiceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int _selectedType = 0;
  int _selectedStatus = 0;
  int? _selectedWarrantyMonths;
  DateTime? _purchaseDate;
  double? _purchasePrice;
  String? _selectedLocationId;

  final _step0Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final d = widget.device;
    if (d != null) {
      _nameCtrl.text = d.name;
      _brandCtrl.text = d.brand ?? '';
      _modelCtrl.text = d.model ?? '';
      _serialCtrl.text = d.serialNumber ?? '';
      _assetCodeCtrl.text = d.assetCode ?? '';
      _cpuCtrl.text = d.cpuInfo ?? '';
      _ramCtrl.text = d.ramInfo ?? '';
      _storageCtrl.text = d.storageInfo ?? '';
      _gpuCtrl.text = d.gpuInfo ?? '';
      _hostNameCtrl.text = d.hostName ?? '';
      _osCtrl.text = d.osInfo ?? '';
      _macCtrl.text = d.macAddress ?? '';
      _ipCtrl.text = d.ipAddress ?? '';
      _biosCtrl.text = d.biosVersion ?? '';
      _motherboardCtrl.text = d.motherboardInfo ?? '';
      _supplierCtrl.text = d.supplier ?? '';
      _notesCtrl.text = d.notes ?? '';
      _selectedType = d.type;
      _selectedStatus = d.status;
      _selectedWarrantyMonths = d.warrantyDurationMonths;
      _purchaseDate = d.purchaseDate;
      _purchasePrice = d.purchasePrice;
      _selectedLocationId = d.locationId;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _brandCtrl, _modelCtrl, _serialCtrl, _assetCodeCtrl,
      _cpuCtrl, _ramCtrl, _storageCtrl, _gpuCtrl, _hostNameCtrl, _osCtrl,
      _macCtrl, _ipCtrl, _biosCtrl, _motherboardCtrl, _supplierCtrl,
      _invoiceCtrl, _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _showField(String key) =>
      (_hardwareFieldsByType[_selectedType] ?? {}).contains(key);

  void _next() {
    if (_step == 0 && !(_step0Key.currentState?.validate() ?? false)) return;
    if (_step == 2 && !(_step2Key.currentState?.validate() ?? false)) return;
    if (_step < 3) setState(() => _step++);
    else _save();
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
    else Navigator.pop(context);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'type': _selectedType,
        'status': _selectedStatus,
        if (_brandCtrl.text.trim().isNotEmpty) 'brand': _brandCtrl.text.trim(),
        if (_modelCtrl.text.trim().isNotEmpty) 'model': _modelCtrl.text.trim(),
        if (_serialCtrl.text.trim().isNotEmpty) 'serialNumber': _serialCtrl.text.trim(),
        if (_assetCodeCtrl.text.trim().isNotEmpty) 'assetCode': _assetCodeCtrl.text.trim(),
        if (_showField('cpu') && _cpuCtrl.text.trim().isNotEmpty) 'cpuInfo': _cpuCtrl.text.trim(),
        if (_showField('ram') && _ramCtrl.text.trim().isNotEmpty) 'ramInfo': _ramCtrl.text.trim(),
        if (_showField('storage') && _storageCtrl.text.trim().isNotEmpty) 'storageInfo': _storageCtrl.text.trim(),
        if (_showField('gpu') && _gpuCtrl.text.trim().isNotEmpty) 'gpuInfo': _gpuCtrl.text.trim(),
        if (_showField('hostname') && _hostNameCtrl.text.trim().isNotEmpty) 'hostName': _hostNameCtrl.text.trim(),
        if (_showField('os') && _osCtrl.text.trim().isNotEmpty) 'osInfo': _osCtrl.text.trim(),
        if (_showField('mac') && _macCtrl.text.trim().isNotEmpty) 'macAddress': _macCtrl.text.trim(),
        if (_showField('ip') && _ipCtrl.text.trim().isNotEmpty) 'ipAddress': _ipCtrl.text.trim(),
        if (_showField('bios') && _biosCtrl.text.trim().isNotEmpty) 'biosVersion': _biosCtrl.text.trim(),
        if (_showField('motherboard') && _motherboardCtrl.text.trim().isNotEmpty) 'motherboardInfo': _motherboardCtrl.text.trim(),
        if (_purchaseDate != null) 'purchaseDate': _purchaseDate!.toIso8601String(),
        if (_purchasePrice != null) 'purchasePrice': _purchasePrice,
        if (_supplierCtrl.text.trim().isNotEmpty) 'supplier': _supplierCtrl.text.trim(),
        if (_selectedWarrantyMonths != null) 'warrantyDurationMonths': _selectedWarrantyMonths,
        if (_selectedLocationId != null) 'locationId': _selectedLocationId,
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      };

      final service = DeviceService();
      if (widget.isEditing) {
        await service.update(widget.device!.id, data);
      } else {
        await service.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Cihaz güncellendi.' : 'Cihaz eklendi.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          _Header(
            isEditing: widget.isEditing,
            onBack: _back,
            step: _step,
          ),
          StepIndicator(steps: _steps, currentStep: _step),
          const Divider(height: 1, color: AppColors.surfaceDivider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100,
              ),
              child: _buildCurrentStep(),
            ),
          ),
          _BottomBar(
            step: _step,
            totalSteps: _steps.length,
            isSaving: _isSaving,
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _buildTemelStep(),
      1 => _buildHardwareStep(),
      2 => _buildAlimStep(),
      _ => _buildLokasyonStep(),
    };
  }


  Widget _buildTemelStep() {
    return Form(
      key: _step0Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepLabel('TEMEL BİLGİLER'),
          const SizedBox(height: 16),
          _DropdownField(
            label: 'CİHAZ TİPİ',
            value: _selectedType,
            items: DeviceTypeLabels.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v ?? 0),
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'CIHAZ ADI',
            hint: 'Örn: ThinkPad T14 Gen 3',
            controller: _nameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Cihaz adı zorunludur' : null,
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'MARKA',
            hint: 'Örn: Lenovo, Dell, HP',
            controller: _brandCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'MODEL',
            hint: 'Örn: T14 Gen 3',
            controller: _modelCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'SERİ NO',
            hint: 'Cihaz seri numarası',
            controller: _serialCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'DEMİRBAŞ KODU',
            hint: 'Örn: AST-2024-001',
            controller: _assetCodeCtrl,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareStep() {
    final allowed = _hardwareFieldsByType[_selectedType] ?? {};

    if (allowed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.memory_outlined,
                  size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text(
                'Bu cihaz tipi için\ndonanım bilgisi gerekmez',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepLabel('DONANIM BİLGİLERİ'),
        const SizedBox(height: 16),
        if (_showField('cpu')) ...[
          AppInput(label: 'İŞLEMCİ', hint: 'Örn: Intel Core i7-1260P', controller: _cpuCtrl),
          const SizedBox(height: 14),
        ],
        if (_showField('ram')) ...[
          _DropdownField(
            label: 'RAM',
            value: _ramOptions.contains(_ramCtrl.text) ? _ramCtrl.text : null,
            items: [
              const DropdownMenuItem(value: null, child: Text('Seçiniz')),
              ..._ramOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))),
            ],
            onChanged: (v) => setState(() => _ramCtrl.text = v ?? ''),
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('storage')) ...[
          _DropdownField(
            label: 'DEPOLAMA',
            value: _storageOptions.contains(_storageCtrl.text) ? _storageCtrl.text : null,
            items: [
              const DropdownMenuItem(value: null, child: Text('Seçiniz')),
              ..._storageOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))),
            ],
            onChanged: (v) => setState(() => _storageCtrl.text = v ?? ''),
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('gpu')) ...[
          AppInput(label: 'EKRAN KARTI', hint: 'Örn: NVIDIA RTX 3060', controller: _gpuCtrl),
          const SizedBox(height: 14),
        ],
        if (_showField('hostname')) ...[
          AppInput(
            label: 'HOSTNAME',
            hint: 'Örn: DESKTOP-ABC123',
            controller: _hostNameCtrl,
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('os')) ...[
          _DropdownField(
            label: 'İŞLETİM SİSTEMİ',
            value: _osOptions.contains(_osCtrl.text) ? _osCtrl.text : null,
            items: [
              const DropdownMenuItem(value: null, child: Text('Seçiniz')),
              ..._osOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))),
            ],
            onChanged: (v) => setState(() => _osCtrl.text = v ?? ''),
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('mac')) ...[
          AppInput(
            label: 'MAC ADRESİ',
            hint: 'AA:BB:CC:DD:EE:FF',
            controller: _macCtrl,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
                      .hasMatch(v.trim())
                  ? null
                  : 'Geçerli bir MAC adresi giriniz';
            },
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('ip')) ...[
          AppInput(
            label: 'IP ADRESİ',
            hint: '192.168.1.100',
            controller: _ipCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
        ],
        if (_showField('bios')) ...[
          AppInput(label: 'BIOS VERSİYONU', hint: 'Örn: F.30', controller: _biosCtrl),
          const SizedBox(height: 14),
        ],
        if (_showField('motherboard')) ...[
          AppInput(label: 'ANAKART', hint: 'Anakart modeli', controller: _motherboardCtrl),
        ],
      ],
    );
  }

  Widget _buildAlimStep() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepLabel('SATIN ALMA & GARANTİ'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: AppInput(
                label: 'SATIN ALMA TARİHİ',
                hint: 'Tarih seçin',
                readOnly: true,
                controller: TextEditingController(
                  text: _purchaseDate != null
                      ? dateFormat.format(_purchaseDate!)
                      : '',
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'SATIN ALMA FİYATI (₺)',
            hint: 'Örn: 15000',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(
              text: _purchasePrice != null
                  ? _purchasePrice.toString()
                  : '',
            ),
            onChanged: (v) => _purchasePrice = double.tryParse(v.replaceAll(',', '.')),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              return double.tryParse(v.trim().replaceAll(',', '.')) == null
                  ? 'Geçerli bir fiyat giriniz'
                  : null;
            },
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'TEDARİKÇİ',
            hint: 'Tedarikçi firma adı',
            controller: _supplierCtrl,
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'FATURA NO',
            hint: 'Fatura numarası',
            controller: _invoiceCtrl,
          ),
          const SizedBox(height: 14),
          _DropdownField(
            label: 'GARANTİ SÜRESİ',
            value: _selectedWarrantyMonths,
            items: [
              const DropdownMenuItem(value: null, child: Text('Garanti yok')),
              ..._warrantyOptions.map((o) =>
                  DropdownMenuItem(value: o.$1, child: Text(o.$2))),
            ],
            onChanged: (v) => setState(() => _selectedWarrantyMonths = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasyonStep() {
    final locAsync = ref.watch(_locationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepLabel('LOKASYON & DURUM'),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'DURUM',
          value: _selectedStatus,
          items: DeviceStatusLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _selectedStatus = v ?? 0),
        ),
        const SizedBox(height: 14),
        locAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.navy, strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Text(
            'Lokasyonlar yüklenemedi.',
            style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary,
            ),
          ),
          data: (locations) => _DropdownField<String>(
            label: 'LOKASYON',
            value: _selectedLocationId,
            items: [
              const DropdownMenuItem(value: null, child: Text('Seçiniz')),
              ...locations.map((l) => DropdownMenuItem(
                    value: l.id,
                    child: Text(l.name),
                  )),
            ],
            onChanged: (v) => setState(() => _selectedLocationId = v),
          ),
        ),
        const SizedBox(height: 14),
        AppInput(
          label: 'NOTLAR',
          hint: 'İsteğe bağlı not ekleyin',
          controller: _notesCtrl,
          maxLines: 4,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }
}

class _Header extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onBack;
  final int step;
  const _Header({
    required this.isEditing,
    required this.onBack,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 18,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'Cihazı Düzenle' : 'Yeni Cihaz',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == totalSteps - 1;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(top: BorderSide(color: AppColors.surfaceDivider)),
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              child: _Btn(
                label: 'Geri',
                secondary: true,
                onTap: onBack,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: _Btn(
              label: isLast ? 'Kaydet' : 'İleri',
              success: isLast,
              isLoading: isSaving,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool secondary;
  final bool success;
  final bool isLoading;
  final VoidCallback onTap;
  const _Btn({
    required this.label,
    this.secondary = false,
    this.success = false,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = success
        ? AppColors.success
        : secondary
            ? AppColors.surfaceWhite
            : AppColors.navy;
    final fg = secondary ? AppColors.navy : Colors.white;
    final border = secondary ? AppColors.surfaceInputBorder : Colors.transparent;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String text;
  const _StepLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.navy, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          dropdownColor: AppColors.surfaceWhite,
          isExpanded: true,
        ),
      ],
    );
  }
}

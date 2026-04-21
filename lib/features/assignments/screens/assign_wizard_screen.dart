import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_input.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';
import 'package:assetflow_mobile/features/assignments/widgets/device_pick_row.dart';
import 'package:assetflow_mobile/features/assignments/widgets/person_pick_row.dart';
import 'package:assetflow_mobile/features/assignments/widgets/signature_pad.dart';
import 'package:assetflow_mobile/features/assignments/widgets/step_indicator.dart';

final _employeesProvider = FutureProvider.autoDispose<List<Employee>>((ref) async {
  final result = await EmployeeService().getAll(page: 1, pageSize: 200);
  return result.items.where((e) => e.isActive).toList();
});

final _availableDevicesProvider = FutureProvider.autoDispose<List<Device>>((ref) async {
  final result = await DeviceService().getAll(page: 1, pageSize: 200);
  return result.items.where((d) => d.status == 1).toList();
});

class AssignWizardScreen extends ConsumerStatefulWidget {
  final String? preselectedDeviceId;
  const AssignWizardScreen({super.key, this.preselectedDeviceId});

  @override
  ConsumerState<AssignWizardScreen> createState() => _AssignWizardScreenState();
}

class _AssignWizardScreenState extends ConsumerState<AssignWizardScreen> {
  static const _steps = ['Kişi', 'Cihaz', 'Şartlar', 'Özet'];

  int _step = 0;
  bool _isSaving = false;
  bool _signed = false;

  Employee? _selectedEmployee;
  Device? _selectedDevice;

  String _personSearch = '';
  String _deviceSearch = '';
  final _personSearchCtrl = TextEditingController();
  final _deviceSearchCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  int? _durationDays;
  bool _personalUse = false;
  bool _international = false;

  static const _durationOptions = [
    (7, '1 Hafta'),
    (14, '2 Hafta'),
    (30, '1 Ay'),
    (90, '3 Ay'),
    (180, '6 Ay'),
    (365, '1 Yıl'),
  ];

  @override
  void dispose() {
    _personSearchCtrl.dispose();
    _deviceSearchCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _selectedEmployee == null) {
      _showSnack('Lütfen bir kişi seçin.');
      return;
    }
    if (_step == 1 && _selectedDevice == null) {
      _showSnack('Lütfen bir cihaz seçin.');
      return;
    }
    if (_step == 3) {
      if (!_signed) {
        _showSnack('Lütfen zimmet belgesini imzalayın.');
        return;
      }
      _save();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        'deviceId': _selectedDevice!.id,
        'employeeId': _selectedEmployee!.id,
        'type': 0,
        'assignedAt': _startDate.toIso8601String(),
        if (_durationDays != null)
          'expectedReturnDate': _startDate
              .add(Duration(days: _durationDays!))
              .toIso8601String(),
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      };
      await AssignmentService().assign(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zimmet başarıyla oluşturuldu.'),
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
          _buildHeader(),
          StepIndicator(steps: _steps, currentStep: _step),
          const Divider(height: 1, color: AppColors.surfaceDivider),
          Expanded(child: _buildCurrentStep()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            onTap: _back,
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
          Text(
            'Yeni Zimmet',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _buildPersonStep(),
      1 => _buildDeviceStep(),
      2 => _buildTermsStep(),
      _ => _buildSummaryStep(),
    };
  }

  Widget _buildPersonStep() {
    final employeesAsync = ref.watch(_employeesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
          ),
          child: AppInput(
            hint: 'İsim, departman veya ünvan ara…',
            controller: _personSearchCtrl,
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
            onChanged: (v) => setState(() => _personSearch = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: employeesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
            ),
            error: (_, __) => Center(
              child: Text('Personel yüklenemedi.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            ),
            data: (employees) {
              final filtered = employees.where((e) {
                if (_personSearch.isEmpty) return true;
                return e.fullName.toLowerCase().contains(_personSearch) ||
                    (e.department ?? '').toLowerCase().contains(_personSearch) ||
                    (e.title ?? '').toLowerCase().contains(_personSearch);
              }).toList();

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => PersonPickRow(
                  employee: filtered[i],
                  selected: _selectedEmployee?.id == filtered[i].id,
                  onTap: () => setState(() => _selectedEmployee = filtered[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceStep() {
    final devicesAsync = ref.watch(_availableDevicesProvider);
    return Column(
      children: [
        if (_selectedEmployee != null)
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.info),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.navy),
                const SizedBox(width: 8),
                Text(
                  _selectedEmployee!.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
          ),
          child: AppInput(
            hint: 'Cihaz adı veya kod ara…',
            controller: _deviceSearchCtrl,
            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
            onChanged: (v) => setState(() => _deviceSearch = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: devicesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
            ),
            error: (_, __) => Center(
              child: Text('Cihazlar yüklenemedi.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            ),
            data: (devices) {
              final filtered = devices.where((d) {
                if (_deviceSearch.isEmpty) return true;
                return d.name.toLowerCase().contains(_deviceSearch) ||
                    (d.assetCode ?? '').toLowerCase().contains(_deviceSearch);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'Depoda bekleyen cihaz bulunamadı.',
                    style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => DevicePickRow(
                  device: filtered[i],
                  selected: _selectedDevice?.id == filtered[i].id,
                  onTap: () => setState(() => _selectedDevice = filtered[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepLabel('ZIMMET KOŞULLARI'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickStartDate,
            child: AbsorbPointer(
              child: AppInput(
                label: 'BAŞLANGIÇ TARİHİ',
                readOnly: true,
                controller: TextEditingController(
                  text: dateFormat.format(_startDate),
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DropdownField<int?>(
            label: 'ZIMMET SÜRESİ',
            value: _durationDays,
            items: [
              const DropdownMenuItem(value: null, child: Text('Süresiz')),
              ..._durationOptions.map((o) =>
                  DropdownMenuItem(value: o.$1, child: Text(o.$2))),
            ],
            onChanged: (v) => setState(() => _durationDays = v),
          ),
          const SizedBox(height: 16),
          _CheckRow(
            label: 'Kişisel kullanım',
            caption: 'Cihaz mesai dışında da kullanılabilir',
            value: _personalUse,
            onChanged: (v) => setState(() => _personalUse = v ?? false),
          ),
          const SizedBox(height: 8),
          _CheckRow(
            label: 'Yurt dışı kullanım',
            caption: 'Cihaz yurt dışına çıkarılabilir',
            value: _international,
            onChanged: (v) => setState(() => _international = v ?? false),
          ),
          const SizedBox(height: 14),
          AppInput(
            label: 'NOTLAR',
            hint: 'İsteğe bağlı not ekleyin',
            controller: _notesCtrl,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepLabel('ZIMMET ÖZETİ'),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Personel',
            rows: [
              _SummaryRow('Ad Soyad', _selectedEmployee?.fullName ?? '—'),
              _SummaryRow('Ünvan', _selectedEmployee?.title ?? '—'),
              _SummaryRow('Departman', _selectedEmployee?.department ?? '—'),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            title: 'Cihaz',
            rows: [
              _SummaryRow('Ad', _selectedDevice?.name ?? '—'),
              _SummaryRow('Demirbaş', _selectedDevice?.assetCode ?? '—'),
              _SummaryRow('Marka/Model',
                  [_selectedDevice?.brand, _selectedDevice?.model]
                      .whereType<String>()
                      .join(' ')),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            title: 'Koşullar',
            rows: [
              _SummaryRow('Başlangıç', dateFormat.format(_startDate)),
              _SummaryRow(
                'Süre',
                _durationDays == null
                    ? 'Süresiz'
                    : _durationOptions
                            .firstWhere(
                              (o) => o.$1 == _durationDays,
                              orElse: () => (_durationDays!, '$_durationDays gün'),
                            )
                            .$2,
              ),
              _SummaryRow(
                'Kişisel Kullanım',
                _personalUse ? 'Evet' : 'Hayır',
              ),
              _SummaryRow(
                'Yurt Dışı',
                _international ? 'Evet' : 'Hayır',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StepLabel('DİJİTAL İMZA'),
          const SizedBox(height: 8),
          SignaturePad(
            signed: _signed,
            onTap: () => setState(() => _signed = true),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Widget _buildBottomBar() {
    final isLast = _step == _steps.length - 1;

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
          if (_step > 0) ...[
            Expanded(
              child: _Btn(label: 'Geri', secondary: true, onTap: _back),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: _Btn(
              label: isLast ? 'Onayla ve Gönder' : 'İleri',
              success: isLast,
              isLoading: _isSaving,
              onTap: _next,
            ),
          ),
        ],
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<_SummaryRow> rows;
  const _SummaryCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Container(
              decoration: isLast
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.surfaceDivider),
                      ),
                    ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.value.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      e.value.value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
}

class _CheckRow extends StatelessWidget {
  final String label;
  final String caption;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckRow({
    required this.label,
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? AppColors.infoBg : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: value ? AppColors.navy : AppColors.surfaceDivider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    caption,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.navy,
              side: const BorderSide(color: AppColors.surfaceInputBorder),
            ),
          ],
        ),
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
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
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

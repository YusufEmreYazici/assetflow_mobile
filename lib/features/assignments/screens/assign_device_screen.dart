import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/core/widgets/qr_scanner_screen.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_form_provider.dart';
import 'package:assetflow_mobile/features/assignments/widgets/form_action_sheet.dart';

class AssignDeviceScreen extends ConsumerStatefulWidget {
  const AssignDeviceScreen({super.key});

  @override
  ConsumerState<AssignDeviceScreen> createState() => _AssignDeviceScreenState();
}

class _AssignDeviceScreenState extends ConsumerState<AssignDeviceScreen> {
  final _deviceService = DeviceService();
  final _employeeService = EmployeeService();
  final _assignmentService = AssignmentService();

  List<Device> _devices = [];
  List<Employee> _employees = [];
  bool _loadingData = true;
  bool _saving = false;

  String? _selectedDeviceId;
  String? _selectedEmployeeId;
  int _type = 0; // 0=Kalici, 1=Gecici
  DateTime? _expectedReturnDate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(
          title: 'Cihaz Tara',
          hint: 'Seri no veya barkodu tarayın',
        ),
      ),
    );
    if (scanned == null || scanned.isEmpty) return;

    // Match against serialNumber or assetCode
    final match = _devices
        .where(
          (d) =>
              (d.serialNumber?.toLowerCase() == scanned.toLowerCase()) ||
              (d.assetCode?.toLowerCase() == scanned.toLowerCase()),
        )
        .firstOrNull;

    if (match != null) {
      setState(() => _selectedDeviceId = match.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cihaz bulundu: ${match.name}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eşleşen cihaz bulunamadı: $scanned'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadFormData() async {
    try {
      final devResult = await _deviceService.getAll(page: 1, pageSize: 100);
      final empResult = await _employeeService.getAll(page: 1, pageSize: 100);
      setState(() {
        // Only show InStorage (status=1) devices
        _devices = devResult.items.where((d) => d.status == 1).toList();
        _employees = empResult.items;
        _loadingData = false;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veriler yuklenemedi'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _loadingData = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary600,
              surface: AppColors.dark800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _expectedReturnDate = picked);
  }

  Future<void> _assign() async {
    if (_selectedDeviceId == null || _selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cihaz ve personel secimi zorunludur'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final newAssignment = await _assignmentService.assign({
        'deviceId': _selectedDeviceId,
        'employeeId': _selectedEmployeeId,
        'type': _type,
        'expectedReturnDate': _expectedReturnDate?.toIso8601String(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      // Send notification
      final selectedDevice = _devices.firstWhere(
        (d) => d.id == _selectedDeviceId,
      );
      final selectedEmployee = _employees.firstWhere(
        (e) => e.id == _selectedEmployeeId,
      );
      await NotificationService.instance.notifyAssignmentCreated(
        employeeName: selectedEmployee.fullName,
        deviceName: selectedDevice.name,
        department: selectedEmployee.department,
      );

      if (!mounted) return;

      // Zimmet formu üret dialog
      final generateForm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Zimmet Formu'),
          content: const Text('Zimmet formu oluşturulup indirilsin mi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Sonra'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet, Üret'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cihaz zimmetlendi'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);

      if (generateForm == true && mounted) {
        final form = await ref
            .read(assignmentFormProvider(newAssignment.id).notifier)
            .generateAssignmentForm();
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => FormActionSheet(form: form),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zimmet islemi basarisiz'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Zimmet')),
      body: _loadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device dropdown + QR scan
                  Row(
                    children: [
                      const Text(
                        'Cihaz *',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _scanQr,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary600.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primary600.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                size: 14,
                                color: AppColors.primary400,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'QR Tara',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDeviceId,
                    hint: const Text('Cihaz secin...'),
                    dropdownColor: AppColors.dark800,
                    isExpanded: true,
                    items: _devices.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(
                          '${d.name} (${d.brand ?? ''} ${d.model ?? ''})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedDeviceId = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.computer, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  if (_devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Depoda cihaz yok',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Employee dropdown
                  const Text(
                    'Personel *',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedEmployeeId,
                    hint: const Text('Personel secin...'),
                    dropdownColor: AppColors.dark800,
                    isExpanded: true,
                    items: _employees.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(
                          '${e.fullName}${e.registrationNumber != null ? ' (${e.registrationNumber})' : ''} ${e.department != null ? '— ${e.department}' : ''}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedEmployeeId = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type + Expected return date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Zimmet Tipi',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: _type,
                              dropdownColor: AppColors.dark800,
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Kalici'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Gecici'),
                                ),
                              ],
                              onChanged: (v) => setState(() {
                                _type = v ?? 0;
                                if (_type == 0) _expectedReturnDate = null;
                              }),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_type == 1) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Iade Tarihi',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _expectedReturnDate != null
                                        ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_expectedReturnDate!)
                                        : 'Tarih sec',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _expectedReturnDate != null
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  const Text(
                    'Notlar',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Zimmet notu (istege bagli)',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Zimmetle',
                    onPressed: _assign,
                    isLoading: _saving,
                    isFullWidth: true,
                    icon: Icons.assignment_turned_in,
                  ),
                ],
              ),
            ),
    );
  }
}

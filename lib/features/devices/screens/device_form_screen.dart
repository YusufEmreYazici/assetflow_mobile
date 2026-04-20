import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/core/widgets/loading_overlay.dart';
import 'package:assetflow_mobile/data/models/device_model.dart'
    show Device, DeviceTypeLabels, DeviceStatusLabels;
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';

class DeviceFormScreen extends ConsumerStatefulWidget {
  final Device? device;

  const DeviceFormScreen({super.key, this.device});

  bool get isEditing => device != null;

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary600),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
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

  static const _temelDonanimFields = {'cpu', 'ram', 'storage', 'gpu'};
  static const _sistemFields = {'hostname', 'os'};
  static const _agFields = {'mac', 'ip'};
  static const _teknikFields = {'bios', 'motherboard'};

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _assetCodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _supplierController = TextEditingController();
  final _warrantyMonthsController = TextEditingController();
  final _notesController = TextEditingController();
  final _cpuController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _gpuController = TextEditingController();
  final _hostNameController = TextEditingController();
  final _osController = TextEditingController();
  final _macController = TextEditingController();
  final _ipController = TextEditingController();
  final _biosController = TextEditingController();
  final _motherboardController = TextEditingController();

  int _selectedType = 0;
  int _selectedStatus = 0;
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.device != null) {
      final d = widget.device!;
      _nameController.text = d.name;
      _brandController.text = d.brand ?? '';
      _modelController.text = d.model ?? '';
      _serialController.text = d.serialNumber ?? '';
      _assetCodeController.text = d.assetCode ?? '';
      _priceController.text = d.purchasePrice?.toString() ?? '';
      _supplierController.text = d.supplier ?? '';
      _warrantyMonthsController.text =
          d.warrantyDurationMonths?.toString() ?? '';
      _notesController.text = d.notes ?? '';
      _selectedType = d.type;
      _selectedStatus = d.status;
      _purchaseDate = d.purchaseDate;
      _cpuController.text = d.cpuInfo ?? '';
      _ramController.text = d.ramInfo ?? '';
      _storageController.text = d.storageInfo ?? '';
      _gpuController.text = d.gpuInfo ?? '';
      _hostNameController.text = d.hostName ?? '';
      _osController.text = d.osInfo ?? '';
      _macController.text = d.macAddress ?? '';
      _ipController.text = d.ipAddress ?? '';
      _biosController.text = d.biosVersion ?? '';
      _motherboardController.text = d.motherboardInfo ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _assetCodeController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _warrantyMonthsController.dispose();
    _notesController.dispose();
    _cpuController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _gpuController.dispose();
    _hostNameController.dispose();
    _osController.dispose();
    _macController.dispose();
    _ipController.dispose();
    _biosController.dispose();
    _motherboardController.dispose();
    super.dispose();
  }

  String? _validateMac(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return regex.hasMatch(value.trim())
        ? null
        : 'Geçerli bir MAC adresi girin (örn: AA:BB:CC:DD:EE:FF)';
  }

  String? _validateIp(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return regex.hasMatch(value.trim())
        ? null
        : 'Geçerli bir IP adresi girin (örn: 192.168.1.1)';
  }

  bool _shouldShowField(String fieldKey) {
    final allowed = _hardwareFieldsByType[_selectedType] ?? {};
    return allowed.contains(fieldKey);
  }

  bool _shouldShowSection(Set<String> sectionFields) {
    final allowed = _hardwareFieldsByType[_selectedType] ?? {};
    return sectionFields.any((f) => allowed.contains(f));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary600,
              onPrimary: Colors.white,
              surface: AppColors.dark800,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final service = DeviceService();
      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        'model': _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        'serialNumber': _serialController.text.trim().isEmpty
            ? null
            : _serialController.text.trim(),
        'assetCode': _assetCodeController.text.trim().isEmpty
            ? null
            : _assetCodeController.text.trim(),
        'type': _selectedType,
        'status': _selectedStatus,
        'purchaseDate': _purchaseDate?.toIso8601String(),
        'purchasePrice': _priceController.text.trim().isNotEmpty
            ? double.tryParse(_priceController.text.trim())
            : null,
        'supplier': _supplierController.text.trim().isEmpty
            ? null
            : _supplierController.text.trim(),
        'warrantyDurationMonths':
            _warrantyMonthsController.text.trim().isNotEmpty
            ? int.tryParse(_warrantyMonthsController.text.trim())
            : null,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'cpuInfo': _cpuController.text.trim().isEmpty
            ? null
            : _cpuController.text.trim(),
        'ramInfo': _ramController.text.trim().isEmpty
            ? null
            : _ramController.text.trim(),
        'storageInfo': _storageController.text.trim().isEmpty
            ? null
            : _storageController.text.trim(),
        'gpuInfo': _gpuController.text.trim().isEmpty
            ? null
            : _gpuController.text.trim(),
        'hostName': _hostNameController.text.trim().isEmpty
            ? null
            : _hostNameController.text.trim(),
        'osInfo': _osController.text.trim().isEmpty
            ? null
            : _osController.text.trim(),
        'macAddress': _macController.text.trim().isEmpty
            ? null
            : _macController.text.trim(),
        'ipAddress': _ipController.text.trim().isEmpty
            ? null
            : _ipController.text.trim(),
        'biosVersion': _biosController.text.trim().isEmpty
            ? null
            : _biosController.text.trim(),
        'motherboardInfo': _motherboardController.text.trim().isEmpty
            ? null
            : _motherboardController.text.trim(),
      };

      if (widget.isEditing) {
        await service.update(widget.device!.id, data);
      } else {
        await service.create(data);
      }

      // Send notification for new device
      if (!widget.isEditing) {
        await NotificationService.instance.notifyNewDevicesAdded(count: 1);
      } else if (_selectedStatus == 4) {
        // Status 4 = Retired
        await NotificationService.instance.notifyDeviceRetired(
          deviceName: _nameController.text.trim(),
        );
      } else if (_selectedStatus == 3) {
        // Status 3 = Maintenance
        await NotificationService.instance.notifyDeviceMaintenance(
          deviceName: _nameController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Cihaz basariyla guncellendi'
                  : 'Cihaz basariyla eklendi',
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
            content: Text(
              widget.isEditing
                  ? 'Cihaz guncellenirken hata olustu'
                  : 'Cihaz eklenirken hata olustu',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Cihaz Duzenle' : 'Yeni Cihaz'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Cihaz Adi *',
                  hint: 'Orn: MacBook Pro 14"',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cihaz adi zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Marka',
                  hint: 'Orn: Apple',
                  controller: _brandController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Model',
                  hint: 'Orn: A2779',
                  controller: _modelController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Seri Numarasi',
                  controller: _serialController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Demirhas Kodu',
                  controller: _assetCodeController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                // Type dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Cihaz Tipi'),
                  dropdownColor: AppColors.dark800,
                  items: DeviceTypeLabels.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                // Status dropdown (only on edit)
                if (widget.isEditing) ...[
                  DropdownButtonFormField<int>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Durum'),
                    dropdownColor: AppColors.dark800,
                    items: DeviceStatusLabels.entries
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Purchase date
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: AppTextField(
                      label: 'Satin Alma Tarihi',
                      hint: 'Tarih secin',
                      controller: TextEditingController(
                        text: _purchaseDate != null
                            ? DateFormat('dd/MM/yyyy').format(_purchaseDate!)
                            : '',
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Satin Alma Fiyati (TL)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Tedarikci',
                  controller: _supplierController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Garanti Suresi (Ay)',
                  controller: _warrantyMonthsController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Notlar',
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                if (_shouldShowSection(_temelDonanimFields)) ...[
                  const _SectionHeader(
                    title: 'TEMEL DONANIM',
                    icon: Icons.memory,
                  ),
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
                if (_shouldShowSection(_sistemFields)) ...[
                  const _SectionHeader(
                    title: 'SİSTEM BİLGİLERİ',
                    icon: Icons.computer,
                  ),
                  const SizedBox(height: 8),
                  if (_shouldShowField('hostname')) ...[
                    AppTextField(
                      label: 'Hostname',
                      hint: 'Örn: LAPTOP-ABC123',
                      controller: _hostNameController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_shouldShowField('os')) ...[
                    AppTextField(
                      label: 'İşletim Sistemi',
                      hint: 'Örn: Windows 11 Pro 23H2',
                      controller: _osController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                if (_shouldShowSection(_agFields)) ...[
                  const _SectionHeader(
                    title: 'AĞ BİLGİLERİ',
                    icon: Icons.lan,
                  ),
                  const SizedBox(height: 8),
                  if (_shouldShowField('mac')) ...[
                    AppTextField(
                      label: 'MAC Adresi',
                      hint: 'AA:BB:CC:DD:EE:FF',
                      controller: _macController,
                      textInputAction: TextInputAction.next,
                      validator: _validateMac,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_shouldShowField('ip')) ...[
                    AppTextField(
                      label: 'IP Adresi',
                      hint: '192.168.1.100',
                      controller: _ipController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: _validateIp,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                if (_shouldShowSection(_teknikFields)) ...[
                  const _SectionHeader(
                    title: 'TEKNİK DETAYLAR',
                    icon: Icons.settings_input_component,
                  ),
                  const SizedBox(height: 8),
                  if (_shouldShowField('bios')) ...[
                    AppTextField(
                      label: 'BIOS Versiyonu',
                      hint: 'Örn: 1.15.0',
                      controller: _biosController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_shouldShowField('motherboard')) ...[
                    AppTextField(
                      label: 'Anakart Bilgisi',
                      hint: 'Örn: ASUS ROG Strix B650-A',
                      controller: _motherboardController,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                const SizedBox(height: 24),
                AppButton(
                  text: widget.isEditing ? 'Guncelle' : 'Kaydet',
                  onPressed: _onSave,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

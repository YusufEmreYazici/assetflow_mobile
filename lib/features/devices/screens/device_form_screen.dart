import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/core/widgets/loading_overlay.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';

class DeviceFormScreen extends ConsumerStatefulWidget {
  final Device? device;

  const DeviceFormScreen({super.key, this.device});

  bool get isEditing => device != null;

  @override
  ConsumerState<DeviceFormScreen> createState() => _DeviceFormScreenState();
}

class _DeviceFormScreenState extends ConsumerState<DeviceFormScreen> {
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
    super.dispose();
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
      };

      if (widget.isEditing) {
        await service.update(widget.device!.id, data);
      } else {
        await service.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Cihaz basariyla guncellendi'
                : 'Cihaz basariyla eklendi'),
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
            content: Text(widget.isEditing
                ? 'Cihaz guncellenirken hata olustu'
                : 'Cihaz eklenirken hata olustu'),
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
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Cihaz Tipi',
                  ),
                  dropdownColor: AppColors.dark800,
                  items: DeviceTypeLabels.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                // Status dropdown (only on edit)
                if (widget.isEditing) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Durum',
                    ),
                    dropdownColor: AppColors.dark800,
                    items: DeviceStatusLabels.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
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
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.textTertiary, size: 20),
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
                  textInputAction: TextInputAction.done,
                ),
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

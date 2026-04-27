import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/utils/api_exception.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';
import 'package:intl/intl.dart';

class EmployeeFormScreen extends StatefulWidget {
  final String? employeeId;
  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EmployeeService();
  bool _loading = false;
  bool _loadingData = false;

  final _fullNameC = TextEditingController();
  final _regNumC = TextEditingController();
  final _emailC = TextEditingController();
  final _deptC = TextEditingController();
  final _titleC = TextEditingController();
  final _phoneC = TextEditingController();
  DateTime? _hireDate;

  bool get isEdit => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _loadEmployee();
  }

  @override
  void dispose() {
    _fullNameC.dispose();
    _regNumC.dispose();
    _emailC.dispose();
    _deptC.dispose();
    _titleC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  Future<void> _loadEmployee() async {
    setState(() => _loadingData = true);
    try {
      final emp = await _service.getById(widget.employeeId!);
      _fullNameC.text = emp.fullName;
      _regNumC.text = emp.registrationNumber ?? '';
      _emailC.text = emp.email ?? '';
      _deptC.text = emp.department ?? '';
      _titleC.text = emp.title ?? '';
      _phoneC.text = emp.phone ?? '';
      _hireDate = emp.hireDate;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personel yuklenemedi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _loadingData = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
    if (picked != null) setState(() => _hireDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'fullName': _fullNameC.text.trim(),
        'registrationNumber': _regNumC.text.trim().isEmpty
            ? null
            : _regNumC.text.trim(),
        'email': _emailC.text.trim().isEmpty ? null : _emailC.text.trim(),
        'department': _deptC.text.trim().isEmpty ? null : _deptC.text.trim(),
        'title': _titleC.text.trim().isEmpty ? null : _titleC.text.trim(),
        'phone': _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        'hireDate': _hireDate?.toIso8601String(),
      };

      if (isEdit) {
        await _service.update(widget.employeeId!, data);
      } else {
        await _service.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Personel guncellendi' : 'Personel eklendi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      final apiEx = e is DioException && e.error is ApiException
          ? e.error as ApiException
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiEx?.message ?? 'İşlem başarısız.'),
          backgroundColor: AppColors.error,
        ),
      );
      if (apiEx?.isConflict == true) {
        Navigator.pop(context, true);
        return;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Personel Duzenle' : 'Yeni Personel'),
      ),
      body: _loadingData
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Ad Soyad *',
                      controller: _fullNameC,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Sicil No',
                            controller: _regNumC,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'E-posta',
                            controller: _emailC,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Departman',
                            controller: _deptC,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Unvan',
                            controller: _titleC,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Telefon',
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ise Giris Tarihi',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                          suffixIcon: _hireDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () =>
                                      setState(() => _hireDate = null),
                                )
                              : null,
                        ),
                        child: Text(
                          _hireDate != null
                              ? DateFormat('dd/MM/yyyy').format(_hireDate!)
                              : 'Tarih secin...',
                          style: TextStyle(
                            color: _hireDate != null
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: isEdit ? 'Guncelle' : 'Ekle',
                      onPressed: _save,
                      isLoading: _loading,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';

class LocationFormScreen extends StatefulWidget {
  final String? locationId;
  const LocationFormScreen({super.key, this.locationId});

  @override
  State<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends State<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = LocationService();
  bool _loading = false;
  bool _loadingData = false;

  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _buildingC = TextEditingController();
  final _floorC = TextEditingController();
  final _roomC = TextEditingController();
  final _descC = TextEditingController();

  bool get isEdit => widget.locationId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _loadLocation();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _addressC.dispose();
    _buildingC.dispose();
    _floorC.dispose();
    _roomC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    setState(() => _loadingData = true);
    try {
      final loc = await _service.getById(widget.locationId!);
      _nameC.text = loc.name;
      _addressC.text = loc.address ?? '';
      _buildingC.text = loc.building ?? '';
      _floorC.text = loc.floor ?? '';
      _roomC.text = loc.room ?? '';
      _descC.text = loc.description ?? '';
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasyon yuklenemedi'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _loadingData = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameC.text.trim(),
        'address': _addressC.text.trim().isEmpty ? null : _addressC.text.trim(),
        'building': _buildingC.text.trim().isEmpty ? null : _buildingC.text.trim(),
        'floor': _floorC.text.trim().isEmpty ? null : _floorC.text.trim(),
        'room': _roomC.text.trim().isEmpty ? null : _roomC.text.trim(),
        'description': _descC.text.trim().isEmpty ? null : _descC.text.trim(),
      };

      if (isEdit) {
        await _service.update(widget.locationId!, data);
      } else {
        await _service.create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Lokasyon guncellendi' : 'Lokasyon eklendi'),
          backgroundColor: AppColors.success,
        ));
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Islem basarisiz'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Lokasyon Duzenle' : 'Yeni Lokasyon')),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary500))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Lokasyon Adi *',
                      controller: _nameC,
                      prefixIcon: const Icon(Icons.location_on, size: 18),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Adres',
                      controller: _addressC,
                      prefixIcon: const Icon(Icons.map, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Bina', controller: _buildingC, prefixIcon: const Icon(Icons.apartment, size: 18))),
                        const SizedBox(width: 12),
                        Expanded(child: AppTextField(label: 'Kat', controller: _floorC, prefixIcon: const Icon(Icons.layers, size: 18))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Oda',
                      controller: _roomC,
                      prefixIcon: const Icon(Icons.meeting_room, size: 18),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Aciklama', controller: _descC),
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

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';

/// CSV Format (ilk satır başlık):
/// name,brand,model,serialNumber,type,status,assetCode,notes
///
/// type:   0=Dizüstü 1=Masaüstü 2=Monitör 3=Yazıcı 4=Telefon 5=Tablet 6=Sunucu 7=Ağ 8=Diğer
/// status: 0=Aktif 1=Depoda 2=Bakımda 3=Emekli

class DeviceImportScreen extends StatefulWidget {
  const DeviceImportScreen({super.key});

  @override
  State<DeviceImportScreen> createState() => _DeviceImportScreenState();
}

class _DeviceImportScreenState extends State<DeviceImportScreen> {
  final _deviceService = DeviceService();

  List<_ImportRow> _rows = [];
  bool _picking = false;
  bool _importing = false;
  int _successCount = 0;
  int _errorCount = 0;

  static const _headers = [
    'name',
    'brand',
    'model',
    'serialNumber',
    'type',
    'status',
    'assetCode',
    'notes',
  ];

  Future<void> _pickFile() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      String content;
      final bytes = result.files.first.bytes;
      if (bytes != null) {
        content = String.fromCharCodes(bytes);
      } else if (result.files.first.path != null) {
        content = await File(result.files.first.path!).readAsString();
      } else {
        return;
      }

      final rows = const CsvToListConverter(eol: '\n').convert(content);
      if (rows.isEmpty) return;

      // Skip header row
      final dataRows = rows.skip(1).where((r) => r.isNotEmpty).toList();
      final parsed = dataRows.map((r) => _ImportRow.fromCsvRow(r)).toList();

      setState(() {
        _rows = parsed;
        _successCount = 0;
        _errorCount = 0;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _import() async {
    if (_rows.isEmpty) return;
    setState(() {
      _importing = true;
      _successCount = 0;
      _errorCount = 0;
    });

    for (final row in _rows) {
      if (!row.isValid) {
        setState(() {
          row.status = _RowStatus.error;
          row.errorMsg = 'Cihaz adı zorunludur';
          _errorCount++;
        });
        continue;
      }
      try {
        await _deviceService.create(row.toJson());
        setState(() {
          row.status = _RowStatus.success;
          _successCount++;
        });
      } catch (e) {
        setState(() {
          row.status = _RowStatus.error;
          row.errorMsg = e.toString().length > 60
              ? 'Sunucu hatası'
              : e.toString();
          _errorCount++;
        });
      }
    }

    setState(() => _importing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_successCount başarılı, $_errorCount hatalı'),
          backgroundColor: _errorCount == 0
              ? AppColors.success
              : AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (_errorCount == 0) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toplu Cihaz İçe Aktar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Format info card
          Container(
            decoration: BoxDecoration(
              color: AppColors.infoLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.4)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    SizedBox(width: 6),
                    Text(
                      'CSV Format',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _headers.join(','),
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'type: 0=Dizüstü 1=Masaüstü 2=Monitör 3=Yazıcı 4=Telefon 5=Tablet 6=Sunucu 7=Ağ 8=Diğer\n'
                  'status: 0=Aktif 1=Depoda 2=Bakımda 3=Emekli',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pick file button
          AppButton(
            text: _rows.isEmpty ? 'CSV Dosyası Seç' : 'Farklı Dosya Seç',
            icon: Icons.upload_file,
            onPressed: _picking ? null : _pickFile,
            isLoading: _picking,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),

          // Preview table
          if (_rows.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${_rows.length} satır yüklendi',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_successCount > 0)
                  Text(
                    '✓ $_successCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                if (_errorCount > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '✗ $_errorCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            ...(_rows.map((row) => _buildRow(row))),
            const SizedBox(height: 16),
            AppButton(
              text: _importing
                  ? 'İçe Aktarılıyor...'
                  : '${_rows.length} Cihazı İçe Aktar',
              icon: Icons.cloud_upload,
              onPressed: _importing ? null : _import,
              isLoading: _importing,
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(_ImportRow row) {
    final Color statusColor;
    final IconData statusIcon;
    switch (row.status) {
      case _RowStatus.pending:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.radio_button_unchecked;
      case _RowStatus.success:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
      case _RowStatus.error:
        statusColor = AppColors.error;
        statusIcon = Icons.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: row.status == _RowStatus.error
              ? AppColors.error.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name.isNotEmpty ? row.name : '(isim yok)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: row.name.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.error,
                  ),
                ),
                Text(
                  [
                    if (row.brand.isNotEmpty) row.brand,
                    if (row.model.isNotEmpty) row.model,
                    deviceTypeLabels[row.deviceType] ?? '',
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (row.status == _RowStatus.error && row.errorMsg != null)
                  Text(
                    row.errorMsg!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _RowStatus { pending, success, error }

class _ImportRow {
  final String name;
  final String brand;
  final String model;
  final String serialNumber;
  final int deviceType;
  final int deviceStatus;
  final String assetCode;
  final String notes;

  _RowStatus rowStatus = _RowStatus.pending;
  String? errorMsg;

  _ImportRow({
    required this.name,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.deviceType,
    required this.deviceStatus,
    required this.assetCode,
    required this.notes,
  });

  _RowStatus get status => rowStatus;
  set status(_RowStatus v) => rowStatus = v;

  bool get isValid => name.trim().isNotEmpty;

  factory _ImportRow.fromCsvRow(List<dynamic> row) {
    String col(int i) => i < row.length ? row[i].toString().trim() : '';
    int intCol(int i, int fallback) => int.tryParse(col(i)) ?? fallback;

    return _ImportRow(
      name: col(0),
      brand: col(1),
      model: col(2),
      serialNumber: col(3),
      deviceType: intCol(4, 8),
      deviceStatus: intCol(5, 1),
      assetCode: col(6),
      notes: col(7),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (brand.isNotEmpty) 'brand': brand,
    if (model.isNotEmpty) 'model': model,
    if (serialNumber.isNotEmpty) 'serialNumber': serialNumber,
    'type': deviceType,
    'status': deviceStatus,
    if (assetCode.isNotEmpty) 'assetCode': assetCode,
    if (notes.isNotEmpty) 'notes': notes,
  };
}

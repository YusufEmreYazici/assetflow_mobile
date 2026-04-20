import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/features/assignments/widgets/assignment_form_section.dart';
import 'package:assetflow_mobile/features/audit/widgets/audit_log_section.dart';
import 'package:assetflow_mobile/features/devices/screens/device_form_screen.dart';

final _deviceDetailProvider = FutureProvider.autoDispose.family<Device, String>(
  (ref, id) async {
    return DeviceService().getById(id);
  },
);

class DeviceDetailScreen extends ConsumerWidget {
  final String id;

  const DeviceDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevice = ref.watch(_deviceDetailProvider(id));

    return asyncDevice.when(
      data: (device) => _buildDetail(context, ref, device),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Yukleniyor...')),
        body: _buildShimmer(),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(_deviceDetailProvider(id)),
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, Device device) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final typeLabel = DeviceTypeLabels[device.type] ?? 'Bilinmiyor';
    final statusLabel = DeviceStatusLabels[device.status] ?? 'Bilinmiyor';
    final statusColor = _statusColor(device.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceFormScreen(device: device),
                ),
              );
              if (result == true) {
                ref.invalidate(_deviceDetailProvider(id));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, device),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Genel Bilgi
          _SectionCard(
            title: 'Genel Bilgi',
            icon: Icons.info_outline,
            rows: [
              _InfoRow('Cihaz Tipi', typeLabel),
              _InfoRow('Durum', statusLabel, valueColor: statusColor),
              if (device.serialNumber != null)
                _InfoRow('Seri Numarasi', device.serialNumber!),
              if (device.assetCode != null)
                _InfoRow('Demirhas Kodu', device.assetCode!),
              if (device.brand != null) _InfoRow('Marka', device.brand!),
              if (device.model != null) _InfoRow('Model', device.model!),
              if (device.assignedTo != null)
                _InfoRow('Zimmetli', device.assignedTo!),
            ],
          ),
          const SizedBox(height: 12),

          // Satin Alma
          if (device.purchaseDate != null ||
              device.purchasePrice != null ||
              device.supplier != null)
            _SectionCard(
              title: 'Satin Alma',
              icon: Icons.shopping_cart_outlined,
              rows: [
                if (device.purchaseDate != null)
                  _InfoRow(
                    'Satin Alma Tarihi',
                    dateFormat.format(device.purchaseDate!),
                  ),
                if (device.purchasePrice != null)
                  _InfoRow(
                    'Fiyat',
                    '${NumberFormat('#,##0.00', 'tr_TR').format(device.purchasePrice)} TL',
                  ),
                if (device.supplier != null)
                  _InfoRow('Tedarikci', device.supplier!),
              ],
            ),
          if (device.purchaseDate != null ||
              device.purchasePrice != null ||
              device.supplier != null)
            const SizedBox(height: 12),

          // Garanti
          if (device.warrantyDurationMonths != null ||
              device.warrantyEndDate != null)
            _SectionCard(
              title: 'Garanti',
              icon: Icons.shield_outlined,
              rows: [
                if (device.warrantyDurationMonths != null)
                  _InfoRow(
                    'Garanti Suresi',
                    '${device.warrantyDurationMonths} Ay',
                  ),
                if (device.warrantyEndDate != null)
                  _InfoRow(
                    'Garanti Bitis',
                    dateFormat.format(device.warrantyEndDate!),
                  ),
                if (device.warrantyStatus != null)
                  _InfoRow(
                    'Garanti Durumu',
                    _warrantyLabel(device.warrantyStatus!),
                    valueColor: _warrantyColor(device.warrantyStatus!),
                  ),
              ],
            ),
          if (device.warrantyDurationMonths != null ||
              device.warrantyEndDate != null)
            const SizedBox(height: 12),

          // Lokasyon
          if (device.locationName != null)
            _SectionCard(
              title: 'Lokasyon',
              icon: Icons.location_on_outlined,
              rows: [_InfoRow('Lokasyon', device.locationName!)],
            ),
          if (device.locationName != null) const SizedBox(height: 12),

          // Zimmet / İade Formu
          if (device.activeAssignmentId != null) ...[
            _FormSectionCard(assignmentId: device.activeAssignmentId!),
            const SizedBox(height: 12),
          ],

          // Donanim
          if (_hasHardwareInfo(device))
            _SectionCard(
              title: 'Donanim',
              icon: Icons.memory,
              rows: [
                if (device.hostName != null)
                  _InfoRow('Bilgisayar Adi', device.hostName!),
                if (device.cpuInfo != null)
                  _InfoRow('Islemci', device.cpuInfo!),
                if (device.ramInfo != null) _InfoRow('RAM', device.ramInfo!),
                if (device.storageInfo != null)
                  _InfoRow('Depolama', device.storageInfo!),
                if (device.gpuInfo != null)
                  _InfoRow('Ekran Karti', device.gpuInfo!),
                if (device.osInfo != null)
                  _InfoRow('Isletim Sistemi', device.osInfo!),
                if (device.ipAddress != null)
                  _InfoRow('IP Adresi', device.ipAddress!),
                if (device.macAddress != null)
                  _InfoRow('MAC Adresi', device.macAddress!),
              ],
            ),
          if (_hasHardwareInfo(device)) const SizedBox(height: 12),

          // Notlar
          if (device.notes != null && device.notes!.isNotEmpty)
            _SectionCard(
              title: 'Notlar',
              icon: Icons.notes,
              rows: [_InfoRow('', device.notes!)],
            ),
          if (device.notes != null && device.notes!.isNotEmpty)
            const SizedBox(height: 12),

          // Değişiklik Geçmişi
          _AuditLogSectionCard(deviceId: device.id),
        ],
      ),
    );
  }

  bool _hasHardwareInfo(Device d) {
    return d.hostName != null ||
        d.cpuInfo != null ||
        d.ramInfo != null ||
        d.storageInfo != null ||
        d.gpuInfo != null ||
        d.osInfo != null ||
        d.ipAddress != null ||
        d.macAddress != null;
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Device device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cihazi Sil'),
        content: Text(
          '"${device.name}" cihazini silmek istediginize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await DeviceService().delete(device.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cihaz basariyla silindi'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cihaz silinirken hata olustu'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return AppColors.statusActive;
      case 1:
        return AppColors.statusInStorage;
      case 2:
        return AppColors.statusMaintenance;
      case 3:
        return AppColors.statusRetired;
      default:
        return AppColors.gray500;
    }
  }

  String _warrantyLabel(int status) {
    switch (status) {
      case 0:
        return 'Garanti Yok';
      case 1:
        return 'Garantide';
      case 2:
        return 'Garanti Yaklasıyor';
      case 3:
        return 'Garanti Bitti';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _warrantyColor(int status) {
    switch (status) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  final String assignmentId;

  const _FormSectionCard({required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.description,
                  size: 18,
                  color: AppColors.primary400,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Zimmet / İade Formu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary400,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: AssignmentFormSection(assignmentId: assignmentId),
          ),
        ],
      ),
    );
  }
}

class _AuditLogSectionCard extends StatelessWidget {
  final String deviceId;

  const _AuditLogSectionCard({required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.history, size: 18, color: AppColors.primary400),
                const SizedBox(width: 8),
                const Text(
                  'Değişiklik Geçmişi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary400,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          AuditLogSection(deviceId: deviceId),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary400),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary400,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final row = entry.value;
                final isLast = entry.key == rows.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: row.label.isEmpty
                      ? Text(
                          row.value,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                row.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                row.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      row.valueColor ?? AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

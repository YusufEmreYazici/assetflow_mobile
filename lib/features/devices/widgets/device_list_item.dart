import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceListItem extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;

  const DeviceListItem({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = DeviceTypeLabels[device.type] ?? 'Bilinmiyor';
    final statusLabel = DeviceStatusLabels[device.status] ?? 'Bilinmiyor';
    final statusColor = _statusColor(device.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.dark800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _Badge(label: statusLabel, color: statusColor),
              ],
            ),
            if (device.brand != null || device.model != null) ...[
              const SizedBox(height: 4),
              Text(
                [device.brand, device.model]
                    .where((e) => e != null && e.isNotEmpty)
                    .join(' '),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _Badge(label: typeLabel, color: AppColors.primary500),
                if (device.warrantyStatus != null) ...[
                  const SizedBox(width: 8),
                  _Badge(
                    label: _warrantyLabel(device.warrantyStatus!),
                    color: _warrantyColor(device.warrantyStatus!),
                  ),
                ],
                const Spacer(),
                if (device.locationName != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        device.locationName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
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
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

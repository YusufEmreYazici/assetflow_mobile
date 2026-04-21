import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceRow extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  final bool isLast;

  const DeviceRow({super.key, required this.device, this.onTap, this.isLast = false});

  IconData get _typeIcon => switch (device.type) {
        0 => Icons.laptop_outlined,
        1 => Icons.desktop_mac_outlined,
        2 => Icons.monitor_outlined,
        3 => Icons.print_outlined,
        4 => Icons.smartphone_outlined,
        5 => Icons.tablet_outlined,
        6 => Icons.dns_outlined,
        7 => Icons.router_outlined,
        _ => Icons.devices_outlined,
      };

  ChipTone get _chipTone => switch (device.status) {
        0 => ChipTone.success,
        1 => ChipTone.info,
        2 => ChipTone.warning,
        _ => ChipTone.neutral,
      };

  String get _statusLabel => deviceStatusLabels[device.status] ?? '?';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceDivider),
                ),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_typeIcon, size: 20, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          device.name,
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AppChip(label: _statusLabel, tone: _chipTone),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${device.assetCode ?? '—'} · ${device.assignedTo ?? 'Atanmamış'}',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

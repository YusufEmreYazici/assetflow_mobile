import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/core/widgets/favorite_star.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceRow extends ConsumerWidget {
  final Device device;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isLast;
  final bool selectionMode;
  final bool isSelected;

  const DeviceRow({
    super.key,
    required this.device,
    this.onTap,
    this.onLongPress,
    this.isLast = false,
    this.selectionMode = false,
    this.isSelected = false,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null ? null : () {
        HapticService.light();
        onTap!();
      },
      onLongPress: onLongPress == null ? null : () {
        HapticService.medium();
        onLongPress!();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy.withValues(alpha: 0.07) : Colors.transparent,
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.surfaceDivider)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Left: selection checkbox OR type icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selectionMode
                  ? SizedBox(
                      key: const ValueKey('checkbox'),
                      width: 40, height: 40,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        size: 24,
                        color: isSelected ? AppColors.navy : AppColors.textTertiary,
                      ),
                    )
                  : Container(
                      key: const ValueKey('icon'),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(_typeIcon, size: 20, color: AppColors.navy),
                    ),
            ),
            const SizedBox(width: 12),
            // Content
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
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            if (!selectionMode)
              FavoriteStar(deviceId: device.id, size: 20),
            if (selectionMode)
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

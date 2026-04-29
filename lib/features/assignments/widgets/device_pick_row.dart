import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DevicePickRow extends StatelessWidget {
  final Device device;
  final bool selected;
  final VoidCallback onTap;

  const DevicePickRow({
    super.key,
    required this.device,
    required this.selected,
    required this.onTap,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoBg : AppColors.surfaceWhite,
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.surfaceDivider,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _typeIcon,
                size: 20,
                color: selected ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (device.assetCode != null || device.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        device.assetCode,
                        device.brand,
                        device.model,
                      ].whereType<String>().join(' · '),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppColors.navy)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceInputBorder),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

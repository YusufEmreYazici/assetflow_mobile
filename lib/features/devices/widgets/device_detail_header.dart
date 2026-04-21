import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceDetailHeader extends StatelessWidget {
  final Device device;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  const DeviceDetailHeader({
    super.key,
    required this.device,
    this.onBack,
    this.onEdit,
  });

  ChipTone get _tone => switch (device.status) {
        0 => ChipTone.success,
        1 => ChipTone.info,
        2 => ChipTone.warning,
        _ => ChipTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final typeLabel = deviceTypeLabels[device.type] ?? 'Cihaz';
    final statusLabel = deviceStatusLabels[device.status] ?? '?';

    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$typeLabel · ${device.assetCode ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.name,
                      style: GoogleFonts.inter(
                        fontSize: 19, fontWeight: FontWeight.w500,
                        color: Colors.white, letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppChip(label: statusLabel, tone: _tone),
                        if (device.assignedTo != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '→ ${device.assignedTo}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          // 3-strip info row
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoCell(label: 'DURUM',    value: statusLabel),
              const SizedBox(width: 8),
              _InfoCell(label: 'ZİMMETLİ', value: device.assignedTo ?? '—'),
              const SizedBox(width: 8),
              _InfoCell(label: 'LOKASYON', value: device.locationName ?? '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9, letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class MetricStrip extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final Color accent;

  const MetricStrip({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.accent = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border(top: BorderSide(color: accent, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9, fontWeight: FontWeight.w500,
                color: AppColors.textSecondary, letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary, letterSpacing: -0.4,
              ),
            ),
            if (trend != null) ...[
              const SizedBox(height: 2),
              Text(
                trend!,
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

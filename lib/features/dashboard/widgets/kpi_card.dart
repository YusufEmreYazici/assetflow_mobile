import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final Color accent;
  final Color? background;
  final IconData? icon;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.accent = AppColors.navy,
    this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? AppColors.surfaceWhite;
    final numericValue = int.tryParse(value);

    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 16, color: accent.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 8),
          if (numericValue != null)
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: numericValue),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) => Text(
                '$animValue',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              delta!,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

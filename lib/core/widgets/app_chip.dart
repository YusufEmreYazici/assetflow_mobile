import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ChipTone { success, warning, error, info, neutral }

class AppChip extends StatelessWidget {
  final String label;
  final ChipTone tone;
  final bool dot;

  const AppChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
    this.dot = true,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.success => (AppColors.successBg, AppColors.success),
      ChipTone.warning => (AppColors.warningBg, AppColors.warning),
      ChipTone.error   => (AppColors.errorBg,   AppColors.error),
      ChipTone.info    => (AppColors.infoBg,     AppColors.info),
      ChipTone.neutral => (AppColors.surfaceLight, AppColors.textSecondary),
    };

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

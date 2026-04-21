import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class SignaturePad extends StatelessWidget {
  final bool signed;
  final VoidCallback onTap;

  const SignaturePad({super.key, required this.signed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: signed ? null : onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: signed ? AppColors.successBg : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: signed ? AppColors.success : AppColors.surfaceInputBorder,
            width: signed ? 1.5 : 1,
          ),
        ),
        child: signed ? _SignedContent() : _EmptyContent(),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.draw_outlined,
          size: 32,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 8),
        Text(
          'İmzalamak için dokunun',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Zimmet belgesini dijital olarak onaylayın',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _SignedContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 26, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'İmzalandı',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Zimmet belgesi dijital olarak onaylandı',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

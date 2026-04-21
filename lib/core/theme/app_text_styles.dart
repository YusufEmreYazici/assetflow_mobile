import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, letterSpacing: -0.2,
  );
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 19, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, letterSpacing: -0.1,
  );
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 17, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 1,
  );
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 1,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static TextStyle captionSmall = GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
}

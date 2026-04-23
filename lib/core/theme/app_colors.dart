import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Enterprise Pro Brand ───────────────────────────────────────────
  static const Color navy              = Color(0xFF1A3A5C);
  static const Color navyDark          = Color(0xFF0F2845);
  static const Color navyLight         = Color(0xFF4670A8);

  // ─── Surface ────────────────────────────────────────────────────────
  static const Color surfaceLight       = Color(0xFFF0F4F8);
  static const Color surfaceWhite       = Color(0xFFFFFFFF);
  static const Color surfaceDivider     = Color(0xFFE5EBF0);
  static const Color surfaceInputBorder = Color(0xFFD1DAE5);

  // ─── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A3A5C);
  static const Color textSecondary = Color(0xFF6B7A8C);
  // WCAG AA için koyu yapıldı (0xFF9CA8B8 = 2.9:1, yetersiz)
  static const Color textTertiary  = Color(0xFF7D8899);
  static const Color textOnPrimary = Colors.white;

  // ─── Semantic ───────────────────────────────────────────────────────
  static const Color success   = Color(0xFF2D8659);
  static const Color successBg = Color(0xFFE8F4ED);
  static const Color warning   = Color(0xFFB85423);
  static const Color warningBg = Color(0xFFFDF3E7);
  static const Color error     = Color(0xFFC53030);
  static const Color errorBg   = Color(0xFFFDECEC);
  static const Color info      = Color(0xFF4670A8);
  static const Color infoBg    = Color(0xFFEAF0F8);

  // ─── Dark theme tokens ──────────────────────────────────────────────
  static const Color darkNavy             = Color(0xFF4670A8);
  static const Color darkNavyDark         = Color(0xFF2B4C7A);
  static const Color darkNavyLight        = Color(0xFF6A8FC4);

  static const Color darkSurfaceLight     = Color(0xFF0B1622);
  static const Color darkSurfaceWhite     = Color(0xFF152235);
  static const Color darkSurfaceDivider   = Color(0xFF1F2E45);
  static const Color darkSurfaceInputBorder = Color(0xFF293B56);

  static const Color darkTextPrimary    = Color(0xFFE5EBF0);
  static const Color darkTextSecondary  = Color(0xFF9CA8B8);
  static const Color darkTextTertiary   = Color(0xFF6B7A8C);

  static const Color darkSuccess   = Color(0xFF3FA06B);
  static const Color darkSuccessBg = Color(0xFF1A3428);
  static const Color darkWarning   = Color(0xFFD27048);
  static const Color darkWarningBg = Color(0xFF3A2418);
  static const Color darkError     = Color(0xFFE04545);
  static const Color darkErrorBg   = Color(0xFF3A1C1C);
  static const Color darkInfo      = Color(0xFF6A8FC4);
  static const Color darkInfoBg    = Color(0xFF1C2A40);

  // ─── Legacy constants (kept during screen migration) ────────────────
  static const Color primary50  = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary200 = Color(0xFFBFDBFE);
  static const Color primary300 = Color(0xFF93C5FD);
  static const Color primary400 = Color(0xFF60A5FA);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary600 = Color(0xFF2563EB);
  static const Color primary700 = Color(0xFF1D4ED8);
  static const Color primary800 = Color(0xFF1E40AF);
  static const Color primary900 = Color(0xFF1E3A8A);

  static const Color dark700 = Color(0xFF374151);
  static const Color dark800 = Color(0xFF1F2937);
  static const Color dark900 = Color(0xFF111827);
  static const Color dark950 = Color(0xFF030712);

  static const Color gray50  = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);

  static const Color surface        = Color(0xFF1F2937);
  static const Color background     = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1F2937);

  static const Color border      = Color(0xFF374151);
  static const Color borderLight = Color(0xFF4B5563);

  static const Color successLight = Color(0xFF065F46);
  static const Color warningLight = Color(0xFF78350F);
  static const Color errorLight   = Color(0xFF7F1D1D);
  static const Color infoLight    = Color(0xFF1E3A8A);

  static const Color statusActive      = Color(0xFF10B981);
  static const Color statusInStorage   = Color(0xFF3B82F6);
  static const Color statusMaintenance = Color(0xFFF59E0B);
  static const Color statusRetired     = Color(0xFFEF4444);
}

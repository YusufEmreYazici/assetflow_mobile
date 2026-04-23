import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, borderColor) = switch (variant) {
      AppButtonVariant.primary   => (AppColors.navy, Colors.white, AppColors.navy),
      AppButtonVariant.secondary => (AppColors.surfaceWhite, AppColors.navy, AppColors.surfaceInputBorder),
      AppButtonVariant.danger    => (AppColors.error, Colors.white, AppColors.error),
      AppButtonVariant.ghost     => (Colors.transparent, AppColors.navy, Colors.transparent),
    };

    Widget child = isLoading
        ? SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fg,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    final button = GestureDetector(
      onTap: (isLoading || onPressed == null)
          ? null
          : () {
              switch (variant) {
                case AppButtonVariant.danger:
                  HapticService.heavy();
                case AppButtonVariant.primary:
                  HapticService.medium();
                default:
                  HapticService.light();
              }
              onPressed!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        decoration: BoxDecoration(
          color: (isLoading || onPressed == null)
              ? bg.withValues(alpha: 0.6)
              : bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

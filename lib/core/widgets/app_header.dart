import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String userName;
  final String role;
  final String company;
  final String title;
  final bool showNotifBadge;
  final VoidCallback? onNotif;
  final VoidCallback? onMenu;

  const AppHeader({
    super.key,
    required this.userName,
    this.role = '',
    this.company = 'ASSETFLOW',
    this.title = 'IT Varlık Yönetimi',
    this.showNotifBadge = false,
    this.onNotif,
    this.onMenu,
  });

  String get _initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0];
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: Colors.white, letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoş geldin, ${userName.split(' ').first}',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    if (role.isNotEmpty)
                      Text(
                        role,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              Stack(
                children: [
                  _NavButton(
                    onTap: onNotif,
                    child: const Icon(Icons.notifications_outlined, size: 18, color: Colors.white),
                  ),
                  if (showNotifBadge)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.navy, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              if (onMenu != null) ...[
                const SizedBox(width: 8),
                _NavButton(onTap: onMenu!, child: const Icon(Icons.menu, size: 18, color: Colors.white)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            company,
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w500,
              color: Colors.white, letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _NavButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}

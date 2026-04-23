import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  /// Back button on the LEFT when provided.
  final VoidCallback? onBack;

  /// Hamburger icon on the RIGHT when true (main tab screens).
  final bool showMenu;

  /// Extra action widget placed right of title, before hamburger.
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showMenu = false,
    this.action,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: back button (Grup B screens)
          if (onBack != null) ...[
            Semantics(
              label: 'Geri',
              button: true,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // MIDDLE: title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 19, fontWeight: FontWeight.w500,
                    color: Colors.white, letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.2,
                    ),
                  ),
              ],
            ),
          ),

          // RIGHT: extra action
          ?action,

          // RIGHT: hamburger (Grup A / main tab screens)
          if (showMenu) ...[
            if (action != null) const SizedBox(width: 8),
            Semantics(
              label: 'Menü',
              button: true,
              child: Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.maybeOf(ctx)?.openEndDrawer(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

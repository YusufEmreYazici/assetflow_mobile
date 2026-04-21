import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum BottomNavTab { home, devices, people, more }

class AppBottomNav extends StatelessWidget {
  final BottomNavTab active;
  final ValueChanged<BottomNavTab>? onChange;
  final VoidCallback? onMore;

  const AppBottomNav({
    super.key,
    required this.active,
    this.onChange,
    this.onMore,
  });

  static const _tabs = [
    (BottomNavTab.home,    'Anasayfa', Icons.home_outlined,    Icons.home),
    (BottomNavTab.devices, 'Cihazlar', Icons.devices_outlined,  Icons.devices),
    (BottomNavTab.people,  'Personel', Icons.people_outline,    Icons.people),
    (BottomNavTab.more,    'Daha Fazla', Icons.menu,            Icons.menu),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 4, right: 4,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: _tabs.map((t) {
          final (tab, label, iconOutline, iconFilled) = t;
          final isActive = tab == active;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (tab == BottomNavTab.more) {
                  onMore?.call();
                } else {
                  onChange?.call(tab);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? iconFilled : iconOutline,
                      size: 20,
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

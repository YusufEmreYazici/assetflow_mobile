import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DrawerItem {
  final String key;
  final String label;
  final IconData icon;
  final String? badge;
  final bool badgeIsError;

  const DrawerItem({
    required this.key,
    required this.label,
    required this.icon,
    this.badge,
    this.badgeIsError = false,
  });
}

class DrawerSection {
  final String title;
  final List<DrawerItem> items;
  const DrawerSection({required this.title, required this.items});
}

final kDrawerSections = [
  DrawerSection(title: 'YÖNETİM', items: [
    const DrawerItem(key: 'home',      label: 'Anasayfa',       icon: Icons.home_outlined),
    const DrawerItem(key: 'devices',   label: 'Cihazlar',       icon: Icons.devices_outlined),
    const DrawerItem(key: 'people',    label: 'Personel',       icon: Icons.people_outline),
    const DrawerItem(key: 'assign',    label: 'Zimmetler',      icon: Icons.assignment_outlined),
    const DrawerItem(key: 'locations', label: 'Lokasyonlar',    icon: Icons.location_on_outlined),
  ]),
  DrawerSection(title: 'RAPORLAR', items: [
    const DrawerItem(key: 'audit',     label: 'Audit Log',       icon: Icons.history),
    const DrawerItem(key: 'export',    label: 'Excel Export',    icon: Icons.download_outlined),
  ]),
  DrawerSection(title: 'SİSTEM', items: [
    const DrawerItem(key: 'notif',     label: 'Bildirimler',     icon: Icons.notifications_outlined),
    const DrawerItem(key: 'sap',       label: 'SAP Senkron.',    icon: Icons.sync),
    const DrawerItem(key: 'settings',  label: 'Ayarlar',         icon: Icons.settings_outlined),
    const DrawerItem(key: 'profile',   label: 'Profilim',        icon: Icons.person_outline),
  ]),
  DrawerSection(title: 'YARDIM', items: [
    const DrawerItem(key: 'about',     label: 'Hakkında',        icon: Icons.info_outline),
  ]),
];

class AppDrawer extends StatelessWidget {
  final String currentKey;
  final String userName;
  final String userEmail;
  final String userRole;
  final String company;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.currentKey,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.company,
    required this.onNavigate,
    required this.onLogout,
  });

  String get _initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0];
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          // Profile header
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20, right: 20, bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 22, fontWeight: FontWeight.w500,
                          color: Colors.white, letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.inter(
                              fontSize: 17, fontWeight: FontWeight.w500,
                              color: Colors.white, letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        userRole.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: Colors.white, letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· $company',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                for (int si = 0; si < kDrawerSections.length; si++) ...[
                  SizedBox(height: si == 0 ? 14.0 : 8.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                    child: Text(
                      kDrawerSections[si].title,
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary, letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  for (final item in kDrawerSections[si].items)
                    _DrawerMenuItem(
                      item: item,
                      active: item.key == currentKey,
                      onTap: () {
                        Navigator.pop(context);
                        onNavigate(item.key);
                      },
                    ),
                  if (si < kDrawerSections.length - 1)
                    Container(
                      height: 1,
                      color: AppColors.surfaceLight,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.surfaceLight)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onLogout();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 18, color: AppColors.error),
                        const SizedBox(width: 14),
                        Text(
                          'Çıkış Yap',
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                  child: Text(
                    'AssetFlow v2.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final DrawerItem item;
  final bool active;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: active
              ? AppColors.navy.withValues(alpha: 0.10)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? AppColors.navy : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(15, 10, 18, 10),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: active ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  color: active ? AppColors.navy : AppColors.textPrimary,
                ),
              ),
            ),
            if (item.badge != null)
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: item.badgeIsError
                      ? AppColors.error
                      : (active ? AppColors.navy : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.badge!,
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: item.badgeIsError
                        ? Colors.white
                        : (active ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

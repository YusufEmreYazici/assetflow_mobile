import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final fullName = authState.fullName ?? 'Kullanıcı';
    final email = authState.email ?? '';
    final role = _roleLabel(authState.role);

    final initials = _initials(fullName);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: goBackOrHome(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        fullName,
                        style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 40),
              children: [
                _Section(
                  label: 'HESAP',
                  children: [
                    _Row(
                      icon: Icons.email_outlined,
                      label: email,
                      caption: 'E-posta',
                    ),
                    _Row(
                      icon: Icons.lock_outline,
                      label: 'Şifreyi Değiştir',
                      chevron: true,
                      onTap: () => _showChangePasswordSheet(context, ref),
                    ),
                    _Row(
                      icon: Icons.delete_sweep_outlined,
                      label: 'Önbelleği Temizle',
                      chevron: true,
                      isLast: true,
                      onTap: () => _clearCache(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Section(
                  label: 'TERCİHLER',
                  children: [
                    _Row(
                      icon: Icons.settings_outlined,
                      label: 'Uygulama Ayarları',
                      chevron: true,
                      isLast: true,
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Section(
                  label: 'HAKKINDA',
                  children: [
                    const _Row(icon: Icons.apps_outlined, label: 'AssetFlow Mobile', caption: 'v2.0.0'),
                    const _Row(icon: Icons.info_outline, label: 'Lisans Bilgisi', chevron: true),
                    const _Row(icon: Icons.policy_outlined, label: 'Gizlilik Politikası', chevron: true, isLast: true),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _confirmLogout(context, ref),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  String _roleLabel(String? role) => switch (role) {
        'Admin' => 'YÖNETİCİ',
        'Manager' => 'MÜDÜR',
        'ITAdmin' => 'IT YÖNETİCİ',
        _ => role?.toUpperCase() ?? '',
      };

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumunuzu kapatmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Çıkış Yap',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) async {
    await CacheManager.instance.clearAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önbellek temizlendi.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Şifre Değiştir',
              style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Şifre değiştirme özelliği yakında aktif olacak.',
              style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Kapat',
                  style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: AppColors.textTertiary, letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceDivider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? caption;
  final bool chevron;
  final bool isLast;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.caption,
    this.chevron = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.surfaceDivider)),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 16, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (chevron)
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

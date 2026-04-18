import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';
import 'package:assetflow_mobile/core/utils/seen_notification_store.dart';
import 'package:assetflow_mobile/data/services/auth_service.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/profile/screens/notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Password change
  final _currentPassC = TextEditingController();
  final _newPassC = TextEditingController();
  final _confirmPassC = TextEditingController();
  final _passFormKey = GlobalKey<FormState>();
  bool _changingPass = false;
  bool _showPassSection = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPassC.dispose();
    _newPassC.dispose();
    _confirmPassC.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_passFormKey.currentState!.validate()) return;
    setState(() => _changingPass = true);

    try {
      await AuthService().changePassword(
        _currentPassC.text,
        _newPassC.text,
      );

      if (mounted) {
        setState(() {
          _changingPass = false;
          _showPassSection = false;
        });
        _currentPassC.clear();
        _newPassC.clear();
        _confirmPassC.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sifre basariyla degistirildi'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _changingPass = false);
        String msg = 'Sifre degistirilemedi';
        if (e.response?.data is Map) {
          msg = (e.response!.data as Map)['error'] ?? msg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _changingPass = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sifre degistirilemedi'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cikis Yap'),
        content: const Text('Oturumu kapatmak istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Cikis Yap', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary600.withValues(alpha: 0.2),
                  child: Text(
                    (auth.fullName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.fullName ?? 'Kullanici',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary600.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel(auth.role),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings Section
          _SectionTitle(title: 'Hesap'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirim Ayarları',
            subtitle: 'Kanal bazında bildirimleri yönetin',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Sifre Degistir',
            subtitle: 'Hesap sifrenizi guncelleyin',
            trailing: Icon(
              _showPassSection ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textTertiary,
            ),
            onTap: () => setState(() => _showPassSection = !_showPassSection),
          ),

          // Password Change Section
          if (_showPassSection) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _passFormKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Mevcut Sifre',
                      controller: _currentPassC,
                      obscureText: _obscureCurrent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textTertiary, size: 20,
                        ),
                        onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Mevcut sifre gerekli' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Yeni Sifre',
                      controller: _newPassC,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textTertiary, size: 20,
                        ),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Yeni sifre gerekli';
                        if (v.length < 8) return 'En az 8 karakter olmali';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Yeni Sifre Tekrar',
                      controller: _confirmPassC,
                      obscureText: true,
                      validator: (v) {
                        if (v != _newPassC.text) return 'Sifreler eslesmiyor';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Sifreyi Degistir',
                      onPressed: _changePassword,
                      isLoading: _changingPass,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
          _SectionTitle(title: 'Uygulama'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Uygulama Hakkinda',
            subtitle: 'AssetFlow v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'AssetFlow',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 AssetFlow. Tum haklar saklidir.',
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary600.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary500, size: 28),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.cached,
            title: 'Onbellek Temizle',
            subtitle: 'Yerel verileri temizle',
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              await CacheManager.instance.clearAll();
              await SeenNotificationStore.instance.clearAll();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Onbellek temizlendi'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Logout Button
          AppButton(
            text: 'Cikis Yap',
            onPressed: _confirmLogout,
            variant: AppButtonVariant.danger,
            isFullWidth: true,
            icon: Icons.logout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'Admin':
        return 'Yonetici';
      case 'Manager':
        return 'Mudur';
      case 'ITAdmin':
        return 'IT Yonetici';
      default:
        return role ?? 'Kullanici';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary600.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary400, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

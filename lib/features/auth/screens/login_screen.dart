import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        HapticService.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            children: [
              const SizedBox(height: 60),

              // Brand block
              _buildBrand(),
              const SizedBox(height: 48),

              // Email field
              _buildLabel('E-POSTA VEYA SİCİL NUMARASI'),
              const SizedBox(height: 8),
              _buildEmailField(),
              const SizedBox(height: 18),

              // Password field
              _buildLabel('ŞİFRE'),
              const SizedBox(height: 8),
              _buildPasswordField(),
              const SizedBox(height: 14),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    HapticService.light();
                    context.push('/forgot-password');
                  },
                  child: Text(
                    'Şifremi unuttum',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Primary button
              _LoginButton(
                isLoading: authState.isLoading,
                onPressed: _onLogin,
              ),
              const SizedBox(height: 14),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.surfaceDivider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'veya',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.surfaceDivider)),
                ],
              ),
              const SizedBox(height: 14),

              // SSO button
              _SsoButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('SSO entegrasyonu yakında aktif olacak.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.dark800,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Asset',
              style: GoogleFonts.inter(
                fontSize: 34, fontWeight: FontWeight.w500,
                color: AppColors.navy, letterSpacing: -1,
              ),
            ),
            Text(
              'Flow',
              style: GoogleFonts.inter(
                fontSize: 34, fontWeight: FontWeight.w300,
                color: AppColors.navy, letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 6),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'IT VARLIK YÖNETİM SİSTEMİ',
          style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: AppColors.textSecondary, letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        Container(width: 32, height: 2, color: AppColors.navy),
        const SizedBox(height: 16),
        Text(
          'Kurumsal hesabınızla giriş yaparak şirket varlıklarınızı yönetin.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary, letterSpacing: 1,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'E-posta veya sicil numarası gerekli';
        return null;
      },
      decoration: _inputDeco(
        hint: 'ad.soyad@sirket.com.tr veya 12345',
        prefix: const Icon(Icons.person_outline, size: 18, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: !_showPass,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Şifre gerekli';
        return null;
      },
      decoration: _inputDeco(
        hint: '••••••••',
        prefix: const Icon(Icons.lock_outline, size: 18, color: AppColors.textTertiary),
        suffix: GestureDetector(
          onTap: () => setState(() => _showPass = !_showPass),
          child: Icon(
            _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18, color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surfaceWhite,
      prefixIcon: prefix != null
          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: prefix)
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 46),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: suffix)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.navy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('v2.2.0', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 0.4)),
            Text('© 2026 AssetFlow', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              HapticService.medium();
              onPressed();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: isLoading ? AppColors.navyDark : AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Giriş Yap',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: Colors.white, letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SsoButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SsoButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        onPressed();
      },
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceInputBorder),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: AppColors.navy),
              const SizedBox(width: 8),
              Text(
                'SSO ile giriş (Active Directory)',
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

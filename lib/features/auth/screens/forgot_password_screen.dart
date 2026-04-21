import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Geçerli bir e-posta adresi girin.');
      return;
    }
    setState(() { _error = null; _isLoading = true; });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.pushReplacement('/password-sent?email=${Uri.encodeComponent(email)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Column(
        children: [
          PageHeader(
            title: 'Şifre Sıfırlama',
            subtitle: 'ASSETFLOW',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mail_outline, size: 22, color: AppColors.info),
                ),
                const SizedBox(height: 20),
                Text(
                  'Şifrenizi mi unuttunuz?',
                  style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary, letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kurumsal e-posta adresinize bir sıfırlama bağlantısı göndereceğiz. Bağlantı 30 dakika geçerli olacaktır.',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.55,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'KURUMSAL E-POSTA',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary, letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                  onChanged: (_) { if (_error != null) setState(() => _error = null); },
                  decoration: InputDecoration(
                    hintText: 'ad.soyad@sirket.com.tr',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(Icons.mail_outline, size: 18, color: AppColors.textTertiary),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 46),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: _error != null ? AppColors.error : AppColors.surfaceInputBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: _error != null ? AppColors.error : AppColors.navy,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.error)),
                ],
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isLoading ? AppColors.navyDark : AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: _isLoading
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
                                  'Sıfırlama Linki Gönder',
                                  style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      '← Giriş ekranına dön',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: AppColors.navy,
                      ),
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

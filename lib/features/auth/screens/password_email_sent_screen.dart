import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';

class PasswordEmailSentScreen extends StatefulWidget {
  final String email;
  const PasswordEmailSentScreen({super.key, required this.email});

  @override
  State<PasswordEmailSentScreen> createState() =>
      _PasswordEmailSentScreenState();
}

class _PasswordEmailSentScreenState extends State<PasswordEmailSentScreen> {
  int _cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 0) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Column(
        children: [
          PageHeader(
            title: 'E-posta Gönderildi',
            subtitle: 'ASSETFLOW',
            onBack: () => context.go('/login'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 32,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'E-posta gönderildi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sıfırlama bağlantısı aşağıdaki adrese gönderildi. Gelen kutunuzu ve spam klasörünüzü kontrol edin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      widget.email,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => context.push('/reset-password'),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Şifreyi Sıfırla',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _cooldown > 0 ? null : _startTimer,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.surfaceInputBorder),
                    ),
                    child: Center(
                      child: Text(
                        _cooldown > 0
                            ? 'Yeniden gönder ($_cooldown s)'
                            : 'Yeniden gönder',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _cooldown > 0
                              ? AppColors.textTertiary
                              : AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Center(
                    child: Text(
                      '← Giriş ekranına dön',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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

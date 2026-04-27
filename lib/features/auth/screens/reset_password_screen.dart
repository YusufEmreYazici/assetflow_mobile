import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _p1Ctrl = TextEditingController();
  final _p2Ctrl = TextEditingController();
  bool _showPass = false;
  bool _isDone = false;
  String? _error;

  @override
  void dispose() {
    _p1Ctrl.dispose();
    _p2Ctrl.dispose();
    super.dispose();
  }

  int _strength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[^A-Za-z0-9]'))) s++;
    return s;
  }

  Future<void> _submit() async {
    final p1 = _p1Ctrl.text;
    final p2 = _p2Ctrl.text;
    if (p1.length < 8) {
      setState(() => _error = 'Şifre en az 8 karakter olmalı.');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'Şifreler eşleşmiyor.');
      return;
    }
    if (_strength(p1) < 2) {
      setState(() => _error = 'Daha güçlü bir şifre seçin.');
      return;
    }
    setState(() {
      _error = null;
      _isDone = true;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final p1 = _p1Ctrl.text;
    final s = _strength(p1);
    final strengthLabel = s <= 1
        ? 'Zayıf'
        : s == 2
        ? 'Orta'
        : 'Güçlü';
    final strengthColor = s <= 1
        ? AppColors.error
        : s == 2
        ? AppColors.warning
        : AppColors.success;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: Column(
        children: [
          PageHeader(
            title: 'Yeni Şifre',
            subtitle: 'ASSETFLOW',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: _isDone
                ? _buildSuccess()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                    children: [
                      Text(
                        'Yeni şifre belirle',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'En az 8 karakter, büyük harf, sayı ve özel karakter içermesi önerilir.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFieldLabel('YENİ ŞİFRE'),
                      const SizedBox(height: 8),
                      _buildPassField(_p1Ctrl, showToggle: true),
                      if (p1.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            4,
                            (i) => Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                                decoration: BoxDecoration(
                                  color: i < s
                                      ? strengthColor
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strengthLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: strengthColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _buildFieldLabel('ŞİFRE TEKRAR'),
                      const SizedBox(height: 8),
                      _buildPassField(_p2Ctrl),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      if (_p2Ctrl.text.isNotEmpty &&
                          _p1Ctrl.text == _p2Ctrl.text &&
                          _error == null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.check,
                              size: 12,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Şifreler eşleşiyor',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              'Şifreyi Güncelle',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildPassField(
    TextEditingController ctrl, {
    bool showToggle = false,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: !_showPass,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surfaceWhite,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textTertiary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        suffixIcon: showToggle
            ? GestureDetector(
                onTap: () => setState(() => _showPass = !_showPass),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    _showPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
            const SizedBox(height: 20),
            Text(
              'Şifre güncellendi',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni şifrenizle giriş yapabilirsiniz.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

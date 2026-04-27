import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_text_field.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/core/widgets/loading_overlay.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            companyName: _companyNameController.text.trim(),
            taxNumber: _taxNumberController.text.trim().isNotEmpty
                ? _taxNumberController.text.trim()
                : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Hesap Olustur',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'AssetFlow\'a baslamak icin kayit olun',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    AppTextField(
                      label: 'Ad Soyad',
                      hint: 'Adinizi ve soyadinizi girin',
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textTertiary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ad soyad gerekli';
                        }
                        if (value.trim().length < 2) {
                          return 'Ad soyad en az 2 karakter olmali';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Company Name
                    AppTextField(
                      label: 'Sirket Adi',
                      hint: 'Sirket adinizi girin',
                      controller: _companyNameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.business_outlined,
                        color: AppColors.textTertiary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Sirket adi gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tax Number (optional)
                    AppTextField(
                      label: 'Vergi No (Opsiyonel)',
                      hint: 'Vergi numaranizi girin',
                      controller: _taxNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    AppTextField(
                      label: 'E-posta',
                      hint: 'ornek@sirket.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textTertiary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'E-posta adresi gerekli';
                        }
                        if (!RegExp(
                          r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'Gecerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AppTextField(
                      label: 'Sifre',
                      hint: 'En az 8 karakter, buyuk/kucuk harf ve rakam',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textTertiary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sifre gerekli';
                        }
                        if (value.length < 8) {
                          return 'Sifre en az 8 karakter olmali';
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value)) {
                          return 'Sifre en az bir buyuk harf icermeli';
                        }
                        if (!RegExp(r'[a-z]').hasMatch(value)) {
                          return 'Sifre en az bir kucuk harf icermeli';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Sifre en az bir rakam icermeli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Register button
                    AppButton(
                      text: 'Kayit Ol',
                      onPressed: _onRegister,
                      isLoading: authState.isLoading,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Zaten hesabiniz var mi? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Giris yap',
                            style: TextStyle(
                              color: AppColors.primary500,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

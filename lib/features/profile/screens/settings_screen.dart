import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_variant_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifAssignment = true;
  bool _notifWarranty = true;
  bool _notifSystem = false;

  @override
  Widget build(BuildContext context) {
    final variant = ref.watch(dashboardVariantProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 18,
            ),
            child: Row(
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
                const SizedBox(width: 12),
                Text(
                  'Ayarlar',
                  style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SectionLabel('DASHBOARD GÖRÜNÜMÜ'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: Column(
                    children: [
                      _VariantRow(
                        label: 'Klasik (A)',
                        caption: '2×2 KPI kartları, kısa özet',
                        selected: variant == DashboardVariant.a,
                        onTap: () => ref
                            .read(dashboardVariantProvider.notifier)
                            .setVariant(DashboardVariant.a),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceDivider, indent: 16, endIndent: 16),
                      _VariantRow(
                        label: 'Analytics (B)',
                        caption: 'Durum çubuğu, metrik strip, grafik',
                        selected: variant == DashboardVariant.b,
                        isLast: true,
                        onTap: () => ref
                            .read(dashboardVariantProvider.notifier)
                            .setVariant(DashboardVariant.b),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('BİLDİRİMLER'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: Column(
                    children: [
                      _ToggleRow(
                        icon: Icons.assignment_outlined,
                        label: 'Zimmet Bildirimleri',
                        caption: 'Yeni zimmet ve iade',
                        value: _notifAssignment,
                        onChanged: (v) => setState(() => _notifAssignment = v),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceDivider),
                      _ToggleRow(
                        icon: Icons.shield_outlined,
                        label: 'Garanti Uyarıları',
                        caption: 'Bitiş tarihine yaklaşan garantiler',
                        value: _notifWarranty,
                        onChanged: (v) => setState(() => _notifWarranty = v),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceDivider),
                      _ToggleRow(
                        icon: Icons.settings_outlined,
                        label: 'Sistem Bildirimleri',
                        caption: 'Bakım ve raporlar',
                        value: _notifSystem,
                        isLast: true,
                        onChanged: (v) => setState(() => _notifSystem = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('DİL'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 20, color: AppColors.navy),
                      const SizedBox(width: 12),
                      Text(
                        'Türkçe',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tek dil destekleniyor',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textTertiary,
                        ),
                      ),
                    ],
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: AppColors.textTertiary, letterSpacing: 0.8,
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final String label;
  final String caption;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;
  const _VariantRow({
    required this.label,
    required this.caption,
    required this.selected,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
                  Text(
                    caption,
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.navy : AppColors.surfaceInputBorder,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.navy,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final bool value;
  final bool isLast;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.caption,
    required this.value,
    this.isLast = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(
                  caption,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.navy,
          ),
        ],
      ),
    );
  }
}

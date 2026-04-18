import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/section_header.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DashboardSectionHeader(title: 'HIZLI İŞLEMLER'),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 82,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _QuickAction(
                icon: Icons.assignment_add,
                label: 'Zimmet Ata',
                color: AppColors.success,
                onTap: () => context.go('/assignments'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.add_box_rounded,
                label: 'Cihaz Ekle',
                color: AppColors.primary500,
                onTap: () => context.go('/devices'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.person_add_rounded,
                label: 'Personel Ekle',
                color: AppColors.info,
                onTap: () => context.go('/employees'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.qr_code_scanner,
                label: 'QR Tara',
                color: AppColors.primary400,
                onTap: () => context.go('/assignments'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.dark800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

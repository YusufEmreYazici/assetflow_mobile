import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  const DashboardSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

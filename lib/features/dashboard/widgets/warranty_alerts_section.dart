import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';

class WarrantyAlertsSection extends StatelessWidget {
  final List<WarrantyAlertItem> items;
  const WarrantyAlertsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...items.map<Widget>((item) {
          final Color accentColor;
          final String urgencyLabel;
          if (item.daysRemaining <= 0) {
            accentColor = AppColors.error;
            urgencyLabel = 'BİTTİ';
          } else if (item.daysRemaining < 30) {
            accentColor = AppColors.error;
            urgencyLabel = 'KRİTİK';
          } else if (item.daysRemaining < 90) {
            accentColor = AppColors.warning;
            urgencyLabel = 'UYARI';
          } else {
            accentColor = AppColors.success;
            urgencyLabel = 'NORMAL';
          }
          final dateStr = DateFormat(
            'dd MMM yyyy',
            'tr_TR',
          ).format(item.warrantyEndDate);

          return GestureDetector(
            onTap: () => context.push('/devices/${item.deviceId}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withValues(
                    alpha: urgencyLabel == 'NORMAL' ? 0.15 : 0.3,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.deviceName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.assignedTo ?? 'Atanmamış',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.daysRemaining <= 0
                              ? urgencyLabel
                              : '${item.daysRemaining} gün',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/section_header.dart';

class RecentActivitySection extends StatelessWidget {
  final List<Assignment> items;
  const RecentActivitySection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'tr_TR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: 'SON AKTİVİTELER'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final a = items[i];
              final isLast = i == items.length - 1;
              final typeLabel = AssignmentTypeLabels[a.type] ?? 'Zimmet';
              final typeColor = a.type == 0
                  ? AppColors.success
                  : a.type == 1
                      ? AppColors.info
                      : AppColors.warning;
              return Column(
                children: [
                  ListTile(
                    onTap: () => context.go('/assignments'),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.assignment_turned_in_rounded,
                          color: typeColor, size: 17),
                    ),
                    title: Text(
                      a.deviceName ?? '-',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      a.employeeName ?? '-',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(typeLabel,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor)),
                        ),
                        const SizedBox(height: 3),
                        Text(dateFormat.format(a.assignedAt),
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 62, color: AppColors.border),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

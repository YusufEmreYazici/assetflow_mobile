import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/section_header.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/stat_card.dart';

class DashboardKpiGrid extends StatelessWidget {
  final DashboardData data;
  const DashboardKpiGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasExpired = data.expiredWarranties > 0;
    final hasExpiring = data.expiringWarranties > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DashboardSectionHeader(title: 'GENEL BAKIŞ'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                icon: Icons.devices_rounded,
                value: '${data.totalDevices}',
                label: 'Toplam Cihaz',
                color: AppColors.primary500,
              ),
              StatCard(
                icon: Icons.assignment_ind_rounded,
                value: '${data.assignedDevices}',
                label: 'Zimmetli',
                color: AppColors.success,
                sublabel: data.totalDevices > 0
                    ? '%${((data.assignedDevices / data.totalDevices) * 100).round()}'
                    : null,
              ),
              StatCard(
                icon: Icons.inventory_2_rounded,
                value: '${data.inStorageDevices}',
                label: 'Depoda',
                color: AppColors.info,
              ),
              StatCard(
                icon: Icons.people_rounded,
                value: '${data.totalEmployees}',
                label: 'Toplam Personel',
                color: AppColors.primary400,
              ),
              StatCard(
                icon: Icons.schedule_rounded,
                value: '${data.expiringWarranties}',
                label: 'Garanti Uyarı',
                color: AppColors.warning,
                sublabel: hasExpiring ? 'DİKKAT' : null,
              ),
              StatCard(
                icon: Icons.gpp_bad_rounded,
                value: '${data.expiredWarranties}',
                label: 'Garanti Biten',
                color: AppColors.error,
                sublabel: hasExpired ? 'KRİTİK' : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

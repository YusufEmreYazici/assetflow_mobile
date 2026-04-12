import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/stat_card.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/device_type_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final greeting = _getGreeting();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting,',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              authState.fullName ?? 'Kullanici',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary500,
        backgroundColor: AppColors.dark800,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          await ref.read(dashboardProvider.future);
        },
        child: dashboardAsync.when(
          data: (data) => _buildContent(context, data, ref),
          loading: () => _buildShimmer(),
          error: (error, _) => _buildError(context, ref, error),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Gunaydin';
    if (hour < 18) return 'Iyi gunler';
    return 'Iyi aksamlar';
  }

  Widget _buildContent(BuildContext context, dynamic data, WidgetRef ref) {
    final recentAsync = ref.watch(recentAssignmentsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Stat Cards ──────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(
              icon: Icons.devices,
              value: '${data.totalDevices}',
              label: 'Toplam Cihaz',
              color: AppColors.primary500,
            ),
            StatCard(
              icon: Icons.assignment_ind,
              value: '${data.assignedDevices}',
              label: 'Zimmetli',
              color: AppColors.success,
            ),
            StatCard(
              icon: Icons.inventory_2,
              value: '${data.inStorageDevices}',
              label: 'Depoda',
              color: AppColors.info,
            ),
            StatCard(
              icon: Icons.warning_amber_rounded,
              value: '${data.expiredWarranties}',
              label: 'Garanti Biten',
              color: AppColors.error,
            ),
            StatCard(
              icon: Icons.people,
              value: '${data.totalEmployees}',
              label: 'Toplam Personel',
              color: AppColors.primary400,
            ),
            StatCard(
              icon: Icons.schedule,
              value: '${data.expiringWarranties}',
              label: 'Garanti Uyarı',
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Cihaz Tipi Grafiği ───────────────────────────
        if (data.devicesByType.isNotEmpty) ...[
          DeviceTypeChart(devicesByType: data.devicesByType),
          const SizedBox(height: 20),
        ],

        // ── Son Aktiviteler ──────────────────────────────
        recentAsync.when(
          data: (items) => items.isEmpty
              ? const SizedBox.shrink()
              : _buildRecentActivity(items),
          loading: () => _buildRecentActivityShimmer(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // ── Garanti Yaklaşanlar ──────────────────────────
        if (data.upcomingWarrantyExpirations.isNotEmpty) ...[
          const Text(
            'Garanti Yaklaşanlar',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...data.upcomingWarrantyExpirations.map<Widget>((item) {
            final Color accentColor;
            if (item.daysRemaining < 30) {
              accentColor = AppColors.error;
            } else if (item.daysRemaining < 90) {
              accentColor = AppColors.warning;
            } else {
              accentColor = AppColors.success;
            }
            final dateStr =
                DateFormat('dd MMM yyyy', 'tr_TR').format(item.warrantyEndDate);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shield_outlined,
                        color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.deviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.assignedTo ?? 'Atanmamış',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.daysRemaining} gün',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildRecentActivity(List<Assignment> items) {
    final dateFormat = DateFormat('dd MMM', 'tr_TR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son Aktiviteler',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final a = items[i];
              final isLast = i == items.length - 1;
              final typeLabel = AssignmentTypeLabels[a.type] ?? 'Zimmet';
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.assignment_turned_in,
                              color: AppColors.success, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.deviceName ?? '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${a.employeeName ?? '-'} · $typeLabel',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          dateFormat.format(a.assignedAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
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
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecentActivityShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            width: 130,
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              6,
              (_) => Container(
                decoration: BoxDecoration(
                  color: AppColors.dark800,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 20,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.dark800,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Veriler yuklenirken hata olustu',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(dashboardProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

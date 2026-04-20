import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/audit/providers/audit_log_provider.dart';
import 'audit_log_tile.dart';

class AuditLogSection extends ConsumerWidget {
  final String deviceId;

  const AuditLogSection({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(deviceAuditLogsProvider(deviceId));

    return auditAsync.when(
      loading: () => _buildShimmer(),
      error: (error, _) => _buildError(ref),
      data: (result) {
        if (result.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Henüz değişiklik yok',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ),
          );
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.items.length,
              separatorBuilder: (context, _) => const Divider(
                height: 1,
                indent: 62,
                color: AppColors.border,
              ),
              itemBuilder: (_, i) => AuditLogTile(log: result.items[i]),
            ),
            if (result.totalPages > 1) ...[
              const Divider(height: 1, color: AppColors.border),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.expand_more,
                  size: 16,
                  color: AppColors.primary400,
                ),
                label: Text(
                  'Daha fazla göster (${result.totalCount - result.items.length} kayıt)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary400,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.dark800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 160,
                        decoration: BoxDecoration(
                          color: AppColors.dark800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.dark800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Text(
            'Geçmiş yüklenemedi',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(deviceAuditLogsProvider(deviceId)),
            child: const Text(
              'Tekrar dene',
              style: TextStyle(fontSize: 12, color: AppColors.primary400),
            ),
          ),
        ],
      ),
    );
  }
}

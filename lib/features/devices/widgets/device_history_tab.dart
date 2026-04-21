import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/audit/providers/audit_log_provider.dart';
import 'package:assetflow_mobile/features/audit/widgets/audit_log_tile.dart';

class DeviceHistoryTab extends ConsumerWidget {
  final String deviceId;
  const DeviceHistoryTab({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deviceAuditLogsProvider(deviceId));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Geçmiş yüklenemedi.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
      data: (result) {
        if (result.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_outlined,
                    size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'Değişiklik geçmişi bulunamadı',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 100),
          itemCount: result.items.length,
          itemBuilder: (context, i) {
            final log = result.items[i];
            final isLast = i == result.items.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 48,
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _dotColor(log.action),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1,
                              color: AppColors.surfaceDivider,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: AppSpacing.lg,
                        bottom: isLast ? 0 : AppSpacing.sm,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.surfaceDivider),
                        ),
                        child: AuditLogTile(log: log),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _dotColor(String action) => switch (action) {
        'Create' => AppColors.success,
        'Update' => AppColors.info,
        'Delete' => AppColors.error,
        _ => AppColors.textTertiary,
      };
}

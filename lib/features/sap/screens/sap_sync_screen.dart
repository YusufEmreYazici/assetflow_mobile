import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/features/sap/providers/sap_provider.dart';

class SapSyncScreen extends ConsumerWidget {
  const SapSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sapProvider);
    final connected = state.connectionStatus?.isConnected == true;
    final lastChecked = state.connectionStatus?.lastChecked;

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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SAP Entegrasyonu',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Connection status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: connected
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connected ? 'SAP Bağlı' : 'SAP Bağlantı Yok',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (lastChecked != null)
                              Text(
                                'Son kontrol: ${DateFormat('d MMM, HH:mm', 'tr_TR').format(lastChecked)}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(sapProvider.notifier).refresh(),
                        child: const Icon(
                          Icons.refresh,
                          size: 20,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionLabel('SYNC İŞLEMLERİ'),
                const SizedBox(height: 8),
                _SyncButton(
                  icon: Icons.people_outlined,
                  label: 'Personel Senkronizasyonu',
                  caption: 'SAP HR\'dan personel listesini çek',
                  isSyncing: state.isSyncingEmployees,
                  onTap: () =>
                      ref.read(sapProvider.notifier).syncEmployees(),
                ),
                const SizedBox(height: 8),
                _SyncButton(
                  icon: Icons.devices_outlined,
                  label: 'Cihaz Senkronizasyonu',
                  caption: 'SAP Asset Manager\'dan cihazları çek',
                  isSyncing: state.isSyncingAssets,
                  onTap: () => ref.read(sapProvider.notifier).syncAssets(),
                ),
                const SizedBox(height: 8),
                _SyncButton(
                  icon: Icons.account_balance_outlined,
                  label: 'Bütçe Verileri',
                  caption: 'SAP FI/CO\'dan bütçe bilgilerini çek',
                  isSyncing: false,
                  onTap: null,
                ),
                // Last sync results
                if (state.lastEmployeeSync != null ||
                    state.lastAssetSync != null) ...[
                  const SizedBox(height: 16),
                  _SectionLabel('SON İŞLEMLER'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.surfaceDivider),
                    ),
                    child: Column(
                      children: [
                        if (state.lastEmployeeSync != null)
                          _SyncResultRow(
                            label: 'Personel Sync',
                            result: state.lastEmployeeSync!,
                            isLast: state.lastAssetSync == null,
                          ),
                        if (state.lastAssetSync != null)
                          _SyncResultRow(
                            label: 'Cihaz Sync',
                            result: state.lastAssetSync!,
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
                ],
                if (state.employeeSyncError != null ||
                    state.assetSyncError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      state.employeeSyncError ?? state.assetSyncError ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncResultRow extends StatelessWidget {
  final String label;
  final dynamic result;
  final bool isLast;

  const _SyncResultRow({
    required this.label,
    required this.result,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final success = result.success as bool;
    final newCount = result.newCount as int;
    final updatedCount = result.updatedCount as int;
    final syncTime = result.syncTime as DateTime;

    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: success ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $newCount yeni, $updatedCount güncelleme',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            DateFormat('HH:mm', 'tr_TR').format(syncTime),
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textTertiary,
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
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final bool isSyncing;
  final VoidCallback? onTap;
  const _SyncButton({
    required this.icon,
    required this.label,
    required this.caption,
    required this.isSyncing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: isSyncing || disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceDivider),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: disabled ? AppColors.surfaceLight : AppColors.infoBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 18,
                color: disabled ? AppColors.textTertiary : AppColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: disabled
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    caption,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSyncing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.navy,
                  strokeWidth: 2,
                ),
              )
            else if (!disabled)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/sap_models.dart';
import 'package:assetflow_mobile/features/sap/providers/sap_provider.dart';

class SapScreen extends ConsumerWidget {
  const SapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAP Entegrasyonu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(sapProvider.notifier).refresh(),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sapProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ConnectionCard(state: state),
            const SizedBox(height: 16),
            _SyncCard(
              title: 'Personel Aktarımı',
              icon: Icons.people_alt_outlined,
              description: 'SAP HR modülünden personel verilerini içe aktarır.',
              isSyncing: state.isSyncingEmployees,
              lastResult: state.lastEmployeeSync,
              error: state.employeeSyncError,
              onSync: () => ref.read(sapProvider.notifier).syncEmployees(),
              resultLabels: const ('Yeni Personel', 'Güncellenen', 'Hata'),
            ),
            const SizedBox(height: 12),
            _SyncCard(
              title: 'Varlık Aktarımı',
              icon: Icons.inventory_2_outlined,
              description:
                  'SAP Asset Management modülünden varlık envanterini içe aktarır.',
              isSyncing: state.isSyncingAssets,
              lastResult: state.lastAssetSync,
              error: state.assetSyncError,
              onSync: () => ref.read(sapProvider.notifier).syncAssets(),
              resultLabels: const ('Yeni Varlık', 'Güncellenen', 'Hata'),
            ),
            const SizedBox(height: 16),
            _BudgetsSection(state: state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Bağlantı Durumu Kartı ───────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final SapState state;
  const _ConnectionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final status = state.connectionStatus;

    if (state.isLoadingStatus) {
      return Shimmer.fromColors(
        baseColor: AppColors.dark800,
        highlightColor: AppColors.dark700,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    final isConnected = status?.isConnected ?? false;
    final isConfigured = status?.isConfigured ?? false;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!isConfigured) {
      statusColor = AppColors.textTertiary;
      statusText = 'Yapılandırılmadı';
      statusIcon = Icons.settings_outlined;
    } else if (isConnected) {
      statusColor = AppColors.success;
      statusText = 'Bağlı';
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = AppColors.error;
      statusText = 'Bağlantı Yok';
      statusIcon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8A800).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'SAP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8A800),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAP Bağlantı Durumu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (status?.version != null)
                  Text(
                    'Sürüm: ${status!.version}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  )
                else
                  const Text(
                    'Backend SAP entegrasyonu gerekli',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Senkronizasyon Kartı ────────────────────────────────────────────────────

class _SyncCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool isSyncing;
  final SapSyncResult? lastResult;
  final String? error;
  final VoidCallback onSync;
  final (String, String, String) resultLabels;

  const _SyncCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.isSyncing,
    required this.lastResult,
    required this.error,
    required this.onSync,
    required this.resultLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFE8A800), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                child: ElevatedButton.icon(
                  onPressed: isSyncing ? null : onSync,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFE8A800,
                    ).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFE8A800),
                    side: const BorderSide(
                      color: Color(0xFFE8A800),
                      width: 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE8A800),
                          ),
                        )
                      : const Icon(Icons.sync, size: 16),
                  label: Text(
                    isSyncing ? 'Aktarılıyor...' : 'Senkronize Et',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Hata mesajı
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Son senkronizasyon sonuçları
          if (lastResult != null) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ResultBadge(
                    label: resultLabels.$1,
                    count: lastResult!.newCount,
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _ResultBadge(
                    label: resultLabels.$2,
                    count: lastResult!.updatedCount,
                    color: AppColors.info,
                  ),
                ),
                Expanded(
                  child: _ResultBadge(
                    label: resultLabels.$3,
                    count: lastResult!.errorCount,
                    color: lastResult!.errorCount > 0
                        ? AppColors.error
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Son aktarım: ${DateFormat('dd.MM.yyyy HH:mm').format(lastResult!.syncTime)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResultBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Bütçe Onayları ─────────────────────────────────────────────────────────

class _BudgetsSection extends StatelessWidget {
  final SapState state;
  const _BudgetsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'BÜTÇE ONAYLARI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (state.isLoadingBudgets)
          _buildBudgetShimmer()
        else if (state.budgetsError != null)
          _buildBudgetError(state.budgetsError!)
        else if (state.budgets.isEmpty)
          _buildEmptyBudgets()
        else
          ...state.budgets.map((b) => _BudgetTile(item: b)),
      ],
    );
  }

  Widget _buildBudgetShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            height: 72,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.dark800,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetError(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.textTertiary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBudgets() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.textTertiary,
              size: 36,
            ),
            SizedBox(height: 8),
            Text(
              'Bekleyen bütçe onayı yok',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final SapBudgetItem item;
  const _BudgetTile({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (item.status) {
      case 'approved':
        statusColor = AppColors.success;
        statusLabel = 'Onaylandı';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusLabel = 'Reddedildi';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.warning;
        statusLabel = 'Bekliyor';
        statusIcon = Icons.schedule;
    }

    final amountStr = NumberFormat('#,##0.00', 'tr_TR').format(item.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.status == 'pending'
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '₺$amountStr',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (item.department != null) ...[
                      const Text(
                        ' · ',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                      Text(
                        item.department!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd.MM.yy').format(item.createdAt),
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
  }
}

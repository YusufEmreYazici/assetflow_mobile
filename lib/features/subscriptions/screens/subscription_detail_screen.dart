import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/subscription_model.dart';
import 'package:assetflow_mobile/features/subscriptions/providers/subscription_provider.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String id;
  const SubscriptionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(subscriptionDetailProvider(id));

    return async.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => context.pop()),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => context.pop()),
        ),
        body: Center(child: Text('Yüklenemedi: $e')),
      ),
      data: (sub) => _SubscriptionDetailView(sub: sub),
    );
  }
}

class _SubscriptionDetailView extends StatelessWidget {
  final Subscription sub;
  const _SubscriptionDetailView({required this.sub});

  Color get _statusColor => switch (sub.subscriptionStatus) {
        'Active' => AppColors.success,
        'Paused' => AppColors.warning,
        'Cancelled' => AppColors.error,
        _ => AppColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => context.pop()),
        title: Text(sub.serviceName,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCostCard(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            if (sub.isRenewingSoon || (sub.daysUntilRenewal ?? 999) <= 30) ...[
              const SizedBox(height: 12),
              _buildRenewalAlert(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.serviceName,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                    if (sub.provider != null)
                      Text(sub.provider!,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(20)),
                child: Text(sub.subscriptionStatusName,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aylık', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      '${sub.monthlyCost.toStringAsFixed(2)} ${sub.currency}',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Yıllık', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      '${sub.effectiveAnnualCost.toStringAsFixed(2)} ${sub.currency}',
                      style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final nextRenewal = sub.nextRenewalDate?.substring(0, 10) ?? '—';
    final rows = <(String, String)>[
      ('Döngü', sub.billingCycleName),
      ('Sonraki Yenileme', nextRenewal),
      ('Otomatik Yenileme', sub.autoRenew ? 'Açık' : 'Kapalı'),
      if (sub.costCenter != null) ('Maliyet Merkezi', sub.costCenter!),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abonelik Bilgileri', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(r.$1, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: Text(r.$2, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
            if (sub.notes != null) ...[
              const Divider(),
              Text('Notlar', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(sub.notes!, style: GoogleFonts.inter(fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRenewalAlert() {
    final days = sub.daysUntilRenewal ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$days gün içinde yenileniyor!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

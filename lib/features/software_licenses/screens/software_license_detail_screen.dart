import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/software_license_model.dart';
import 'package:assetflow_mobile/features/software_licenses/providers/software_license_provider.dart';

class SoftwareLicenseDetailScreen extends ConsumerWidget {
  final String id;
  const SoftwareLicenseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(softwareLicenseDetailProvider(id));

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
      data: (license) => _LicenseDetailView(license: license),
    );
  }
}

class _LicenseDetailView extends StatelessWidget {
  final SoftwareLicense license;
  const _LicenseDetailView({required this.license});

  @override
  Widget build(BuildContext context) {
    final utilPct = license.totalSeats > 0
        ? (license.usedSeats / license.totalSeats).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => context.pop()),
        title: Text(license.productName,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + seat usage card
            _buildSeatCard(utilPct),
            const SizedBox(height: 16),
            // Info card
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatCard(double utilPct) {
    final isOverused = utilPct >= 1.0;
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
              Text('${license.vendor} ${license.productName}',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              _statusChip(),
            ],
          ),
          Text(license.version ?? '', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('${license.usedSeats}',
                        style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800,
                            color: isOverused ? AppColors.error : AppColors.navy)),
                    Text('Kullanılan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('/', style: GoogleFonts.inter(fontSize: 28, color: AppColors.textTertiary)),
              Expanded(
                child: Column(
                  children: [
                    Text('${license.totalSeats}',
                        style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800)),
                    Text('Toplam', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: utilPct,
            backgroundColor: AppColors.surfaceDivider,
            color: utilPct > 0.9 ? AppColors.error : AppColors.navy,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text('${license.availableSeats} koltuk boş · %${(utilPct * 100).round()} kullanımda',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _statusChip() {
    Color color;
    String label;
    if (license.isExpired) {
      color = AppColors.error;
      label = 'Sona Erdi';
    } else if (license.isExpiringSoon) {
      color = AppColors.warning;
      label = '${license.daysUntilExpiry} gün';
    } else {
      color = AppColors.success;
      label = 'Aktif';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final rows = <(String, String)>[
      ('Lisans Türü', license.licenseType),
      ('Birim Fiyat', license.purchasePrice != null ? '${license.purchasePrice!.toStringAsFixed(2)} ${license.currency}' : '—'),
      ('Yenileme Maliyeti', license.renewalCost != null ? '${license.renewalCost!.toStringAsFixed(2)} ${license.currency}' : '—'),
      ('Başlangıç', license.startDate?.substring(0, 10) ?? '—'),
      ('Bitiş', license.expiryDate?.substring(0, 10) ?? '—'),
      ('Otomatik Yenileme', license.autoRenew ? 'Açık' : 'Kapalı'),
      ('Tedarikçi', license.supplier ?? '—'),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lisans Bilgileri', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(r.$1, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: Text(r.$2, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
            if (license.notes != null) ...[
              const Divider(),
              Text('Notlar', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(license.notes!, style: GoogleFonts.inter(fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

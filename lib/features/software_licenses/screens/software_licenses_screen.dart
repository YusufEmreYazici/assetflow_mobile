import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/data/models/software_license_model.dart';
import 'package:assetflow_mobile/features/software_licenses/providers/software_license_provider.dart';

class SoftwareLicensesScreen extends ConsumerStatefulWidget {
  const SoftwareLicensesScreen({super.key});

  @override
  ConsumerState<SoftwareLicensesScreen> createState() => _SoftwareLicensesScreenState();
}

class _SoftwareLicensesScreenState extends ConsumerState<SoftwareLicensesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(softwareLicenseListProvider);
    final items = state.result?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Yazılım Lisansları',
            subtitle: state.result?.totalCount != null && state.result!.totalCount > 0
                ? '${state.result!.totalCount} lisans'
                : null,
            onBack: () => context.pop(),
          ),
          _buildSearchBar(),
          Expanded(
            child: state.isLoading && items.isEmpty
                ? _buildShimmer()
                : state.error != null && items.isEmpty
                    ? _buildErrorState(state.error!)
                    : items.isEmpty
                        ? const EmptyState(
                            icon: Icons.security_outlined,
                            title: 'Yazılım lisansı bulunamadı',
                            description: 'Henüz kayıtlı yazılım lisansı yok.',
                          )
                        : RefreshIndicator(
                            color: AppColors.navy,
                            onRefresh: () =>
                                ref.read(softwareLicenseListProvider.notifier).load(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              itemCount: items.length,
                              itemBuilder: (ctx, i) => _LicenseRow(license: items[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceWhite,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: 7,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Lisans ara...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                    ref.read(softwareLicenseListProvider.notifier).setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.navy, width: 2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        onChanged: (v) {
          setState(() {});
          ref.read(softwareLicenseListProvider.notifier).setSearch(v);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(softwareLicenseListProvider.notifier).load(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseRow extends StatelessWidget {
  final SoftwareLicense license;
  const _LicenseRow({required this.license});

  @override
  Widget build(BuildContext context) {
    final utilPct = license.totalSeats > 0
        ? (license.usedSeats / license.totalSeats).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = license.isExpired
        ? AppColors.error
        : license.isExpiringSoon
            ? AppColors.warning
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.surfaceInputBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.navy.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.security_outlined, color: AppColors.navy),
        ),
        title: Text('${license.vendor} ${license.productName}',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${license.licenseType} · ${license.usedSeats}/${license.totalSeats} koltuk',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: utilPct,
              backgroundColor: AppColors.surfaceDivider,
              color: utilPct > 0.9 ? AppColors.error : AppColors.navy,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            license.isExpired ? 'Sona Erdi' : license.isExpiringSoon ? 'Yakında' : 'Aktif',
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        onTap: () => context.push('/software-licenses/${license.id}'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state.result?.totalCount ?? 0),
            _buildSearchBar(),
            Expanded(
              child: state.isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))
                  : items.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.navy,
                          onRefresh: () => ref.read(softwareLicenseListProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) => _LicenseRow(license: items[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: AppColors.navy,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yazılım Lisansları',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                if (count > 0)
                  Text('$count lisans',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Lisans ara...',
          hintStyle: GoogleFonts.inter(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(softwareLicenseListProvider.notifier).setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) => ref.read(softwareLicenseListProvider.notifier).setSearch(v),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Yazılım lisansı bulunamadı',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
          child: Text(
            license.isExpired ? 'Sona Erdi' : license.isExpiringSoon ? 'Yakında' : 'Aktif',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        onTap: () => context.push('/software-licenses/${license.id}'),
      ),
    );
  }
}

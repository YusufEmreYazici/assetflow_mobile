import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/data/models/consumable_model.dart';
import 'package:assetflow_mobile/features/consumables/providers/consumable_provider.dart';

class ConsumablesScreen extends ConsumerStatefulWidget {
  const ConsumablesScreen({super.key});

  @override
  ConsumerState<ConsumablesScreen> createState() => _ConsumablesScreenState();
}

class _ConsumablesScreenState extends ConsumerState<ConsumablesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(consumableListProvider);
    final items = state.result?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Sarf Malzemeleri',
            subtitle:
                state.result?.totalCount != null && state.result!.totalCount > 0
                ? '${state.result!.totalCount} malzeme'
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
                    icon: Icons.inventory_2_outlined,
                    title: 'Sarf malzeme bulunamadı',
                    description: 'Henüz kayıtlı sarf malzeme yok.',
                  )
                : RefreshIndicator(
                    color: AppColors.navy,
                    onRefresh: () => ref
                        .read(consumableListProvider.notifier)
                        .load(reset: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) => _ConsumableRow(item: items[i]),
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
          height: 72,
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
          hintText: 'Malzeme ara...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.textTertiary,
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                    ref.read(consumableListProvider.notifier).setSearch('');
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        onChanged: (v) {
          setState(() {});
          ref.read(consumableListProvider.notifier).setSearch(v);
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
            const Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(consumableListProvider.notifier).load(reset: true),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumableRow extends StatelessWidget {
  final Consumable item;
  const _ConsumableRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.surfaceInputBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.isLowStock
                ? AppColors.warning.withAlpha(30)
                : AppColors.success.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: item.isLowStock ? AppColors.warning : AppColors.success,
          ),
        ),
        title: Text(
          item.name,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${item.category} · ${item.storageLocation ?? item.locationName ?? '—'}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.isLowStock ? AppColors.warning : AppColors.success,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${item.currentStock} ${item.unit}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (item.isLowStock)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Düşük!',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => context.push('/consumables/${item.id}'),
      ),
    );
  }
}

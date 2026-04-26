import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state.result?.totalCount ?? 0),
            _buildSearchBar(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(state.error!, style: const TextStyle(color: AppColors.error)),
              ),
            Expanded(
              child: state.isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))
                  : items.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.navy,
                          onRefresh: () => ref.read(consumableListProvider.notifier).load(reset: true),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) => _ConsumableRow(item: items[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: AppColors.navy,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sarf Malzemeleri',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                if (count > 0)
                  Text('$count malzeme',
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
          hintText: 'Malzeme ara...',
          hintStyle: GoogleFonts.inter(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(consumableListProvider.notifier).setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) => ref.read(consumableListProvider.notifier).setSearch(v),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Sarf malzeme bulunamadı',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
        ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.isLowStock ? AppColors.warning.withAlpha(30) : AppColors.success.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: item.isLowStock ? AppColors.warning : AppColors.success,
          ),
        ),
        title: Text(item.name,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('${item.category} · ${item.storageLocation ?? item.locationName ?? '—'}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
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
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            if (item.isLowStock)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Düşük!',
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        onTap: () => context.push('/consumables/${item.id}'),
      ),
    );
  }
}

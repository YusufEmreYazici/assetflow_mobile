import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/consumable_model.dart';
import 'package:assetflow_mobile/features/consumables/providers/consumable_provider.dart';

class ConsumableDetailScreen extends ConsumerWidget {
  final String id;
  const ConsumableDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consumableDetailProvider(id));

    ref.listen(consumableDetailProvider(id), (prev, next) {
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(consumableDetailProvider(id).notifier).clearMessages();
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(consumableDetailProvider(id).notifier).clearMessages();
      }
    });

    if (state.isLoading && state.consumable == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => context.pop()),
          title: Text('Yükleniyor...', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)),
      );
    }

    final item = state.consumable;
    if (item == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceLight,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => context.pop()),
        ),
        body: Center(child: Text('Bulunamadı', style: GoogleFonts.inter(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white), onPressed: () => context.pop()),
        title: Text(item.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Stok Girişi',
            onPressed: () => _showStockDialog(context, ref, item, isIn: true),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
            tooltip: 'Stok Çıkışı',
            onPressed: () => _showStockDialog(context, ref, item, isIn: false),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: () => ref.read(consumableDetailProvider(id).notifier).load(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock card
              _StockCard(item: item),
              const SizedBox(height: 16),

              // Info card
              _InfoCard(item: item),
              const SizedBox(height: 16),

              // Movement history
              _MovementsCard(movements: state.movements),
            ],
          ),
        ),
      ),
    );
  }

  void _showStockDialog(BuildContext context, WidgetRef ref, Consumable item, {required bool isIn}) {
    final qtyCtrl = TextEditingController(text: '1');
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isIn ? 'Stok Girişi' : 'Stok Çıkışı',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Mevcut: ${item.currentStock} ${item.unit}',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Miktar',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Sebep (isteğe bağlı)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIn ? AppColors.success : AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  if (qty <= 0) return;
                  Navigator.of(ctx).pop();
                  final notifier = ref.read(consumableDetailProvider(id).notifier);
                  if (isIn) {
                    await notifier.stockIn(qty, reasonCtrl.text.isEmpty ? null : reasonCtrl.text);
                  } else {
                    await notifier.stockOut(qty, reasonCtrl.text.isEmpty ? null : reasonCtrl.text);
                  }
                },
                child: Text(isIn ? 'Giriş Kaydet' : 'Çıkış Kaydet',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final Consumable item;
  const _StockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: item.isLowStock ? AppColors.warning.withAlpha(20) : AppColors.success.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.isLowStock ? AppColors.warning : AppColors.success, width: 1.5),
      ),
      child: Column(
        children: [
          Text('Mevcut Stok',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('${item.currentStock}',
              style: GoogleFonts.inter(
                  fontSize: 56, fontWeight: FontWeight.w800,
                  color: item.isLowStock ? AppColors.warning : AppColors.success)),
          Text(item.unit, style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
          if (item.isLowStock) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(20)),
              child: Text('Stok Düşük!',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StockStat(label: 'Min', value: '${item.minStock}'),
              Container(width: 1, height: 30, color: AppColors.surfaceDivider),
              _StockStat(label: 'Yeniden Sipariş', value: '${item.reorderPoint}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockStat extends StatelessWidget {
  final String label;
  final String value;
  const _StockStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Consumable item;
  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bilgiler', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _kv('Kategori', item.category),
            if (item.brand != null) _kv('Marka', item.brand!),
            if (item.model != null) _kv('Model', item.model!),
            if (item.partNumber != null) _kv('Part No', item.partNumber!),
            _kv('Depo', item.storageLocation ?? item.locationName ?? '—'),
            if (item.supplier != null) _kv('Tedarikçi', item.supplier!),
            if (item.unitCost != null)
              _kv('Birim Maliyet', '${item.unitCost!.toStringAsFixed(2)} ${item.currency}'),
            if (item.notes != null) _kv('Notlar', item.notes!),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _MovementsCard extends StatelessWidget {
  final List<StockMovement> movements;
  const _MovementsCard({required this.movements});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stok Hareketleri', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (movements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Henüz hareket yok',
                      style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ),
              )
            else
              ...movements.map((mv) => _MovementRow(movement: mv)),
          ],
        ),
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  final StockMovement movement;
  const _MovementRow({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isIn = movement.type == 'In';
    final isAdjust = movement.type == 'Adjust';
    final color = isIn ? AppColors.success : isAdjust ? AppColors.info : AppColors.error;
    final sign = isIn ? '+' : isAdjust ? '~' : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(
              isIn ? Icons.add : isAdjust ? Icons.tune : Icons.remove,
              color: color, size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.reason ?? movement.typeName,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(
                  '${movement.stockBefore} → ${movement.stockAfter}  ·  '
                  '${DateTime.parse(movement.createdAt).toLocal().toString().substring(0, 16)}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '$sign${movement.quantity}',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

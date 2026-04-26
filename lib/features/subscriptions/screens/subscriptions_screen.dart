import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/subscription_model.dart';
import 'package:assetflow_mobile/features/subscriptions/providers/subscription_provider.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionListProvider);
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
                          onRefresh: () => ref.read(subscriptionListProvider.notifier).load(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) => _SubscriptionRow(sub: items[i]),
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
                Text('Abonelikler',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                if (count > 0)
                  Text('$count abonelik',
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
          hintText: 'Abonelik ara...',
          hintStyle: GoogleFonts.inter(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) => ref.read(subscriptionListProvider.notifier).setSearch(v),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text('Abonelik bulunamadı',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  final Subscription sub;
  const _SubscriptionRow({required this.sub});

  Color get _statusColor => switch (sub.subscriptionStatus) {
        'Active' => AppColors.success,
        'Paused' => AppColors.warning,
        'Cancelled' => AppColors.error,
        _ => AppColors.textTertiary,
      };

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
            color: _statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.subscriptions_outlined, color: _statusColor),
        ),
        title: Text(sub.serviceName,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${sub.provider ?? '—'} · ${sub.billingCycleName}',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${sub.monthlyCost.toStringAsFixed(0)} ${sub.currency}/ay',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(6)),
              child: Text(
                sub.subscriptionStatusName,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        onTap: () => context.push('/subscriptions/${sub.id}'),
      ),
    );
  }
}

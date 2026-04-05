import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/locations/providers/location_provider.dart';
import 'package:assetflow_mobile/features/locations/screens/location_form_screen.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lokasyonu Sil'),
        content: Text('"$name" lokasyonunu silmek istediginize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(locationProvider.notifier).deleteLocation(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success ? 'Lokasyon silindi' : 'Hata olustu'),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context, WidgetRef ref, {String? locationId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LocationFormScreen(locationId: locationId)),
    );
    if (result == true) {
      ref.read(locationProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lokasyonlar')),
      body: state.isLoading
          ? _buildShimmer()
          : state.error != null
              ? _buildError(context, ref, state.error!)
              : state.locations.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.primary500,
                      backgroundColor: AppColors.dark800,
                      onRefresh: () => ref.read(locationProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.locations.length,
                        itemBuilder: (context, index) {
                          final loc = state.locations[index];
                          return Dismissible(
                            key: ValueKey(loc.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              _confirmDelete(context, ref, loc.id, loc.name);
                              return false;
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _navigateToForm(context, ref, locationId: loc.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary600.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.location_on, color: AppColors.primary400, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loc.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                            ),
                                            if (loc.address != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                loc.address!,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                if (loc.building != null) _infoChip(Icons.apartment, loc.building!),
                                                if (loc.floor != null) _infoChip(Icons.layers, loc.floor!),
                                                if (loc.room != null) _infoChip(Icons.meeting_room, loc.room!),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.computer, size: 12, color: AppColors.textTertiary),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${loc.deviceCount}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textTertiary),
          const SizedBox(width: 2),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 90,
          decoration: BoxDecoration(color: AppColors.dark800, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(locationProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text('Henuz lokasyon eklenmemis', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

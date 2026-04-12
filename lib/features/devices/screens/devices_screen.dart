import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_list_item.dart';
import 'package:assetflow_mobile/features/devices/screens/device_form_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/device_import_screen.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(deviceProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(deviceProvider.notifier).refresh();
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cihazi Sil'),
        content: Text('"$name" cihazini silmek istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await ref.read(deviceProvider.notifier).deleteDevice(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Cihaz basariyla silindi'
                        : 'Cihaz silinirken hata olustu'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceFormScreen()),
    );
    if (result == true) ref.read(deviceProvider.notifier).refresh();
  }

  Future<void> _navigateToImport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeviceImportScreen()),
    );
    if (result == true) ref.read(deviceProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihazlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            tooltip: 'CSV İçe Aktar',
            onPressed: _navigateToImport,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToForm,
          ),
        ],
      ),
      body: state.isLoading
          ? _buildShimmer()
          : state.error != null
              ? _buildError(state.error!)
              : state.devices.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: AppColors.primary500,
                      backgroundColor: AppColors.dark800,
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.devices.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.devices.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary500,
                                ),
                              ),
                            );
                          }
                          final device = state.devices[index];
                          return Dismissible(
                            key: ValueKey(device.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              _confirmDelete(device.id, device.name);
                              return false;
                            },
                            child: DeviceListItem(
                              device: device,
                              onTap: () {
                                context.go('/devices/${device.id}');
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(error,
              style: const TextStyle(color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(deviceProvider.notifier).refresh(),
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
          Icon(Icons.devices, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'Henuz cihaz eklenmemis',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yeni cihaz eklemek icin + butonunu kullanin',
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

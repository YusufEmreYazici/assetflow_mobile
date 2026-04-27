import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';
import 'package:assetflow_mobile/core/widgets/connectivity_wrapper.dart';
import 'package:assetflow_mobile/features/devices/providers/bulk_selection_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/favorites_provider.dart';

class BulkActionBar extends ConsumerStatefulWidget {
  final List<String> filteredDeviceIds;

  const BulkActionBar({super.key, required this.filteredDeviceIds});

  @override
  ConsumerState<BulkActionBar> createState() => _BulkActionBarState();
}

class _BulkActionBarState extends ConsumerState<BulkActionBar> {
  bool _isBusy = false;
  String _busyText = '';

  void _warnOffline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Çevrimiçi olduğunuzda bu işlemi yapabilirsiniz'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _changeStatus() async {
    if (!ref.read(connectivityProvider)) {
      _warnOffline();
      return;
    }
    final selected = ref.read(bulkSelectionProvider).selectedIds.toList();
    if (selected.isEmpty) return;

    final newStatus = await _showStatusPicker();
    if (newStatus == null || !mounted) return;

    final label = deviceStatusLabels[newStatus] ?? '$newStatus';
    setState(() {
      _isBusy = true;
      _busyText = '0/${selected.length} güncelleniyor…';
    });

    int done = 0;
    final svc = DeviceService();
    for (final id in selected) {
      try {
        await svc.update(id, {'status': newStatus});
      } catch (_) {}
      done++;
      if (mounted)
        setState(() => _busyText = '$done/${selected.length} güncelleniyor…');
    }

    if (!mounted) return;
    setState(() => _isBusy = false);
    ref.read(deviceProvider.notifier).refresh();
    ref.read(bulkSelectionProvider.notifier).exit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selected.length} cihazın durumu "$label" yapıldı'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<int?> _showStatusPicker() async {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Yeni Durum',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...deviceStatusLabels.entries.map(
              (e) => ListTile(
                title: Text(e.value, style: GoogleFonts.inter(fontSize: 14)),
                onTap: () => Navigator.pop(ctx, e.key),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLocation() async {
    if (!ref.read(connectivityProvider)) {
      _warnOffline();
      return;
    }
    final selected = ref.read(bulkSelectionProvider).selectedIds.toList();
    if (selected.isEmpty) return;

    // Load locations
    String? locationId;
    String? locationName;
    try {
      final result = await LocationService().getAll(page: 1, pageSize: 100);
      if (!mounted) return;
      final picked = await _showLocationPicker(result.items);
      if (picked == null || !mounted) return;
      locationId = picked.$1;
      locationName = picked.$2;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasyonlar yüklenemedi'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isBusy = true;
      _busyText = '0/${selected.length} güncelleniyor…';
    });

    int done = 0;
    final svc = DeviceService();
    for (final id in selected) {
      try {
        await svc.update(id, {'locationId': locationId});
      } catch (_) {}
      done++;
      if (mounted)
        setState(() => _busyText = '$done/${selected.length} güncelleniyor…');
    }

    if (!mounted) return;
    setState(() => _isBusy = false);
    ref.read(deviceProvider.notifier).refresh();
    ref.read(bulkSelectionProvider.notifier).exit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selected.length} cihaz "$locationName" lokasyonuna taşındı',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<(String, String)?> _showLocationPicker(List<dynamic> locations) async {
    return showModalBottomSheet<(String, String)>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scroll) => Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Lokasyon Seç',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: locations.length,
                  itemBuilder: (_, i) {
                    final loc = locations[i];
                    return ListTile(
                      leading: const Icon(
                        Icons.place_outlined,
                        color: AppColors.navy,
                      ),
                      title: Text(
                        loc.name as String,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      onTap: () => Navigator.pop(ctx, (
                        loc.id as String,
                        loc.name as String,
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteSelected() async {
    if (!ref.read(connectivityProvider)) {
      _warnOffline();
      return;
    }
    final selected = ref.read(bulkSelectionProvider).selectedIds.toList();
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cihazları Sil',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${selected.length} cihazı silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'İptal',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              'Sil',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isBusy = true;
      _busyText = '0/${selected.length} siliniyor…';
    });

    int done = 0;
    final notifier = ref.read(deviceProvider.notifier);
    for (final id in selected) {
      await notifier.deleteDevice(id);
      done++;
      if (mounted)
        setState(() => _busyText = '$done/${selected.length} siliniyor…');
    }

    if (!mounted) return;
    setState(() => _isBusy = false);
    ref.read(bulkSelectionProvider.notifier).exit();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selected.length} cihaz silindi'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreMenu() {
    final selectionNotifier = ref.read(bulkSelectionProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.select_all, color: AppColors.navy),
              title: Text(
                'Tümünü Seç (${widget.filteredDeviceIds.length})',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              onTap: () {
                selectionNotifier.selectAll(widget.filteredDeviceIds);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_border, color: AppColors.warning),
              title: Text(
                'Favorilere Ekle',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              onTap: () {
                final ids = ref.read(bulkSelectionProvider).selectedIds;
                ref.read(favoritesProvider.notifier).addAll(ids);
                Navigator.pop(ctx);
                selectionNotifier.exit();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${ids.length} cihaz favorilere eklendi'),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Seçilenleri Sil',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deleteSelected();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectionState = ref.watch(bulkSelectionProvider);
    final count = selectionState.count;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: _isBusy
          ? Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _busyText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Text(
                  '$count seçili',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.swap_horiz_rounded,
                  tooltip: 'Durum Değiştir',
                  onTap: _changeStatus,
                ),
                _ActionBtn(
                  icon: Icons.place_outlined,
                  tooltip: 'Lokasyon Değiştir',
                  onTap: _changeLocation,
                ),
                _ActionBtn(
                  icon: Icons.download_outlined,
                  tooltip: 'Excel İndir',
                  onTap: () => context.push('/excel-export'),
                ),
                _ActionBtn(
                  icon: Icons.more_vert,
                  tooltip: 'Daha Fazla',
                  onTap: _showMoreMenu,
                ),
              ],
            ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }
}

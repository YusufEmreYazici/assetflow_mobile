import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/features/locations/providers/location_provider.dart';
import 'package:assetflow_mobile/features/locations/screens/location_form_screen.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  bool _hierarchyMode = true;

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lokasyonu Sil'),
        content: Text('"$name" lokasyonunu silmek istediginize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Iptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(locationProvider.notifier)
                  .deleteLocation(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Lokasyon silindi' : 'Hata olustu'),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.error,
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

  Future<void> _navigateToForm({String? locationId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationFormScreen(locationId: locationId),
      ),
    );
    if (result == true) ref.read(locationProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasyonlar'),
        actions: [
          IconButton(
            icon: Icon(
              _hierarchyMode ? Icons.list : Icons.account_tree_outlined,
            ),
            tooltip: _hierarchyMode ? 'Liste görünümü' : 'Hiyerarşi görünümü',
            onPressed: () => setState(() => _hierarchyMode = !_hierarchyMode),
          ),
        ],
      ),
      body: state.isLoading
          ? _buildShimmer()
          : state.error != null
          ? _buildError(state.error!)
          : state.locations.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: AppColors.primary500,
              backgroundColor: AppColors.dark800,
              onRefresh: () => ref.read(locationProvider.notifier).refresh(),
              child: _hierarchyMode
                  ? _buildHierarchy(state.locations)
                  : _buildFlatList(state.locations),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── Hiyerarşi Görünümü ───��────────────────────────────────
  Widget _buildHierarchy(List<Location> locations) {
    // Group: building → floor → [locations]
    final Map<String, Map<String, List<Location>>> tree = {};
    const ungrouped = '—';

    for (final loc in locations) {
      final building = loc.building ?? ungrouped;
      final floor = loc.floor ?? ungrouped;
      tree.putIfAbsent(building, () => {});
      tree[building]!.putIfAbsent(floor, () => []);
      tree[building]![floor]!.add(loc);
    }

    final buildings = tree.keys.toList()
      ..sort((a, b) {
        if (a == ungrouped) return 1;
        if (b == ungrouped) return -1;
        return a.compareTo(b);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: buildings.map((building) {
        final floors = tree[building]!;
        final totalDevices = floors.values
            .expand((locs) => locs)
            .fold<int>(0, (sum, l) => sum + l.deviceCount);

        // If only one floor and it's ungrouped, flatten to building level
        final floorKeys = floors.keys.toList()
          ..sort((a, b) {
            if (a == ungrouped) return 1;
            if (b == ungrouped) return -1;
            return a.compareTo(b);
          });

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.apartment,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              title: Text(
                building == ungrouped ? 'Bilinmeyen Bina' : building,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                '${floors.values.expand((l) => l).length} lokasyon · $totalDevices cihaz',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _deviceCountBadge(totalDevices),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
              children: floorKeys.map((floor) {
                final locs = floors[floor]!;
                final floorDevices = locs.fold<int>(
                  0,
                  (sum, l) => sum + l.deviceCount,
                );

                if (floor == ungrouped && floorKeys.length == 1) {
                  // No floor grouping — show locations directly
                  return Column(
                    children: locs
                        .map((l) => _locationTile(l, indent: 16))
                        .toList(),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        childrenPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.layers_outlined,
                          color: AppColors.primary400,
                          size: 18,
                        ),
                        title: Text(
                          floor == ungrouped ? 'Kat belirtilmemiş' : floor,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _deviceCountBadge(floorDevices, small: true),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ],
                        ),
                        children: locs
                            .map((l) => _locationTile(l, indent: 12))
                            .toList(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _locationTile(Location loc, {double indent = 0}) {
    return Dismissible(
      key: ValueKey(loc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async {
        _confirmDelete(loc.id, loc.name);
        return false;
      },
      child: InkWell(
        onTap: () => _navigateToForm(locationId: loc.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.only(
            left: indent + 8,
            right: 12,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (loc.room != null)
                      Text(
                        'Oda: ${loc.room}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              _deviceCountBadge(loc.deviceCount, small: true),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Düz Liste Görünümü ────────────────────────────────────
  Widget _buildFlatList(List<Location> locations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final loc = locations[index];
        return Dismissible(
          key: ValueKey(loc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            _confirmDelete(loc.id, loc.name);
            return false;
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToForm(locationId: loc.id),
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
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary400,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (loc.address != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              loc.address!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (loc.building != null)
                                _infoChip(Icons.apartment, loc.building!),
                              if (loc.floor != null)
                                _infoChip(Icons.layers, loc.floor!),
                              if (loc.room != null)
                                _infoChip(Icons.meeting_room, loc.room!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _deviceCountBadge(loc.deviceCount),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Yardımcı widgetlar ────────────────────────────────────
  Widget _deviceCountBadge(int count, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.computer,
            size: small ? 10 : 12,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
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
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 140,
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
          const Text(
            'Henuz lokasyon eklenmemis',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

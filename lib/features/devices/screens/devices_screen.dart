import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/barcode_scanner_service.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/bulk_action_bar.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/models/device_filter.dart';
import 'package:assetflow_mobile/features/devices/providers/bulk_selection_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/device_filter_provider.dart';
import 'package:assetflow_mobile/core/widgets/connectivity_wrapper.dart';
import 'package:assetflow_mobile/core/widgets/animated_list_item.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/widgets/advanced_filter_sheet.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_list_skeleton.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_row.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  final bool returnMode;
  final String? initialSearch;
  const DevicesScreen({super.key, this.returnMode = false, this.initialSearch});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _filterStatus;
  bool _fabVisible = true;

  static const _statusFilters = [
    (null, 'Tümü'),
    (0,    'Aktif'),
    (1,    'Depoda'),
    (2,    'Bakımda'),
    (3,    'Emekli'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    if (widget.returnMode) _filterStatus = 0;
    if (widget.initialSearch != null) {
      _searchCtrl.text = widget.initialSearch!;
      _query = widget.initialSearch!.toLowerCase();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(deviceProvider.notifier).loadMore();
    }
    final scrollingDown = _scrollCtrl.position.userScrollDirection.name == 'reverse';
    final scrollingUp = _scrollCtrl.position.userScrollDirection.name == 'forward';
    if (scrollingDown && _fabVisible) setState(() => _fabVisible = false);
    if (scrollingUp && !_fabVisible) setState(() => _fabVisible = true);
  }

  List<Device> _applyLocalFilters(List<Device> base) {
    return base.where((d) {
      if (_filterStatus != null && d.status != _filterStatus) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!d.name.toLowerCase().contains(q) &&
            !(d.assetCode ?? '').toLowerCase().contains(q) &&
            !(d.assignedTo ?? '').toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: const AdvancedFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceProvider);
    final advFiltered = ref.watch(filteredDevicesProvider);
    final filtered = _applyLocalFilters(advFiltered);
    final advFilter = ref.watch(deviceFilterProvider);
    final presets = ref.watch(filterPresetsProvider);
    final selectionState = ref.watch(bulkSelectionProvider);
    final inSelection = selectionState.isActive;
    final isOnline = ref.watch(connectivityProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      bottomNavigationBar: inSelection
          ? BulkActionBar(filteredDeviceIds: filtered.map((d) => d.id).toList())
          : null,
      floatingActionButton: inSelection
          ? null
          : AnimatedScale(
              scale: _fabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Tooltip(
                message: isOnline ? '' : 'Çevrimiçi olduğunuzda yapabilirsiniz',
                child: FloatingActionButton(
                  onPressed: isOnline ? () {
                    HapticService.medium();
                    context.push('/devices/new');
                  } : null,
                  backgroundColor: isOnline ? AppColors.navy : AppColors.textTertiary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ),
      body: Column(
        children: [
          // Header — changes when selection mode is active
          inSelection
              ? Container(
                  color: AppColors.navy,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 14,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: 18,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(bulkSelectionProvider.notifier).exit(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${selectionState.count} seçili',
                          style: GoogleFonts.inter(
                            fontSize: 19, fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : PageHeader(
                  title: 'Cihazlar',
                  subtitle: '${filtered.length} CİHAZ',
                  showMenu: true,
                  action: Tooltip(
                    message: isOnline ? '' : 'Çevrimiçi olduğunuzda yapabilirsiniz',
                    child: GestureDetector(
                      onTap: isOnline ? () => context.push('/devices/new') : null,
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? Colors.white.withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, size: 18,
                            color: isOnline ? Colors.white : Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
          if (widget.returnMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.infoBg,
                border: Border(bottom: BorderSide(color: AppColors.info)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text('İade edilecek cihazı seçin',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.info)),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                // Search bar + filter icon
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Cihaz, kod, personel ara…',
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary),
                            filled: true,
                            fillColor: AppColors.surfaceWhite,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16, color: AppColors.textTertiary),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.qr_code_scanner, size: 18, color: AppColors.textTertiary),
                                    tooltip: 'QR / Barkod Tara',
                                    onPressed: () async {
                                      final code = await BarcodeScannerService.scanBarcode(context);
                                      if (code != null && mounted) {
                                        _searchCtrl.text = code;
                                        setState(() => _query = code.toLowerCase());
                                      }
                                    },
                                  ),
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter button with active count badge
                      Semantics(
                        label: 'Filtrele',
                        button: true,
                        child: GestureDetector(
                        onTap: _openFilterSheet,
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: advFilter.activeCount > 0 ? AppColors.navy : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: advFilter.activeCount > 0 ? AppColors.navy : AppColors.surfaceInputBorder,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: advFilter.activeCount > 0 ? Colors.white : AppColors.textSecondary,
                              ),
                              if (advFilter.activeCount > 0)
                                Positioned(
                                  top: -4, right: -4,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${advFilter.activeCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),

                // Status filter chips
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    itemCount: _statusFilters.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final (status, label) = _statusFilters[i];
                      final active = _filterStatus == status;
                      return GestureDetector(
                        onTap: () {
                          HapticService.selection();
                          setState(() => _filterStatus = status);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: active ? AppColors.navy : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: active ? AppColors.navy : AppColors.surfaceInputBorder),
                          ),
                          child: Text(label, style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: active ? Colors.white : AppColors.textSecondary,
                          )),
                        ),
                      );
                    },
                  ),
                ),

                // Preset chips (T6)
                if (presets.isNotEmpty)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      itemCount: presets.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final preset = presets[i];
                        return GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            ref.read(deviceFilterProvider.notifier).state = preset.filter;
                          },
                          onLongPress: () => _showPresetDeleteMenu(context, preset.id, preset.name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.push_pin_outlined, size: 11, color: AppColors.primary600),
                                const SizedBox(width: 4),
                                Text(preset.name, style: GoogleFonts.inter(
                                  fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary700,
                                )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Active filter summary strip
                if (advFilter.activeCount > 0)
                  GestureDetector(
                    onTap: () => ref.read(deviceFilterProvider.notifier).state = const DeviceFilter(),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.infoBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.info.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt_outlined, size: 13, color: AppColors.navy),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${advFilter.activeCount} filtre aktif',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.navy, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.close, size: 13, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),

                // Device list
                Expanded(
                  child: state.isLoading && state.devices.isEmpty
                      ? const SingleChildScrollView(child: DeviceListSkeleton())
                      : filtered.isEmpty
                          ? _buildEmptyState(state)
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                              itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i == filtered.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2)),
                                  );
                                }
                                final d = filtered[i];
                                final isSelected = selectionState.selectedIds.contains(d.id);
                                final rowWidget = Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: i == 0
                                        ? const BorderRadius.vertical(top: Radius.circular(AppRadius.md))
                                        : i == filtered.length - 1
                                            ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.md))
                                            : BorderRadius.zero,
                                  ),
                                  child: DeviceRow(
                                    device: d,
                                    isLast: i == filtered.length - 1,
                                    selectionMode: inSelection,
                                    isSelected: isSelected,
                                    onTap: inSelection
                                        ? () => ref.read(bulkSelectionProvider.notifier).toggle(d.id)
                                        : () => context.push('/devices/${d.id}'),
                                    onLongPress: inSelection
                                        ? null
                                        : () {
                                            ref.read(bulkSelectionProvider.notifier).enter();
                                            ref.read(bulkSelectionProvider.notifier).toggle(d.id);
                                          },
                                  ),
                                );
                                if (i < 10) {
                                  return AnimatedListItem(index: i, child: rowWidget);
                                }
                                return rowWidget;
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DeviceListState state) {
    final hasFilter = _filterStatus != null || _query.isNotEmpty || ref.read(deviceFilterProvider) != const DeviceFilter();
    if (hasFilter) {
      return EmptyState.filterNoResults(
        onClearFilter: () {
          setState(() {
            _filterStatus = null;
            _query = '';
            _searchCtrl.clear();
          });
          ref.read(deviceFilterProvider.notifier).state = const DeviceFilter();
        },
      );
    }
    if (_query.isNotEmpty) {
      return EmptyState.noSearchResults(query: _query);
    }
    return EmptyState.noDevices(
      onAddDevice: () => context.push('/devices/new'),
    );
  }

  void _showPresetDeleteMenu(BuildContext context, String id, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('"$name" presetini sil', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.error,
              )),
              onTap: () {
                ref.read(filterPresetsProvider.notifier).remove(id);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

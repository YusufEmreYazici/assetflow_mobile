import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_row.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _filterStatus; // null = all

  static const _filters = [
    (null,  'Tümü'),
    (0,     'Aktif'),
    (1,     'Depoda'),
    (2,     'Bakımda'),
    (3,     'Emekli'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
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
  }

  List<Device> _filtered(List<Device> all) {
    return all.where((d) {
      if (_filterStatus != null && d.status != _filterStatus) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final name = d.name.toLowerCase();
        final code = (d.assetCode ?? '').toLowerCase();
        final assignee = (d.assignedTo ?? '').toLowerCase();
        if (!name.contains(q) && !code.contains(q) && !assignee.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceProvider);
    final filtered = _filtered(state.devices);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Cihazlar',
            subtitle: '${filtered.length} CİHAZ',
            onBack: () => Scaffold.maybeOf(context)?.openDrawer(),
            action: GestureDetector(
              onTap: () => context.push('/devices/new'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                          : null,
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
                  ),
                ),
                // Filter chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final (status, label) = _filters[i];
                      final active = _filterStatus == status;
                      return GestureDetector(
                        onTap: () => setState(() => _filterStatus = status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.navy : AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: active ? AppColors.navy : AppColors.surfaceInputBorder,
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: active ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // List
                Expanded(
                  child: state.isLoading && state.devices.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.navy, strokeWidth: 2,
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'Sonuç bulunamadı.',
                                style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                              itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (i == filtered.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.navy, strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final d = filtered[i];
                                return Container(
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
                                    onTap: () => context.push('/devices/${d.id}'),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/devices/new'),
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }
}

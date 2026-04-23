import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/models/device_filter.dart';
import 'package:assetflow_mobile/features/devices/providers/device_filter_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';

class AdvancedFilterSheet extends ConsumerStatefulWidget {
  const AdvancedFilterSheet({super.key});

  @override
  ConsumerState<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends ConsumerState<AdvancedFilterSheet> {
  late DeviceFilter _filter;
  final _assigneeCtrl = TextEditingController();
  final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _filter = ref.read(deviceFilterProvider);
    _assigneeCtrl.text = _filter.assigneeQuery ?? '';
  }

  @override
  void dispose() {
    _assigneeCtrl.dispose();
    super.dispose();
  }

  List<String> _uniqueSorted(Iterable<String?> values) {
    final set = values.where((v) => v != null && v.isNotEmpty).cast<String>().toSet().toList();
    set.sort();
    return set;
  }

  Future<void> _pickDateRange({required bool isPurchase}) async {
    final current = isPurchase ? _filter.purchaseDateRange : _filter.warrantyEndRange;
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2035),
      initialDateRange: current != null
          ? DateTimeRange(start: current.start, end: current.end)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: AppColors.navy,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() {
        _filter = isPurchase
            ? _filter.copyWith(purchaseDateRange: DateRange(start: result.start, end: result.end))
            : _filter.copyWith(warrantyEndRange: DateRange(start: result.start, end: result.end));
      });
    }
  }

  Future<void> _savePreset() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Preset Adı', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'örn. Mersin Laptopları',
            hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.navy, width: 2),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: Text('Kaydet', style: GoogleFonts.inter(
              color: AppColors.navy, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(filterPresetsProvider.notifier).add(name, _filter);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preset "$name" kaydedildi'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyFilter() {
    final withAssignee = _filter.copyWith(
      assigneeQuery: _assigneeCtrl.text.trim().isEmpty ? null : _assigneeCtrl.text.trim(),
      clearAssigneeQuery: _assigneeCtrl.text.trim().isEmpty,
    );
    ref.read(deviceFilterProvider.notifier).state = withAssignee;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allDevices = ref.watch(deviceProvider).devices;
    final locations = _uniqueSorted(allDevices.map((d) => d.locationName));
    final brands = _uniqueSorted(allDevices.map((d) => d.brand));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Filtre', style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    )),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filter = const DeviceFilter();
                          _assigneeCtrl.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Sıfırla', style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w500,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 16, color: AppColors.surfaceDivider),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                _SectionTitle('CİHAZ TİPİ'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: deviceTypeLabels.entries.map((e) {
                    final selected = _filter.types.contains(e.key);
                    return _FilterChip(
                      label: e.value,
                      selected: selected,
                      onTap: () {
                        final list = [..._filter.types];
                        selected ? list.remove(e.key) : list.add(e.key);
                        setState(() => _filter = _filter.copyWith(types: list));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _SectionTitle('DURUM'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: deviceStatusLabels.entries.map((e) {
                    final selected = _filter.statuses.contains(e.key);
                    return _FilterChip(
                      label: e.value,
                      selected: selected,
                      onTap: () {
                        final list = [..._filter.statuses];
                        selected ? list.remove(e.key) : list.add(e.key);
                        setState(() => _filter = _filter.copyWith(statuses: list));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                if (locations.isNotEmpty) ...[
                  _SectionTitle('LOKASYON'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: locations.map((loc) {
                      final selected = _filter.locations.contains(loc);
                      return _FilterChip(
                        label: loc,
                        selected: selected,
                        onTap: () {
                          final list = [..._filter.locations];
                          selected ? list.remove(loc) : list.add(loc);
                          setState(() => _filter = _filter.copyWith(locations: list));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                if (brands.isNotEmpty) ...[
                  _SectionTitle('MARKA'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: brands.map((brand) {
                      final selected = _filter.brands.contains(brand);
                      return _FilterChip(
                        label: brand,
                        selected: selected,
                        onTap: () {
                          final list = [..._filter.brands];
                          selected ? list.remove(brand) : list.add(brand);
                          setState(() => _filter = _filter.copyWith(brands: list));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                _SectionTitle('ZİMMETLİ KİŞİ'),
                const SizedBox(height: 8),
                TextField(
                  controller: _assigneeCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Personel adı ara…',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.surfaceInputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.navy, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _SectionTitle('SATIN ALMA TARİHİ'),
                const SizedBox(height: 8),
                _DateRangeRow(
                  range: _filter.purchaseDateRange,
                  dateFormat: _dateFormat,
                  onTap: () => _pickDateRange(isPurchase: true),
                  onClear: () => setState(() => _filter = _filter.copyWith(clearPurchaseDateRange: true)),
                ),
                const SizedBox(height: 16),

                _SectionTitle('GARANTİ BİTİŞ'),
                const SizedBox(height: 8),
                _DateRangeRow(
                  range: _filter.warrantyEndRange,
                  dateFormat: _dateFormat,
                  onTap: () => _pickDateRange(isPurchase: false),
                  onClear: () => setState(() => _filter = _filter.copyWith(clearWarrantyEndRange: true)),
                ),
                const SizedBox(height: 4),
                // 90-day shortcut
                GestureDetector(
                  onTap: () {
                    final now = DateTime.now();
                    setState(() => _filter = _filter.copyWith(
                      warrantyEndRange: DateRange(
                        start: now,
                        end: now.add(const Duration(days: 90)),
                      ),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_outlined, size: 13, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text('90 gün içinde bitenler', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.warning,
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _SectionTitle('DİĞER'),
                const SizedBox(height: 8),
                _SwitchRow(
                  label: 'Sadece Favoriler',
                  value: _filter.onlyFavorites,
                  onChanged: (v) => setState(() => _filter = _filter.copyWith(onlyFavorites: v)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(top: BorderSide(color: AppColors.surfaceDivider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _savePreset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text('Preset Kaydet', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                    )),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Builder(builder: (context) {
                      final count = _filter.copyWith(
                        assigneeQuery: _assigneeCtrl.text.trim().isEmpty
                            ? null
                            : _assigneeCtrl.text.trim(),
                        clearAssigneeQuery: _assigneeCtrl.text.trim().isEmpty,
                      ).activeCount;
                      return Text(
                        count > 0 ? 'Filtre Uygula ($count)' : 'Filtre Uygula',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.textTertiary,
      letterSpacing: 0.8,
    ));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.surfaceInputBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  final DateRange? range;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateRangeRow({
    required this.range,
    required this.dateFormat,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: range != null ? AppColors.infoBg : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: range != null ? AppColors.navy : AppColors.surfaceInputBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: range != null ? AppColors.navy : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                range != null
                    ? '${dateFormat.format(range!.start)} — ${dateFormat.format(range!.end)}'
                    : 'Tarih aralığı seç',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: range != null ? AppColors.navy : AppColors.textTertiary,
                ),
              ),
            ),
            if (range != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 15, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          )),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.navy,
          activeTrackColor: AppColors.navyLight,
        ),
      ],
    );
  }
}

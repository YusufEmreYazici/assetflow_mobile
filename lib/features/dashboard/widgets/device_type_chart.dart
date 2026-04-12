import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceTypeChart extends StatefulWidget {
  final Map<String, int> devicesByType;

  const DeviceTypeChart({super.key, required this.devicesByType});

  @override
  State<DeviceTypeChart> createState() => _DeviceTypeChartState();
}

class _DeviceTypeChartState extends State<DeviceTypeChart> {
  int _touchedIndex = -1;

  static const List<Color> _colors = [
    AppColors.primary500,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.info,
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
    AppColors.gray400,
  ];

  List<MapEntry<String, int>> get _sortedEntries {
    final entries = widget.devicesByType.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _sortedEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cihaz Tipi Dağılımı',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(entries.length, (i) {
                      final isTouched = i == _touchedIndex;
                      final entry = entries[i];
                      final color = _colors[i % _colors.length];
                      final pct =
                          total > 0 ? (entry.value / total * 100) : 0.0;
                      return PieChartSectionData(
                        color: color,
                        value: entry.value.toDouble(),
                        title: isTouched ? '%${pct.toStringAsFixed(0)}' : '',
                        radius: isTouched ? 28 : 22,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(entries.length, (i) {
                    final entry = entries[i];
                    final color = _colors[i % _colors.length];
                    final label = DeviceTypeLabels[int.tryParse(entry.key)] ??
                        entry.key;
                    final pct = total > 0
                        ? (entry.value / total * 100).toStringAsFixed(0)
                        : '0';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${entry.value} (%$pct)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

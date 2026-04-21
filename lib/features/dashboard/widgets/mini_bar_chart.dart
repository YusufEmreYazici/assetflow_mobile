import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class MiniBarChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final Color accent;
  final double height;

  const MiniBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.accent = AppColors.navy,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final frac = maxVal > 0 ? data[i] / maxVal : 0.0;
          final isLast = i == data.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < data.length - 1 ? 3 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: (frac * 30).clamp(2.0, 30.0),
                    decoration: BoxDecoration(
                      color: isLast ? accent : AppColors.surfaceDivider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 9, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

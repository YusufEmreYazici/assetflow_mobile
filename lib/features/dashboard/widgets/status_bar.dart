import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class StatusSegment {
  final String label;
  final int value;
  final Color color;
  const StatusSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class StatusBar extends StatelessWidget {
  final List<StatusSegment> segments;
  const StatusBar({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final total = segments.fold(0, (sum, s) => sum + s.value);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: segments.map((s) {
              final frac = s.value / total;
              return Expanded(
                flex: (frac * 1000).round(),
                child: Container(height: 8, color: s.color),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: segments
              .map(
                (s) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.value}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

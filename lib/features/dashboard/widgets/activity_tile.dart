import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class ActivityItem {
  final String type;
  final String main;
  final String detail;
  final String when;
  final String kind; // success, info, warning, error

  const ActivityItem({
    required this.type,
    required this.main,
    required this.detail,
    required this.when,
    required this.kind,
  });
}

class ActivityTile extends StatelessWidget {
  final ActivityItem item;
  final bool isLast;

  const ActivityTile({super.key, required this.item, this.isLast = false});

  Color get _dotColor => switch (item.kind) {
        'success' => AppColors.success,
        'info'    => AppColors.info,
        'warning' => AppColors.warning,
        'error'   => AppColors.error,
        _         => AppColors.textTertiary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceDivider)),
            ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.type.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary, letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      item.when,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.main,
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary, height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary,
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

// Static mock activity data
const kMockActivity = [
  ActivityItem(type: 'Zimmet',     main: 'Mehmet Yılmaz → Dell Latitude 5540',  detail: 'ZMT-20260421-0142 • Mersin Limanı',   when: '12 dk önce',  kind: 'success'),
  ActivityItem(type: 'Güncelleme', main: 'Cihaz güncellendi — GVN-LPT-0208',    detail: 'Zeynep Aksoy • Durum: Zimmetli',        when: '1 saat önce', kind: 'info'),
  ActivityItem(type: 'Form',       main: 'Zimmet formu üretildi',                detail: 'ZF-2026-0097 • Ayşe Demir',             when: '2 saat önce', kind: 'warning'),
  ActivityItem(type: 'İade',       main: 'HP LaserJet Pro M404 iade edildi',     detail: 'Durum: Bakımda • Aliağa Rafineri',      when: 'Dün, 16:42',  kind: 'error'),
  ActivityItem(type: 'Zimmet',     main: 'Burak Öztürk → Samsung Galaxy A54',   detail: 'ZMT-20260420-0141',                     when: 'Dün, 11:08',  kind: 'success'),
];

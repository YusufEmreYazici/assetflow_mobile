import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class ExcelExportScreen extends StatefulWidget {
  const ExcelExportScreen({super.key});

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen> {
  int? _exporting;

  static const _reportTypes = [
    (
      icon: Icons.devices_outlined,
      label: 'Tüm Cihazlar',
      caption: 'Tüm kayıtlı cihazların listesi',
    ),
    (
      icon: Icons.assignment_outlined,
      label: 'Aktif Zimmetler',
      caption: 'Şu anda aktif olan zimmet kayıtları',
    ),
    (
      icon: Icons.people_outlined,
      label: 'Personel Listesi',
      caption: 'Tüm personel ve cihaz bilgileri',
    ),
    (
      icon: Icons.shield_outlined,
      label: 'Garanti Uyarıları',
      caption: '90 gün içinde biten garantiler',
    ),
    (
      icon: Icons.history_outlined,
      label: 'Audit Log',
      caption: 'Sistem işlem geçmişi',
    ),
  ];

  static final _mockHistory = [
    _Export(
      label: 'Tüm Cihazlar',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      rows: 147,
    ),
    _Export(
      label: 'Aktif Zimmetler',
      time: DateTime.now().subtract(const Duration(days: 1)),
      rows: 89,
    ),
    _Export(
      label: 'Personel Listesi',
      time: DateTime.now().subtract(const Duration(days: 3)),
      rows: 63,
    ),
  ];

  Future<void> _download(int index) async {
    setState(() => _exporting = index);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _exporting = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_reportTypes[index].label} raporu indirildi.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
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
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Excel Export',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SectionLabel('RAPORLAR'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: Column(
                    children: _reportTypes.asMap().entries.map((e) {
                      final isLast = e.key == _reportTypes.length - 1;
                      final type = e.value;
                      final isLoading = _exporting == e.key;
                      return Container(
                        decoration: isLast
                            ? null
                            : const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.surfaceDivider,
                                  ),
                                ),
                              ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.infoBg,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                type.icon,
                                size: 18,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    type.caption,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: (_exporting != null || isLoading)
                                  ? null
                                  : () => _download(e.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navy,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'İndir',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel('GEÇMIŞ RAPORLAR'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: Column(
                    children: _mockHistory.asMap().entries.map((e) {
                      final isLast = e.key == _mockHistory.length - 1;
                      final export = e.value;
                      return Container(
                        decoration: isLast
                            ? null
                            : const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.surfaceDivider,
                                  ),
                                ),
                              ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.table_chart_outlined,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    export.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${export.rows} satır',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('d MMM, HH:mm', 'tr_TR')
                                  .format(export.time),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

class _Export {
  final String label;
  final DateTime time;
  final int rows;
  const _Export({required this.label, required this.time, required this.rows});
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';

class _ReportTemplate {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String endpoint;
  final String fileName;
  final Map<String, dynamic> params;

  const _ReportTemplate({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.endpoint,
    required this.fileName,
    this.params = const {},
  });
}

const _templates = [
  _ReportTemplate(
    key: 'all_devices',
    title: 'Tüm Cihazlar',
    subtitle: 'Marka, model, durum, garanti bilgileriyle tam liste',
    icon: Icons.devices_outlined,
    color: Color(0xFF1e3a5f),
    endpoint: '/api/devices/bulk/export',
    fileName: 'tum_cihazlar.xlsx',
    params: {},
  ),
  _ReportTemplate(
    key: 'active_assignments',
    title: 'Aktif Zimmetler',
    subtitle: 'Şu an zimmetli cihazlar ve personel bilgileri',
    icon: Icons.assignment_outlined,
    color: Color(0xFF059669),
    endpoint: '/api/assignments/export',
    fileName: 'aktif_zimmetler.xlsx',
    params: {'status': 'active'},
  ),
  _ReportTemplate(
    key: 'warranty_expiring',
    title: 'Garanti Uyarısı',
    subtitle: 'Son 90 gün içinde garantisi dolacak cihazlar',
    icon: Icons.shield_outlined,
    color: Color(0xFFD97706),
    endpoint: '/api/devices/bulk/export',
    fileName: 'garanti_uyarilari.xlsx',
    params: {'warrantyExpiring': true},
  ),
  _ReportTemplate(
    key: 'retired_devices',
    title: 'Emekli Cihazlar',
    subtitle: 'Kullanım dışı bırakılan tüm cihazlar',
    icon: Icons.archive_outlined,
    color: Color(0xFF6B7280),
    endpoint: '/api/devices/bulk/export',
    fileName: 'emekli_cihazlar.xlsx',
    params: {'status': 3},
  ),
  _ReportTemplate(
    key: 'employees_assets',
    title: 'Personel Varlık Özeti',
    subtitle: 'Her personelin zimmetindeki cihaz sayısı',
    icon: Icons.people_outline,
    color: Color(0xFF7C3AED),
    endpoint: '/api/employees/export',
    fileName: 'personel_ozeti.xlsx',
    params: {},
  ),
  _ReportTemplate(
    key: 'location_inventory',
    title: 'Lokasyon Envanteri',
    subtitle: 'Lokasyona göre cihaz dağılımı',
    icon: Icons.location_on_outlined,
    color: Color(0xFF0891B2),
    endpoint: '/api/locations/export',
    fileName: 'lokasyon_envanteri.xlsx',
    params: {},
  ),
];

final _downloadingProvider = StateProvider.autoDispose<String?>((ref) => null);

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    _ReportTemplate template,
  ) async {
    ref.read(_downloadingProvider.notifier).state = template.key;
    try {
      final dio = ApiClient.instance.dio;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${template.fileName}';

      final params = <String, dynamic>{'ids': <String>[], ...template.params};

      final response = await dio.post<List<int>>(
        template.endpoint,
        data: params,
        options: Options(responseType: ResponseType.bytes),
      );

      final file = File(filePath);
      await file.writeAsBytes(response.data!);

      if (context.mounted) {
        _showDownloadSheet(context, filePath, template.title);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İndirme başarısız: ${e.toString().length > 60 ? '${e.toString().substring(0, 60)}...' : e.toString()}',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (ref.context.mounted) {
        ref.read(_downloadingProvider.notifier).state = null;
      }
    }
  }

  void _showDownloadSheet(BuildContext context, String filePath, String title) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: 12),
            Text(
              '$title indirildi',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      OpenFile.open(filePath);
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Aç'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Share.shareXFiles([XFile(filePath)], subject: title);
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Paylaş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloading = ref.watch(_downloadingProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          // Header
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
                  onTap: goBackOrHome(context),
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
                  'Raporlar',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Info banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Raporlar Excel formatında indirilir ve paylaşılabilir.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Report cards
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _templates.length,
              separatorBuilder: (context2, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final template = _templates[i];
                final isDownloading = downloading == template.key;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.surfaceDivider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: template.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        template.icon,
                        color: template.color,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      template.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        template.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    trailing: isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.navy,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.download_outlined,
                              color: AppColors.navy,
                              size: 22,
                            ),
                            onPressed: downloading != null
                                ? null
                                : () => _download(context, ref, template),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

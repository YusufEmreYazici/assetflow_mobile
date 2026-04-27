import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/utils/api_exception.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/kv_row.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';

final _locationDetailProvider = FutureProvider.autoDispose
    .family<Location, String>((ref, id) async {
      return LocationService().getById(id);
    });

class LocationDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const LocationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<LocationDetailScreen> createState() =>
      _LocationDetailScreenState();
}

class _LocationDetailScreenState extends ConsumerState<LocationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_locationDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: async.when(
        loading: () => Column(
          children: [
            Container(
              color: AppColors.navy,
              height: MediaQuery.of(context).padding.top + 70,
            ),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.navy,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
        error: (err, stack) => Column(
          children: [
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 14,
                left: AppSpacing.lg,
                bottom: 18,
              ),
              child: GestureDetector(
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
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Lokasyon yüklenemedi.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        data: (location) => _buildDetail(context, location),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Location location) {
    return Column(
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOKASYON',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    if (location.address != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        location.address!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticService.light();
                  final result = await context.push(
                    '/location/${widget.id}/edit',
                  );
                  if (result == true && mounted) {
                    ref.invalidate(_locationDetailProvider(widget.id));
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text('Sil', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (action) {
                  if (action == 'delete') _confirmAndDelete(location);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.surfaceDivider),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        'DETAYLAR',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    KvRow(
                      label: 'Cihaz Sayısı',
                      value: '${location.deviceCount}',
                    ),
                    KvRow(
                      label: 'Durum',
                      value: location.isActive ? 'Aktif' : 'Pasif',
                    ),
                    if (location.building != null)
                      KvRow(label: 'Bina', value: location.building!),
                    if (location.floor != null)
                      KvRow(label: 'Kat', value: location.floor!),
                    if (location.room != null)
                      KvRow(label: 'Oda', value: location.room!),
                    if (location.description != null)
                      KvRow(
                        label: 'Açıklama',
                        value: location.description!,
                        last: true,
                      )
                    else
                      KvRow(
                        label: 'Adres',
                        value: location.address ?? '—',
                        last: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete(Location location) async {
    HapticService.medium();

    if (location.deviceCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bu lokasyonda ${location.deviceCount} cihaz var. '
            'Önce cihazları başka lokasyona taşıyın.',
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lokasyonu Sil?'),
        content: Text('${location.name} silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticService.heavy();
      try {
        await LocationService().delete(location.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${location.name} silindi.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        final apiEx = e is DioException && e.error is ApiException
            ? e.error as ApiException
            : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiEx?.message ?? 'Lokasyon silinemedi.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

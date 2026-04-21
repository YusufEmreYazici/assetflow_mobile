import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/kv_row.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';

final _locationDetailProvider =
    FutureProvider.autoDispose.family<Location, String>((ref, id) async {
  return LocationService().getById(id);
});

class LocationDetailScreen extends ConsumerWidget {
  final String id;
  const LocationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_locationDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: async.when(
        loading: () => Column(
          children: [
            Container(color: AppColors.navy, height: MediaQuery.of(context).padding.top + 70),
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.navy, strokeWidth: 2))),
          ],
        ),
        error: (err, stack) => Column(
          children: [
            Container(
              color: AppColors.navy,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 14, left: AppSpacing.lg, bottom: 18),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('Lokasyon yüklenemedi.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
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
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
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
                        fontSize: 10, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: GoogleFonts.inter(
                        fontSize: 19, fontWeight: FontWeight.w500,
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
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary, letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    KvRow(label: 'Cihaz Sayısı', value: '${location.deviceCount}'),
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
                      KvRow(label: 'Açıklama', value: location.description!, last: true)
                    else
                      KvRow(label: 'Adres', value: location.address ?? '—', last: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

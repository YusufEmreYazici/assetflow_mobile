import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/services/location_service.dart';

final _locationListProvider = FutureProvider.autoDispose<List<Location>>((ref) async {
  final result = await LocationService().getAll(page: 1, pageSize: 100);
  return result.items;
});

class LocationListScreen extends ConsumerWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_locationListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Lokasyonlar',
            subtitle: async.maybeWhen(
              data: (l) => '${l.length} LOKASYON',
              orElse: () => '',
            ),
            onBack: goBackOrHome(context),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.navy, strokeWidth: 2,
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Lokasyonlar yüklenemedi.',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary,
                  ),
                ),
              ),
              data: (locations) {
                if (locations.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz lokasyon eklenmemiş.',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: locations.length,
                  itemBuilder: (_, i) => _LocationCard(
                    location: locations[i],
                    onTap: () => context.push('/location/${locations[i].id}'),
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

class _LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;
  const _LocationCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceDivider),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.location_on_outlined,
                  size: 20, color: AppColors.navy),
            ),
            const SizedBox(height: 10),
            Text(
              location.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (location.address != null) ...[
              const SizedBox(height: 4),
              Text(
                location.address!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            const Divider(height: 1, color: AppColors.surfaceDivider),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metric(
                  value: '${location.deviceCount}',
                  label: 'Cihaz',
                ),
                Container(
                  width: 1, height: 24,
                  color: AppColors.surfaceDivider,
                ),
                _Metric(
                  value: location.isActive ? 'Aktif' : 'Pasif',
                  label: 'Durum',
                  valueColor: location.isActive
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  const _Metric({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

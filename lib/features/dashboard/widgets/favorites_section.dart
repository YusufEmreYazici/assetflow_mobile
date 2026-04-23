import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_chip.dart';
import 'package:assetflow_mobile/core/widgets/section_header.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/favorites_provider.dart';

class FavoritesSection extends ConsumerWidget {
  const FavoritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final allDevices = ref.watch(deviceProvider).devices;

    final favorites = allDevices
        .where((d) => favoriteIds.contains(d.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'FAVORİLER',
          padding: EdgeInsets.zero,
          action: favoriteIds.isNotEmpty
              ? TextButton(
                  onPressed: () => context.push('/devices'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'TÜMÜ →',
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w500,
                      color: AppColors.navyLight, letterSpacing: 0.3,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        if (favorites.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.surfaceDivider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_border_rounded, size: 28, color: AppColors.navyLight),
                const SizedBox(height: 8),
                Text(
                  'Favori cihaz yok',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sık eriştiğin cihazları ★ ile işaretleyerek buraya ekleyebilirsin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary, height: 1.4,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _FavoriteCard(device: favorites[i]),
            ),
          ),
      ],
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Device device;
  const _FavoriteCard({required this.device});

  IconData get _typeIcon => switch (device.type) {
        0 => Icons.laptop_outlined,
        1 => Icons.desktop_mac_outlined,
        2 => Icons.monitor_outlined,
        3 => Icons.print_outlined,
        4 => Icons.smartphone_outlined,
        5 => Icons.tablet_outlined,
        6 => Icons.dns_outlined,
        7 => Icons.router_outlined,
        _ => Icons.devices_outlined,
      };

  ChipTone get _chipTone => switch (device.status) {
        0 => ChipTone.success,
        1 => ChipTone.info,
        2 => ChipTone.warning,
        _ => ChipTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final statusLabel = deviceStatusLabels[device.status] ?? '?';

    return GestureDetector(
      onTap: () => context.push('/devices/${device.id}'),
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_typeIcon, size: 15, color: AppColors.navy),
                ),
                const Spacer(),
                AppChip(label: statusLabel, tone: _chipTone),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              device.name,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              device.assetCode ?? '—',
              style: GoogleFonts.inter(
                fontSize: 10, color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

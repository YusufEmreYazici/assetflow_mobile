import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/devices/providers/favorites_provider.dart';

class FavoriteStar extends ConsumerWidget {
  final String deviceId;
  final double size;
  final Color inactiveColor;

  const FavoriteStar({
    super.key,
    required this.deviceId,
    this.size = 22,
    this.inactiveColor = AppColors.textTertiary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(deviceId);
    return IconButton(
      icon: Icon(
        isFav ? Icons.star_rounded : Icons.star_border_rounded,
        color: isFav ? AppColors.warning : inactiveColor,
        size: size,
      ),
      onPressed: () {
        ref.read(favoritesProvider.notifier).toggle(deviceId);
        HapticFeedback.lightImpact();
      },
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
    );
  }
}

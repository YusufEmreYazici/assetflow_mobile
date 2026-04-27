import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
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
    return Semantics(
      label: isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
      button: true,
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(
            isFav ? Icons.star_rounded : Icons.star_border_rounded,
            key: ValueKey(isFav),
            color: isFav ? AppColors.warning : inactiveColor,
            size: size,
          ),
        ),
        onPressed: () {
          HapticService.medium();
          ref.read(favoritesProvider.notifier).toggle(deviceId);
        },
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
      ),
    );
  }
}

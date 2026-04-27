import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';

enum HapticType { light, medium, heavy, selection }

class HapticButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final HapticType type;
  final Widget child;

  const HapticButton({
    super.key,
    this.onPressed,
    this.type = HapticType.light,
    required this.child,
  });

  void _handleTap() {
    switch (type) {
      case HapticType.light:
        HapticService.light();
      case HapticType.medium:
        HapticService.medium();
      case HapticType.heavy:
        HapticService.heavy();
      case HapticType.selection:
        HapticService.selection();
    }
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onPressed == null ? null : _handleTap, child: child);
  }
}

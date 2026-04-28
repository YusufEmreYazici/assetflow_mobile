import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/widgets/animated_logo_loading.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? AnimatedLogoLoading(message: message ?? 'Yükleniyor...')
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

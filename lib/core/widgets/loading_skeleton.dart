import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

/// Shimmer efektli dikdörtgen placeholder
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceWhite,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDivider,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer efektli dairesel placeholder
class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceWhite,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDivider,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Shimmer efektli metin satırı placeholder
class SkeletonText extends StatelessWidget {
  final double widthFactor;
  final double height;

  const SkeletonText({
    super.key,
    this.widthFactor = 1.0,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: SkeletonBox(height: height, borderRadius: 4),
    );
  }
}

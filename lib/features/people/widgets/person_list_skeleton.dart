import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/loading_skeleton.dart';

class PersonListSkeleton extends StatelessWidget {
  final int itemCount;
  const PersonListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (i) => _PersonRowSkeleton(isLast: i == itemCount - 1),
        ),
      ),
    );
  }
}

class _PersonRowSkeleton extends StatelessWidget {
  final bool isLast;
  const _PersonRowSkeleton({this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
      child: const Row(
        children: [
          SkeletonCircle(size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(widthFactor: 0.50, height: 13),
                SizedBox(height: 6),
                SkeletonText(widthFactor: 0.35, height: 11),
              ],
            ),
          ),
          SizedBox(width: 8),
          SkeletonBox(width: 60, height: 18, borderRadius: 9),
        ],
      ),
    );
  }
}

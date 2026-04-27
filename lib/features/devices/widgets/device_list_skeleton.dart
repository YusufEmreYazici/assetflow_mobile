import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/loading_skeleton.dart';

class DeviceListSkeleton extends StatelessWidget {
  final int itemCount;
  const DeviceListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (i) => _DeviceRowSkeleton(isLast: i == itemCount - 1),
        ),
      ),
    );
  }
}

class _DeviceRowSkeleton extends StatelessWidget {
  final bool isLast;
  const _DeviceRowSkeleton({this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
      child: const Row(
        children: [
          SkeletonBox(width: 40, height: 40, borderRadius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(widthFactor: 0.55, height: 13),
                SizedBox(height: 6),
                SkeletonText(widthFactor: 0.38, height: 11),
              ],
            ),
          ),
          SizedBox(width: 8),
          SkeletonBox(width: 52, height: 20, borderRadius: 10),
        ],
      ),
    );
  }
}

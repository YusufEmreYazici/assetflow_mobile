import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_variant_provider.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_a_view.dart';
import 'package:assetflow_mobile/features/dashboard/widgets/dashboard_b_view.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variant = ref.watch(dashboardVariantProvider);

    final onMenu = Scaffold.maybeOf(context)?.openDrawer;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: variant == DashboardVariant.a
          ? DashboardAView(onMenuTap: onMenu)
          : DashboardBView(onMenuTap: onMenu),
    );
  }
}

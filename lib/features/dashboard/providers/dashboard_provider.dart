import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/data/services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.get();
});

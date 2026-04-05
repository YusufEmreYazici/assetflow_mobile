import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';

class DashboardService {
  final _dio = ApiClient.instance.dio;

  Future<DashboardData> get() async {
    final response = await _dio.get(ApiConstants.dashboard);
    return DashboardData.fromJson(response.data as Map<String, dynamic>);
  }
}

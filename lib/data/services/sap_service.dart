import 'package:dio/dio.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/data/models/sap_models.dart';

class SapService {
  final _dio = ApiClient.instance.dio;

  Future<SapConnectionStatus> getStatus() async {
    try {
      final res = await _dio.get(ApiConstants.sapStatus);
      return SapConnectionStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 501) {
        return SapConnectionStatus.notConfigured;
      }
      rethrow;
    }
  }

  Future<SapSyncResult> syncEmployees() async {
    final res = await _dio.post(ApiConstants.sapSyncEmployees);
    return SapSyncResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<SapSyncResult> syncAssets() async {
    final res = await _dio.post(ApiConstants.sapSyncAssets);
    return SapSyncResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<SapBudgetItem>> getBudgets() async {
    final res = await _dio.get(ApiConstants.sapBudgets);
    final list = res.data as List<dynamic>;
    return list.map((e) => SapBudgetItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

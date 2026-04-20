import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class AuditLogService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<AuditLog>> getForDevice(
    String deviceId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.auditLogsForDevice(deviceId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      AuditLog.fromJson,
    );
  }
}

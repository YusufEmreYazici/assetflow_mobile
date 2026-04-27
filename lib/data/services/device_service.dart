import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class DeviceService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Device>> getAll({int page = 1, int pageSize = 15}) async {
    final response = await _dio.get(
      ApiConstants.devices,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Device.fromJson(json),
    );
  }

  Future<Device> getById(String id) async {
    final response = await _dio.get(ApiConstants.deviceById(id));
    return Device.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Device> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.devices, data: data);
    return Device.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Device> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.deviceById(id), data: data);
    return Device.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiConstants.deviceById(id));
  }

  Future<Device> updateStatus(String id, int status) async {
    final response = await _dio.patch(
      ApiConstants.deviceStatus(id),
      data: {'status': status},
    );
    return Device.fromJson(response.data as Map<String, dynamic>);
  }
}

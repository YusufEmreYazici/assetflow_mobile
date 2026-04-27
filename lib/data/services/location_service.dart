import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class LocationService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Location>> getAll({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      ApiConstants.locations,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Location.fromJson(json),
    );
  }

  Future<Location> getById(String id) async {
    final response = await _dio.get(ApiConstants.locationById(id));
    return Location.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Location> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.locations, data: data);
    return Location.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Location> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.locationById(id), data: data);
    return Location.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiConstants.locationById(id));
  }
}

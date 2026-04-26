import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/software_license_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class SoftwareLicenseService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<SoftwareLicense>> getAll({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _dio.get('/api/assets/software', queryParameters: params);
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => SoftwareLicense.fromJson(json),
    );
  }

  Future<SoftwareLicense> getById(String id) async {
    final response = await _dio.get('/api/assets/software/$id');
    return SoftwareLicense.fromJson(response.data as Map<String, dynamic>);
  }
}

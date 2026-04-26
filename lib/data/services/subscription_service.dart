import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/subscription_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class SubscriptionService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Subscription>> getAll({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null) params['status'] = status;
    final response = await _dio.get('/api/assets/subscriptions', queryParameters: params);
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Subscription.fromJson(json),
    );
  }

  Future<Subscription> getById(String id) async {
    final response = await _dio.get('/api/assets/subscriptions/$id');
    return Subscription.fromJson(response.data as Map<String, dynamic>);
  }
}

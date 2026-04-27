import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/consumable_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class ConsumableService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Consumable>> getAll({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _dio.get(
      '/api/assets/consumables',
      queryParameters: params,
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Consumable.fromJson(json),
    );
  }

  Future<Consumable> getById(String id) async {
    final response = await _dio.get('/api/assets/consumables/$id');
    return Consumable.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Consumable>> getLowStock() async {
    final response = await _dio.get('/api/assets/consumables/low-stock');
    return (response.data as List)
        .map((e) => Consumable.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<StockMovement>> getMovementHistory(String id) async {
    final response = await _dio.get(
      '/api/assets/consumables/movement-history/$id',
    );
    return (response.data as List)
        .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StockMovement> stockIn(
    String id, {
    required int quantity,
    String? reason,
  }) async {
    final response = await _dio.post(
      '/api/assets/consumables/$id/stock-in',
      data: {'quantity': quantity, 'reason': reason},
    );
    return StockMovement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StockMovement> stockOut(
    String id, {
    required int quantity,
    String? reason,
  }) async {
    final response = await _dio.post(
      '/api/assets/consumables/$id/stock-out',
      data: {'quantity': quantity, 'reason': reason},
    );
    return StockMovement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Consumable> create(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/assets/consumables', data: data);
    return Consumable.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Consumable> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      '/api/assets/consumables/$id',
      data: data,
    );
    return Consumable.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/api/assets/consumables/$id');
  }
}

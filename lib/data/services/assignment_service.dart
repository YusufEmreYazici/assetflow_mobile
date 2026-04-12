import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class AssignmentService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Assignment>> getAll({
    int page = 1,
    int pageSize = 15,
    String? search,
    bool? isActive,
  }) async {
    final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isActive != null) params['isActive'] = isActive;
    final response = await _dio.get(ApiConstants.assignments, queryParameters: params);
    return PagedResult.fromJson(response.data as Map<String, dynamic>, (json) => Assignment.fromJson(json));
  }

  Future<Assignment> getById(String id) async {
    final response = await _dio.get(ApiConstants.assignmentById(id));
    return Assignment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Assignment> assign(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.assignments, data: data);
    return Assignment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> returnDevice(String id) async {
    await _dio.post(ApiConstants.assignmentReturn(id));
  }

  Future<Uint8List> exportForm(String id) async {
    final response = await _dio.get(
      ApiConstants.assignmentExport(id),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }
}

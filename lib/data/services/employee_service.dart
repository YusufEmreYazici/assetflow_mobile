import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

class EmployeeService {
  final _dio = ApiClient.instance.dio;

  Future<PagedResult<Employee>> getAll({
    int page = 1,
    int pageSize = 15,
  }) async {
    final response = await _dio.get(
      ApiConstants.employees,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(
      response.data as Map<String, dynamic>,
      (json) => Employee.fromJson(json),
    );
  }

  Future<Employee> getById(String id) async {
    final response = await _dio.get(ApiConstants.employeeById(id));
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> create(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.employees, data: data);
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> update(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConstants.employeeById(id), data: data);
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiConstants.employeeById(id));
  }
}

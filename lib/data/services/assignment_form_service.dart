import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/assignment_form_model.dart';

class AssignmentFormService {
  final _dio = ApiClient.instance.dio;

  Future<AssignmentForm> generateAssignmentForm(String assignmentId) async {
    final response = await _dio.post(
      ApiConstants.assignmentFormsGenerateAssignment(assignmentId),
    );
    return AssignmentForm.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AssignmentForm> generateReturnForm(String assignmentId) async {
    final response = await _dio.post(
      ApiConstants.assignmentFormsGenerateReturn(assignmentId),
    );
    return AssignmentForm.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Uint8List> downloadForm(String formId) async {
    final response = await _dio.get(
      ApiConstants.formDownload(formId),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  Future<Uint8List> downloadSigned(String formId) async {
    final response = await _dio.get(
      ApiConstants.formDownloadSigned(formId),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }

  Future<AssignmentForm> uploadSigned(
    String formId,
    String filePath,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.post(
      ApiConstants.formUploadSigned(formId),
      data: formData,
    );
    return AssignmentForm.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AssignmentForm>> getByAssignment(String assignmentId) async {
    final response = await _dio.get(ApiConstants.assignmentForms(assignmentId));
    final list = response.data as List<dynamic>;
    return list
        .map((item) => AssignmentForm.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AssignmentForm?> getLatest(String assignmentId) async {
    try {
      final response = await _dio.get(
        ApiConstants.assignmentFormsLatest(assignmentId),
      );
      return AssignmentForm.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/data/models/profile_models.dart';

class ProfileService {
  final _dio = ApiClient.instance.dio;

  Future<ProfileDto> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>(ApiConstants.userMe);
    return ProfileDto.fromJson(res.data!);
  }

  Future<ProfileDto> updateMe(UpdateProfileRequest request) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.userMe,
      data: request.toJson(),
    );
    return ProfileDto.fromJson(res.data!);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.post<void>(
      ApiConstants.userMeChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<String> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar${imageFile.path.split('.').last.isEmpty ? '.jpg' : '.${imageFile.path.split('.').last}'}',
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      ApiConstants.userMeAvatar,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data!['avatarUrl'] as String?) ?? '';
  }
}

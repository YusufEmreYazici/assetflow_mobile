import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';
import 'package:assetflow_mobile/data/models/auth_models.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;
  final _tokenManager = TokenManager.instance;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _tokenManager.saveTokens(authResponse.token, authResponse.refreshToken);
    await _tokenManager.saveUser(
      email: authResponse.email,
      fullName: authResponse.fullName,
      role: authResponse.role,
      companyId: authResponse.companyId,
    );
    return authResponse;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _tokenManager.saveTokens(authResponse.token, authResponse.refreshToken);
    await _tokenManager.saveUser(
      email: authResponse.email,
      fullName: authResponse.fullName,
      role: authResponse.role,
      companyId: authResponse.companyId,
    );
    return authResponse;
  }

  Future<AuthResponse> refresh() async {
    final accessToken = await _tokenManager.getAccessToken();
    final refreshToken = await _tokenManager.getRefreshToken();
    final response = await _dio.post(
      ApiConstants.refresh,
      data: {
        'token': accessToken,
        'refreshToken': refreshToken,
      },
    );
    final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await _tokenManager.saveTokens(authResponse.token, authResponse.refreshToken);
    return authResponse;
  }

  Future<void> revoke() async {
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken != null) {
      await _dio.post(
        ApiConstants.revoke,
        data: {'refreshToken': refreshToken},
      );
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.post(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout() async {
    try {
      await revoke();
    } catch (_) {
      // Ignore revoke errors during logout
    } finally {
      await _tokenManager.clearTokens();
    }
  }
}

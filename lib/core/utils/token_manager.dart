import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  TokenManager._();
  static final TokenManager instance = TokenManager._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';
  static const String _fullNameKey = 'user_full_name';
  static const String _roleKey = 'user_role';
  static const String _companyIdKey = 'user_company_id';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _fullNameKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _companyIdKey);
  }

  Future<void> saveUser({
    required String email,
    required String fullName,
    required String role,
    required int companyId,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _fullNameKey, value: fullName);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _companyIdKey, value: companyId.toString());
  }

  Future<Map<String, String?>> getUser() async {
    final email = await _storage.read(key: _emailKey);
    final fullName = await _storage.read(key: _fullNameKey);
    final role = await _storage.read(key: _roleKey);
    final companyId = await _storage.read(key: _companyIdKey);
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'companyId': companyId,
    };
  }
}

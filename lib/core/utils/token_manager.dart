import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  TokenManager._();
  static final TokenManager instance = TokenManager._();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';
  static const String _fullNameKey = 'user_full_name';
  static const String _roleKey = 'user_role';
  static const String _companyIdKey = 'user_company_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_companyIdKey);
  }

  Future<void> saveUser({
    required String email,
    required String fullName,
    required String role,
    required String companyId,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_emailKey, email);
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_companyIdKey, companyId);
  }

  Future<Map<String, String?>> getUser() async {
    final prefs = await _prefs;
    return {
      'email': prefs.getString(_emailKey),
      'fullName': prefs.getString(_fullNameKey),
      'role': prefs.getString(_roleKey),
      'companyId': prefs.getString(_companyIdKey),
    };
  }
}

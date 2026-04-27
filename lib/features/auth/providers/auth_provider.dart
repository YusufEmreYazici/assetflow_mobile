import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/services/error_reporting_service.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';
import 'package:assetflow_mobile/data/models/auth_models.dart';
import 'package:assetflow_mobile/data/services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final String? fullName;
  final String? role;
  final String? companyId;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.email,
    this.fullName,
    this.role,
    this.companyId,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    String? fullName,
    String? role,
    String? companyId,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenManager _tokenManager;

  AuthNotifier({AuthService? authService, TokenManager? tokenManager})
    : _authService = authService ?? AuthService(),
      _tokenManager = tokenManager ?? TokenManager.instance,
      super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await _tokenManager.getAccessToken();
      if (token == null) {
        state = const AuthState();
        return;
      }
      final user = await _tokenManager.getUser();
      if (user['email'] != null) {
        state = AuthState(
          isAuthenticated: true,
          email: user['email'],
          fullName: user['fullName'],
          role: user['role'],
          companyId: user['companyId'],
        );
      } else {
        state = const AuthState();
      }
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(
        LoginRequest(identifier: identifier, password: password),
      );
      state = AuthState(
        isAuthenticated: true,
        email: response.email,
        fullName: response.fullName,
        role: response.role,
        companyId: response.companyId,
      );
      ErrorReportingService.instance.setUser(response.email, response.email);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: message);
    } catch (e, st) {
      ErrorReportingService.instance.captureException(e, stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        error: 'Beklenmeyen bir hata olustu.',
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    String? taxNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.register(
        RegisterRequest(
          email: email,
          password: password,
          confirmPassword: password,
          fullName: fullName,
          companyName: companyName,
        ),
      );
      state = AuthState(
        isAuthenticated: true,
        email: response.email,
        fullName: response.fullName,
        role: response.role,
        companyId: response.companyId,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Beklenmeyen bir hata olustu.',
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore logout errors
    } finally {
      ErrorReportingService.instance.clearUser();
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Sunucuya baglanilamadi. Lutfen internet baglantinizi kontrol edin.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sunucuya baglanilamadi. Lutfen daha sonra tekrar deneyin.';
    }
    return 'Bir hata olustu. Lutfen tekrar deneyin.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

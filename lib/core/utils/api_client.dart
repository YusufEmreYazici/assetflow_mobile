import 'package:dio/dio.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/api_exception.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(_authInterceptor());
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  Dio get dio => _dio;

  /// Callback invoked when token refresh fails and user must log out.
  /// Set this from the app layer to navigate to login screen.
  void Function()? onLogout;

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.instance.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRetryRequest(error.requestOptions)) {
          if (!_isRefreshing) {
            _isRefreshing = true;
            final refreshed = await _refreshToken();
            _isRefreshing = false;

            if (refreshed) {
              // Retry all pending requests
              for (final pending in _pendingRequests) {
                final newToken = await TokenManager.instance.getAccessToken();
                pending.options.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final response = await _dio.fetch(pending.options);
                  pending.handler.resolve(response);
                } on DioException catch (e) {
                  pending.handler.reject(e);
                }
              }
              _pendingRequests.clear();

              // Retry the original request
              final newToken = await TokenManager.instance.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              error.requestOptions.extra['_retried'] = true;
              try {
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
              } on DioException catch (e) {
                handler.reject(e);
              }
              return;
            } else {
              // Refresh failed — reject all pending
              for (final pending in _pendingRequests) {
                pending.handler.reject(error);
              }
              _pendingRequests.clear();
              await _logout();
              handler.reject(error);
              return;
            }
          } else {
            // Already refreshing — queue this request
            _pendingRequests.add(
              _RetryRequest(options: error.requestOptions, handler: handler),
            );
            return;
          }
        }
        // Structured error handling for 400/409/422
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          final data = error.response?.data;
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException(
                statusCode: 400,
                message: (data is Map ? data['error'] ?? data['message'] : null) as String? ??
                    'İstek geçersiz.',
                details: data is Map ? data['details'] : null,
              ),
              response: error.response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        if (statusCode == 409) {
          final data = error.response?.data;
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiException(
                statusCode: 409,
                message: (data is Map ? data['error'] ?? data['message'] : null) as String? ??
                    'Bu kayıt başka biri tarafından değiştirildi. Sayfayı yenileyip tekrar deneyin.',
                details: data is Map ? data['details'] : null,
                isConflict: true,
              ),
              response: error.response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        if (statusCode == 422) {
          final data = error.response?.data;
          final errors = (data is Map ? data['errors'] : null) as Map<String, dynamic>? ?? {};
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ValidationException(errors),
              response: error.response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.next(error);
      },
    );
  }

  bool _isRetryRequest(RequestOptions options) {
    return options.extra['_retried'] == true;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenManager.instance.getRefreshToken();
      final accessToken = await TokenManager.instance.getAccessToken();
      if (refreshToken == null || accessToken == null) return false;

      final response = await Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).post(
        ApiConstants.refresh,
        data: {
          'token': accessToken,
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await TokenManager.instance.saveTokens(
          data['token'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _logout() async {
    await TokenManager.instance.clearTokens();
    onLogout?.call();
  }
}

class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RetryRequest({required this.options, required this.handler});
}

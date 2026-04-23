import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorReportingService {
  ErrorReportingService._();
  static final instance = ErrorReportingService._();

  Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    if (kDebugMode) {
      debugPrint('[ErrorReporting] $exception\n$stackTrace');
      return;
    }
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: extras != null
          ? (scope) => scope.setContexts('extras', extras)
          : null,
    );
  }

  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (kDebugMode) {
      debugPrint('[ErrorReporting] [$level] $message');
      return;
    }
    await Sentry.captureMessage(message, level: level);
  }

  void setUser(String id, String email) {
    Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: id, email: email)),
    );
  }

  void clearUser() {
    Sentry.configureScope((scope) => scope.setUser(null));
  }
}

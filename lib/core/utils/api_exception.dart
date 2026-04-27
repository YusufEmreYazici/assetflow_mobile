class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;
  final bool isConflict;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.details,
    this.isConflict = false,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;

  const ValidationException(this.errors);

  String get message {
    if (errors.isEmpty) return 'Girilen bilgiler geçersiz.';
    return errors.values.expand((v) => v is List ? v : [v]).join('\n');
  }

  @override
  String toString() => 'ValidationException: $message';
}

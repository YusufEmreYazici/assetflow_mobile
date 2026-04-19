class ApiConstants {
  ApiConstants._();

  /// Build-time override — --dart-define ile URL belirle:
  ///
  ///   Android emülatör (varsayılan):
  ///     flutter run
  ///     → http://10.0.2.2:5160  (host PC'nin emülatör içinden adresi)
  ///
  ///   Fiziksel cihaz (aynı WiFi ağında):
  ///     flutter run --dart-define=API_BASE_URL=http://192.168.1.X:5160
  ///
  ///   Production:
  ///     flutter build apk --dart-define=API_BASE_URL=https://api.assetflow.io
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5160',
  );

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String revoke = '/api/auth/revoke';
  static const String changePassword = '/api/auth/change-password';

  // Devices
  static const String devices = '/api/devices';
  static String deviceById(String id) => '/api/devices/$id';

  // Employees
  static const String employees = '/api/employees';
  static String employeeById(String id) => '/api/employees/$id';

  // Assignments
  static const String assignments = '/api/assignments';
  static String assignmentById(String id) => '/api/assignments/$id';
  static const String assignmentAssign = '/api/assignments/assign';
  static String assignmentReturn(String id) => '/api/assignments/$id/return';
  static String assignmentExport(String id) => '/api/assignments/$id/export';

  // Locations
  static const String locations = '/api/locations';
  static String locationById(String id) => '/api/locations/$id';

  // Assignment Forms
  static String assignmentForms(String assignmentId) => '/api/assignments/$assignmentId/forms';
  static String assignmentFormsLatest(String assignmentId) => '/api/assignments/$assignmentId/forms/latest';
  static String assignmentFormsGenerateAssignment(String assignmentId) => '/api/assignments/$assignmentId/forms/generate-assignment';
  static String assignmentFormsGenerateReturn(String assignmentId) => '/api/assignments/$assignmentId/forms/generate-return';
  static String formDownload(String formId) => '/api/assignment-forms/$formId/download';
  static String formDownloadSigned(String formId) => '/api/assignment-forms/$formId/download-signed';
  static String formUploadSigned(String formId) => '/api/assignment-forms/$formId/upload-signed';

  // Dashboard
  static const String dashboard = '/api/dashboard';

  // SAP Entegrasyon
  static const String sapSyncEmployees = '/api/sap/sync/employees';
  static const String sapSyncAssets = '/api/sap/sync/assets';
  static const String sapBudgets = '/api/sap/budgets';
  static const String sapStatus = '/api/sap/status';
}

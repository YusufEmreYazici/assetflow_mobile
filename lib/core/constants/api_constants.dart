import 'dart:io' show Platform;

class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5160';
    }
    return 'http://localhost:5160';
  }

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String revoke = '/api/auth/revoke';

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

  // Dashboard
  static const String dashboard = '/api/dashboard';
}

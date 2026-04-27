import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';

class OfflineCacheService {
  static const _deviceBox = 'devices_cache';
  static const _employeeBox = 'employees_cache';
  static const _assignmentBox = 'assignments_cache';
  static const _metaBox = 'cache_meta';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_deviceBox);
    await Hive.openBox<String>(_employeeBox);
    await Hive.openBox<String>(_assignmentBox);
    await Hive.openBox<String>(_metaBox);
  }

  // ── Devices ────────────────────────────────────────────────────────────────

  static Future<void> cacheDevices(List<Device> devices) async {
    final box = Hive.box<String>(_deviceBox);
    await box.clear();
    for (final d in devices) {
      await box.put(d.id, jsonEncode(d.toJson()));
    }
    await _setLastSync('devices');
  }

  static List<Device> getCachedDevices() {
    final box = Hive.box<String>(_deviceBox);
    return box.values
        .map((s) => Device.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static bool get hasDeviceCache => Hive.box<String>(_deviceBox).isNotEmpty;

  // ── Employees ──────────────────────────────────────────────────────────────

  static Future<void> cacheEmployees(List<Employee> employees) async {
    final box = Hive.box<String>(_employeeBox);
    await box.clear();
    for (final e in employees) {
      await box.put(e.id, jsonEncode(e.toJson()));
    }
    await _setLastSync('employees');
  }

  static List<Employee> getCachedEmployees() {
    final box = Hive.box<String>(_employeeBox);
    return box.values
        .map((s) => Employee.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static bool get hasEmployeeCache => Hive.box<String>(_employeeBox).isNotEmpty;

  // ── Assignments ────────────────────────────────────────────────────────────

  static Future<void> cacheAssignments(List<Assignment> assignments) async {
    final box = Hive.box<String>(_assignmentBox);
    await box.clear();
    for (final a in assignments) {
      await box.put(a.id, jsonEncode(a.toJson()));
    }
    await _setLastSync('assignments');
  }

  static List<Assignment> getCachedAssignments() {
    final box = Hive.box<String>(_assignmentBox);
    return box.values
        .map((s) => Assignment.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static bool get hasAssignmentCache =>
      Hive.box<String>(_assignmentBox).isNotEmpty;

  // ── Meta ───────────────────────────────────────────────────────────────────

  static Future<void> _setLastSync(String key) async {
    await Hive.box<String>(
      _metaBox,
    ).put('${key}_last_sync', DateTime.now().toIso8601String());
  }

  static DateTime? getLastSync(String key) {
    final iso = Hive.box<String>(_metaBox).get('${key}_last_sync');
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  static String? getLastSyncLabel(String key) {
    final dt = getLastSync(key);
    if (dt == null) return null;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }
}

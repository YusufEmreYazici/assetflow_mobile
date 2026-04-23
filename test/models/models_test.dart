import 'package:flutter_test/flutter_test.dart';

import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/location_model.dart';
import 'package:assetflow_mobile/data/models/paged_result.dart';

void main() {
  // ─── Device ──────────────────────────────────────────────────────────────────

  group('Device.fromJson', () {
    test('zorunlu alanları doğru ayrıştırır', () {
      final json = {
        'id': 'dev-1',
        'name': 'ThinkPad T14',
        'type': 0,
        'status': 1,
      };
      final device = Device.fromJson(json);
      expect(device.id, 'dev-1');
      expect(device.name, 'ThinkPad T14');
      expect(device.type, 0);
      expect(device.status, 1);
    });

    test('opsiyonel alanlar null kalır', () {
      final device = Device.fromJson({'id': '1', 'name': 'Test', 'type': 0, 'status': 0});
      expect(device.brand, isNull);
      expect(device.model, isNull);
      expect(device.serialNumber, isNull);
      expect(device.purchaseDate, isNull);
      expect(device.warrantyEndDate, isNull);
      expect(device.assignedTo, isNull);
    });

    test('purchasePrice double olarak ayrıştırılır', () {
      final device = Device.fromJson({
        'id': '1', 'name': 'Dell', 'type': 1, 'status': 0,
        'purchasePrice': 15000,
      });
      expect(device.purchasePrice, 15000.0);
      expect(device.purchasePrice, isA<double>());
    });

    test('purchaseDate ve warrantyEndDate DateTime olarak ayrıştırılır', () {
      final device = Device.fromJson({
        'id': '1', 'name': 'HP', 'type': 2, 'status': 0,
        'purchaseDate': '2024-01-15T00:00:00',
        'warrantyEndDate': '2027-01-15T00:00:00',
      });
      expect(device.purchaseDate, isNotNull);
      expect(device.purchaseDate!.year, 2024);
      expect(device.warrantyEndDate!.year, 2027);
    });

    test('id int olarak gelirse string\'e çevrilir', () {
      final device = Device.fromJson({'id': 42, 'name': 'Test', 'type': 0, 'status': 0});
      expect(device.id, '42');
    });

    test('deviceTypeLabels tüm tip kodlarını içerir', () {
      expect(deviceTypeLabels[0], 'Dizustu Bilgisayar');
      expect(deviceTypeLabels[1], 'Masaustu Bilgisayar');
      expect(deviceTypeLabels[8], 'Diger');
    });

    test('deviceStatusLabels tüm durum kodlarını içerir', () {
      expect(deviceStatusLabels[0], 'Aktif');
      expect(deviceStatusLabels[1], 'Depoda');
      expect(deviceStatusLabels[2], 'Bakimda');
      expect(deviceStatusLabels[3], 'Emekli');
    });
  });

  // ─── Employee ────────────────────────────────────────────────────────────────

  group('Employee.fromJson', () {
    test('zorunlu alanları doğru ayrıştırır', () {
      final json = {
        'id': 'emp-1',
        'fullName': 'Ahmet Yılmaz',
        'isActive': true,
        'assignedDeviceCount': 2,
      };
      final emp = Employee.fromJson(json);
      expect(emp.id, 'emp-1');
      expect(emp.fullName, 'Ahmet Yılmaz');
      expect(emp.isActive, isTrue);
      expect(emp.assignedDeviceCount, 2);
    });

    test('opsiyonel alanlar null kalır', () {
      final emp = Employee.fromJson({
        'id': '1', 'fullName': 'Test', 'isActive': false, 'assignedDeviceCount': 0,
      });
      expect(emp.email, isNull);
      expect(emp.department, isNull);
      expect(emp.title, isNull);
      expect(emp.phone, isNull);
    });

    test('hireDate DateTime olarak ayrıştırılır', () {
      final emp = Employee.fromJson({
        'id': '1', 'fullName': 'Test', 'isActive': true,
        'assignedDeviceCount': 0,
        'hireDate': '2023-06-01T08:00:00',
      });
      expect(emp.hireDate, isNotNull);
      expect(emp.hireDate!.year, 2023);
      expect(emp.hireDate!.month, 6);
    });

    test('assignedDeviceCount eksikse sıfır döner', () {
      final emp = Employee.fromJson({'id': '1', 'fullName': 'Test', 'isActive': true});
      expect(emp.assignedDeviceCount, 0);
    });
  });

  // ─── Assignment ───────────────────────────────────────────────────────────────

  group('Assignment.fromJson', () {
    test('aktif zimmet doğru ayrıştırılır', () {
      final json = {
        'id': 'asgn-1',
        'assetTag': 'ZMT-20240101-001',
        'type': 0,
        'deviceId': 'dev-1',
        'deviceName': 'ThinkPad T14',
        'employeeId': 'emp-1',
        'employeeName': 'Ahmet Yılmaz',
        'assignedAt': '2024-01-01T09:00:00',
        'isActive': true,
      };
      final asgn = Assignment.fromJson(json);
      expect(asgn.id, 'asgn-1');
      expect(asgn.assetTag, 'ZMT-20240101-001');
      expect(asgn.type, 0);
      expect(asgn.deviceName, 'ThinkPad T14');
      expect(asgn.isActive, isTrue);
      expect(asgn.returnedAt, isNull);
    });

    test('iade edilmiş zimmet returnedAt içerir', () {
      final json = {
        'id': 'asgn-2',
        'type': 1,
        'assignedAt': '2024-01-01T00:00:00',
        'returnedAt': '2024-03-01T14:30:00',
        'returnCondition': 0,
        'isActive': false,
      };
      final asgn = Assignment.fromJson(json);
      expect(asgn.returnedAt, isNotNull);
      expect(asgn.returnedAt!.month, 3);
      expect(asgn.returnCondition, 0);
      expect(asgn.isActive, isFalse);
    });

    test('assignmentTypeLabels tüm tipleri içerir', () {
      expect(assignmentTypeLabels[0], 'Zimmet');
      expect(assignmentTypeLabels[1], 'Odunc');
      expect(assignmentTypeLabels[2], 'Gecici');
    });

    test('returnConditionLabels tüm durumları içerir', () {
      expect(returnConditionLabels[0], 'Iyi');
      expect(returnConditionLabels[1], 'Hasarli');
      expect(returnConditionLabels[2], 'Arizali');
      expect(returnConditionLabels[3], 'Kayip');
    });
  });

  // ─── Location ─────────────────────────────────────────────────────────────────

  group('Location.fromJson', () {
    test('zorunlu alanları doğru ayrıştırır', () {
      final json = {
        'id': 'loc-1',
        'name': 'Mersin Terminal',
        'isActive': true,
        'deviceCount': 12,
      };
      final loc = Location.fromJson(json);
      expect(loc.id, 'loc-1');
      expect(loc.name, 'Mersin Terminal');
      expect(loc.isActive, isTrue);
      expect(loc.deviceCount, 12);
    });

    test('opsiyonel adres alanları null kalır', () {
      final loc = Location.fromJson({
        'id': '1', 'name': 'Depo', 'isActive': true, 'deviceCount': 0,
      });
      expect(loc.address, isNull);
      expect(loc.building, isNull);
      expect(loc.floor, isNull);
      expect(loc.room, isNull);
    });

    test('deviceCount eksikse sıfır döner', () {
      final loc = Location.fromJson({'id': '1', 'name': 'Test', 'isActive': false});
      expect(loc.deviceCount, 0);
    });

    test('toJson round-trip doğru çalışır', () {
      final loc = Location.fromJson({
        'id': 'loc-2', 'name': 'İskenderun', 'isActive': true,
        'deviceCount': 5, 'building': 'A Blok',
      });
      final json = loc.toJson();
      expect(json['id'], 'loc-2');
      expect(json['name'], 'İskenderun');
      expect(json['building'], 'A Blok');
    });
  });

  // ─── PagedResult ──────────────────────────────────────────────────────────────

  group('PagedResult.fromJson', () {
    test('Device listesi ile doğru ayrıştırılır', () {
      final json = {
        'items': [
          {'id': '1', 'name': 'Laptop A', 'type': 0, 'status': 0},
          {'id': '2', 'name': 'Laptop B', 'type': 0, 'status': 1},
        ],
        'totalCount': 2,
        'page': 1,
        'pageSize': 20,
      };
      final result = PagedResult.fromJson(json, (j) => Device.fromJson(j));
      expect(result.items.length, 2);
      expect(result.totalCount, 2);
      expect(result.page, 1);
      expect(result.items.first.name, 'Laptop A');
    });

    test('boş items listesi ile çalışır', () {
      final result = PagedResult.fromJson(
        {'items': [], 'totalCount': 0, 'page': 1, 'pageSize': 20},
        (j) => Device.fromJson(j),
      );
      expect(result.items, isEmpty);
      expect(result.totalCount, 0);
    });
  });
}

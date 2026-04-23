import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assetflow_mobile/core/utils/cache_manager.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';
import 'package:assetflow_mobile/core/widgets/connectivity_wrapper.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/sap_models.dart';
import 'package:assetflow_mobile/data/models/dashboard_model.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

void main() {
  // ─── CacheManager ───────────────────────────────────────────────────────────

  group('CacheManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('set ve get — TTL içinde veri döner', () async {
      await CacheManager.instance.set('test_key', {'value': 42});
      final data = await CacheManager.instance.get('test_key');
      expect(data, isNotNull);
      expect(data!['value'], 42);
    });

    test('get — TTL geçmiş key için null döner', () async {
      await CacheManager.instance.set(
        'expired_key',
        {'value': 'stale'},
        ttl: const Duration(seconds: 0),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      final data = await CacheManager.instance.get('expired_key');
      expect(data, isNull);
    });

    test('getStale — TTL geçse bile veriyi döner', () async {
      await CacheManager.instance.set(
        'stale_key',
        {'value': 'offline'},
        ttl: const Duration(seconds: 0),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      final data = await CacheManager.instance.getStale('stale_key');
      expect(data, isNotNull);
      expect(data!['value'], 'offline');
    });

    test('clearAll — tüm cache temizlenir', () async {
      await CacheManager.instance.set('key1', {'a': 1});
      await CacheManager.instance.set('key2', {'b': 2});
      await CacheManager.instance.clearAll();
      expect(await CacheManager.instance.get('key1'), isNull);
      expect(await CacheManager.instance.get('key2'), isNull);
    });

    test('olmayan key için null döner', () async {
      final data = await CacheManager.instance.get('nonexistent_key');
      expect(data, isNull);
    });
  });

  // ─── TokenManager ────────────────────────────────────────────────────────────

  group('TokenManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('token kaydet ve oku', () async {
      await TokenManager.instance.saveTokens('access_123', 'refresh_456');
      expect(await TokenManager.instance.getAccessToken(), 'access_123');
      expect(await TokenManager.instance.getRefreshToken(), 'refresh_456');
    });

    test('kullanıcı bilgisi kaydet ve oku', () async {
      await TokenManager.instance.saveUser(
        email: 'test@test.com',
        fullName: 'Test Kullanici',
        role: 'Admin',
        companyId: 'comp-1',
      );
      final user = await TokenManager.instance.getUser();
      expect(user['email'], 'test@test.com');
      expect(user['fullName'], 'Test Kullanici');
      expect(user['role'], 'Admin');
      expect(user['companyId'], 'comp-1');
    });

    test('clearTokens — tüm token bilgileri silinir', () async {
      await TokenManager.instance.saveTokens('access_123', 'refresh_456');
      await TokenManager.instance.clearTokens();
      expect(await TokenManager.instance.getAccessToken(), isNull);
      expect(await TokenManager.instance.getRefreshToken(), isNull);
    });

    test('token yokken null döner', () async {
      expect(await TokenManager.instance.getAccessToken(), isNull);
    });
  });

  // ─── AuthState ────────────────────────────────────────────────────────────

  group('AuthState', () {
    test('başlangıç durumu — unauthenticated, not loading', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.email, isNull);
      expect(state.error, isNull);
    });

    test('copyWith — sadece belirtilen alanlar değişir', () {
      const state = AuthState();
      final updated = state.copyWith(
        isAuthenticated: true,
        email: 'user@mail.com',
        fullName: 'Test User',
        isLoading: false,
      );
      expect(updated.isAuthenticated, isTrue);
      expect(updated.email, 'user@mail.com');
      expect(updated.fullName, 'Test User');
      expect(updated.isLoading, isFalse);
      expect(updated.role, isNull);
      expect(updated.companyId, isNull);
    });

    test('copyWith — error alanı doğru taşınır', () {
      const state = AuthState();
      final withError = state.copyWith(error: 'Hata olustu', isLoading: false);
      expect(withError.error, 'Hata olustu');
      final cleared = withError.copyWith(error: null);
      expect(cleared.error, isNull);
    });

    test('copyWith — tüm alanlar dolu state', () {
      const full = AuthState(
        isAuthenticated: true,
        isLoading: false,
        email: 'a@b.com',
        fullName: 'Ad Soyad',
        role: 'Admin',
        companyId: 'c-1',
      );
      final updated = full.copyWith(role: 'Manager');
      expect(updated.role, 'Manager');
      expect(updated.email, 'a@b.com'); // değişmedi
      expect(updated.companyId, 'c-1'); // değişmedi
    });
  });

  // ─── SapModels ────────────────────────────────────────────────────────────

  group('SapSyncResult.fromJson', () {
    test('tüm alanları doğru ayrıştırır', () {
      final json = {
        'newCount': 5,
        'updatedCount': 3,
        'errorCount': 0,
        'syncTime': '2026-04-12T10:00:00',
        'success': true,
      };
      final result = SapSyncResult.fromJson(json);
      expect(result.newCount, 5);
      expect(result.updatedCount, 3);
      expect(result.errorCount, 0);
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('eksik alanlar için varsayılan değerleri kullanır', () {
      final result = SapSyncResult.fromJson({});
      expect(result.newCount, 0);
      expect(result.updatedCount, 0);
      expect(result.success, isTrue);
    });

    test('errorMessage alanı taşınır', () {
      final result = SapSyncResult.fromJson({
        'success': false,
        'errorMessage': 'SAP bağlantısı reddedildi',
      });
      expect(result.success, isFalse);
      expect(result.errorMessage, 'SAP bağlantısı reddedildi');
    });
  });

  group('SapBudgetItem.fromJson', () {
    test('tüm alanları doğru ayrıştırır', () {
      final json = {
        'id': 'b-1',
        'amount': 15000.50,
        'description': 'Laptop alimi',
        'status': 'pending',
        'createdAt': '2026-04-01T08:00:00',
        'requestedBy': 'Emre Yazici',
        'department': 'IT',
      };
      final item = SapBudgetItem.fromJson(json);
      expect(item.id, 'b-1');
      expect(item.amount, 15000.50);
      expect(item.status, 'pending');
      expect(item.department, 'IT');
      expect(item.requestedBy, 'Emre Yazici');
    });

    test('department opsiyonel — null olabilir', () {
      final item = SapBudgetItem.fromJson({
        'id': 'b-2',
        'amount': 5000.0,
        'description': 'Test',
        'status': 'approved',
        'createdAt': '2026-01-01T00:00:00',
        'requestedBy': 'Admin',
      });
      expect(item.department, isNull);
      expect(item.status, 'approved');
    });
  });

  group('SapConnectionStatus', () {
    test('notConfigured factory doğru değerleri döner', () {
      final status = SapConnectionStatus.notConfigured;
      expect(status.isConfigured, isFalse);
      expect(status.isConnected, isFalse);
    });

    test('fromJson — bağlı durum', () {
      final status = SapConnectionStatus.fromJson({
        'isConfigured': true,
        'isConnected': true,
        'version': '7.5',
      });
      expect(status.isConfigured, isTrue);
      expect(status.isConnected, isTrue);
      expect(status.version, '7.5');
    });
  });

  // ─── DashboardModel ───────────────────────────────────────────────────────

  group('DashboardData.fromJson', () {
    test('temel istatistikleri doğru ayrıştırır', () {
      final json = {
        'totalDevices': 100,
        'assignedDevices': 60,
        'inStorageDevices': 30,
        'expiringWarranties': 8,
        'expiredWarranties': 2,
        'totalEmployees': 50,
        'devicesByType': <String, dynamic>{},
        'upcomingWarrantyExpirations': <dynamic>[],
      };
      final data = DashboardData.fromJson(json);
      expect(data.totalDevices, 100);
      expect(data.assignedDevices, 60);
      expect(data.inStorageDevices, 30);
      expect(data.expiringWarranties, 8);
      expect(data.totalEmployees, 50);
    });

    test('eksik alanlar için sıfır kullanır', () {
      final data = DashboardData.fromJson({});
      expect(data.totalDevices, 0);
      expect(data.expiringWarranties, 0);
      expect(data.upcomingWarrantyExpirations, isEmpty);
    });

    test('devicesByType map ayrıştırılır', () {
      final json = {
        'devicesByType': {'0': 10, '1': 5, '2': 3},
        'upcomingWarrantyExpirations': <dynamic>[],
      };
      final data = DashboardData.fromJson(json);
      expect(data.devicesByType['0'], 10);
      expect(data.devicesByType['1'], 5);
    });
  });

  // ─── OfflineBanner Widget ─────────────────────────────────────────────────

  group('OfflineBanner Widget', () {
    testWidgets('online iken banner görünmez', (tester) async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) {
            final notifier = ConnectivityNotifier.forTest(isOnline: true);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [OfflineBanner(), Text('içerik')],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Cevrimdisi - Kaydedilmis veriler gosteriliyor'), findsNothing);
    });

    testWidgets('offline iken banner görünür', (tester) async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) {
            return ConnectivityNotifier.forTest(isOnline: false);
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [OfflineBanner(), Text('içerik')],
              ),
            ),
          ),
        ),
      );
      expect(find.text('Cevrimdisi - Kaydedilmis veriler gosteriliyor'), findsOneWidget);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';
import 'package:assetflow_mobile/features/notifications/providers/notification_provider.dart';

final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class SignalRService {
  final Ref _ref;
  HubConnection? _connection;
  bool _isConnecting = false;

  SignalRService(this._ref);

  static String get _hubUrl {
    final base = Uri.parse(ApiConstants.baseUrl);
    return '${base.scheme}://${base.host}/hubs/activity';
  }

  Future<void> connect() async {
    if (_isConnecting) return;
    if (_connection != null) return;

    _isConnecting = true;
    try {
      _connection = HubConnectionBuilder()
          .withUrl(
            _hubUrl,
            options: HttpConnectionOptions(
              // Her bağlantı/yeniden bağlantıda storage'dan taze token oku
              // Token süresi dolmuşsa Dio interceptor zaten yenilemiş olur
              accessTokenFactory: () async =>
                  (await TokenManager.instance.getAccessToken()) ?? '',
              transport: HttpTransportType.LongPolling,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _connection!.on('DataChanged', _onDataChanged);
      _connection!.on('NewNotification', _onNewNotification);

      _connection!.onclose(({error}) {
        // ignore: avoid_print
        print('[SignalR] bağlantı kapandı: $error');
      });

      _connection!.onreconnecting(({error}) {
        // ignore: avoid_print
        print('[SignalR] yeniden bağlanıyor: $error');
      });

      _connection!.onreconnected(({connectionId}) {
        // ignore: avoid_print
        print('[SignalR] bağlandı: $connectionId');
      });

      await _connection!.start();
      // ignore: avoid_print
      print('[SignalR] bağlantı kuruldu → $_hubUrl');
    } catch (e) {
      // ignore: avoid_print
      print('[SignalR] bağlantı hatası: $e');
      _connection = null;
      // 5 sn sonra tekrar dene — Dio interceptor token'ı yenilemiş olabilir
      Future.delayed(const Duration(seconds: 5), _retryConnect);
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _retryConnect() async {
    final token = await TokenManager.instance.getAccessToken();
    if (token != null && _connection == null && !_isConnecting) {
      // ignore: avoid_print
      print('[SignalR] yeniden bağlanma denemesi...');
      await connect();
    }
  }

  void _onDataChanged(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final entityType = args[0]?.toString() ?? '';

    switch (entityType) {
      case 'devices':
        _ref.read(deviceProvider.notifier).refresh();
        _ref.invalidate(dashboardProvider);
      case 'assignments':
        _ref.invalidate(recentAssignmentsProvider);
        _ref.invalidate(dashboardProvider);
      case 'employees':
        _ref.invalidate(dashboardProvider);
      case 'dashboard':
        _ref.invalidate(dashboardProvider);
        _ref.invalidate(recentAssignmentsProvider);
    }
  }

  void _onNewNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    final payload = args[0];
    if (payload is! Map) return;

    final title = payload['title']?.toString() ?? 'Bildirim';
    final message = payload['message']?.toString() ?? '';
    final type = (payload['type'] as num?)?.toInt() ?? 4; // 4 = System

    NotificationService.instance.showFromBackend(
      title: title,
      message: message,
      notificationType: type,
    );

    // Bildirim listesini ve badge'i güncelle
    _ref.read(notificationProvider.notifier).load();
  }

  Future<void> dispose() async {
    await _connection?.stop();
    _connection = null;
  }
}

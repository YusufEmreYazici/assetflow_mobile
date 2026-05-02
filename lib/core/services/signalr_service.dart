import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
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

  // Hub URL: baseUrl'deki tenant path'ini çıkar, sadece origin + /hubs/activity
  // Örnek: https://api.mobnet.online/t/guvenok → https://api.mobnet.online/hubs/activity
  static String get _hubUrl {
    final base = Uri.parse(ApiConstants.baseUrl);
    return '${base.scheme}://${base.host}/hubs/activity';
  }

  Future<void> connect(String token) async {
    // Eş zamanlı çift çağrıyı engelle (ref.listen + initState microtask race)
    if (_isConnecting) return;
    if (_connection != null) return; // zaten bağlı

    _isConnecting = true;
    try {
      _connection = HubConnectionBuilder()
          .withUrl(
            _hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              // skipNegotiation YOK — negotiate → WebSocket/SSE/LongPolling otomatik seçilir
              // IIS'de WebSocket manuel aktifleştirilmeden skipNegotiation crash eder
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
      _connection = null; // hata durumunda reset — retry mümkün olsun
    } finally {
      _isConnecting = false;
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

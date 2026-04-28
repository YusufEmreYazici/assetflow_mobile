import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:assetflow_mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:assetflow_mobile/features/devices/providers/device_provider.dart';

const _hubUrl = 'http://10.0.2.2:5160/hubs/activity';

final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService(ref);
  ref.onDispose(service.dispose);
  return service;
});

class SignalRService {
  final Ref _ref;
  HubConnection? _connection;

  SignalRService(this._ref);

  Future<void> connect(String token) async {
    if (_connection != null) await dispose();

    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('DataChanged', _onDataChanged);

    try {
      await _connection!.start();
    } catch (_) {
      // Bağlantı kurulamazsa sessizce geç — offline modda çalışmaya devam et
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

  Future<void> dispose() async {
    await _connection?.stop();
    _connection = null;
  }
}

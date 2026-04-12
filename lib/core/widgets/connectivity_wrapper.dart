import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';

class ConnectivityNotifier extends StateNotifier<bool> {
  Timer? _timer;

  ConnectivityNotifier() : super(true) {
    _startChecking();
  }

  /// Test için — timer başlatmadan sabit durum döner
  ConnectivityNotifier.forTest({required bool isOnline}) : super(isOnline);


  void _startChecking() {
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl);
      final host = uri.host;
      final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      if (!state) state = true;
    } catch (_) {
      if (state) state = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.warning,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.black87),
          SizedBox(width: 6),
          Text(
            'Cevrimdisi - Kaydedilmis veriler gosteriliyor',
            style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

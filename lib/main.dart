import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/app_router.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AssetFlowApp()));
}

class AssetFlowApp extends ConsumerStatefulWidget {
  const AssetFlowApp({super.key});

  @override
  ConsumerState<AssetFlowApp> createState() => _AssetFlowAppState();
}

class _AssetFlowAppState extends ConsumerState<AssetFlowApp> {
  @override
  void initState() {
    super.initState();
    // Check for existing auth tokens on app start
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });

    // Set up ApiClient logout callback to clear auth state
    ApiClient.instance.onLogout = () {
      ref.read(authProvider.notifier).logout();
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AssetFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

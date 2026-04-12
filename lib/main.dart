import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/app_router.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('tr_TR', null);
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
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
      NotificationService.instance.init();
    });

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

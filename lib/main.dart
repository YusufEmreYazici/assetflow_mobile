import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/theme/theme_provider.dart';
import 'package:assetflow_mobile/core/providers/locale_provider.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/services/offline_cache_service.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/app_router.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('tr_TR', null);
  await OfflineCacheService.init();
  await HapticService.init();
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
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'AssetFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: toFlutterThemeMode(themeMode),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      routerConfig: router,
    );
  }
}

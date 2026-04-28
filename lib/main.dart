import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/providers/locale_provider.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/services/offline_cache_service.dart';
import 'package:assetflow_mobile/core/services/signalr_service.dart';
import 'package:assetflow_mobile/core/utils/token_manager.dart';
import 'package:assetflow_mobile/core/utils/api_client.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';
import 'package:assetflow_mobile/app_router.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/l10n/app_localizations.dart';

// Replace with real DSN from https://sentry.io before production deploy
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await initializeDateFormatting('tr_TR', null);
  await OfflineCacheService.init();
  await HapticService.init();

  await SentryFlutter.init((options) {
    options.dsn = _sentryDsn;
    options.tracesSampleRate = 0.2;
    options.environment = const String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    options.release = 'assetflow-mobile@2.3.1+26';
  }, appRunner: () => runApp(const ProviderScope(child: AssetFlowApp())));
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
      ref.read(signalRServiceProvider).dispose();
    };
  }

  Future<void> _connectSignalR() async {
    final token = await TokenManager.instance.getAccessToken();
    if (token != null && mounted) {
      await ref.read(signalRServiceProvider).connect(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (prev, next) {
      final wasAuth = prev?.isAuthenticated ?? false;
      if (!wasAuth && next.isAuthenticated) {
        _connectSignalR();
      } else if (wasAuth && !next.isAuthenticated) {
        ref.read(signalRServiceProvider).dispose();
      }
    });

    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'AssetFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr'), Locale('en')],
      routerConfig: router,
    );
  }
}

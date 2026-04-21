import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/app_shell.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/auth/screens/login_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/register_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/password_email_sent_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:assetflow_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/devices_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/device_detail_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/device_form_screen.dart';
import 'package:assetflow_mobile/features/employees/screens/employees_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assignments_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assign_wizard_screen.dart';
import 'package:assetflow_mobile/features/locations/screens/locations_screen.dart';
import 'package:assetflow_mobile/features/locations/screens/location_list_screen.dart';
import 'package:assetflow_mobile/features/locations/screens/location_detail_screen.dart';
import 'package:assetflow_mobile/features/profile/screens/profile_screen.dart';
import 'package:assetflow_mobile/features/people/person_list_screen.dart';
import 'package:assetflow_mobile/features/people/person_detail_screen.dart';
import 'package:assetflow_mobile/features/sap/screens/sap_screen.dart';
import 'package:assetflow_mobile/features/notifications/notifications_screen.dart';
import 'package:assetflow_mobile/features/audit_log/audit_log_screen.dart';
import 'package:assetflow_mobile/features/profile/screens/settings_screen.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              '$title yakında aktif olacak.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier(0);
  ref.listen(authProvider, (prev, next) {
    refreshNotifier.value++;
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/register' ||
          loc == '/forgot-password' || loc.startsWith('/password-sent') ||
          loc == '/reset-password';

      if (isLoading) return null;
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';

      return null;
    },
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────
      GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/password-sent',
        builder: (_, state) => PasswordEmailSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),

      // ── Shell (authenticated) ────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/devices',
              builder: (_, __) => const DevicesScreen(),
              routes: [
                GoRoute(path: 'new', builder: (_, __) => const DeviceFormScreen()),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => DeviceDetailScreen(
                    id: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, __) => const _PlaceholderScreen('Cihaz Düzenle'),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/employees', builder: (_, __) => const EmployeesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/assignments', builder: (_, __) => const AssignmentsScreen()),
          ]),
        ],
      ),

      // ── Full-page routes (pushed on top of shell) ────────────────────
      GoRoute(
        path: '/assignments/new',
        builder: (_, state) => AssignWizardScreen(
          preselectedDeviceId: state.uri.queryParameters['deviceId'],
        ),
      ),
      GoRoute(
        path: '/assignments/:id/return',
        builder: (_, state) => _PlaceholderScreen('İade Et'),
      ),
      GoRoute(path: '/people',        builder: (_, __) => const PersonListScreen()),
      GoRoute(
        path: '/person/:id',
        builder: (_, state) => PersonDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/locations',    builder: (_, __) => const LocationListScreen()),
      GoRoute(path: '/locations-old', builder: (_, __) => const LocationsScreen()),
      GoRoute(
        path: '/location/:id',
        builder: (_, state) => LocationDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/profile',      builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/sap',          builder: (_, __) => const SapScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/audit-log',    builder: (_, __) => const AuditLogScreen()),
      GoRoute(path: '/excel-export', builder: (_, __) => const _PlaceholderScreen('Excel Export')),
      GoRoute(path: '/settings',     builder: (_, __) => const SettingsScreen()),
    ],
  );
});

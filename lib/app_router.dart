import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/app_shell.dart';
import 'package:assetflow_mobile/core/widgets/page_transitions.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/auth/screens/login_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/register_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/password_email_sent_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:assetflow_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/devices_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/device_detail_screen.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/features/devices/screens/device_form_screen.dart';
import 'package:assetflow_mobile/features/employees/screens/employees_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assignments_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assign_wizard_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assignment_detail_screen.dart';
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
import 'package:assetflow_mobile/features/export/excel_export_screen.dart';

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
      GoRoute(path: '/login',  builder: (ctx, routeState) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, routeState) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (ctx, routeState) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/password-sent',
        builder: (_, state) => PasswordEmailSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(path: '/reset-password', builder: (ctx, routeState) => const ResetPasswordScreen()),

      // ── Shell (authenticated) ────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (ctx, routeState) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/devices',
              builder: (ctx, routeState) => DevicesScreen(
                returnMode: (routeState.extra as Map<String, dynamic>?)?['returnMode'] == true,
                initialSearch: (routeState.extra as Map<String, dynamic>?)?['qrCode'] as String?,
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  pageBuilder: (ctx, routeState) => slideFromBottomPage(
                    key: routeState.pageKey,
                    child: const DeviceFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  pageBuilder: (_, state) => slideFromRightPage(
                    key: state.pageKey,
                    child: DeviceDetailScreen(id: state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      pageBuilder: (ctx, routeState) => slideFromBottomPage(
                        key: routeState.pageKey,
                        child: DeviceFormScreen(
                          device: routeState.extra as Device?,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/employees', builder: (ctx, routeState) => const EmployeesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/assignments', builder: (ctx, routeState) => const AssignmentsScreen()),
          ]),
        ],
      ),

      // ── Full-page routes (pushed on top of shell) ────────────────────
      GoRoute(
        path: '/assignments/new',
        pageBuilder: (_, state) => slideFromBottomPage(
          key: state.pageKey,
          child: AssignWizardScreen(
            preselectedDeviceId: state.uri.queryParameters['deviceId'],
          ),
        ),
      ),
      GoRoute(
        path: '/assignments/:id',
        pageBuilder: (_, state) => slideFromRightPage(
          key: state.pageKey,
          child: AssignmentDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/assignments/:id/return',
        pageBuilder: (ctx, routeState) => slideFromBottomPage(
          key: routeState.pageKey,
          child: const _PlaceholderScreen('İade Et'),
        ),
      ),
      GoRoute(
        path: '/people',
        pageBuilder: (ctx, routeState) => slideFromRightPage(
          key: routeState.pageKey,
          child: const PersonListScreen(),
        ),
      ),
      GoRoute(
        path: '/person/:id',
        pageBuilder: (_, state) => slideFromRightPage(
          key: state.pageKey,
          child: PersonDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/locations',
        pageBuilder: (ctx, routeState) => slideFromRightPage(
          key: routeState.pageKey,
          child: const LocationListScreen(),
        ),
      ),
      GoRoute(path: '/locations-old', builder: (ctx, routeState) => const LocationsScreen()),
      GoRoute(
        path: '/location/:id',
        pageBuilder: (_, state) => slideFromRightPage(
          key: state.pageKey,
          child: LocationDetailScreen(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (ctx, routeState) => slideFromRightPage(
          key: routeState.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(path: '/sap', builder: (ctx, routeState) => const SapScreen()),
      GoRoute(
        path: '/notifications',
        pageBuilder: (ctx, routeState) => slideFromRightPage(
          key: routeState.pageKey,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(path: '/audit-log', builder: (ctx, routeState) => const AuditLogScreen()),
      GoRoute(path: '/excel-export', builder: (ctx, routeState) => const ExcelExportScreen()),
      GoRoute(
        path: '/settings',
        pageBuilder: (ctx, routeState) => slideFromRightPage(
          key: routeState.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
});

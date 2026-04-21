import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/auth/screens/login_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/register_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/password_email_sent_screen.dart';
import 'package:assetflow_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:assetflow_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/devices_screen.dart';
import 'package:assetflow_mobile/features/devices/screens/device_detail_screen.dart';
import 'package:assetflow_mobile/features/employees/screens/employees_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/assignments_screen.dart';
import 'package:assetflow_mobile/features/locations/screens/locations_screen.dart';
import 'package:assetflow_mobile/features/profile/screens/profile_screen.dart';
import 'package:assetflow_mobile/features/sap/screens/sap_screen.dart';
import 'package:assetflow_mobile/core/widgets/connectivity_wrapper.dart';

// Shell route scaffold with bottom navigation
class _ShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        backgroundColor: AppColors.dark800,
        indicatorColor: AppColors.primary600.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 22),
            selectedIcon: Icon(Icons.dashboard, size: 22, color: AppColors.primary400),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_outlined, size: 22),
            selectedIcon: Icon(Icons.devices, size: 22, color: AppColors.primary400),
            label: 'Cihazlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline, size: 22),
            selectedIcon: Icon(Icons.people, size: 22, color: AppColors.primary400),
            label: 'Personel',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined, size: 22),
            selectedIcon: Icon(Icons.assignment, size: 22, color: AppColors.primary400),
            label: 'Zimmet',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz, size: 22),
            selectedIcon: Icon(Icons.more_horiz, size: 22, color: AppColors.primary400),
            label: 'Daha Fazla',
          ),
        ],
      ),
    );
  }
}

// "Daha Fazla" menu - Lokasyonlar + Profil
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daha Fazla')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreTile(
            icon: Icons.location_on,
            color: AppColors.info,
            title: 'Lokasyonlar',
            subtitle: 'Ofis, bina ve oda yonetimi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LocationsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _MoreTile(
            icon: Icons.account_tree_outlined,
            color: const Color(0xFFE8A800),
            title: 'SAP Entegrasyonu',
            subtitle: 'Personel & varlik aktarimi, butce onaylari',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SapScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _MoreTile(
            icon: Icons.person,
            color: AppColors.primary500,
            title: 'Profil & Ayarlar',
            subtitle: 'Hesap bilgileri, sifre degistirme',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/password-sent',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return PasswordEmailSentScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/devices',
                builder: (context, state) => const DevicesScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => DeviceDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/employees',
                builder: (context, state) => const EmployeesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assignments',
                builder: (context, state) => const AssignmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const _MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

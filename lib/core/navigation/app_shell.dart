import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_bottom_nav.dart';
import 'package:assetflow_mobile/core/widgets/app_drawer.dart';
import 'package:assetflow_mobile/core/widgets/connectivity_wrapper.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  BottomNavTab get _activeTab => switch (widget.navigationShell.currentIndex) {
    0 => BottomNavTab.home,
    1 => BottomNavTab.devices,
    2 => BottomNavTab.people,
    _ => BottomNavTab.more,
  };

  static const _branchPaths = ['/', '/devices', '/employees', '/assignments'];

  void _onTabChange(BottomNavTab tab) {
    final index = switch (tab) {
      BottomNavTab.home => 0,
      BottomNavTab.devices => 1,
      BottomNavTab.people => 2,
      BottomNavTab.more => -1,
    };
    if (index < 0) return;

    if (index == widget.navigationShell.currentIndex) {
      // Aynı tab: branch root'a dön.
      // goBranch(initialLocation:true) go_router 14.x'te bazen app
      // initialLocation'ına (/) yönlendiriyor — context.go() daha güvenilir.
      if (index < _branchPaths.length) context.go(_branchPaths[index]);
    } else {
      widget.navigationShell.goBranch(index);
    }
  }

  void _onDrawerNav(String key) {
    switch (key) {
      case 'home':
        _onTabChange(BottomNavTab.home);
      case 'devices':
        _onTabChange(BottomNavTab.devices);
      case 'people':
        _onTabChange(BottomNavTab.people);
      case 'assign':
        context.go('/assignments');
      case 'locations':
        context.push('/locations');
      case 'reports':
        context.push('/reports');
      case 'audit':
        context.push('/audit-log');
      case 'export':
        context.push('/excel-export');
      case 'notif':
        context.push('/notifications');
      case 'sap':
        context.push('/sap');
      case 'settings':
        context.push('/settings');
      case 'profile':
        context.push('/profile');
      case 'consumables':
        context.push('/consumables');
      case 'software-licenses':
        context.push('/software-licenses');
      case 'subscriptions':
        context.push('/subscriptions');
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$key yakında aktif olacak.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.dark800,
          ),
        );
    }
  }

  String _currentDrawerKey() {
    switch (widget.navigationShell.currentIndex) {
      case 0:
        return 'home';
      case 1:
        return 'devices';
      case 2:
        return 'people';
      default:
        return 'home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.fullName ?? authState.email ?? 'Kullanıcı';
    final userEmail = authState.email ?? '';
    final userRole = _roleLabel(authState.role);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceLight,
      endDrawer: AppDrawer(
        currentKey: _currentDrawerKey(),
        userName: userName,
        userEmail: userEmail,
        userRole: userRole,
        company: 'ASSETFLOW',
        onNavigate: _onDrawerNav,
        onLogout: () => ref.read(authProvider.notifier).logout(),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        active: _activeTab,
        onChange: _onTabChange,
        onMore: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
    );
  }

  String _roleLabel(String? role) {
    return switch (role) {
      'Admin' => 'Yönetici',
      'Manager' => 'Müdür',
      'ITAdmin' => 'IT Yönetici',
      _ => role ?? 'Kullanıcı',
    };
  }
}

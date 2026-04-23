import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';

class DashboardAppBar extends StatelessWidget {
  final AuthState authState;
  final int notifCount;
  final bool panelSeen;
  final VoidCallback onNotifTap;

  const DashboardAppBar({
    super.key,
    required this.authState,
    required this.notifCount,
    required this.panelSeen,
    required this.onNotifTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(now);
    final firstName = (authState.fullName ?? 'Kullanıcı').split(' ').first;
    final initials = (authState.fullName ?? 'K')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return SliverAppBar(
      backgroundColor: AppColors.dark900,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      expandedHeight: 100,
      toolbarHeight: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppColors.dark900,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 14,
            20,
            14,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_greeting()}, $firstName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bildirim zili
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onNotifTap,
                    icon: Icon(
                      panelSeen && notifCount == 0
                          ? Icons.notifications_rounded
                          : panelSeen
                          ? Icons.notifications_rounded
                          : Icons.notifications_outlined,
                      color: notifCount > 0
                          ? AppColors.error
                          : panelSeen
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: notifCount > 0
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.dark800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(42, 42),
                    ),
                  ),
                  if (notifCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            notifCount > 99 ? '99+' : '$notifCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Tümü okundu işareti
                  if (panelSeen && notifCount == 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              // Avatar
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary700.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }
}

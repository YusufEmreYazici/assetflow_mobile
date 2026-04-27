import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/constants/api_constants.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/core/utils/cache_manager.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/models/profile_models.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/profile/providers/profile_provider.dart';

final _myActiveAssignmentsProvider =
    FutureProvider.autoDispose<List<Assignment>>((ref) async {
      final result = await AssignmentService().getAll(
        isActive: true,
        pageSize: 5,
      );
      return result.items;
    });

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final profile = profileState.profile;

    final displayName = profile?.fullName ?? authState.fullName ?? 'Kullanıcı';
    final displayEmail = profile?.email ?? authState.email ?? '';
    final displayRole = _roleLabel(profile?.role ?? authState.role);
    final initials = _initials(displayName);

    // Show snackbars for success/error
    ref.listen(profileProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(profileProvider.notifier).clearMessages();
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(profileProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: goBackOrHome(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Avatar with upload button
                GestureDetector(
                  onTap: () => _pickAvatar(context),
                  child: Stack(
                    children: [
                      _buildAvatar(profile, initials, 56),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayEmail,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          displayRole,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          Expanded(
            child: profileState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      40,
                    ),
                    children: [
                      // Stats
                      if (profile != null) ...[
                        _buildStatsRow(profile),
                        const SizedBox(height: 16),
                      ],

                      // Aktif Zimmetlerim
                      _buildActiveAssignments(context),
                      const SizedBox(height: 12),

                      // Hızlı Erişim — Varlıklar
                      _buildAssetQuickAccess(context),
                      const SizedBox(height: 12),

                      // Profil Bilgileri
                      _Section(
                        label: 'PROFİL BİLGİLERİ',
                        children: [
                          _Row(
                            icon: Icons.badge_outlined,
                            label: displayName,
                            caption: 'Ad Soyad',
                            chevron: true,
                            onTap: () => _showEditNameSheet(context),
                          ),
                          _Row(
                            icon: Icons.email_outlined,
                            label: displayEmail,
                            caption: 'E-posta',
                          ),
                          if (profile?.phoneNumber != null &&
                              profile!.phoneNumber!.isNotEmpty)
                            _Row(
                              icon: Icons.phone_outlined,
                              label: profile.phoneNumber!,
                              caption: 'Telefon',
                              chevron: true,
                              onTap: () => _showEditPhoneSheet(
                                context,
                                profile.phoneNumber,
                              ),
                            )
                          else
                            _Row(
                              icon: Icons.phone_outlined,
                              label: 'Telefon ekle',
                              caption: 'Telefon',
                              chevron: true,
                              onTap: () => _showEditPhoneSheet(context, null),
                            ),
                          if (profile?.companyName != null)
                            _Row(
                              icon: Icons.business_outlined,
                              label: profile!.companyName,
                              caption: 'Şirket',
                            ),
                          if (profile?.department != null)
                            _Row(
                              icon: Icons.corporate_fare_outlined,
                              label: profile!.department!,
                              caption: 'Departman',
                            ),
                          if (profile?.title != null)
                            _Row(
                              icon: Icons.work_outline,
                              label: profile!.title!,
                              caption: 'Pozisyon',
                              isLast: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Hesap
                      _Section(
                        label: 'HESAP',
                        children: [
                          _Row(
                            icon: Icons.lock_outline,
                            label: 'Şifreyi Değiştir',
                            chevron: true,
                            onTap: () => _showChangePasswordSheet(context),
                          ),
                          _Row(
                            icon: Icons.delete_sweep_outlined,
                            label: 'Önbelleği Temizle',
                            chevron: true,
                            isLast: true,
                            onTap: () => _clearCache(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tercihler
                      _Section(
                        label: 'TERCİHLER',
                        children: [
                          _Row(
                            icon: Icons.settings_outlined,
                            label: 'Uygulama Ayarları',
                            chevron: true,
                            isLast: true,
                            onTap: () => context.push('/settings'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Hakkında
                      _Section(
                        label: 'HAKKINDA',
                        children: [
                          const _Row(
                            icon: Icons.apps_outlined,
                            label: 'AssetFlow Mobile',
                            caption: 'v2.3.0',
                          ),
                          const _Row(
                            icon: Icons.info_outline,
                            label: 'Lisans Bilgisi',
                            chevron: true,
                          ),
                          const _Row(
                            icon: Icons.policy_outlined,
                            label: 'Gizlilik Politikası',
                            chevron: true,
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Çıkış
                      GestureDetector(
                        onTap: () {
                          HapticService.heavy();
                          _confirmLogout(context);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Çıkış Yap',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────

  Widget _buildAvatar(ProfileDto? profile, String initials, double size) {
    final avatarUrl = profile?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      final fullUrl = '${ApiConstants.baseUrl}$avatarUrl';
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (e, _) {},
        child: null,
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    await ref
        .read(profileProvider.notifier)
        .uploadAvatar(File(result.files.single.path!));
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(ProfileDto profile) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Aktif Zimmet',
            value: '${profile.activeAssignmentCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Toplam Zimmet',
            value: '${profile.totalAssignmentCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Son Giriş',
            value: profile.lastLoginAt != null
                ? _formatDate(profile.lastLoginAt!)
                : '—',
          ),
        ),
      ],
    );
  }

  // ── Active assignments ─────────────────────────────────────────────────────

  Widget _buildActiveAssignments(BuildContext context) {
    final asyncAssignments = ref.watch(_myActiveAssignmentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AKTİF ZİMMETLER',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/assignments'),
                child: Text(
                  'Tümünü Gör',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceDivider),
          ),
          child: asyncAssignments.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.navy,
                ),
              ),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Yüklenemedi',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            data: (assignments) => assignments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aktif zimmet yok.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < assignments.length; i++)
                        _AssignmentRow(
                          assignment: assignments[i],
                          isLast: i == assignments.length - 1,
                          onTap: () =>
                              context.push('/assignments/${assignments[i].id}'),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ── Asset quick access ─────────────────────────────────────────────────────

  Widget _buildAssetQuickAccess(BuildContext context) {
    const items = [
      (
        Icons.inventory_2_outlined,
        'Sarf\nMalzemeleri',
        '/consumables',
        AppColors.warning,
      ),
      (
        Icons.security_outlined,
        'Yazılım\nLisansları',
        '/software-licenses',
        AppColors.navy,
      ),
      (
        Icons.subscriptions_outlined,
        'Abonelikler',
        '/subscriptions',
        AppColors.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'VARLIK YÖNETİMİ',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticService.light();
                    context.push(items[i].$3);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.surfaceDivider),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: items[i].$4.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            items[i].$1,
                            size: 18,
                            color: items[i].$4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          items[i].$2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Bottom sheets ──────────────────────────────────────────────────────────

  void _showEditNameSheet(BuildContext context) {
    final profile = ref.read(profileProvider).profile;
    final ctrl = TextEditingController(text: profile?.fullName ?? '');
    _showEditSheet(
      context: context,
      title: 'Ad Soyad',
      child: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          labelText: 'Ad Soyad',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      onSave: () async {
        if (ctrl.text.trim().length < 2) return;
        Navigator.pop(context);
        final p = profile!;
        await ref
            .read(profileProvider.notifier)
            .updateProfile(
              UpdateProfileRequest(
                fullName: ctrl.text.trim(),
                phoneNumber: p.phoneNumber,
                language: p.language,
                timeZone: p.timeZone,
              ),
            );
      },
    );
  }

  void _showEditPhoneSheet(BuildContext context, String? current) {
    final profile = ref.read(profileProvider).profile;
    final ctrl = TextEditingController(text: current ?? '');
    _showEditSheet(
      context: context,
      title: 'Telefon',
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Telefon',
          hintText: '+90 5XX XXX XX XX',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      onSave: () async {
        Navigator.pop(context);
        final p = profile!;
        await ref
            .read(profileProvider.notifier)
            .updateProfile(
              UpdateProfileRequest(
                fullName: p.fullName,
                phoneNumber: ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
                language: p.language,
                timeZone: p.timeZone,
              ),
            );
      },
    );
  }

  void _showEditSheet({
    required BuildContext context,
    required String title,
    required Widget child,
    required Future<void> Function() onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.surfaceDivider),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'İptal',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          String err = '';
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şifre Değiştir',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mevcut Şifre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre (tekrar)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (err.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    err,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    if (newCtrl.text != confirmCtrl.text) {
                      setModalState(() => err = 'Şifreler eşleşmiyor.');
                      return;
                    }
                    if (newCtrl.text.length < 6) {
                      setModalState(() => err = 'En az 6 karakter olmalı.');
                      return;
                    }
                    Navigator.pop(ctx);
                    await ref
                        .read(profileProvider.notifier)
                        .changePassword(currentCtrl.text, newCtrl.text);
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Değiştir',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.toUpperCase();
  }

  String _roleLabel(String? role) => switch (role) {
    'Admin' => 'YÖNETİCİ',
    'SuperAdmin' => 'SÜPER YÖNETİCİ',
    'User' => 'KULLANICI',
    _ => role?.toUpperCase() ?? '',
  };

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumunuzu kapatmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              HapticService.heavy();
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context) async {
    await CacheManager.instance.clearAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önbellek temizlendi.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceDivider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final Assignment assignment;
  final bool isLast;
  final VoidCallback onTap;

  const _AssignmentRow({
    required this.assignment,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceLabel = assignment.deviceName ?? 'Cihaz';
    final subLabel = [
      assignment.deviceBrand,
      assignment.deviceModel,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
    final date =
        '${assignment.assignedAt.day}.${assignment.assignedAt.month.toString().padLeft(2, '0')}.${assignment.assignedAt.year}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceDivider),
                ),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.devices_outlined,
                size: 16,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subLabel.isNotEmpty)
                    Text(
                      subLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? caption;
  final bool chevron;
  final bool isLast;
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.caption,
    this.chevron = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticService.light();
              onTap!();
            },
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceDivider),
                ),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 16, color: AppColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (chevron)
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

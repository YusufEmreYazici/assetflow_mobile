import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';
import 'package:assetflow_mobile/features/audit_log/providers/audit_log_provider.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  final _scrollController = ScrollController();

  static const _actionFilters = [
    (null, 'Tümü'),
    ('Create', 'Oluşturma'),
    ('Update', 'Güncelleme'),
    ('Delete', 'Silme'),
    ('Assign', 'Zimmet'),
    ('Return', 'İade'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auditLogProvider.notifier).load(reset: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(auditLogProvider.notifier).load();
    }
  }

  Map<String, List<AuditLog>> _grouped(List<AuditLog> logs) {
    final fmt = DateFormat('d MMMM yyyy', 'tr_TR');
    final result = <String, List<AuditLog>>{};
    for (final log in logs) {
      final key = fmt.format(log.timestamp.toLocal());
      (result[key] ??= []).add(log);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditLogProvider);
    final notifier = ref.read(auditLogProvider.notifier);
    final grouped = _grouped(state.logs);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 18,
            ),
            child: Row(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Audit Log',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),

          // Action filter chips
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              itemCount: _actionFilters.length,
              separatorBuilder: (context2, i) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final (action, label) = _actionFilters[i];
                final active = state.filterAction == action;
                return GestureDetector(
                  onTap: () => notifier.setFilterAction(action),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active ? AppColors.navy : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? AppColors.navy
                            : AppColors.surfaceInputBorder,
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Error banner
          if (state.error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yüklenemedi. Tekrar deneyin.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.load(reset: true),
                    child: const Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: state.isLoading
                ? _buildShimmer()
                : state.logs.isEmpty
                ? const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'Kayıt bulunamadı',
                    description: 'Seçili filtrelere uygun işlem kaydı yok.',
                  )
                : RefreshIndicator(
                    color: AppColors.navy,
                    onRefresh: () => notifier.load(reset: true),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        20,
                      ),
                      children: [
                        ...grouped.entries.expand(
                          (e) => [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 8),
                              child: Text(
                                e.key,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.surfaceDivider,
                                ),
                              ),
                              child: Column(
                                children: e.value.asMap().entries.map((entry) {
                                  final isLast =
                                      entry.key == e.value.length - 1;
                                  return _LogRow(
                                    log: entry.value,
                                    isLast: isLast,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.navy,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        if (!state.hasMore && state.logs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Tüm kayıtlar yüklendi (${state.logs.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDivider,
      highlightColor: AppColors.surfaceWhite,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        itemCount: 8,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final AuditLog log;
  final bool isLast;
  const _LogRow({required this.log, required this.isLast});

  Color get _actionColor => switch (log.action.toLowerCase()) {
    'create' => AppColors.success,
    'update' => AppColors.info,
    'delete' => AppColors.error,
    'assign' => const Color(0xFF7C3AED),
    'return' => const Color(0xFFF59E0B),
    _ => AppColors.textTertiary,
  };

  String get _actionLabel => switch (log.action.toLowerCase()) {
    'create' => 'OLUŞTURMA',
    'update' => 'GÜNCELLEME',
    'delete' => 'SİLME',
    'assign' => 'ZİMMET',
    'return' => 'İADE',
    _ => log.action.toUpperCase(),
  };

  String get _relTime {
    final diff = DateTime.now().difference(log.timestamp.toLocal());
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('dd.MM.yyyy', 'tr_TR').format(log.timestamp.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: _actionColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _actionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _actionLabel,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _actionColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.entityName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  log.entityId,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${log.userEmail ?? 'Sistem'} · $_relTime',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

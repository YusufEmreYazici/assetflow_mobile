import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String? _filterAction;

  static const _filters = [
    (null, 'Tümü'),
    ('Create', 'Oluşturma'),
    ('Update', 'Güncelleme'),
    ('Delete', 'Silme'),
  ];

  static final _mockLogs = [
    _Log(id: '1', action: 'Update', entity: 'Cihaz', user: 'admin@assetflow.io', desc: 'ThinkPad T14 durumu güncellendi', time: DateTime.now().subtract(const Duration(minutes: 5))),
    _Log(id: '2', action: 'Create', entity: 'Zimmet', user: 'it@assetflow.io', desc: 'Samsung S27A600N zimmetlendi → Ahmet Yılmaz', time: DateTime.now().subtract(const Duration(hours: 1))),
    _Log(id: '3', action: 'Update', entity: 'Personel', user: 'hr@assetflow.io', desc: 'Mehmet Öztürk departmanı güncellendi', time: DateTime.now().subtract(const Duration(hours: 2))),
    _Log(id: '4', action: 'Create', entity: 'Cihaz', user: 'admin@assetflow.io', desc: 'HP LaserJet Pro M404n eklendi', time: DateTime.now().subtract(const Duration(hours: 5))),
    _Log(id: '5', action: 'Delete', entity: 'Lokasyon', user: 'admin@assetflow.io', desc: 'Eski İzmir Ofisi lokasyonu silindi', time: DateTime.now().subtract(const Duration(hours: 8))),
    _Log(id: '6', action: 'Update', entity: 'Cihaz', user: 'it@assetflow.io', desc: 'Dell XPS 15 seri numarası güncellendi', time: DateTime.now().subtract(const Duration(days: 1))),
    _Log(id: '7', action: 'Create', entity: 'Personel', user: 'hr@assetflow.io', desc: 'Yeni personel Fatma Kaya eklendi', time: DateTime.now().subtract(const Duration(days: 1))),
    _Log(id: '8', action: 'Update', entity: 'Zimmet', user: 'it@assetflow.io', desc: 'Lenovo X1 Carbon iade alındı', time: DateTime.now().subtract(const Duration(days: 2))),
    _Log(id: '9', action: 'Create', entity: 'Lokasyon', user: 'admin@assetflow.io', desc: 'Aliağa Rafineri lokasyonu eklendi', time: DateTime.now().subtract(const Duration(days: 3))),
    _Log(id: '10', action: 'Delete', entity: 'Cihaz', user: 'admin@assetflow.io', desc: 'Eski HP Compaq silindi', time: DateTime.now().subtract(const Duration(days: 4))),
  ];

  List<_Log> _filtered() => _filterAction == null
      ? _mockLogs
      : _mockLogs.where((l) => l.action == _filterAction).toList();

  Map<String, List<_Log>> _grouped(List<_Log> logs) {
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final Map<String, List<_Log>> result = {};
    for (final log in logs) {
      final key = dateFormat.format(log.time);
      (result[key] ??= []).add(log);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    final grouped = _grouped(filtered);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
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
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Audit Log',
                  style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final (action, label) = _filters[i];
                final active = _filterAction == action;
                return GestureDetector(
                  onTap: () => setState(() => _filterAction = action),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.navy : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active ? AppColors.navy : AppColors.surfaceInputBorder,
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: active ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Kayıt bulunamadı.',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 20,
                    ),
                    children: grouped.entries.expand((e) => [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Text(
                          e.key,
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.surfaceDivider),
                        ),
                        child: Column(
                          children: e.value.asMap().entries.map((entry) {
                            final isLast = entry.key == e.value.length - 1;
                            return _LogRow(log: entry.value, isLast: isLast);
                          }).toList(),
                        ),
                      ),
                    ]).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Log {
  final String id;
  final String action;
  final String entity;
  final String user;
  final String desc;
  final DateTime time;
  const _Log({
    required this.id,
    required this.action,
    required this.entity,
    required this.user,
    required this.desc,
    required this.time,
  });
}

class _LogRow extends StatelessWidget {
  final _Log log;
  final bool isLast;
  const _LogRow({required this.log, required this.isLast});

  Color get _actionColor => switch (log.action) {
        'Create' => AppColors.success,
        'Update' => AppColors.info,
        'Delete' => AppColors.error,
        _ => AppColors.textTertiary,
      };

  String get _relTime {
    final diff = DateTime.now().difference(log.time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceDivider)),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _actionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.action.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w500,
                          color: _actionColor, letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.entity,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  log.desc,
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${log.user} · $_relTime',
                  style: GoogleFonts.inter(
                    fontSize: 10, color: AppColors.textTertiary,
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

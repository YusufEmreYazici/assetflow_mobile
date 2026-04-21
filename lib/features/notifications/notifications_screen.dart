import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tabIndex = 0;
  final Set<String> _readIds = {};

  static const _tabs = ['Tümü', 'Okunmamış', 'Garanti', 'Sistem'];

  static final _mockNotifications = [
    _Notif(
      id: '1',
      kind: _NotifKind.warning,
      title: 'Garanti Süresi Yaklaşıyor',
      detail: 'ThinkPad T14 cihazının garantisi 14 gün içinde sona eriyor.',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      category: 'warranty',
    ),
    _Notif(
      id: '2',
      kind: _NotifKind.success,
      title: 'Zimmet Tamamlandı',
      detail: 'Samsung S27A600N monitörü Ahmet Yılmaz\'a zimmetlendi.',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      category: 'assignment',
    ),
    _Notif(
      id: '3',
      kind: _NotifKind.info,
      title: 'Cihaz İade Edildi',
      detail: 'Dell XPS 15 iyi durumda iade edildi.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      category: 'assignment',
    ),
    _Notif(
      id: '4',
      kind: _NotifKind.warning,
      title: 'Garanti Süresi Doldu',
      detail: 'HP LaserJet Pro M404n yazıcısının garantisi sona erdi.',
      time: DateTime.now().subtract(const Duration(hours: 6)),
      category: 'warranty',
    ),
    _Notif(
      id: '5',
      kind: _NotifKind.system,
      title: 'Haftalık Rapor Hazır',
      detail: '18-25 Nisan 2026 haftalık varlık raporu oluşturuldu.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      category: 'system',
    ),
    _Notif(
      id: '6',
      kind: _NotifKind.warning,
      title: '3 Cihaz Garantisi Yaklaşıyor',
      detail: 'Önümüzdeki 30 gün içinde 3 cihazın garantisi sona eriyor.',
      time: DateTime.now().subtract(const Duration(days: 2)),
      category: 'warranty',
    ),
    _Notif(
      id: '7',
      kind: _NotifKind.system,
      title: 'Sistem Bakımı',
      detail: 'Pazar gecesi 02:00-04:00 arası planlı bakım yapılacak.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      category: 'system',
    ),
  ];

  List<_Notif> _filtered() {
    return _mockNotifications.where((n) {
      switch (_tabIndex) {
        case 1:
          return !_readIds.contains(n.id);
        case 2:
          return n.category == 'warranty';
        case 3:
          return n.category == 'system';
        default:
          return true;
      }
    }).toList();
  }

  void _markAllRead() {
    setState(() {
      for (final n in _mockNotifications) {
        _readIds.add(n.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    final unreadCount = _mockNotifications
        .where((n) => !_readIds.contains(n.id))
        .length;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bildirimler',
                        style: GoogleFonts.inter(
                          fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white,
                        ),
                      ),
                      if (unreadCount > 0)
                        Text(
                          '$unreadCount okunmamış',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Text(
                      'Tümünü Oku',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Tab bar
          Container(
            color: AppColors.surfaceWhite,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceDivider),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  final isActive = e.key == _tabIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive ? AppColors.navy : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.navy : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Bildirim bulunamadı.',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _NotifCard(
                      notif: filtered[i],
                      isRead: _readIds.contains(filtered[i].id),
                      onTap: () => setState(() => _readIds.add(filtered[i].id)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _NotifKind { success, warning, info, system }

class _Notif {
  final String id;
  final _NotifKind kind;
  final String title;
  final String detail;
  final DateTime time;
  final String category;
  const _Notif({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.time,
    required this.category,
  });
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final bool isRead;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.isRead, required this.onTap});

  IconData get _icon => switch (notif.kind) {
        _NotifKind.success => Icons.check_circle_outline,
        _NotifKind.warning => Icons.warning_amber_outlined,
        _NotifKind.info => Icons.info_outline,
        _NotifKind.system => Icons.settings_outlined,
      };

  Color get _color => switch (notif.kind) {
        _NotifKind.success => AppColors.success,
        _NotifKind.warning => AppColors.warning,
        _NotifKind.info => AppColors.info,
        _NotifKind.system => AppColors.textSecondary,
      };

  Color get _bgColor => switch (notif.kind) {
        _NotifKind.success => AppColors.successBg,
        _NotifKind.warning => AppColors.warningBg,
        _NotifKind.info => AppColors.infoBg,
        _NotifKind.system => AppColors.surfaceLight,
      };

  String _relativeTime() {
    final diff = DateTime.now().difference(notif.time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM', 'tr_TR').format(notif.time);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surfaceWhite : _bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isRead ? AppColors.surfaceDivider : _color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: isRead ? 0.08 : 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(_icon, size: 18, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.detail,
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(),
                    style: GoogleFonts.inter(
                      fontSize: 10, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

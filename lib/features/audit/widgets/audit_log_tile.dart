import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';
import 'audit_log_detail_sheet.dart';

class AuditLogTile extends StatelessWidget {
  final AuditLog log;

  const AuditLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconColorFor(log.action);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
      title: Text(
        _actionLabel(log.action, log.entityName),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${log.userEmail ?? 'Bilinmiyor'} · ${_formatDate(log.timestamp)}',
        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          size: 18,
          color: AppColors.textTertiary,
        ),
        color: AppColors.dark800,
        onSelected: (_) => _showDetail(context),
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'detail',
            child: Text(
              'Detayları Göster',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuditLogDetailSheet(log: log),
    );
  }

  static (IconData, Color) _iconColorFor(String action) => switch (action) {
    'Create' => (Icons.add_circle_outline, AppColors.success),
    'Update' => (Icons.edit_outlined, AppColors.info),
    'Delete' => (Icons.delete_outline, AppColors.error),
    _ => (Icons.history, AppColors.textTertiary),
  };

  static String _actionLabel(String action, String entityName) {
    final entity = _entityLabel(entityName);
    return switch (action) {
      'Create' => '$entity oluşturuldu',
      'Update' => '$entity güncellendi',
      'Delete' => '$entity silindi',
      _ => '$entity: $action',
    };
  }

  static String _entityLabel(String entityName) => switch (entityName) {
    'Device' => 'Cihaz',
    'Assignment' => 'Zimmet',
    'AssignmentForm' => 'Form',
    _ => entityName,
  };

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return DateFormat('dd MMM, HH:mm', 'tr_TR').format(dt);
  }
}

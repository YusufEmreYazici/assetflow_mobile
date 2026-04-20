import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';

class AuditLogDetailSheet extends StatelessWidget {
  final AuditLog log;

  const AuditLogDetailSheet({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.dark800,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _actionLabel(log.action, log.entityName),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  _InfoSection(
                    rows: [
                      if (log.userEmail != null)
                        _DetailRow('Kullanıcı', log.userEmail!),
                      if (log.ipAddress != null)
                        _DetailRow('IP Adresi', log.ipAddress!),
                      _DetailRow(
                        'Tarih',
                        DateFormat('dd MMM yyyy HH:mm', 'tr_TR')
                            .format(log.timestamp),
                      ),
                      _DetailRow('Varlık Tipi', _entityLabel(log.entityName)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (log.action == 'Update' &&
                      log.affectedColumns != null &&
                      log.affectedColumns!.isNotEmpty) ...[
                    _ValuesSection(
                      title: 'Değişen Alanlar',
                      icon: Icons.compare_arrows,
                      color: AppColors.info,
                      child: _ChangesTable(
                        columns: log.affectedColumns!,
                        oldValues: log.oldValues ?? {},
                        newValues: log.newValues ?? {},
                      ),
                    ),
                  ] else if (log.action == 'Create' &&
                      log.newValues != null &&
                      log.newValues!.isNotEmpty) ...[
                    _ValuesSection(
                      title: 'Oluşturulan Değerler',
                      icon: Icons.add_circle_outline,
                      color: AppColors.success,
                      child: _ValuesList(values: log.newValues!),
                    ),
                  ] else if (log.action == 'Delete' &&
                      log.oldValues != null &&
                      log.oldValues!.isNotEmpty) ...[
                    _ValuesSection(
                      title: 'Silinen Değerler',
                      icon: Icons.delete_outline,
                      color: AppColors.error,
                      child: _ValuesList(values: log.oldValues!),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Kapat'),
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
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
}

class _InfoSection extends StatelessWidget {
  final List<_DetailRow> rows;
  const _InfoSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dark900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    e.value.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.value.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ValuesSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _ValuesSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dark900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    );
  }
}

class _ChangesTable extends StatelessWidget {
  final List<String> columns;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;

  const _ChangesTable({
    required this.columns,
    required this.oldValues,
    required this.newValues,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: columns.asMap().entries.map((e) {
        final isLast = e.key == columns.length - 1;
        final col = e.value;
        final oldVal = oldValues[col]?.toString() ?? '-';
        final newVal = newValues[col]?.toString() ?? '-';
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                col,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      oldVal,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.error,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  Expanded(
                    child: Text(
                      newVal,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast)
                const Divider(height: 14, color: AppColors.border),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ValuesList extends StatelessWidget {
  final Map<String, dynamic> values;
  const _ValuesList({required this.values});

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.where((e) => e.value != null).toList();
    return Column(
      children: entries.asMap().entries.map((e) {
        final isLast = e.key == entries.length - 1;
        final entry = e.value;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

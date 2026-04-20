import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/data/models/audit_log_model.dart';

class AuditLogTile extends StatelessWidget {
  final AuditLog log;

  const AuditLogTile({super.key, required this.log});

  bool get _hasDetails {
    if (log.action == 'Create' &&
        log.newValues != null &&
        log.newValues!.isNotEmpty) {
      return true;
    }
    if (log.action == 'Delete' &&
        log.oldValues != null &&
        log.oldValues!.isNotEmpty) {
      return true;
    }
    if (log.action == 'Update' &&
        log.affectedColumns != null &&
        log.affectedColumns!.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconColorFor(log.action);

    if (!_hasDetails) {
      return ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _buildIcon(icon, color),
        title: Text(
          _actionLabel(log.action, log.entityName),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${log.userEmail ?? 'Bilinmiyor'} · ${_relativeTime(log.timestamp)}',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: _buildIcon(icon, color),
        title: Text(
          _actionLabel(log.action, log.entityName),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${log.userEmail ?? 'Bilinmiyor'} · ${_relativeTime(log.timestamp)}',
          style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        children: _buildDetailRows(),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      );

  List<Widget> _buildDetailRows() {
    if (log.action == 'Update' && log.affectedColumns != null) {
      return log.affectedColumns!.map((field) {
        final oldVal = _formatValue(log.oldValues?[field]);
        final newVal = _formatValue(log.newValues?[field]);
        return _buildDiffRow(_fieldLabel(field), oldVal, newVal);
      }).toList();
    }

    if (log.action == 'Create' && log.newValues != null) {
      return log.newValues!.entries
          .map((e) => _buildValueRow(_fieldLabel(e.key), _formatValue(e.value)))
          .toList();
    }

    if (log.action == 'Delete' && log.oldValues != null) {
      return log.oldValues!.entries
          .map((e) => _buildValueRow(_fieldLabel(e.key), _formatValue(e.value)))
          .toList();
    }

    return const [];
  }

  Widget _buildDiffRow(String label, String oldVal, String newVal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  oldVal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.error,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  newVal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
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

  static String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return DateFormat('d MMM, HH:mm', 'tr_TR').format(t);
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is String &&
        RegExp(r'^\d{4}-\d{2}-\d{2}T').hasMatch(value)) {
      try {
        return DateFormat('d MMM yyyy, HH:mm', 'tr_TR')
            .format(DateTime.parse(value).toLocal());
      } catch (_) {
        return value;
      }
    }
    if (value is num) return value.toString();
    if (value is bool) return value ? 'Evet' : 'Hayır';
    return value.toString();
  }

  static String _fieldLabel(String field) => switch (field) {
        'Name' => 'Ad',
        'Brand' => 'Marka',
        'Model' => 'Model',
        'SerialNumber' => 'Seri No',
        'AssetCode' => 'Demirbaş Kodu',
        'Status' => 'Durum',
        'Type' => 'Tip',
        'Notes' => 'Notlar',
        'PurchaseDate' => 'Satın Alma Tarihi',
        'PurchasePrice' => 'Satın Alma Fiyatı',
        'Supplier' => 'Tedarikçi',
        'WarrantyEndDate' => 'Garanti Bitiş',
        'WarrantyDurationMonths' => 'Garanti (Ay)',
        'LocationId' => 'Lokasyon',
        'CpuInfo' => 'İşlemci',
        'RamInfo' => 'RAM',
        'StorageInfo' => 'Depolama',
        'GpuInfo' => 'Ekran Kartı',
        'HostName' => 'Hostname',
        'OsInfo' => 'İşletim Sistemi',
        'MacAddress' => 'MAC Adresi',
        'IpAddress' => 'IP Adresi',
        'BiosVersion' => 'BIOS',
        'MotherboardInfo' => 'Anakart',
        'AssignedAt' => 'Atama Tarihi',
        'ReturnedAt' => 'İade Tarihi',
        'ReturnCondition' => 'İade Durumu',
        'ReturnNotes' => 'İade Notları',
        'EmployeeId' => 'Personel',
        'DeviceId' => 'Cihaz',
        'AssetTag' => 'Zimmet No',
        'ExpectedReturnDate' => 'Beklenen İade',
        'AssignedByUserId' => 'Atayan',
        'UserId' => 'Kullanıcı',
        'CreatedByUserId' => 'Oluşturan',
        'GeneratedByUserId' => 'Form Üreten',
        'SignedUploadedByUserId' => 'İmza Yükleyen',
        'GeneratedFilePath' => 'Form Dosyası',
        'SignedFilePath' => 'İmzalı Dosya',
        'FormNumber' => 'Form No',
        'AssignmentId' => 'Zimmet',
        _ => field,
      };
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/kv_row.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceGeneralTab extends StatelessWidget {
  final Device device;
  const DeviceGeneralTab({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final typeLabel = deviceTypeLabels[device.type] ?? 'Cihaz';
    final statusLabel = deviceStatusLabels[device.status] ?? '?';

    final bool hasPurchase = device.purchaseDate != null ||
        device.purchasePrice != null ||
        device.supplier != null;
    final bool hasWarranty = device.warrantyDurationMonths != null ||
        device.warrantyEndDate != null;
    final bool hasNotes = device.notes != null && device.notes!.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100,
      ),
      children: [
        _Section(
          label: 'GENEL BİLGİ',
          children: [
            KvRow(label: 'Cihaz Tipi', value: typeLabel),
            KvRow(label: 'Durum', value: statusLabel),
            if (device.brand != null)
              KvRow(label: 'Marka', value: device.brand!),
            if (device.model != null)
              KvRow(label: 'Model', value: device.model!),
            if (device.serialNumber != null)
              KvRow(label: 'Seri No', value: device.serialNumber!, mono: true),
            if (device.assetCode != null)
              KvRow(label: 'Demirbaş Kodu', value: device.assetCode!, mono: true),
            if (device.locationName != null)
              KvRow(label: 'Lokasyon', value: device.locationName!),
            KvRow(
              label: 'Zimmmetli',
              value: device.assignedTo ?? '—',
              last: true,
            ),
          ],
        ),
        if (hasPurchase) ...[
          const SizedBox(height: 12),
          _Section(
            label: 'SATIN ALMA',
            children: [
              if (device.purchaseDate != null)
                KvRow(
                  label: 'Tarih',
                  value: dateFormat.format(device.purchaseDate!),
                ),
              if (device.purchasePrice != null)
                KvRow(
                  label: 'Fiyat',
                  value:
                      '${NumberFormat('#,##0.00', 'tr_TR').format(device.purchasePrice)} ₺',
                ),
              if (device.supplier != null)
                KvRow(label: 'Tedarikçi', value: device.supplier!, last: true),
              if (device.supplier == null && device.purchasePrice != null)
                KvRow(
                  label: 'Fiyat',
                  value:
                      '${NumberFormat('#,##0.00', 'tr_TR').format(device.purchasePrice)} ₺',
                  last: true,
                ),
            ],
          ),
        ],
        if (hasWarranty) ...[
          const SizedBox(height: 12),
          _Section(
            label: 'GARANTİ',
            children: [
              if (device.warrantyDurationMonths != null)
                KvRow(
                  label: 'Süre',
                  value: '${device.warrantyDurationMonths} Ay',
                ),
              if (device.warrantyEndDate != null)
                KvRow(
                  label: 'Bitiş Tarihi',
                  value: dateFormat.format(device.warrantyEndDate!),
                ),
              if (device.warrantyStatus != null)
                KvRow(
                  label: 'Garanti Durumu',
                  value: _warrantyLabel(device.warrantyStatus!),
                  last: true,
                ),
            ],
          ),
        ],
        if (hasNotes) ...[
          const SizedBox(height: 12),
          _Section(
            label: 'NOTLAR',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  device.notes!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _warrantyLabel(int status) => switch (status) {
        0 => 'Garanti Yok',
        1 => 'Garantide',
        2 => 'Yakında Bitiyor',
        3 => 'Süresi Dolmuş',
        _ => '?',
      };
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
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
          ...children,
        ],
      ),
    );
  }
}

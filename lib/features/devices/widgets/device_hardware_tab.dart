import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/kv_row.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';

class DeviceHardwareTab extends StatelessWidget {
  final Device device;
  const DeviceHardwareTab({super.key, required this.device});

  bool get _hasHardware =>
      device.cpuInfo != null ||
      device.ramInfo != null ||
      device.storageInfo != null ||
      device.gpuInfo != null ||
      device.hostName != null ||
      device.osInfo != null ||
      device.biosVersion != null ||
      device.motherboardInfo != null;

  bool get _hasNetwork =>
      device.ipAddress != null || device.macAddress != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasHardware && !_hasNetwork) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.memory_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Donanım bilgisi girilmemiş',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100,
      ),
      children: [
        if (_hasHardware)
          _Section(
            label: 'DONANIM',
            children: [
              if (device.hostName != null)
                KvRow(label: 'Hostname', value: device.hostName!, mono: true),
              if (device.osInfo != null)
                KvRow(label: 'İşletim Sistemi', value: device.osInfo!),
              if (device.cpuInfo != null)
                KvRow(label: 'İşlemci', value: device.cpuInfo!),
              if (device.ramInfo != null)
                KvRow(label: 'RAM', value: device.ramInfo!),
              if (device.storageInfo != null)
                KvRow(label: 'Depolama', value: device.storageInfo!),
              if (device.gpuInfo != null)
                KvRow(label: 'Ekran Kartı', value: device.gpuInfo!),
              if (device.biosVersion != null)
                KvRow(
                  label: 'BIOS',
                  value: device.biosVersion!,
                  mono: true,
                ),
              if (device.motherboardInfo != null)
                KvRow(
                  label: 'Anakart',
                  value: device.motherboardInfo!,
                  last: true,
                ),
            ],
          ),
        if (_hasHardware && _hasNetwork) const SizedBox(height: 12),
        if (_hasNetwork)
          _Section(
            label: 'AĞ',
            children: [
              if (device.ipAddress != null)
                KvRow(
                  label: 'IP Adresi',
                  value: device.ipAddress!,
                  mono: true,
                ),
              if (device.macAddress != null)
                KvRow(
                  label: 'MAC Adresi',
                  value: device.macAddress!,
                  mono: true,
                  last: true,
                ),
            ],
          ),
      ],
    );
  }
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

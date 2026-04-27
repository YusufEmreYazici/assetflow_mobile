import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/utils/notification_settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  Map<String, bool> _settings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await NotificationSettings.instance.getAll();
    if (mounted)
      setState(() {
        _settings = settings;
        _loading = false;
      });
  }

  Future<void> _toggle(String channel, bool value) async {
    await NotificationSettings.instance.setEnabled(channel, value);
    setState(() => _settings[channel] = value);
  }

  static const Map<String, IconData> _icons = {
    NotificationSettings.assignments: Icons.assignment_turned_in_outlined,
    NotificationSettings.warranty: Icons.shield_outlined,
    NotificationSettings.devices: Icons.devices_outlined,
    NotificationSettings.sap: Icons.sync_outlined,
    NotificationSettings.system: Icons.bar_chart_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.infoLight.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.35),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 16,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kanal bazında bildirimleri açıp kapatabilirsiniz. '
                          'Kapalı kanaldan hiçbir bildirim gönderilmez.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...NotificationSettings.allChannels.map((ch) {
                  final enabled = _settings[ch] ?? true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.dark800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: enabled
                              ? AppColors.primary600.withValues(alpha: 0.12)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _icons[ch] ?? Icons.notifications_outlined,
                          size: 20,
                          color: enabled
                              ? AppColors.primary400
                              : AppColors.textTertiary,
                        ),
                      ),
                      title: Text(
                        NotificationSettings.channelLabels[ch] ?? ch,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      subtitle: Text(
                        NotificationSettings.channelDescriptions[ch] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      value: enabled,
                      onChanged: (v) => _toggle(ch, v),
                      activeThumbColor: AppColors.primary500,
                      inactiveThumbColor: AppColors.textTertiary,
                      inactiveTrackColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

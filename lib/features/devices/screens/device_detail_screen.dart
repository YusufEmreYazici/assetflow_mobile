import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_tab_bar.dart';
import 'package:assetflow_mobile/data/models/device_model.dart';
import 'package:assetflow_mobile/data/services/device_service.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_detail_header.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_general_tab.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_hardware_tab.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_assignments_tab.dart';
import 'package:assetflow_mobile/features/devices/widgets/device_history_tab.dart';

final _deviceDetailProvider =
    FutureProvider.autoDispose.family<Device, String>((ref, id) async {
  return DeviceService().getById(id);
});

class DeviceDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const DeviceDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends ConsumerState<DeviceDetailScreen> {
  int _tabIndex = 0;
  final _pageController = PageController();

  static const _tabs = ['Genel', 'Donanım', 'Zimmetler', 'Geçmiş'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int i) {
    setState(() => _tabIndex = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_deviceDetailProvider(widget.id));

    return async.when(
      loading: () => _buildLoading(),
      error: (err, _) => _buildError(err),
      data: (device) => _buildDetail(device),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            color: AppColors.navy,
            height: MediaQuery.of(context).padding.top + 90,
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.navy,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object err) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          Container(
            color: AppColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              left: AppSpacing.lg,
              bottom: 18,
            ),
            child: GestureDetector(
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
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      'Cihaz yüklenemedi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => ref.invalidate(_deviceDetailProvider(widget.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          'Tekrar Dene',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(Device device) {
    final hasActiveAssignment = device.activeAssignmentId != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          DeviceDetailHeader(
            device: device,
            onEdit: () async {
              final result = await context.push('/devices/${widget.id}/edit');
              if (result == true) {
                ref.invalidate(_deviceDetailProvider(widget.id));
              }
            },
          ),
          AppTabBar(
            tabs: _tabs,
            activeIndex: _tabIndex,
            onChanged: _onTabChanged,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _tabIndex = i),
              children: [
                DeviceGeneralTab(device: device),
                DeviceHardwareTab(device: device),
                DeviceAssignmentsTab(deviceId: device.id),
                DeviceHistoryTab(deviceId: device.id),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (hasActiveAssignment) {
            _showReturnDialog(device);
          } else {
            context.push('/assignments/new?deviceId=${device.id}');
          }
        },
        backgroundColor: hasActiveAssignment ? AppColors.warning : AppColors.navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: Icon(
          hasActiveAssignment
              ? Icons.assignment_return_outlined
              : Icons.assignment_outlined,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          hasActiveAssignment ? 'İade Et' : 'Zimmetle',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showReturnDialog(Device device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İade Et',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${device.assignedTo ?? 'personel'}ten ${device.name} cihazını iade almak istiyor musunuz?',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.surfaceDivider),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'İptal',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(
                        '/assignments/${device.activeAssignmentId}/return',
                      );
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'İade Al',
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
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

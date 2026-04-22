import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/data/models/assignment_model.dart';
import 'package:assetflow_mobile/data/services/assignment_service.dart';
import 'package:assetflow_mobile/features/assignments/providers/assignment_provider.dart';
import 'package:assetflow_mobile/features/assignments/screens/assign_device_screen.dart';
import 'package:assetflow_mobile/features/assignments/screens/return_device_screen.dart';

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary400;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : AppColors.dark800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accent : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(assignmentProvider.notifier).loadMore();
    }
  }

  void _onSearch() {
    ref.read(assignmentProvider.notifier).search(_searchController.text.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(assignmentProvider.notifier).search('');
  }

  Future<void> _navigateToReturn(Assignment assignment) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReturnDeviceScreen(assignment: assignment),
      ),
    );
  }

  Future<void> _exportForm(String id, String assetTag) async {
    try {
      final service = AssignmentService();
      final bytes = await service.exportForm(id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Zimmet_$assetTag.xlsx');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Excel indirilemedi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAssign() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssignDeviceScreen()),
    );
    if (result == true) {
      ref.read(assignmentProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignmentProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Zimmetler',
            subtitle: '${state.assignments.length} ZİMMET',
            showMenu: true,
            action: GestureDetector(
              onTap: _navigateToAssign,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Zimmet no, cihaz, personel ara...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: _clearSearch,
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _onSearch,
                    child: const Icon(Icons.search, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: state.filter == AssignmentFilter.all,
                  onTap: () => ref
                      .read(assignmentProvider.notifier)
                      .setFilter(AssignmentFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Aktif',
                  selected: state.filter == AssignmentFilter.active,
                  color: AppColors.success,
                  onTap: () => ref
                      .read(assignmentProvider.notifier)
                      .setFilter(AssignmentFilter.active),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Tamamlanan',
                  selected: state.filter == AssignmentFilter.returned,
                  color: AppColors.textTertiary,
                  onTap: () => ref
                      .read(assignmentProvider.notifier)
                      .setFilter(AssignmentFilter.returned),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: state.isLoading
                ? _buildShimmer()
                : state.error != null
                ? _buildError(state.error!)
                : state.assignments.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: AppColors.primary500,
                    backgroundColor: AppColors.dark800,
                    onRefresh: () =>
                        ref.read(assignmentProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          state.assignments.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.assignments.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary500,
                              ),
                            ),
                          );
                        }
                        return _buildAssignmentItem(state.assignments[index]);
                      },
                    ),
                  ),
          ),
        ],
          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAssign,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAssignmentItem(Assignment a) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isActive = a.isActive;
    final typeLabel = assignmentTypeLabels[a.type] ?? 'Kalici';

    return GestureDetector(
      onTap: () => context.push('/assignments/${a.id}'),
      child: Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: assetTag + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary600.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    a.assetTag ?? '-',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary400,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: a.type == 0
                        ? AppColors.info.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: a.type == 0 ? AppColors.info : AppColors.warning,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isActive ? 'Aktif' : 'Iade Edildi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Device
            Row(
              children: [
                const Icon(
                  Icons.computer,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${a.deviceName ?? ''} ${[a.deviceBrand, a.deviceModel].where((s) => s != null).join(' ')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Employee
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  a.employeeName ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (a.employeeRegistrationNumber != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(${a.employeeRegistrationNumber})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(a.assignedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (a.returnedAt != null) ...[
                  const Text(
                    ' → ',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    dateFormat.format(a.returnedAt!),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            // Actions
            if (isActive) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _exportForm(a.id, a.assetTag ?? a.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            size: 14,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Excel',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _navigateToReturn(a),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.undo, size: 14, color: AppColors.warning),
                          SizedBox(width: 4),
                          Text(
                            'Iade Et',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.dark800,
      highlightColor: AppColors.dark700,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.dark800,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(assignmentProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            ref.read(assignmentProvider).searchQuery.isNotEmpty
                ? 'Sonuc bulunamadi'
                : 'Henuz zimmet kaydı yok',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

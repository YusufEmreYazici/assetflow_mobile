import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/animated_list_item.dart';
import 'package:assetflow_mobile/core/widgets/empty_state.dart';
import 'package:assetflow_mobile/features/people/widgets/person_list_skeleton.dart';
import 'package:assetflow_mobile/core/widgets/page_header.dart';
import 'package:assetflow_mobile/core/navigation/nav_helpers.dart';
import 'package:assetflow_mobile/data/models/employee_model.dart';
import 'package:assetflow_mobile/data/services/employee_service.dart';

final _personListProvider =
    StateNotifierProvider.autoDispose<_PersonListNotifier, _PersonListState>(
      (ref) => _PersonListNotifier(),
    );

class _PersonListState {
  final List<Employee> employees;
  final bool isLoading;
  final String? error;
  const _PersonListState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
  });
  _PersonListState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? error,
  }) => _PersonListState(
    employees: employees ?? this.employees,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

class _PersonListNotifier extends StateNotifier<_PersonListState> {
  _PersonListNotifier() : super(const _PersonListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await EmployeeService().getAll(page: 1, pageSize: 200);
      state = state.copyWith(isLoading: false, employees: result.items);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Personel listesi yüklenemedi.',
      );
    }
  }

  Future<void> refresh() => _load();
}

class PersonListScreen extends ConsumerStatefulWidget {
  const PersonListScreen({super.key});

  @override
  ConsumerState<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends ConsumerState<PersonListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Employee> _filtered(List<Employee> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where(
          (e) =>
              e.fullName.toLowerCase().contains(q) ||
              (e.department ?? '').toLowerCase().contains(q) ||
              (e.title ?? '').toLowerCase().contains(q) ||
              (e.registrationNumber ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String, List<Employee>> _grouped(List<Employee> employees) {
    final sorted = [...employees]
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    final Map<String, List<Employee>> groups = {};
    for (final e in sorted) {
      final letter = e.fullName.isEmpty ? '#' : e.fullName[0].toUpperCase();
      (groups[letter] ??= []).add(e);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_personListProvider);
    final filtered = _filtered(state.employees);
    final grouped = _query.isEmpty ? _grouped(filtered) : {'': filtered};

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: Column(
        children: [
          PageHeader(
            title: 'Personel',
            subtitle: '${filtered.length} PERSONEL',
            onBack: goBackOrHome(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'İsim, departman veya sicil ara…',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.surfaceInputBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.navy, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: state.isLoading
                ? const SingleChildScrollView(child: PersonListSkeleton())
                : state.error != null
                ? Center(
                    child: Text(
                      state.error!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(_personListProvider.notifier).refresh(),
                    color: AppColors.navy,
                    child: filtered.isEmpty
                      ? _query.isNotEmpty
                            ? EmptyState.noSearchResults(query: _query)
                            : const EmptyState.noEmployees()
                      : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: () {
                      int groupIndex = 0;
                      return grouped.entries.expand((entry) {
                        final letter = entry.key;
                        final list = entry.value;
                        final idx = groupIndex++;
                        return [
                          if (letter.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 4,
                              ),
                              child: Text(
                                letter,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          if (idx < 10)
                            AnimatedListItem(
                              index: idx,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                  border: Border.all(
                                    color: AppColors.surfaceDivider,
                                  ),
                                ),
                                child: Column(
                                  children: list.asMap().entries.map((e) {
                                    final isLast = e.key == list.length - 1;
                                    return _PersonRow(
                                      employee: e.value,
                                      isLast: isLast,
                                      onTap: () =>
                                          context.push('/person/${e.value.id}'),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.surfaceDivider,
                                ),
                              ),
                              child: Column(
                                children: list.asMap().entries.map((e) {
                                  final isLast = e.key == list.length - 1;
                                  return _PersonRow(
                                    employee: e.value,
                                    isLast: isLast,
                                    onTap: () =>
                                        context.push('/person/${e.value.id}'),
                                  );
                                }).toList(),
                              ),
                            ),
                        ];
                      }).toList();
                    }(),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  final Employee employee;
  final bool isLast;
  final VoidCallback onTap;
  const _PersonRow({
    required this.employee,
    required this.isLast,
    required this.onTap,
  });

  String get _initials {
    final parts = employee.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return employee.fullName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.surfaceDivider),
                ),
              ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      employee.title,
                      employee.department,
                    ].whereType<String>().join(' · '),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (employee.assignedDeviceCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${employee.assignedDeviceCount} cihaz',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.navy),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

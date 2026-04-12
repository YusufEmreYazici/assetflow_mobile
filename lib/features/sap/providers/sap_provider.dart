import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assetflow_mobile/data/models/sap_models.dart';
import 'package:assetflow_mobile/data/services/sap_service.dart';
import 'package:assetflow_mobile/core/utils/notification_service.dart';

class SapState {
  final SapConnectionStatus? connectionStatus;
  final bool isLoadingStatus;

  final SapSyncResult? lastEmployeeSync;
  final bool isSyncingEmployees;
  final String? employeeSyncError;

  final SapSyncResult? lastAssetSync;
  final bool isSyncingAssets;
  final String? assetSyncError;

  final List<SapBudgetItem> budgets;
  final bool isLoadingBudgets;
  final String? budgetsError;

  const SapState({
    this.connectionStatus,
    this.isLoadingStatus = false,
    this.lastEmployeeSync,
    this.isSyncingEmployees = false,
    this.employeeSyncError,
    this.lastAssetSync,
    this.isSyncingAssets = false,
    this.assetSyncError,
    this.budgets = const [],
    this.isLoadingBudgets = false,
    this.budgetsError,
  });

  SapState copyWith({
    SapConnectionStatus? connectionStatus,
    bool? isLoadingStatus,
    SapSyncResult? lastEmployeeSync,
    bool? isSyncingEmployees,
    String? employeeSyncError,
    bool clearEmployeeSyncError = false,
    SapSyncResult? lastAssetSync,
    bool? isSyncingAssets,
    String? assetSyncError,
    bool clearAssetSyncError = false,
    List<SapBudgetItem>? budgets,
    bool? isLoadingBudgets,
    String? budgetsError,
    bool clearBudgetsError = false,
  }) {
    return SapState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isLoadingStatus: isLoadingStatus ?? this.isLoadingStatus,
      lastEmployeeSync: lastEmployeeSync ?? this.lastEmployeeSync,
      isSyncingEmployees: isSyncingEmployees ?? this.isSyncingEmployees,
      employeeSyncError: clearEmployeeSyncError ? null : (employeeSyncError ?? this.employeeSyncError),
      lastAssetSync: lastAssetSync ?? this.lastAssetSync,
      isSyncingAssets: isSyncingAssets ?? this.isSyncingAssets,
      assetSyncError: clearAssetSyncError ? null : (assetSyncError ?? this.assetSyncError),
      budgets: budgets ?? this.budgets,
      isLoadingBudgets: isLoadingBudgets ?? this.isLoadingBudgets,
      budgetsError: clearBudgetsError ? null : (budgetsError ?? this.budgetsError),
    );
  }
}

class SapNotifier extends StateNotifier<SapState> {
  final _service = SapService();

  SapNotifier() : super(const SapState()) {
    _loadStatus();
    _loadBudgets();
  }

  Future<void> _loadStatus() async {
    state = state.copyWith(isLoadingStatus: true);
    try {
      final status = await _service.getStatus();
      state = state.copyWith(connectionStatus: status, isLoadingStatus: false);
    } catch (_) {
      state = state.copyWith(
        connectionStatus: SapConnectionStatus.notConfigured,
        isLoadingStatus: false,
      );
    }
  }

  Future<void> syncEmployees() async {
    if (state.isSyncingEmployees) return;
    state = state.copyWith(isSyncingEmployees: true, clearEmployeeSyncError: true);
    try {
      final result = await _service.syncEmployees();
      state = state.copyWith(lastEmployeeSync: result, isSyncingEmployees: false);
      if (result.newCount > 0) {
        await NotificationService.instance.notifySapNewEmployee(
          employeeName: '${result.newCount} personel',
          department: 'SAP aktarımı',
        );
      }
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isSyncingEmployees: false, employeeSyncError: msg);
    }
  }

  Future<void> syncAssets() async {
    if (state.isSyncingAssets) return;
    state = state.copyWith(isSyncingAssets: true, clearAssetSyncError: true);
    try {
      final result = await _service.syncAssets();
      state = state.copyWith(lastAssetSync: result, isSyncingAssets: false);
      if (result.newCount > 0) {
        await NotificationService.instance.notifySapAssetsImported(count: result.newCount);
      }
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isSyncingAssets: false, assetSyncError: msg);
    }
  }

  Future<void> _loadBudgets() async {
    state = state.copyWith(isLoadingBudgets: true, clearBudgetsError: true);
    try {
      final budgets = await _service.getBudgets();
      state = state.copyWith(budgets: budgets, isLoadingBudgets: false);

      // Bekleyen bütçe varsa bildirim gönder
      final pending = budgets.where((b) => b.status == 'pending').toList();
      if (pending.isNotEmpty) {
        for (final b in pending.take(1)) {
          await NotificationService.instance.notifySapBudgetApproved(
            amount: b.amount,
            description: b.description,
          );
        }
      }
    } catch (e) {
      final msg = _parseError(e);
      state = state.copyWith(isLoadingBudgets: false, budgetsError: msg);
    }
  }

  Future<void> refresh() async {
    await Future.wait([_loadStatus(), _loadBudgets()]);
  }

  String _parseError(Object e) {
    try {
      final dynamic err = e;
      if (err?.response?.data is Map) {
        return (err.response.data as Map)['error'] ??
            (err.response.data as Map)['message'] ??
            'SAP baglantisi kurulamadi';
      }
      if (err?.response?.statusCode == 404 || err?.response?.statusCode == 501) {
        return 'SAP entegrasyonu henuz yapilandirilmadi';
      }
    } catch (_) {}
    return 'SAP baglantisi kurulamadi';
  }
}

final sapProvider = StateNotifierProvider.autoDispose<SapNotifier, SapState>(
  (ref) => SapNotifier(),
);

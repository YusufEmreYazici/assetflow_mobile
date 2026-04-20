class SapSyncResult {
  final int newCount;
  final int updatedCount;
  final int errorCount;
  final DateTime syncTime;
  final bool success;
  final String? errorMessage;

  const SapSyncResult({
    required this.newCount,
    required this.updatedCount,
    required this.errorCount,
    required this.syncTime,
    required this.success,
    this.errorMessage,
  });

  factory SapSyncResult.fromJson(Map<String, dynamic> json) {
    return SapSyncResult(
      newCount: json['newCount'] as int? ?? 0,
      updatedCount: json['updatedCount'] as int? ?? 0,
      errorCount: json['errorCount'] as int? ?? 0,
      syncTime:
          DateTime.tryParse(json['syncTime']?.toString() ?? '') ??
          DateTime.now(),
      success: json['success'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class SapBudgetItem {
  final String id;
  final double amount;
  final String description;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String requestedBy;
  final String? department;

  const SapBudgetItem({
    required this.id,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.requestedBy,
    this.department,
  });

  factory SapBudgetItem.fromJson(Map<String, dynamic> json) {
    return SapBudgetItem(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      requestedBy: json['requestedBy'] as String? ?? '',
      department: json['department'] as String?,
    );
  }
}

class SapConnectionStatus {
  final bool isConfigured;
  final bool isConnected;
  final String? version;
  final DateTime? lastChecked;

  const SapConnectionStatus({
    required this.isConfigured,
    required this.isConnected,
    this.version,
    this.lastChecked,
  });

  factory SapConnectionStatus.fromJson(Map<String, dynamic> json) {
    return SapConnectionStatus(
      isConfigured: json['isConfigured'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      version: json['version'] as String?,
      lastChecked: DateTime.tryParse(json['lastChecked']?.toString() ?? ''),
    );
  }

  static SapConnectionStatus get notConfigured =>
      const SapConnectionStatus(isConfigured: false, isConnected: false);
}

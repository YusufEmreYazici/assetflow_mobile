class AuditLog {
  final String id;
  final String action;
  final String entityName;
  final String entityId;
  final String? userEmail;
  final String? ipAddress;
  final DateTime timestamp;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final List<String>? affectedColumns;

  AuditLog({
    required this.id,
    required this.action,
    required this.entityName,
    required this.entityId,
    this.userEmail,
    this.ipAddress,
    required this.timestamp,
    this.oldValues,
    this.newValues,
    this.affectedColumns,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: json['action'] as String,
      entityName: json['entityName'] as String,
      entityId: json['entityId'] as String,
      userEmail: json['userEmail'] as String?,
      ipAddress: json['ipAddress'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      oldValues: json['oldValues'] as Map<String, dynamic>?,
      newValues: json['newValues'] as Map<String, dynamic>?,
      affectedColumns: (json['affectedColumns'] as List?)?.cast<String>(),
    );
  }
}

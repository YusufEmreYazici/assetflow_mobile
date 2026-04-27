class NotificationItem {
  final String id;
  final String title;
  final String message;
  final int
  type; // 0=WarrantyExpiring, 1=WarrantyExpired, 2=DeviceAssigned, 3=DeviceUnassigned, 4=System
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? relatedEntityType; // "Device", "Assignment", "Employee"
  final String? relatedEntityId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
    );
  }

  NotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
  }

  String get typeLabel =>
      const {
        0: 'Garanti Yaklaşıyor',
        1: 'Garanti Doldu',
        2: 'Zimmet',
        3: 'İade',
        4: 'Sistem',
      }[type] ??
      'Bildirim';

  String get category => switch (type) {
    0 || 1 => 'warranty',
    2 || 3 => 'assignment',
    _ => 'system',
  };
}

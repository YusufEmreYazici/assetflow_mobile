class DashboardData {
  final int totalDevices;
  final int assignedDevices;
  final int inStorageDevices;
  final int expiringWarranties;
  final int expiredWarranties;
  final int totalEmployees;
  final Map<String, int> devicesByType;
  final List<WarrantyAlertItem> upcomingWarrantyExpirations;

  DashboardData({
    required this.totalDevices,
    required this.assignedDevices,
    required this.inStorageDevices,
    required this.expiringWarranties,
    required this.expiredWarranties,
    required this.totalEmployees,
    required this.devicesByType,
    required this.upcomingWarrantyExpirations,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final devicesByTypeRaw = json['devicesByType'] as Map<String, dynamic>? ?? {};
    final devicesByType = devicesByTypeRaw.map(
      (key, value) => MapEntry(key, value as int),
    );

    final warrantiesRaw = json['upcomingWarrantyExpirations'] as List<dynamic>? ?? [];
    final warranties = warrantiesRaw
        .map((e) => WarrantyAlertItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardData(
      totalDevices: json['totalDevices'] as int? ?? 0,
      assignedDevices: json['assignedDevices'] as int? ?? 0,
      inStorageDevices: json['inStorageDevices'] as int? ?? 0,
      expiringWarranties: json['expiringWarranties'] as int? ?? 0,
      expiredWarranties: json['expiredWarranties'] as int? ?? 0,
      totalEmployees: json['totalEmployees'] as int? ?? 0,
      devicesByType: devicesByType,
      upcomingWarrantyExpirations: warranties,
    );
  }
}

class WarrantyAlertItem {
  final int deviceId;
  final String deviceName;
  final String? assignedTo;
  final DateTime warrantyEndDate;
  final int daysRemaining;

  WarrantyAlertItem({
    required this.deviceId,
    required this.deviceName,
    this.assignedTo,
    required this.warrantyEndDate,
    required this.daysRemaining,
  });

  factory WarrantyAlertItem.fromJson(Map<String, dynamic> json) {
    return WarrantyAlertItem(
      deviceId: json['deviceId'] as int,
      deviceName: json['deviceName'] as String,
      assignedTo: json['assignedTo'] as String?,
      warrantyEndDate: DateTime.parse(json['warrantyEndDate'] as String),
      daysRemaining: json['daysRemaining'] as int,
    );
  }
}

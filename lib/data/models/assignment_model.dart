class Assignment {
  final String id;
  final String? assetTag;
  final int type;
  final String? deviceId;
  final String? deviceName;
  final String? deviceSerialNumber;
  final String? deviceBrand;
  final String? deviceModel;
  final String? employeeId;
  final String? employeeName;
  final String? employeeRegistrationNumber;
  final String? employeeDepartment;
  final String? employeeTitle;
  final DateTime assignedAt;
  final DateTime? expectedReturnDate;
  final DateTime? returnedAt;
  final int? returnCondition;
  final bool isActive;
  final String? notes;
  final String? assignedByName;

  Assignment({
    required this.id,
    this.assetTag,
    required this.type,
    this.deviceId,
    this.deviceName,
    this.deviceSerialNumber,
    this.deviceBrand,
    this.deviceModel,
    this.employeeId,
    this.employeeName,
    this.employeeRegistrationNumber,
    this.employeeDepartment,
    this.employeeTitle,
    required this.assignedAt,
    this.expectedReturnDate,
    this.returnedAt,
    this.returnCondition,
    required this.isActive,
    this.notes,
    this.assignedByName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'].toString(),
      assetTag: json['assetTag'] as String?,
      type: json['type'] as int,
      deviceId: json['deviceId']?.toString(),
      deviceName: json['deviceName'] as String?,
      deviceSerialNumber: json['deviceSerialNumber'] as String?,
      deviceBrand: json['deviceBrand'] as String?,
      deviceModel: json['deviceModel'] as String?,
      employeeId: json['employeeId']?.toString(),
      employeeName: json['employeeName'] as String?,
      employeeRegistrationNumber: json['employeeRegistrationNumber'] as String?,
      employeeDepartment: json['employeeDepartment'] as String?,
      employeeTitle: json['employeeTitle'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      expectedReturnDate: json['expectedReturnDate'] != null
          ? DateTime.parse(json['expectedReturnDate'] as String)
          : null,
      returnedAt: json['returnedAt'] != null
          ? DateTime.parse(json['returnedAt'] as String)
          : null,
      returnCondition: json['returnCondition'] as int?,
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String?,
      assignedByName: json['assignedByName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetTag': assetTag,
    'type': type,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'deviceSerialNumber': deviceSerialNumber,
    'deviceBrand': deviceBrand,
    'deviceModel': deviceModel,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'employeeRegistrationNumber': employeeRegistrationNumber,
    'employeeDepartment': employeeDepartment,
    'employeeTitle': employeeTitle,
    'assignedAt': assignedAt.toIso8601String(),
    'expectedReturnDate': expectedReturnDate?.toIso8601String(),
    'returnedAt': returnedAt?.toIso8601String(),
    'returnCondition': returnCondition,
    'isActive': isActive,
    'notes': notes,
    'assignedByName': assignedByName,
  };
}

const Map<int, String> assignmentTypeLabels = {
  0: 'Zimmet',
  1: 'Odunc',
  2: 'Gecici',
};

const Map<int, String> returnConditionLabels = {
  0: 'Iyi',
  1: 'Hasarli',
  2: 'Arizali',
  3: 'Kayip',
};

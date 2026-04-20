class Device {
  final String id;
  final String name;
  final String? assetCode;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final int type;
  final int status;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? supplier;
  final int? warrantyDurationMonths;
  final DateTime? warrantyEndDate;
  final int? warrantyStatus;
  final String? notes;
  final String? assignedTo;
  final String? activeAssignmentId;
  final String? locationId;
  final String? locationName;
  final String? hostName;
  final String? cpuInfo;
  final String? ramInfo;
  final String? storageInfo;
  final String? gpuInfo;
  final String? osInfo;
  final String? ipAddress;
  final String? macAddress;
  final String? biosVersion;
  final String? motherboardInfo;

  Device({
    required this.id,
    required this.name,
    this.assetCode,
    this.brand,
    this.model,
    this.serialNumber,
    required this.type,
    required this.status,
    this.purchaseDate,
    this.purchasePrice,
    this.supplier,
    this.warrantyDurationMonths,
    this.warrantyEndDate,
    this.warrantyStatus,
    this.notes,
    this.assignedTo,
    this.activeAssignmentId,
    this.locationId,
    this.locationName,
    this.hostName,
    this.cpuInfo,
    this.ramInfo,
    this.storageInfo,
    this.gpuInfo,
    this.osInfo,
    this.ipAddress,
    this.macAddress,
    this.biosVersion,
    this.motherboardInfo,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'].toString(),
      name: json['name'] as String,
      assetCode: json['assetCode'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      type: json['type'] as int,
      status: json['status'] as int,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      supplier: json['supplier'] as String?,
      warrantyDurationMonths: json['warrantyDurationMonths'] as int?,
      warrantyEndDate: json['warrantyEndDate'] != null
          ? DateTime.parse(json['warrantyEndDate'] as String)
          : null,
      warrantyStatus: json['warrantyStatus'] as int?,
      notes: json['notes'] as String?,
      assignedTo: json['assignedTo'] as String?,
      activeAssignmentId: json['activeAssignmentId'] as String?,
      locationId: json['locationId']?.toString(),
      locationName: json['locationName'] as String?,
      hostName: json['hostName'] as String?,
      cpuInfo: json['cpuInfo'] as String?,
      ramInfo: json['ramInfo'] as String?,
      storageInfo: json['storageInfo'] as String?,
      gpuInfo: json['gpuInfo'] as String?,
      osInfo: json['osInfo'] as String?,
      ipAddress: json['ipAddress'] as String?,
      macAddress: json['macAddress'] as String?,
      biosVersion: json['biosVersion'] as String?,
      motherboardInfo: json['motherboardInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'assetCode': assetCode,
        'brand': brand,
        'model': model,
        'serialNumber': serialNumber,
        'type': type,
        'status': status,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'purchasePrice': purchasePrice,
        'supplier': supplier,
        'warrantyDurationMonths': warrantyDurationMonths,
        'warrantyEndDate': warrantyEndDate?.toIso8601String(),
        'warrantyStatus': warrantyStatus,
        'notes': notes,
        'assignedTo': assignedTo,
        'activeAssignmentId': activeAssignmentId,
        'locationId': locationId,
        'locationName': locationName,
        'hostName': hostName,
        'cpuInfo': cpuInfo,
        'ramInfo': ramInfo,
        'storageInfo': storageInfo,
        'gpuInfo': gpuInfo,
        'osInfo': osInfo,
        'ipAddress': ipAddress,
        'macAddress': macAddress,
        'biosVersion': biosVersion,
        'motherboardInfo': motherboardInfo,
      };
}

const Map<int, String> DeviceTypeLabels = {
  0: 'Dizustu Bilgisayar',
  1: 'Masaustu Bilgisayar',
  2: 'Monitor',
  3: 'Yazici',
  4: 'Telefon',
  5: 'Tablet',
  6: 'Sunucu',
  7: 'Ag Cihazi',
  8: 'Diger',
};

const Map<int, String> DeviceStatusLabels = {
  0: 'Aktif',
  1: 'Depoda',
  2: 'Bakimda',
  3: 'Emekli',
};

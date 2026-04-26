class SoftwareLicense {
  final String id;
  final String productName;
  final String vendor;
  final String? version;
  final String licenseType;
  final int totalSeats;
  final int usedSeats;
  final int availableSeats;
  final bool hasLicenseKey;
  final String? startDate;
  final String? expiryDate;
  final bool autoRenew;
  final double? purchasePrice;
  final String currency;
  final double? renewalCost;
  final String? supplier;
  final String? notes;
  final bool isExpired;
  final bool isExpiringSoon;
  final int? daysUntilExpiry;
  final String createdAt;

  const SoftwareLicense({
    required this.id,
    required this.productName,
    required this.vendor,
    this.version,
    required this.licenseType,
    required this.totalSeats,
    required this.usedSeats,
    required this.availableSeats,
    required this.hasLicenseKey,
    this.startDate,
    this.expiryDate,
    required this.autoRenew,
    this.purchasePrice,
    required this.currency,
    this.renewalCost,
    this.supplier,
    this.notes,
    required this.isExpired,
    required this.isExpiringSoon,
    this.daysUntilExpiry,
    required this.createdAt,
  });

  factory SoftwareLicense.fromJson(Map<String, dynamic> json) => SoftwareLicense(
        id: json['id'] as String,
        productName: json['productName'] as String,
        vendor: json['vendor'] as String,
        version: json['version'] as String?,
        licenseType: json['licenseType'] as String,
        totalSeats: json['totalSeats'] as int? ?? 0,
        usedSeats: json['usedSeats'] as int? ?? 0,
        availableSeats: json['availableSeats'] as int? ?? 0,
        hasLicenseKey: json['hasLicenseKey'] as bool? ?? false,
        startDate: json['startDate'] as String?,
        expiryDate: json['expiryDate'] as String?,
        autoRenew: json['autoRenew'] as bool? ?? false,
        purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
        currency: json['currency'] as String? ?? 'TRY',
        renewalCost: (json['renewalCost'] as num?)?.toDouble(),
        supplier: json['supplier'] as String?,
        notes: json['notes'] as String?,
        isExpired: json['isExpired'] as bool? ?? false,
        isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
        daysUntilExpiry: json['daysUntilExpiry'] as int?,
        createdAt: json['createdAt'] as String,
      );
}

class Consumable {
  final String id;
  final String name;
  final String category;
  final String? brand;
  final String? model;
  final String? partNumber;
  final String unit;
  final int currentStock;
  final int minStock;
  final int reorderPoint;
  final bool isLowStock;
  final bool needsReorder;
  final String? locationName;
  final String? storageLocation;
  final double? unitCost;
  final String currency;
  final String? supplier;
  final String? notes;
  final String? lastRestockedAt;
  final String createdAt;

  const Consumable({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    this.model,
    this.partNumber,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.reorderPoint,
    required this.isLowStock,
    required this.needsReorder,
    this.locationName,
    this.storageLocation,
    this.unitCost,
    required this.currency,
    this.supplier,
    this.notes,
    this.lastRestockedAt,
    required this.createdAt,
  });

  factory Consumable.fromJson(Map<String, dynamic> json) => Consumable(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        brand: json['brand'] as String?,
        model: json['model'] as String?,
        partNumber: json['partNumber'] as String?,
        unit: json['unit'] as String? ?? 'adet',
        currentStock: json['currentStock'] as int? ?? 0,
        minStock: json['minStock'] as int? ?? 0,
        reorderPoint: json['reorderPoint'] as int? ?? 0,
        isLowStock: json['isLowStock'] as bool? ?? false,
        needsReorder: json['needsReorder'] as bool? ?? false,
        locationName: json['locationName'] as String?,
        storageLocation: json['storageLocation'] as String?,
        unitCost: (json['unitCost'] as num?)?.toDouble(),
        currency: json['currency'] as String? ?? 'TRY',
        supplier: json['supplier'] as String?,
        notes: json['notes'] as String?,
        lastRestockedAt: json['lastRestockedAt'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

class StockMovement {
  final String id;
  final String consumableId;
  final String type;
  final String typeName;
  final int quantity;
  final int stockBefore;
  final int stockAfter;
  final String? reason;
  final String? recipientEmployeeName;
  final String createdAt;

  const StockMovement({
    required this.id,
    required this.consumableId,
    required this.type,
    required this.typeName,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.reason,
    this.recipientEmployeeName,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
        id: json['id'] as String,
        consumableId: json['consumableId'] as String,
        type: json['type'] as String,
        typeName: json['typeName'] as String? ?? json['type'] as String,
        quantity: json['quantity'] as int,
        stockBefore: json['stockBefore'] as int,
        stockAfter: json['stockAfter'] as int,
        reason: json['reason'] as String?,
        recipientEmployeeName: json['recipientEmployeeName'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

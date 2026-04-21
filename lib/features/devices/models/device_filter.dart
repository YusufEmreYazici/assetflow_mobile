import 'package:assetflow_mobile/data/models/device_model.dart';

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  factory DateRange.fromJson(Map<String, dynamic> json) => DateRange(
    start: DateTime.parse(json['start'] as String),
    end: DateTime.parse(json['end'] as String),
  );
}

class FilterPreset {
  final String id;
  final String name;
  final DeviceFilter filter;
  final DateTime createdAt;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.filter,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filter': filter.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FilterPreset.fromJson(Map<String, dynamic> json) => FilterPreset(
    id: json['id'] as String,
    name: json['name'] as String,
    filter: DeviceFilter.fromJson(json['filter'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class DeviceFilter {
  final List<int> types;
  final List<int> statuses;
  final List<String> locations;
  final List<String> brands;
  final String? assigneeQuery;
  final DateRange? purchaseDateRange;
  final DateRange? warrantyEndRange;
  final bool onlyFavorites;

  const DeviceFilter({
    this.types = const [],
    this.statuses = const [],
    this.locations = const [],
    this.brands = const [],
    this.assigneeQuery,
    this.purchaseDateRange,
    this.warrantyEndRange,
    this.onlyFavorites = false,
  });

  bool get isEmpty =>
      types.isEmpty &&
      statuses.isEmpty &&
      locations.isEmpty &&
      brands.isEmpty &&
      (assigneeQuery == null || assigneeQuery!.isEmpty) &&
      purchaseDateRange == null &&
      warrantyEndRange == null &&
      !onlyFavorites;

  int get activeCount =>
      types.length +
      statuses.length +
      locations.length +
      brands.length +
      ((assigneeQuery != null && assigneeQuery!.isNotEmpty) ? 1 : 0) +
      (purchaseDateRange != null ? 1 : 0) +
      (warrantyEndRange != null ? 1 : 0) +
      (onlyFavorites ? 1 : 0);

  DeviceFilter copyWith({
    List<int>? types,
    List<int>? statuses,
    List<String>? locations,
    List<String>? brands,
    String? assigneeQuery,
    DateRange? purchaseDateRange,
    DateRange? warrantyEndRange,
    bool? onlyFavorites,
    bool clearAssigneeQuery = false,
    bool clearPurchaseDateRange = false,
    bool clearWarrantyEndRange = false,
  }) {
    return DeviceFilter(
      types: types ?? this.types,
      statuses: statuses ?? this.statuses,
      locations: locations ?? this.locations,
      brands: brands ?? this.brands,
      assigneeQuery: clearAssigneeQuery ? null : (assigneeQuery ?? this.assigneeQuery),
      purchaseDateRange: clearPurchaseDateRange ? null : (purchaseDateRange ?? this.purchaseDateRange),
      warrantyEndRange: clearWarrantyEndRange ? null : (warrantyEndRange ?? this.warrantyEndRange),
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
    );
  }

  bool matches(Device d, {Set<String> favorites = const {}}) {
    if (types.isNotEmpty && !types.contains(d.type)) return false;
    if (statuses.isNotEmpty && !statuses.contains(d.status)) return false;
    if (locations.isNotEmpty && !locations.contains(d.locationName)) return false;
    if (brands.isNotEmpty && !brands.contains(d.brand)) return false;
    if (assigneeQuery != null && assigneeQuery!.isNotEmpty) {
      if (!(d.assignedTo ?? '').toLowerCase().contains(assigneeQuery!.toLowerCase())) return false;
    }
    if (purchaseDateRange != null) {
      if (d.purchaseDate == null) return false;
      if (d.purchaseDate!.isBefore(purchaseDateRange!.start)) return false;
      if (d.purchaseDate!.isAfter(purchaseDateRange!.end)) return false;
    }
    if (warrantyEndRange != null) {
      if (d.warrantyEndDate == null) return false;
      if (d.warrantyEndDate!.isBefore(warrantyEndRange!.start)) return false;
      if (d.warrantyEndDate!.isAfter(warrantyEndRange!.end)) return false;
    }
    if (onlyFavorites && !favorites.contains(d.id)) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'types': types,
    'statuses': statuses,
    'locations': locations,
    'brands': brands,
    'assigneeQuery': assigneeQuery,
    'purchaseDateRange': purchaseDateRange?.toJson(),
    'warrantyEndRange': warrantyEndRange?.toJson(),
    'onlyFavorites': onlyFavorites,
  };

  factory DeviceFilter.fromJson(Map<String, dynamic> json) => DeviceFilter(
    types: List<int>.from(json['types'] as List? ?? []),
    statuses: List<int>.from(json['statuses'] as List? ?? []),
    locations: List<String>.from(json['locations'] as List? ?? []),
    brands: List<String>.from(json['brands'] as List? ?? []),
    assigneeQuery: json['assigneeQuery'] as String?,
    purchaseDateRange: json['purchaseDateRange'] != null
        ? DateRange.fromJson(json['purchaseDateRange'] as Map<String, dynamic>)
        : null,
    warrantyEndRange: json['warrantyEndRange'] != null
        ? DateRange.fromJson(json['warrantyEndRange'] as Map<String, dynamic>)
        : null,
    onlyFavorites: json['onlyFavorites'] as bool? ?? false,
  );
}

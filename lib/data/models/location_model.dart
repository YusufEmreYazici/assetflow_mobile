class Location {
  final String id;
  final String name;
  final String? address;
  final String? building;
  final String? floor;
  final String? room;
  final String? description;
  final bool isActive;
  final int deviceCount;

  Location({
    required this.id,
    required this.name,
    this.address,
    this.building,
    this.floor,
    this.room,
    this.description,
    required this.isActive,
    required this.deviceCount,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String?,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      room: json['room'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool,
      deviceCount: json['deviceCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'building': building,
    'floor': floor,
    'room': room,
    'description': description,
    'isActive': isActive,
    'deviceCount': deviceCount,
  };
}

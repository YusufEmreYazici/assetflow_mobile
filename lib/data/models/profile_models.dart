class ProfileDto {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final String companyName;
  final String companyId;
  final String? department;
  final String? title;
  final String language;
  final String timeZone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int activeAssignmentCount;
  final int totalAssignmentCount;

  const ProfileDto({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    required this.companyName,
    required this.companyId,
    this.department,
    this.title,
    required this.language,
    required this.timeZone,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    required this.activeAssignmentCount,
    required this.totalAssignmentCount,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) => ProfileDto(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['fullName'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    role: (json['role'] is int)
        ? _roleFromInt(json['role'] as int)
        : (json['role'] as String? ?? 'Admin'),
    companyName: json['companyName'] as String? ?? '',
    companyId: json['companyId'] as String,
    department: json['department'] as String?,
    title: json['title'] as String?,
    language: json['language'] as String? ?? 'tr',
    timeZone: json['timeZone'] as String? ?? 'Europe/Istanbul',
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastLoginAt: json['lastLoginAt'] != null
        ? DateTime.parse(json['lastLoginAt'] as String)
        : null,
    activeAssignmentCount: json['activeAssignmentCount'] as int? ?? 0,
    totalAssignmentCount: json['totalAssignmentCount'] as int? ?? 0,
  );

  static String _roleFromInt(int v) => switch (v) {
    0 => 'User',
    1 => 'Admin',
    2 => 'SuperAdmin',
    _ => 'Admin',
  };

  ProfileDto copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? language,
    String? timeZone,
  }) => ProfileDto(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role,
    companyName: companyName,
    companyId: companyId,
    department: department,
    title: title,
    language: language ?? this.language,
    timeZone: timeZone ?? this.timeZone,
    isActive: isActive,
    createdAt: createdAt,
    lastLoginAt: lastLoginAt,
    activeAssignmentCount: activeAssignmentCount,
    totalAssignmentCount: totalAssignmentCount,
  );
}

class UpdateProfileRequest {
  final String fullName;
  final String? phoneNumber;
  final String language;
  final String timeZone;

  const UpdateProfileRequest({
    required this.fullName,
    this.phoneNumber,
    required this.language,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    'language': language,
    'timeZone': timeZone,
  };
}

class Employee {
  final String id;
  final String fullName;
  final String? registrationNumber;
  final String? email;
  final String? department;
  final String? title;
  final String? phone;
  final bool isActive;
  final DateTime? hireDate;
  final int assignedDeviceCount;

  Employee({
    required this.id,
    required this.fullName,
    this.registrationNumber,
    this.email,
    this.department,
    this.title,
    this.phone,
    required this.isActive,
    this.hireDate,
    required this.assignedDeviceCount,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      fullName: json['fullName'] as String,
      registrationNumber: json['registrationNumber'] as String?,
      email: json['email'] as String?,
      department: json['department'] as String?,
      title: json['title'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool,
      hireDate: json['hireDate'] != null
          ? DateTime.parse(json['hireDate'] as String)
          : null,
      assignedDeviceCount: json['assignedDeviceCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'registrationNumber': registrationNumber,
    'email': email,
    'department': department,
    'title': title,
    'phone': phone,
    'isActive': isActive,
    'hireDate': hireDate?.toIso8601String(),
    'assignedDeviceCount': assignedDeviceCount,
  };
}

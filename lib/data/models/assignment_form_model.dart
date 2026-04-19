class AssignmentForm {
  final String id;
  final String assignmentId;
  final int type; // 0=Zimmet, 1=İade
  final String formNumber;
  final DateTime generatedAt;
  final String generatedByUserName;
  final bool isSigned;
  final DateTime? signedUploadedAt;

  AssignmentForm({
    required this.id,
    required this.assignmentId,
    required this.type,
    required this.formNumber,
    required this.generatedAt,
    required this.generatedByUserName,
    required this.isSigned,
    this.signedUploadedAt,
  });

  factory AssignmentForm.fromJson(Map<String, dynamic> json) {
    return AssignmentForm(
      id: json['id'].toString(),
      assignmentId: json['assignmentId'].toString(),
      type: json['type'] as int,
      formNumber: json['formNumber'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedByUserName: json['generatedByUserName'] as String,
      isSigned: json['isSigned'] as bool,
      signedUploadedAt: json['signedUploadedAt'] != null
          ? DateTime.parse(json['signedUploadedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'assignmentId': assignmentId,
    'type': type,
    'formNumber': formNumber,
    'generatedAt': generatedAt.toIso8601String(),
    'generatedByUserName': generatedByUserName,
    'isSigned': isSigned,
    'signedUploadedAt': signedUploadedAt?.toIso8601String(),
  };

  String get typeLabel => type == 0 ? 'Zimmet Formu' : 'İade Formu';
  String get fileName => '$formNumber.xlsx';
}

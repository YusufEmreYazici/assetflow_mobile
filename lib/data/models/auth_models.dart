class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String confirmPassword;
  final String fullName;
  final String companyName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.fullName,
    required this.companyName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'fullName': fullName,
    'companyName': companyName,
  };
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final String email;
  final String fullName;
  final String role;
  final String companyId;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.email,
    required this.fullName,
    required this.role,
    required this.companyId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenExpiresAt: DateTime.parse(json['tokenExpiresAt'] as String),
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      companyId: json['companyId'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'tokenExpiresAt': tokenExpiresAt.toIso8601String(),
    'email': email,
    'fullName': fullName,
    'role': role,
    'companyId': companyId,
  };
}

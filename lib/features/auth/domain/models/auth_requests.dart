class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String role;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.role = 'customer',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'password': password,
      'full_name': fullName.trim(),
      'phone_number': phoneNumber.trim(),
      'role': role,
    };
  }
}

class PasswordResetOtpRequest {
  final String email;

  const PasswordResetOtpRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
    };
  }
}

class PasswordResetConfirmRequest {
  final String email;
  final String otp;
  final String newPassword;

  const PasswordResetConfirmRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
      'new_password': newPassword,
    };
  }
}

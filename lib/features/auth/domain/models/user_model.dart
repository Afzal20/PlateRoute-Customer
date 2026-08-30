class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final bool isEmailVerified;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.role = 'customer',
    this.isEmailVerified = false,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'customer').toString(),
      isEmailVerified: json['is_email_verified'] == true || json['email_verified'] == true,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'is_email_verified': isEmailVerified,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    bool? isEmailVerified,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

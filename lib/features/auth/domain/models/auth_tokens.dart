class AuthTokens {
  final String access;
  final String refresh;

  const AuthTokens({
    required this.access,
    required this.refresh,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      access: (json['access'] ?? json['access_token'] ?? '').toString(),
      refresh: (json['refresh'] ?? json['refresh_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}

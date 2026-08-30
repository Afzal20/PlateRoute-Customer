import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/auth_requests.dart';
import '../../domain/models/auth_tokens.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(UserModel, AuthTokens)> login(LoginRequest request);
  Future<(UserModel, AuthTokens)> register(RegisterRequest request);
  Future<UserModel> getProfile();
  Future<void> requestPasswordResetOtp(PasswordResetOtpRequest request);
  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<(UserModel, AuthTokens)> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final data = response as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
    final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>? ?? data);

    return (user, tokens);
  }

  @override
  Future<(UserModel, AuthTokens)> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    final data = response as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
    final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>? ?? data);

    return (user, tokens);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.profile);
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordResetOtp(PasswordResetOtpRequest request) async {
    await _apiClient.post(
      ApiEndpoints.passwordResetOtp,
      data: request.toJson(),
    );
  }

  @override
  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request) async {
    await _apiClient.post(
      ApiEndpoints.passwordResetConfirm,
      data: request.toJson(),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Best-effort remote logout
    }
  }
}

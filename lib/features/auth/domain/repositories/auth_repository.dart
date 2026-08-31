import '../../domain/models/auth_requests.dart';
import '../../domain/models/auth_tokens.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRepository {
  Future<(UserModel, AuthTokens)> login(LoginRequest request);
  Future<(UserModel, AuthTokens)> loginWithGoogleToken(String accessToken);
  Future<(UserModel, AuthTokens)> register(RegisterRequest request);
  Future<UserModel> getCurrentProfile();
  Future<void> requestPasswordResetOtp(PasswordResetOtpRequest request);
  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request);
  Future<void> logout();
}

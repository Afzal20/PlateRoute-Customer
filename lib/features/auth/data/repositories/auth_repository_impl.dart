import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/auth_requests.dart';
import '../../domain/models/auth_tokens.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<(UserModel, AuthTokens)> login(LoginRequest request) async {
    final (user, tokens) = await remoteDataSource.login(request);
    await secureStorage.saveTokens(
      access: tokens.access,
      refresh: tokens.refresh,
    );
    return (user, tokens);
  }

  @override
  Future<(UserModel, AuthTokens)> loginWithGoogleToken(String accessToken) async {
    final (user, tokens) = await remoteDataSource.loginWithGoogleToken(accessToken);
    await secureStorage.saveTokens(
      access: tokens.access,
      refresh: tokens.refresh,
    );
    return (user, tokens);
  }

  @override
  Future<(UserModel, AuthTokens)> register(RegisterRequest request) async {
    final (user, tokens) = await remoteDataSource.register(request);
    if (tokens.access.isNotEmpty) {
      await secureStorage.saveTokens(
        access: tokens.access,
        refresh: tokens.refresh,
      );
    }
    return (user, tokens);
  }

  @override
  Future<UserModel> getCurrentProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<void> requestPasswordResetOtp(PasswordResetOtpRequest request) async {
    await remoteDataSource.requestPasswordResetOtp(request);
  }

  @override
  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request) async {
    await remoteDataSource.confirmPasswordReset(request);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await secureStorage.clearTokens();
  }
}

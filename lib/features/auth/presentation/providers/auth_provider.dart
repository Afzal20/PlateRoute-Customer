import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/auth_requests.dart';
import '../../domain/models/auth_state.dart' as my_auth;
import '../../domain/repositories/auth_repository.dart';

// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

// Auth State Provider
final authProvider = StateNotifierProvider<AuthStateNotifier, my_auth.AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});

class AuthStateNotifier extends StateNotifier<my_auth.AuthState> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const my_auth.AuthState.initial());

  Future<void> checkAuthStatus() async {
    state = const my_auth.AuthState.authenticating();
    try {
      final user = await _repository.getCurrentProfile();
      if (!user.isEmailVerified && user.email.isNotEmpty) {
        state = my_auth.AuthState.emailUnverified(user.email);
      } else {
        state = my_auth.AuthState.authenticated(user);
      }
    } on UnauthorizedException {
      state = const my_auth.AuthState.unauthenticated();
    } catch (_) {
      state = const my_auth.AuthState.unauthenticated();
    }
  }

  /// Direct DRF Google SSO (no Supabase): interactive Google sign-in gives
  /// an ID token, the backend verifies it and returns our JWT pair.
  Future<bool> loginWithGoogle() async {
    state = const my_auth.AuthState.authenticating();
    try {
      final serverClientId = AppConfig.instance.googleWebClientId;
      if (serverClientId.isEmpty) {
        state = const my_auth.AuthState.error('Google sign-in is not configured.');
        return false;
      }
      await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        state = const my_auth.AuthState.error('Google Login failed.');
        return false;
      }
      final (user, _) = await _repository.loginWithGoogleToken(idToken);
      if (!user.isEmailVerified && user.email.isNotEmpty) {
        state = my_auth.AuthState.emailUnverified(user.email);
      } else {
        state = my_auth.AuthState.authenticated(user);
      }
      return true;
    } catch (e) {
      state = my_auth.AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const my_auth.AuthState.authenticating();
    try {
      final (user, _) = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      if (!user.isEmailVerified && user.email.isNotEmpty) {
        state = my_auth.AuthState.emailUnverified(user.email);
        return false;
      }

      state = my_auth.AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      state = my_auth.AuthState.error(e.message);
      return false;
    } catch (e) {
      state = my_auth.AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    state = const my_auth.AuthState.authenticating();
    try {
      final (user, tokens) = await _repository.register(
        RegisterRequest(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
        ),
      );

      if (!user.isEmailVerified && tokens.access.isEmpty) {
        state = my_auth.AuthState.emailUnverified(email);
        return true;
      }

      state = my_auth.AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      state = my_auth.AuthState.error(e.message);
      return false;
    } catch (e) {
      state = my_auth.AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> requestPasswordResetOtp(String email) async {
    try {
      await _repository.requestPasswordResetOtp(
        PasswordResetOtpRequest(email: email),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _repository.confirmPasswordReset(
        PasswordResetConfirmRequest(
          email: email,
          otp: otp,
          newPassword: newPassword,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    state = const my_auth.AuthState.authenticating();
    await _repository.logout();
    state = const my_auth.AuthState.unauthenticated();
  }
}

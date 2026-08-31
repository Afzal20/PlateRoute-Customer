import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/auth_requests.dart';
import '../../domain/models/auth_state.dart';
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
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AuthState.initial()) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        state = const AuthState.authenticating();
        try {
          final (user, _) = await _repository.loginWithGoogleToken(session.accessToken);
          if (!user.isEmailVerified && user.email.isNotEmpty) {
            state = AuthState.emailUnverified(user.email);
          } else {
            state = AuthState.authenticated(user);
          }
        } catch (e) {
          state = AuthState.error(e.toString());
        }
      }
    });
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.authenticating();
    try {
      final user = await _repository.getCurrentProfile();
      if (!user.isEmailVerified && user.email.isNotEmpty) {
        state = AuthState.emailUnverified(user.email);
      } else {
        state = AuthState.authenticated(user);
      }
    } on UnauthorizedException {
      state = const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> loginWithGoogle() async {
    state = const AuthState.authenticating();
    try {
      final success = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'plateroutecustomer://login-callback',
      );
      return success;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      final (user, _) = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      if (!user.isEmailVerified && user.email.isNotEmpty) {
        state = AuthState.emailUnverified(user.email);
        return false;
      }

      state = AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      state = AuthState.error(e.message);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    state = const AuthState.authenticating();
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
        state = AuthState.emailUnverified(email);
        return true;
      }

      state = AuthState.authenticated(user);
      return true;
    } on ApiException catch (e) {
      state = AuthState.error(e.message);
      return false;
    } catch (e) {
      state = AuthState.error(e.toString());
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
    state = const AuthState.authenticating();
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}

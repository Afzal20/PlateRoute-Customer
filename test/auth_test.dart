import 'package:customer/core/storage/secure_storage_service.dart';
import 'package:customer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:customer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:customer/features/auth/domain/models/auth_requests.dart';
import 'package:customer/features/auth/domain/models/auth_state.dart';
import 'package:customer/features/auth/domain/models/auth_tokens.dart';
import 'package:customer/features/auth/domain/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? mockUser;
  AuthTokens? mockTokens;
  bool otpRequested = false;
  bool otpConfirmed = false;
  bool loggedOut = false;

  @override
  Future<(UserModel, AuthTokens)> login(LoginRequest request) async {
    return (
      mockUser ??
          const UserModel(
            id: '1',
            email: 'test@example.com',
            fullName: 'Test User',
            phoneNumber: '01700000000',
            isEmailVerified: true,
          ),
      mockTokens ?? const AuthTokens(access: 'access_jwt', refresh: 'refresh_jwt'),
    );
  }

  @override
  Future<(UserModel, AuthTokens)> register(RegisterRequest request) async {
    return (
      UserModel(
        id: '2',
        email: request.email,
        fullName: request.fullName,
        phoneNumber: request.phoneNumber,
        isEmailVerified: false,
      ),
      const AuthTokens(access: '', refresh: ''),
    );
  }

  @override
  Future<UserModel> getProfile() async {
    return mockUser ??
        const UserModel(
          id: '1',
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '01700000000',
          isEmailVerified: true,
        );
  }

  @override
  Future<void> requestPasswordResetOtp(PasswordResetOtpRequest request) async {
    otpRequested = true;
  }

  @override
  Future<void> confirmPasswordReset(PasswordResetConfirmRequest request) async {
    otpConfirmed = true;
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }
}

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveAccessToken(String token) async {
    _storage['access'] = token;
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage['access'];
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _storage['refresh'] = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage['refresh'];
  }

  @override
  Future<void> saveTokens({required String access, required String refresh}) async {
    _storage['access'] = access;
    _storage['refresh'] = refresh;
  }

  @override
  Future<void> clearTokens() async {
    _storage.remove('access');
    _storage.remove('refresh');
  }
}

void main() {
  group('Auth Models Tests', () {
    test('UserModel fromJson / toJson', () {
      final json = {
        'id': 'usr_123',
        'email': 'user@plateroute.com',
        'full_name': 'Afzal Hossain',
        'phone_number': '+8801700000000',
        'role': 'customer',
        'is_email_verified': true,
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'usr_123');
      expect(user.email, 'user@plateroute.com');
      expect(user.fullName, 'Afzal Hossain');
      expect(user.isEmailVerified, true);

      final encoded = user.toJson();
      expect(encoded['id'], 'usr_123');
      expect(encoded['email'], 'user@plateroute.com');
    });

    test('AuthTokens fromJson / toJson', () {
      final json = {
        'access': 'mock_access_token',
        'refresh': 'mock_refresh_token',
      };

      final tokens = AuthTokens.fromJson(json);
      expect(tokens.access, 'mock_access_token');
      expect(tokens.refresh, 'mock_refresh_token');
    });

    test('AuthState status indicators', () {
      const initial = AuthState.initial();
      expect(initial.status, AuthStatus.initial);
      expect(initial.isAuthenticated, false);
      expect(initial.isLoading, false);

      const authenticating = AuthState.authenticating();
      expect(authenticating.isLoading, true);

      const user = UserModel(
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '01700000000',
      );
      const authenticated = AuthState.authenticated(user);
      expect(authenticated.isAuthenticated, true);
      expect(authenticated.user?.email, 'test@example.com');
    });
  });

  group('Auth Repository Tests', () {
    late MockAuthRemoteDataSource mockDataSource;
    late FakeSecureStorageService fakeStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      fakeStorage = FakeSecureStorageService();
      repository = AuthRepositoryImpl(
        remoteDataSource: mockDataSource,
        secureStorage: fakeStorage,
      );
    });

    test('Login saves access and refresh tokens to secure storage', () async {
      const request = LoginRequest(email: 'test@example.com', password: 'password123');
      final (user, tokens) = await repository.login(request);

      expect(user.email, 'test@example.com');
      expect(tokens.access, 'access_jwt');
      expect(await fakeStorage.getAccessToken(), 'access_jwt');
      expect(await fakeStorage.getRefreshToken(), 'refresh_jwt');
    });

    test('Logout clears tokens from secure storage', () async {
      await fakeStorage.saveTokens(access: 'tok1', refresh: 'tok2');
      await repository.logout();

      expect(mockDataSource.loggedOut, true);
      expect(await fakeStorage.getAccessToken(), isNull);
      expect(await fakeStorage.getRefreshToken(), isNull);
    });
  });
}

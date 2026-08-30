import 'user_model.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  emailUnverified,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? unverifiedEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.unverifiedEmail,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        unverifiedEmail = null;

  const AuthState.unauthenticated([String? message])
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = message,
        unverifiedEmail = null;

  const AuthState.authenticating()
      : status = AuthStatus.authenticating,
        user = null,
        errorMessage = null,
        unverifiedEmail = null;

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null,
        unverifiedEmail = null;

  const AuthState.emailUnverified(String email)
      : status = AuthStatus.emailUnverified,
        user = null,
        errorMessage = null,
        unverifiedEmail = email;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message,
        unverifiedEmail = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;
}

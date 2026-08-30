import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/models/auth_state.dart';
import 'route_paths.dart';

class AuthGuard {
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    AuthState authState,
  ) {
    final location = state.matchedLocation;
    final isGoingToSplash = location == RoutePaths.splash;
    final isGoingToAuth = location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.forgotPassword;
    final isGoingToVerifyEmail = location == RoutePaths.verifyEmail;

    // During initial loading / splash, let splash screen resolve
    if (authState.status == AuthStatus.initial ||
        (authState.status == AuthStatus.authenticating && isGoingToSplash)) {
      return null;
    }

    // Email unverified state
    if (authState.status == AuthStatus.emailUnverified) {
      if (!isGoingToVerifyEmail && !isGoingToAuth) {
        return RoutePaths.verifyEmail;
      }
      return null;
    }

    // Unauthenticated state
    if (authState.status == AuthStatus.unauthenticated || authState.status == AuthStatus.error) {
      // Protected routes that require authentication
      final isProtectedRoute = location.startsWith('/profile') ||
          location.startsWith('/orders') ||
          location.startsWith('/checkout') ||
          location.startsWith('/addresses') ||
          location.startsWith('/support') ||
          location.startsWith('/review');

      if (isProtectedRoute) {
        return RoutePaths.login;
      }

      if (isGoingToSplash) {
        return RoutePaths.home;
      }

      return null;
    }

    // Authenticated state
    if (authState.status == AuthStatus.authenticated) {
      if (isGoingToAuth || isGoingToSplash || isGoingToVerifyEmail) {
        return RoutePaths.home;
      }
    }

    return null;
  }
}

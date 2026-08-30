import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import 'app_shell.dart';
import 'route_paths.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final homeTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final ordersTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'ordersNav');
final profileTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register Screen')),
        ),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Verify Email')),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Forgot Password')),
        ),
      ),

      // Main Shell with 3 Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Home Feed')),
                ),
              ),
            ],
          ),

          // Branch 1: Orders
          StatefulShellBranch(
            navigatorKey: ordersTabNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.orders,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Orders List')),
                ),
              ),
            ],
          ),

          // Branch 2: Profile
          StatefulShellBranch(
            navigatorKey: profileTabNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Profile')),
                ),
              ),
            ],
          ),
        ],
      ),

      // Global Detail Routes
      GoRoute(
        path: RoutePaths.search,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Search Screen')),
        ),
      ),
      GoRoute(
        path: RoutePaths.restaurantDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Restaurant ${state.pathParameters['uuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.cart,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Cart Screen')),
        ),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Checkout Screen')),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Order Placed ${state.pathParameters['uuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.liveTracking,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Live Tracking ${state.pathParameters['uuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Order Detail ${state.pathParameters['uuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.orderChat,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Chat ${state.pathParameters['threadUuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.reviewComposer,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Review ${state.pathParameters['orderUuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.addresses,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Address Manager')),
        ),
      ),
      GoRoute(
        path: RoutePaths.addressEditor,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Address Editor')),
        ),
      ),
      GoRoute(
        path: RoutePaths.vouchers,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Vouchers')),
        ),
      ),
      GoRoute(
        path: RoutePaths.issueReport,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Issue Report ${state.pathParameters['orderUuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.supportTicket,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => Scaffold(
          body: Center(child: Text('Support Ticket ${state.pathParameters['uuid']}')),
        ),
      ),
      GoRoute(
        path: RoutePaths.securityCenter,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Security Center')),
        ),
      ),
      GoRoute(
        path: RoutePaths.notificationPreferences,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Notification Preferences')),
        ),
      ),
      GoRoute(
        path: RoutePaths.paymentMethods,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Payment Methods')),
        ),
      ),
    ],
  );
});

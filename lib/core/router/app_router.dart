import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/support/presentation/screens/issue_report_screen.dart';
import '../../features/review/presentation/screens/review_composer_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/tracking/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/order_success_screen.dart';
import '../../features/orders/presentation/screens/orders_list_screen.dart';
import '../../features/cart/presentation/screens/vouchers_list_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_detail_screen.dart';
import '../../features/discovery/presentation/screens/search_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_password_reset_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_shell.dart';
import 'auth_guard.dart';
import 'route_paths.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final homeTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final ordersTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'ordersNav');
final profileTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) => AuthGuard.redirect(context, state, authState),
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
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const OtpPasswordResetScreen(),
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Orders
          StatefulShellBranch(
            navigatorKey: ordersTabNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.orders,
                builder: (context, state) => const OrdersListScreen(),
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
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.restaurantDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => RestaurantDetailScreen(
          restaurantUuid: state.pathParameters['uuid'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.cart,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RoutePaths.orderSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? 'ord_latest';
          final restaurant = state.uri.queryParameters['restaurant'];
          final totalStr = state.uri.queryParameters['total'];
          final total = totalStr != null ? double.tryParse(totalStr) : null;

          return OrderSuccessScreen(
            orderUuid: uuid,
            restaurantName: restaurant,
            totalAmount: total,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.liveTracking,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => OrderTrackingScreen(
          orderUuid: state.pathParameters['uuid'] ?? 'ord_latest',
        ),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => OrderDetailScreen(
          orderUuid: state.pathParameters['uuid'] ?? 'ord_latest',
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
        builder: (context, state) => ReviewComposerScreen(
          orderUuid: state.pathParameters['orderUuid'] ?? 'ord_latest',
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
        builder: (context, state) => const VouchersListScreen(),
      ),
      GoRoute(
        path: RoutePaths.issueReport,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => IssueReportScreen(
          orderUuid: state.pathParameters['orderUuid'] ?? 'ord_latest',
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

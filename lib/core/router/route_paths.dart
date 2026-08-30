class RoutePaths {
  // Root & Splash
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  // Main Tabs (Shell)
  static const String home = '/home';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Discovery & Restaurant
  static const String search = '/search';
  static const String restaurantDetail = '/restaurant/:uuid';
  static String restaurantDetailUri(String uuid) => '/restaurant/$uuid';

  // Cart & Checkout
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success/:uuid';
  static String orderSuccessUri(String uuid) => '/order-success/$uuid';

  // Orders & Tracking
  static const String orderDetail = '/orders/:uuid';
  static String orderDetailUri(String uuid) => '/orders/$uuid';
  static const String liveTracking = '/tracking/:uuid';
  static String liveTrackingUri(String uuid) => '/tracking/$uuid';
  static const String orderChat = '/chat/:threadUuid';
  static String orderChatUri(String threadUuid) => '/chat/$threadUuid';
  static const String reviewComposer = '/review/:orderUuid';
  static String reviewComposerUri(String orderUuid) => '/review/$orderUuid';

  // Address & Vouchers
  static const String addresses = '/addresses';
  static const String addressEditor = '/addresses/editor';

  static const String vouchers = '/vouchers';

  // Support
  static const String issueReport = '/support/issue/:orderUuid';
  static String issueReportUri(String orderUuid) => '/support/issue/$orderUuid';
  static const String supportTicket = '/support/ticket/:uuid';
  static String supportTicketUri(String uuid) => '/support/ticket/$uuid';

  // Profile Sub-screens
  static const String securityCenter = '/profile/security';
  static const String notificationPreferences = '/profile/notifications';
  static const String paymentMethods = '/profile/payments';
}

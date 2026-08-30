class ApiEndpoints {
  // Base URLs (can be overridden by environment)
  static const String defaultBaseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String defaultWsUrl = 'ws://10.0.2.2:8000';

  // Auth Endpoints
  static const String login = '/api/auth/login/';
  static const String register = '/api/auth/register/';
  static const String logout = '/api/auth/logout/';
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String passwordResetOtp = '/api/auth/password-reset-otp/';
  static const String passwordResetConfirm = '/api/auth/password-reset-otp/confirm/';
  static const String profile = '/api/auth/profile/';

  // System & Config
  static const String health = '/api/healthz/';
  static const String config = '/api/v1/config/';

  // Discovery & Restaurants
  static const String restaurants = '/api/v1/restaurants/';
  static String restaurantDetails(String uuid) => '/api/v1/restaurants/$uuid/';

  // Cart Endpoints
  static const String cart = '/api/v1/carts/';
  static const String cartClear = '/api/v1/carts/clear/';
  static const String cartItems = '/api/v1/carts/items/';
  static String cartItemDetail(int id) => '/api/v1/carts/items/$id/';

  // Orders Endpoints
  static const String orders = '/api/v1/orders/';
  static const String placeOrder = '/api/v1/orders/place/';
  static String orderDetail(String uuid) => '/api/v1/orders/$uuid/';
  static String orderTransition(String uuid) => '/api/v1/orders/$uuid/transition/';

  // Payments Endpoints
  static String paymentStart(String orderUuid) => '/api/v1/payments/$orderUuid/start/';
  static String paymentStatus(String orderUuid) => '/api/v1/payments/$orderUuid/status/';
  static const String refunds = '/api/v1/payments/refunds/';

  // Delivery & Tracking
  static String orderTracking(String orderUuid) => '/api/v1/delivery/orders/$orderUuid/tracking/';

  // Addresses & Geocoding
  static const String addresses = '/api/v1/addresses/';
  static String addressDefault(String uuid) => '/api/v1/addresses/$uuid/default/';
  static const String geocode = '/api/v1/geocode/';

  // Promotions & Coupons
  static const String couponValidate = '/api/v1/coupons/validate/';

  // Reviews
  static const String reviews = '/api/v1/reviews/';
  static String branchReviews(String branchUuid) => '/api/v1/reviews/branches/$branchUuid/';

  // Support
  static const String supportTickets = '/api/v1/support/tickets/';
  static String supportTicketDetail(String uuid) => '/api/v1/support/tickets/$uuid/';

  // Chat
  static const String chatThreads = '/api/v1/chat/threads/';
  static String chatMessages(String threadUuid) => '/api/v1/chat/threads/$threadUuid/messages/';
  static String chatRead(String threadUuid) => '/api/v1/chat/threads/$threadUuid/read/';

  // Notifications
  static const String deviceRegister = '/api/v1/notifications/devices/';
  static const String notificationPreferences = '/api/v1/notifications/preferences/';

  // WebSockets
  static String wsOrderTracking(String orderUuid) => '/ws/orders/$orderUuid/';
  static String wsChat(String threadUuid) => '/ws/chat/$threadUuid/';
}

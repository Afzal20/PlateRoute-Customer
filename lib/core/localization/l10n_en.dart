import 'app_strings.dart';

class StringsEn implements AppStrings {
  const StringsEn();

  @override
  String get appName => 'PlateRoute';
  @override
  String get home => 'Home';
  @override
  String get orders => 'Orders';
  @override
  String get profile => 'Profile';
  @override
  String get cart => 'Cart';
  @override
  String get retry => 'Retry';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get save => 'Save';
  @override
  String get edit => 'Edit';
  @override
  String get delete => 'Delete';
  @override
  String get close => 'Close';
  @override
  String get apply => 'Apply';
  @override
  String get clear => 'Clear';
  @override
  String get loading => 'Loading...';
  @override
  String get genericError => 'That did not go through. Retry?';
  @override
  String get noInternetConnection => 'No internet connection. Please check your network.';
  @override
  String get viewAll => 'View All';
  @override
  String get seeMore => 'See More';
  @override
  String get seeLess => 'See Less';

  @override
  String get login => 'Log In';
  @override
  String get register => 'Sign Up';
  @override
  String get signup => 'Sign Up';
  @override
  String get logout => 'Log Out';
  @override
  String get email => 'Email Address';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get fullName => 'Full Name';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get sendOtp => 'Send OTP';
  @override
  String get enterOtp => 'Enter Verification Code';
  @override
  String get verifyOtp => 'Verify OTP';
  @override
  String get resendOtp => 'Resend OTP';
  @override
  String get otpSentNotice => 'A verification code has been sent to your email/phone.';
  @override
  String get dontHaveAccount => "Don't have an account? Sign up";
  @override
  String get alreadyHaveAccount => 'Already have an account? Log in';
  @override
  String get emailVerificationNotice => 'Please verify your email address to continue.';
  @override
  String get verifyEmailMessage => 'We sent a verification link to your email. Please click the link to activate your account.';
  @override
  String get backToLogin => 'Back to Log In';

  @override
  String get deliveringTo => 'Delivering to';
  @override
  String get currentLocation => 'Current Location';
  @override
  String get selectAddress => 'Select Address';
  @override
  String get searchPlaceholder => 'Search dishes, cuisines, or restaurants';
  @override
  String get openNow => 'Open Now';
  @override
  String get topRated => 'Top Rated';
  @override
  String get offersAndDeals => 'Offers & Deals';
  @override
  String get popularCuisines => 'Popular Cuisines';
  @override
  String get featuredRestaurants => 'Featured Restaurants';
  @override
  String get allRestaurants => 'All Restaurants';
  @override
  String get noResultsFound => 'No results found';
  @override
  String get noResultsSuggestion => 'Try searching for another dish or cuisine';
  @override
  String get searchHistory => 'Recent Searches';
  @override
  String get clearHistory => 'Clear History';
  @override
  String get filters => 'Filters';
  @override
  String get sortBy => 'Sort By';
  @override
  String get rating => 'Rating';
  @override
  String get deliveryTime => 'Delivery Time';
  @override
  String get minOrder => 'Min Order';

  @override
  String get addToCart => 'Add to cart';
  @override
  String get customize => 'Customize';
  @override
  String get requiredSelection => 'Required';
  @override
  String get optionalSelection => 'Optional';
  @override
  String chooseUpTo(int max) => 'Choose up to $max';
  @override
  String chooseAtLeast(int min) => 'Choose at least $min';
  @override
  String get outOfStock => 'Out of Stock';
  @override
  String get closed => 'Closed';
  @override
  String get reviews => 'Reviews';
  @override
  String get ratings => 'Ratings';
  @override
  String get mins => 'mins';
  @override
  String get freeDelivery => 'Free Delivery';
  @override
  String get aboutRestaurant => 'About Restaurant';

  @override
  String get yourCart => 'Your Cart';
  @override
  String get cartEmpty => 'Your cart is empty';
  @override
  String get cartEmptyPrompt => 'No orders yet — Home is two taps away';
  @override
  String get exploreRestaurants => 'Explore Restaurants';
  @override
  String get feeBreakdownTitle => 'Your total, fully shown';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get deliveryFee => 'Delivery Fee';
  @override
  String get platformFee => 'Platform Fee';
  @override
  String get vatTax => 'VAT & Taxes';
  @override
  String get discount => 'Discount';
  @override
  String get voucherSavings => 'Voucher Applied';
  @override
  String get enterVoucherCode => 'Enter voucher code';
  @override
  String get voucherApplied => 'Voucher successfully applied';
  @override
  String get invalidVoucher => 'Invalid or expired voucher code';
  @override
  String quoteExpiring(int minutes) => 'Items reserved: $minutes min';
  @override
  String get refreshQuote => 'Refresh quote';
  @override
  String get proceedToCheckout => 'Proceed to Checkout';
  @override
  String get placeOrder => 'Place Order';
  @override
  String get deliveryAddress => 'Delivery Address';
  @override
  String get paymentMethod => 'Payment Method';
  @override
  String get cashOnDelivery => 'Cash on Delivery';
  @override
  String get creditDebitCard => 'Credit / Debit Card';
  @override
  String get digitalWallet => 'bKash / Nagad Wallet';
  @override
  String get orderNotes => 'Special Instructions';
  @override
  String get orderNotesHint => 'e.g. Please leave at the door, less spicy';
  @override
  String get tipRider => 'Rider Tip';
  @override
  String get crossRestaurantConflictTitle => 'Replace Cart Items?';
  @override
  String get crossRestaurantConflictMessage => 'Your cart contains items from another restaurant. Do you want to discard them and add items from this restaurant?';
  @override
  String get clearAndAdd => 'Clear & Add';
  @override
  String get keepCurrent => 'Keep Current';

  @override
  String get orderSuccessTitle => 'Order Placed!';
  @override
  String orderAcceptedTime(String name, int minutes) => '$name accepted in ${minutes}m';
  @override
  String get viewLiveTracking => 'View Live Tracking';
  @override
  String get trackOrder => 'Track Order';
  @override
  String get orderStatusPlaced => 'Order Placed';
  @override
  String get orderStatusAccepted => 'Order Accepted';
  @override
  String get orderStatusPreparing => 'Preparing Food';
  @override
  String get orderStatusPicked => 'Out for Delivery';
  @override
  String get orderStatusDelivered => 'Delivered';
  @override
  String get orderStatusCancelled => 'Cancelled';
  @override
  String etaLine(String time) => 'Arrives by $time';
  @override
  String courierOnWay(String name) => '$name picked up your order';
  @override
  String get contactCourier => 'Call Courier';
  @override
  String get contactRestaurant => 'Call Restaurant';
  @override
  String get orderDetails => 'Order Details';
  @override
  String get orderSummary => 'Order Summary';
  @override
  String get orderId => 'Order ID';
  @override
  String get reorder => 'Reorder';
  @override
  String get reorderSuccess => 'Items added to cart';
  @override
  String get threadClosedHint => 'This conversation closed after delivery';

  @override
  String get rateOrder => 'Rate Order';
  @override
  String get howWasYourFood => 'How was your food and delivery?';
  @override
  String get writeReviewHint => 'Share your experience (optional)...';
  @override
  String get submitReview => 'Submit Review';
  @override
  String get reviewSubmitted => 'Thank you for your review!';
  @override
  String get reportIssue => 'Report Issue';
  @override
  String get selectIssueType => 'Select issue type';
  @override
  String get issueMissingItem => 'Missing Item';
  @override
  String get issueColdFood => 'Cold Food or Spilled';
  @override
  String get issueLateDelivery => 'Extremely Late Delivery';
  @override
  String get issueWrongOrder => 'Wrong Order Received';
  @override
  String get describeIssue => 'Please describe what went wrong';
  @override
  String get submitTicket => 'Submit Support Ticket';
  @override
  String get ticketCreated => 'Support ticket created successfully';

  @override
  String get savedAddresses => 'Saved Addresses';
  @override
  String get addNewAddress => 'Add New Address';
  @override
  String get editAddress => 'Edit Address';
  @override
  String get setAsDefault => 'Set as default address';
  @override
  String get defaultAddressBadge => 'Default';
  @override
  String get addressTitleHint => 'e.g. Home, Office, Gym';
  @override
  String get houseFlatFloor => 'House / Apartment / Floor number';
  @override
  String get deliveryInstructions => 'Delivery directions or notes';

  @override
  String get availableVouchers => 'Available Vouchers';
  @override
  String get expiredVouchers => 'Expired Vouchers';
  @override
  String get termsAndConditions => 'Terms & Conditions';
  @override
  String minSpendRequired(String amount) => 'Min. spend ৳$amount';
  @override
  String validUntil(String date) => 'Valid until $date';

  @override
  String get accountSecurity => 'Security Center';
  @override
  String get activeSessions => 'Active Login Sessions';
  @override
  String get revokeSession => 'Revoke Session';
  @override
  String get changePassword => 'Change Password';
  @override
  String get notificationSettings => 'Notification Preferences';
  @override
  String get pushNotifications => 'Push Notifications';
  @override
  String get promoUpdates => 'Promotional Updates & Offers';
  @override
  String get appLanguage => 'App Language';
  @override
  String get appearance => 'Appearance';
  @override
  String get lightMode => 'Light Mode';
  @override
  String get darkMode => 'Dark Mode';
  @override
  String get systemTheme => 'System Default';
  @override
  String get deleteAccount => 'Delete Account';
  @override
  String get deleteAccountConfirm => 'Are you sure you want to delete your account? This action cannot be undone.';
  @override
  String get helpCenter => 'Help & Support';
}

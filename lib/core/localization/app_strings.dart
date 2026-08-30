abstract class AppStrings {
  // Common & Navigation
  String get appName;
  String get home;
  String get orders;
  String get profile;
  String get cart;
  String get retry;
  String get cancel;
  String get confirm;
  String get save;
  String get edit;
  String get delete;
  String get close;
  String get apply;
  String get clear;
  String get loading;
  String get genericError;
  String get noInternetConnection;
  String get viewAll;
  String get seeMore;
  String get seeLess;

  // Auth Flow
  String get login;
  String get register;
  String get signup;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get fullName;
  String get phoneNumber;
  String get forgotPassword;
  String get resetPassword;
  String get sendOtp;
  String get enterOtp;
  String get verifyOtp;
  String get resendOtp;
  String get otpSentNotice;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get emailVerificationNotice;
  String get verifyEmailMessage;
  String get backToLogin;

  // Discovery & Search
  String get deliveringTo;
  String get currentLocation;
  String get selectAddress;
  String get searchPlaceholder;
  String get openNow;
  String get topRated;
  String get offersAndDeals;
  String get popularCuisines;
  String get featuredRestaurants;
  String get allRestaurants;
  String get noResultsFound;
  String get noResultsSuggestion;
  String get searchHistory;
  String get clearHistory;
  String get filters;
  String get sortBy;
  String get rating;
  String get deliveryTime;
  String get minOrder;

  // Restaurant & Menu
  String get addToCart;
  String get customize;
  String get requiredSelection;
  String get optionalSelection;
  String chooseUpTo(int max);
  String chooseAtLeast(int min);
  String get outOfStock;
  String get closed;
  String get reviews;
  String get ratings;
  String get mins;
  String get freeDelivery;
  String get aboutRestaurant;

  // Cart & Checkout
  String get yourCart;
  String get cartEmpty;
  String get cartEmptyPrompt;
  String get exploreRestaurants;
  String get feeBreakdownTitle;
  String get subtotal;
  String get deliveryFee;
  String get platformFee;
  String get vatTax;
  String get discount;
  String get voucherSavings;
  String get enterVoucherCode;
  String get voucherApplied;
  String get invalidVoucher;
  String quoteExpiring(int minutes);
  String get refreshQuote;
  String get proceedToCheckout;
  String get placeOrder;
  String get deliveryAddress;
  String get paymentMethod;
  String get cashOnDelivery;
  String get creditDebitCard;
  String get digitalWallet;
  String get orderNotes;
  String get orderNotesHint;
  String get tipRider;
  String get crossRestaurantConflictTitle;
  String get crossRestaurantConflictMessage;
  String get clearAndAdd;
  String get keepCurrent;

  // Order Success & Tracking
  String get orderSuccessTitle;
  String orderAcceptedTime(String name, int minutes);
  String get viewLiveTracking;
  String get trackOrder;
  String get orderStatusPlaced;
  String get orderStatusAccepted;
  String get orderStatusPreparing;
  String get orderStatusPicked;
  String get orderStatusDelivered;
  String get orderStatusCancelled;
  String etaLine(String time);
  String courierOnWay(String name);
  String get contactCourier;
  String get contactRestaurant;
  String get orderDetails;
  String get orderSummary;
  String get orderId;
  String get reorder;
  String get reorderSuccess;
  String get threadClosedHint;

  // Reviews & Issues
  String get rateOrder;
  String get howWasYourFood;
  String get writeReviewHint;
  String get submitReview;
  String get reviewSubmitted;
  String get reportIssue;
  String get selectIssueType;
  String get issueMissingItem;
  String get issueColdFood;
  String get issueLateDelivery;
  String get issueWrongOrder;
  String get describeIssue;
  String get submitTicket;
  String get ticketCreated;

  // Address Manager
  String get savedAddresses;
  String get addNewAddress;
  String get editAddress;
  String get setAsDefault;
  String get defaultAddressBadge;
  String get addressTitleHint;
  String get houseFlatFloor;
  String get deliveryInstructions;

  // Vouchers
  String get availableVouchers;
  String get expiredVouchers;
  String get termsAndConditions;
  String minSpendRequired(String amount);
  String validUntil(String date);

  // Profile & Settings
  String get accountSecurity;
  String get activeSessions;
  String get revokeSession;
  String get changePassword;
  String get notificationSettings;
  String get pushNotifications;
  String get promoUpdates;
  String get appLanguage;
  String get appearance;
  String get lightMode;
  String get darkMode;
  String get systemTheme;
  String get deleteAccount;
  String get deleteAccountConfirm;
  String get helpCenter;
}

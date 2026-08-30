import 'package:latlong2/latlong.dart';

class AppConstants {
  // App Info
  static const String appName = 'PlateRoute';
  static const String appVersion = '1.0.0';

  // Currency & Locale Defaults
  static const String defaultCurrencySymbol = '৳';
  static const String defaultCurrencyCode = 'BDT';
  static const String defaultLocale = 'en';

  // Network & Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;

  // Polling & Throttling
  static const Duration trackingPollInterval = Duration(seconds: 15);
  static const Duration etaUpdateThrottle = Duration(seconds: 15);
  static const Duration quoteTtlWarningThreshold = Duration(seconds: 120); // 2 minutes

  // UI Metrics & Animations
  static const Duration microAnimDuration = Duration(milliseconds: 120);
  static const Duration standardAnimDuration = Duration(milliseconds: 240);
  static const Duration countUpTweenDuration = Duration(milliseconds: 300);
  static const Duration celebratoryAnimDuration = Duration(milliseconds: 600);
  static const Duration bannerAutoScrollInterval = Duration(seconds: 4);

  // Pagination & Lists
  static const int defaultPageSize = 20;
  static const int maxSearchHistoryItems = 10;
  static const int maxReviewCharCount = 1000;
  static const int reviewCharCountSoftWarning = 800;

  // Default Map Coordinates (Dhaka, Bangladesh)
  static const LatLng defaultLocation = LatLng(23.8103, 90.4125);
  static const double defaultMapZoom = 15.0;
  static const double trackingMapZoom = 16.0;

  // Tile Server URL (OpenStreetMap)
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'PlateRouteCustomerApp/1.0.0 (contact@plateroute.com)';

  // Validation Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp bdPhoneRegex = RegExp(
    r'^(?:\+8801|8801|01)[3-9]\d{8}$',
  );
}

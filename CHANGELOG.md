# Changelog

All notable changes to the PlateRoute Customer application are documented in this file.

## [1.0.0] - Production Release

### Summary of Completed Milestones (95 Atomic Commits)

#### Phase 0 & 1: Foundation & Core Design Tokens
- Configured project dependencies, Dio client, FlutterSecureStorage, and PreferencesService.
- Implemented core design system tokens: Plate Blue (`#2563EB`), Flame Orange (`#EA580C`), 0-elevation, tabular figures.
- Built reusable core widgets: `AppButton`, `AppTextField`, `StatusPill`, `InteractiveRatingBar`, `TimelineStrip`, `MapPane`.

#### Phase 2: Navigation & Authentication
- Implemented `GoRouter` shell routing with auth guards and tab navigation.
- Built `SplashScreen`, `LoginScreen`, `RegisterScreen`, `EmailVerificationScreen`, and `OtpPasswordResetScreen`.
- Added authentication unit and repository test suite.

#### Phase 3: Discovery, Search & Filters
- Built `HomeScreen` (S5) with hero banners, cuisines rail, search bar, and restaurant feed.
- Built `SearchFilterSheet` (S6) with multi-select cuisine chips, sort pills, and dietary toggles.
- Implemented discovery repository, data sources, and unit tests.

#### Phase 4: Restaurant & Menu Customization
- Built `RestaurantDetailScreen` (S7) with sticky category headers and rating cards.
- Built `MenuItemCustomizationSheet` (S8) with radio groups and option modifiers.
- Built `CartProvider` and `PriceCalculator` with 5% VAT and single-restaurant isolation.

#### Phase 5: Cart, Vouchers & Checkout
- Built `CartScreen` (S9) with quantity steppers and voucher selection sheet.
- Built `CheckoutScreen` (S10) with address picker, payment switcher (bKash, Nagad, Card, Cash), and 5-min TTL quote countdown.
- Built `VouchersListScreen` (S11) for platform coupon browsing and clipboard copy.
- Added checkout test suite with voucher caps and quote expiry tests.

#### Phase 6: Order Lifecycle & Live Tracking
- Built `OrdersListScreen` (S14) with active tracking card and past orders history.
- Built `OrderSuccessScreen` (S12) with animated elastic checkmark.
- Built `OrderTrackingScreen` (S13) with OpenStreetMap rider tracking, 4-stage timeline, and WebSocket/polling fallback.
- Built `OrderDetailScreen` (S15), `CancellationReasonSheet`, and `ReorderService`.

#### Phase 7: Reviews, In-App Support & Chat
- Built `ReviewComposerScreen` (S16) with interactive 5-star rating, tags, and 800-char warning / 1000-char cap.
- Built `IssueReportScreen` (S17) with category selector and photo attachments.
- Built `OrderChatScreen` (S18) with WebSocket duplexing, canned quick replies, and receipt checkmarks.
- Built `SupportTicketDetailScreen` (S19) with investigation timeline and agent reply flow.

#### Phase 8: Profile, Addresses, Security & Offline Resilience
- Built `AddressManagementScreen` (S20) and `AddressEditorScreen` (S21) with map pin picker.
- Built `ProfileScreen` (S22), `SecurityCenterScreen` (S23), `NotificationPreferencesScreen` (S24), and `PaymentMethodsScreen` (S25).
- Built `LanguageSwitcherSheet` (English/Bengali) and `OfflineBanner` network degradation monitor.
- Implemented `DeepLinkHandler` and configured `main.dart` app root.
- Created end-to-end integration test suite (`test/app_flow_test.dart`) and release documentation.

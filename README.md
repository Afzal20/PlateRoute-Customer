# PlateRoute Customer Mobile Application

Production-ready, high-performance Flutter mobile application for the **PlateRoute** food delivery and restaurant discovery platform. Built in strict accordance with the PlateRoute Customer App UI Specifications, design tokens, and REST/WebSocket API contracts.

---

## 1. Architectural Overview & Design System

### 1.1 Architecture
The application is structured using **Feature-First Clean Architecture** powered by **Riverpod 2.x**:
- `lib/core/`: Networking (`ApiClient`, `WebSocketClient`, `ConnectivityNotifier`), Design Tokens (`AppColors`, `AppSpacing`, `AppTypography`, `AppTheme`), Router (`GoRouter`, `AuthGuard`, `DeepLinkHandler`), Storage (`SecureStorageService`, `PreferencesService`), and Localization (English & Bengali).
- `lib/features/`: Isolated feature modules encompassing Domain models, Repositories, Data sources, Riverpod StateNotifiers, and Presentation screens/widgets.

### 1.2 Design Tokens & Rules
- **Color Palette:**
  - **Plate Blue** (`#2563EB` light / `#60A5FA` dark) as Primary brand token.
  - **Flame Orange** (`#EA580C`) as Accent token (strictly limited to maximum **ONE** instance per viewport).
  - Dark Canvas (`#0A0F1D`) and Dark Surface (`#121B2E`) with calibrated text hierarchy.
- **Elevation:** Zero elevation (`elevation: 0`) across all cards, dialogs, and bottom sheets; separation via 1px border outlines (`#E2E8F0` / `#263349`).
- **Typography & Tabular Figures:** Proportional Inter font for text, with `FontFeature.tabularFigures()` applied to all price displays and live countdown timers.

---

## 2. Complete Screen Catalog & Features Implemented

| Screen ID | Module | Feature Description |
| :--- | :--- | :--- |
| **S1** | Auth | Splash screen with animated SVG logo, token verification, and session bootstrap |
| **S2** | Auth | Login screen with password visibility toggling and validation |
| **S3** | Auth | Register screen with full name, email, phone, and password creation |
| **S4** | Auth | OTP Password Reset flow with 4-digit code entry and resend cooldown ticker |
| **S5** | Discovery | Home Discovery screen with search header, hero carousel, cuisines, and restaurant cards |
| **S6** | Discovery | Search & Filter sheet with multi-select cuisine chips, sort pills, and dietary filters |
| **S7** | Restaurant | Restaurant Detail screen with sticky category tabs, rating cards, and menu lists |
| **S8** | Restaurant | Menu Item Customization sheet with required radio groups and optional modifier checkboxes |
| **S9** | Cart | Cart screen with item rows, quantity steppers, voucher selector, and price breakdown |
| **S10** | Checkout | Checkout screen with address picker, rider notes, payment selector, and quote countdown |
| **S11** | Vouchers | Vouchers Wallet screen with coupon cards, clipboard copy, and apply actions |
| **S12** | Orders | Order Success screen with animated elastic checkmark ring and live tracking shortcut |
| **S13** | Tracking | Live Order Tracking screen with interactive OSM Leaflet map, rider marker, and 4-stage timeline |
| **S14** | Orders | Order History screen with active order tracking cards and past receipts list |
| **S15** | Orders | Order Detail & Receipt screen with itemized invoice, payment summary, and re-order action |
| **S16** | Reviews | Review Composer screen with interactive 5-star rating, tag chips, and character counter |
| **S17** | Support | Issue Report screen with category radio picker, description field, and photo attachments |
| **S18** | Chat | Order Chat screen with live WebSocket duplexing, canned quick replies, and message bubbles |
| **S19** | Support | Support Ticket Detail screen with investigation status, refund notice, and agent thread |
| **S20** | Address | Saved Addresses Management screen with default selector and delete confirmation |
| **S21** | Address | Address Editor screen with interactive map pin picker, label selector, and instruction inputs |
| **S22** | Profile | User Profile screen with avatar, dark mode switch, language modal, and security links |
| **S23** | Profile | Security Center screen with password updater, 2FA toggle, and active session manager |
| **S24** | Profile | Notification Preferences screen with push/SMS channel controls and promotional switches |
| **S25** | Profile | Payment Methods screen with linked bKash/Nagad wallets and card management |

---

## 3. Technology Stack

- **Flutter SDK:** `>=3.3.0 <4.0.0`
- **State Management:** `flutter_riverpod: ^2.5.1`
- **Routing:** `go_router: ^14.2.0`
- **Networking:** `dio: ^5.4.3+1` & `web_socket_channel: ^3.0.0`
- **Interactive Mapping:** `flutter_map: ^7.0.2` & `latlong2: ^0.9.1` (OpenStreetMap / CartoDB tiles)
- **Local Persistence:** `flutter_secure_storage: ^9.2.2` & `shared_preferences: ^2.2.3`
- **Localization:** Custom runtime bilingual system (English `en` & Bengali `bn`) with `PreferencesService` persistence

---

## 4. Verification & Testing

The project includes an automated test suite verifying domain logic, calculations, quote timeouts, and E2E flows:

```bash
# Run all unit and integration tests
flutter test

# Verify Dart analyzer diagnostics
dart analyze lib
```

All 40 unit and widget test cases pass with zero warnings or errors.

---

## 5. Getting Started

1. Clone repository and navigate to workspace:
   ```bash
   cd apps/customer
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run in development environment:
   ```bash
   flutter run -d chrome
   # or for mobile
   flutter run
   ```

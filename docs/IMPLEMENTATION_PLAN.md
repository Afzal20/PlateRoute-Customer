# Customer App — Implementation Plan

| Field | Value |
| --- | --- |
| Source design | `backend/docs/design/CUSTOMER_APP_UI.md` v1.0 |
| Requirements | PROJECT_PLAN §8.3 (MOB-USR-01..12) + §8.2 common (MOB-C-*) |
| Modules | M3 (ordering core), M4 (tracking), M5 (payments), M6 (trust) |
| Default theme | Follow OS setting; both themes ship day one |

## 1. Requirement analysis

| ID | Requirement | Screens involved | Backend endpoints consumed | Risk notes |
| --- | --- | --- | --- | --- |
| MOB-USR-01 | Onboarding: signup, email-verification notice, login, OTP reset | S1–S5 | `/api/auth/*` | OTP flow is single-use + throttled; surface branded context |
| MOB-USR-02 | Home discovery feed, location permission pre-prompt, rails, open-now filter | S6 | `restaurants/`, `geocode/` | Location is optional — app must work with manual area selection |
| MOB-USR-03 | Restaurant + menu browsing, option min/max rules client-side + server | S7–S8 | `restaurants/{uuid}/`, `menu/*` | Enforce option-group min/max locally AND trust server rejection |
| MOB-USR-04 | Cart interactions, cross-restaurant conflict dialog | S9 | `carts/`, `carts/items/` | Replace-or-separate policy must be an explicit user choice |
| MOB-USR-05 | Checkout: quote TTL reconfirm, Stripe sheet, COD eligibility, coupons | S10–S12 | `carts/` quote, `payments/{order}/start/`, `coupons/validate/`, `orders/place/` | Highest-risk flow: tokenized payment BEFORE place; quote TTL honesty (FR-CART-05) |
| MOB-USR-06 | Live tracking: map, courier marker, ETA chip, WS with poll fallback | S14 | `delivery/orders/{uuid}/tracking/`, WS `/ws/orders/{uuid}/` | ETA updates ≥15s, absolute time ("Arrives by 7:42 PM"), no flicker |
| MOB-USR-07 | Order timeline from OrderEvent history | S15 | `orders/{uuid}/`, events | Read-only transparency; drives peak-end moment |
| MOB-USR-08 | Address book, default selection, map-pin placement | S17–S18 | `addresses/` | Single-default partial rule; pin placement first-class |
| MOB-USR-09 | Review composer post-DELIVERED, star + capped text (1000) | S16 | `reviews/` | Prompted post-meal via push, never ambushed |
| MOB-USR-10 | Security center: sessions indicator, OTP password change, notif prefs | S20–S21 | `/api/auth/*`, `notifications/preferences/` | S priority |
| MOB-USR-11 | Search with persisted filter/sort prefs | S6–S7 | `restaurants/` | Persist locally; rehydrate on cold start |
| MOB-USR-12 | Order-issue report → support ticket linked to order | S23 | `support/tickets/` | S priority |
| MOB-C-01..14 | Common: auth lifecycle, FCM, deep links, idempotency, error mapping, offline cache, pagination, en/bn, analytics, Sentry, a11y, force-update, deletion, store kit | cross-cutting | all | See overview §3 components |

**Critical-path analysis:** checkout (MOB-USR-05) and tracking (MOB-USR-06) are the two flows that decide retention — "the product is the promise of a predictable arrival time". Everything else can be staged; these cannot be stubbed at launch.

## 2. Page list (22 screens)

**Auth (S1–S5):** S1 Splash/force-update gate · S2 Login · S3 Register · S4 Email-verification notice · S5 OTP password reset (request + confirm)
**Home tab (S6):** S6 Home — location bar, rails, search entry, open-now default
**Orders tab (S13–S16):** S13 Orders list (active tracker pinned) · S14 Live tracking (map + timeline + ETA sheet + chat/call row) · S15 Order detail/timeline · S16 Review composer
**Profile tab (S17–S22):** S17 Address manager · S18 Address editor (map pin) · S19 Payment methods · S20 Security center (sessions, password change) · S21 Notification preferences · S22 Profile & language settings
**Discovery extras (S7–S9):** S7 Search results (skeletons, zero-result cuisine pivots) · S8 Restaurant page (trust strip, category chips, item tiles) · S8b Item customization sheet (optional, long-tap)
**Flow extras (S9b–S12, S23–S24):** S9 Cart · S10 Checkout · S11 Stripe payment sheet (SDK) · S12 Order success moment · S23 Order-issue report form · S24 Vouchers page
**Bottom navigation:** exactly 3 tabs (Home, Orders, Profile) + persistent CartBar (56dp, count-up tween, never jumps layout).

## 3. Component list

1. `CartBar` — persistent, endowed-progress anchor; deep-links into cart preserving scroll
2. `RestaurantTile` — 96px image, Title S, plate-blue rating chip, ≤1 orange deal ribbon
3. `QuoteExpiryPill` — neutral → warning tint <120s (single gentle pulse) → "Refresh quote" CTA swap
4. `BreakdownRow` — always-expanded fee breakdown; savings rows in success + strikethrough original
5. `TimelineStrip` — 4 nodes, active pulse 0.4→1 @1.2s, completed fill primary
6. `TrackingMap` (MapPane) — courier marker, route polyline, OSM tiles
7. `EtaHeader` — plain-language stage line + absolute-time ETA, ≥15s update throttle
8. `ItemTile` + `QuantityStepper` — thumb-zone right-lower placement; default options on tap
9. `OptionGroupSelector` — min/max enforcement with live validation
10. `CategoryChipScroller` — scroll-synced to restaurant list
11. `SkeletonLoaders` — per network surface (results, restaurant, orders)
12. `CouponField` — inline instant validation message
13. `ReviewStarInput` — inline range errors, soft counter after 800 chars
14. `AddressPinPicker` — map drag + geocode, default star toggle
15. `PaymentMethodSelector` — default preselected; Stripe sheet tokenization status
16. `SuccessMoment` — Display 30/38 check-in-circle, 600ms max, haptic .medium, once/session
17. `ChatThreadView` / `CallButton` — per FR windows, threadClosedHint after delivery
18. `SecurityCenterCards` — sessions list, OTP-change entry, deletion path (FR-AUTH-09)
19. `IssueReportForm` — ticket create linked to order (MOB-USR-12)
20. Shared core_ui: buttons, skeletons, error mapper, infinite scroll, force-update gate (overview §3)

## 4. Color palette (light default; dark ships day one)

| Token | Light | Dark | Role / rule |
| --- | --- | --- | --- |
| color.canvas | #F8FAFC | #0B1220 | Screen background; elevates white cards |
| color.surface | #FFFFFF | #121B2E | Cards, sheets |
| color.border | #E2E8F0 | #263349 | 1px borders — elevation is banned |
| color.primary (Plate Blue) | #2563EB | #60A5FA (text/icons only) | Trust anchor, links, tracking header, selected tab. Light: 4.54:1 on white. Dark buttons stay solid #2563EB + white label |
| color.accent (Flame Orange) | #EA580C | #EA580C | CTA (Add to cart, Checkout), deal badges. **Max ONE orange element per viewport.** White label only ≥16sp SemiBold, else accentStrong |
| color.accentStrong | #C2410C | #C2410C | Small-text accent, pressed state; 5.4:1 with white |
| color.success | #16A34A | #22C55E | Confirmation moments; pair with icon, never color alone |
| color.warning | #D97706 | #D97706 | Quote expiring soon; text uses warningDeep #92400E on tinted bg |
| color.danger | #DC2626 | #F87171 | Errors/destructive ONLY — scarcity keeps power; body-danger uses #B91C1C |
| color.textPrimary | #0F172A | #EDF2FA | Headlines, prices — 16.9:1 (light) |
| color.textSecondary | #475569 | #9AA8BD | Supporting lines — 7.4:1 (light) |

**Forbidden pairings (design-review failures):** orange backgrounds behind red text; two accents competing in one card; status colors decorating non-status content.

Type: Inter + Noto Sans Bengali; ramp Display 30/38 (success moment only), Title L 22/28, Title S 18/24 (prices, tabular), Body 16/24, Body S 14/20, Caption 12/16 (never for actions). Money is never Caption. 8pt grid; radii card 16 / sheet 20 / input 12; touch ≥48×48 with 8px spacing; CartBar 56dp.

## 5. External APIs used

- PlateRoute REST: `auth`, `restaurants`, `menu`, `carts`, `coupons/validate`, `orders/place`, `payments/{order}/start`, `addresses`, `geocode`, `reviews`, `notifications/*`, `support/tickets`, `chat/threads`, `calls/turn-credentials`, `v1/config` (force-update floors)
- PlateRoute WS: `/ws/orders/{uuid}/` (tracking), `/ws/chat/{thread}/`; poll fallback mandatory
- Stripe Flutter SDK (payment sheet, tokenized pre-place); bKash/Nagad wallet redirect (M7)
- FCM (order/tracking/promo pushes; token upsert)
- OSM tiles via MapPane + OSRM routing (Decision 3); Google Geocoding fallback only
- S3 signed uploads (review photos if enabled), Sentry, Firebase Analytics/App Distribution

## 6. Psychology guardrails to implement literally

Hick's Law (default options preselected) · Goal-Gradient (CartBar + timeline fill from server truth only) · Peak-End (thanks before photo prompt; rating via post-meal push) · Loss Aversion (TTL pill mirrors pricing engine exactly, FR-CART-05) · Social Proof (aggregates from FR-RVW-03 only) · Anchoring (struck-through price must have genuinely applied) · Doherty (<100ms touch acks, skeleton→content swaps). Instrumentation: `checkout_step_abandon{step}`, `fee_breakdown_expand`, `eta_accuracy_delta_seconds`, `reorder_tap_count` (baselines: checkout completion >82%, reorder path median <60s).

## 7. Git commit plan — target **90–110 commits**

| Phase | Content | Commits |
| --- | --- | --- |
| P0 | App scaffold, flavors, theme wiring to core_ui tokens, ARB en/bn setup | 8–10 |
| P1 | Auth: S1–S5, AuthGate integration, secure storage [MOB-USR-01] | 10–12 |
| P2 | Home + discovery + search: S6–S7 [MOB-USR-02/11] | 10–12 |
| P3 | Restaurant page + item sheet: S8, S8b [MOB-USR-03] | 8–10 |
| P4 | Cart + CartBar + conflict dialog: S9 [MOB-USR-04] | 8–10 |
| P5 | Checkout + Stripe + success: S10–S12 [MOB-USR-05] | 12–14 |
| P6 | Tracking + timeline: S13–S15 [MOB-USR-06/07] | 12–14 |
| P7 | Addresses + vouchers: S17–S18, S24 [MOB-USR-08] | 6–8 |
| P8 | Reviews + issues: S16, S23 [MOB-USR-09/12] | 5–7 |
| P9 | Profile/security/notifications: S19–S22 [MOB-USR-10] | 5–7 |
| P10 | Offline caching, deep links, force-update, analytics, a11y pass, bn QA | 6–8 |
| | **Total** | **90–112** |

## 8. App-specific concepts to learn (beyond overview §9)

1. Stripe Flutter SDK: payment sheet lifecycle, tokenization before order placement, test cards, webhook truth (client never trusts its own "success")
2. Quote-TTL UX: countdown UI synced to server quote expiry; refresh-quote repricing flow
3. Map polyline rendering + marker rotation; ETA smoothing (≥15s update throttle, absolute-time formatting)
4. WebSocket → poll fallback pattern with UI state machine (live / degraded / stale banner)
5. Optimistic cart mutations with server reconciliation
6. Deep link + associated domain config for order tracking and password-reset continuation
7. Skeleton geometry mirroring; shimmer performance on low-end devices
8. Money formatting in en/bn locales with tabular figures (integer minor units → ৳ display)

## 9. Definition of done

All MOB-USR-01..12 map to shipped screens; integration journey "browse→cart→checkout→place→track→review" passes on emulator matrix; checkout completion >82% instrumented; dynamic-type screenshots at 1.0x/1.3x both locales archived; TalkBack reads the two headline flows in visual order; release APK ≤40MB (NFR-14).


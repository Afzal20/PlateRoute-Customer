import 'package:flutter/material.dart';

class AppSpacing {
  // 8pt Grid Values
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  // Specific UI Metrics
  static const double screenGutter = 16.0;
  static const double cardPadding = 16.0;
  static const double interCard = 12.0;
  static const double intraGroup = 8.0;

  // Radii
  static const double radiusCard = 16.0;
  static const double radiusSheet = 20.0;
  static const double radiusInput = 12.0;
  static const double radiusButton = 12.0;
  static const double radiusPill = 100.0;

  // Heights & Touch
  static const double minTouchTarget = 48.0;
  static const double buttonHeightProminent = 56.0;
  static const double buttonHeightStandard = 48.0;
  static const double cartBarHeight = 56.0;
  static const double sheetGrabHandleWidth = 36.0;
  static const double sheetGrabHandleHeight = 4.0;

  // Border Radii Helpers
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius roundedSheet = BorderRadius.vertical(top: Radius.circular(radiusSheet));
  static const BorderRadius roundedInput = BorderRadius.all(Radius.circular(radiusInput));
  static const BorderRadius roundedButton = BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(radiusPill));
}

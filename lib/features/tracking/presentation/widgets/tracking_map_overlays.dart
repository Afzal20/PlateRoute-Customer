import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';

class TrackingMapOverlays {
  static Marker buildRiderMarker({
    required LatLng position,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Marker(
      point: position,
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  static Marker buildRestaurantMarker({
    required LatLng position,
    required bool isDark,
  }) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.accentDark : AppColors.accentLight,
            width: 2.0,
          ),
        ),
        child: Icon(
          Icons.storefront_rounded,
          color: isDark ? AppColors.accentDark : AppColors.accentStrongLight,
          size: 20,
        ),
      ),
    );
  }

  static Marker buildCustomerMarker({
    required LatLng position,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2.0),
        ),
        child: const Icon(
          Icons.home_rounded,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  static Polyline buildRoutePolyline({
    required List<LatLng> points,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Polyline(
      points: points,
      strokeWidth: 4.0,
      color: primaryColor,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/models/restaurant_model.dart';

class TrustStrip extends StatelessWidget {
  final RestaurantModel restaurant;

  const TrustStrip({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Rating Metric
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.rating.toStringAsFixed(1),
                style: AppTypography.bodySmallMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              if (restaurant.reviewCount > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '(${restaurant.reviewCount}+)',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),

          // Divider dot
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
          ),

          // 2. Prep / Delivery Time Metric
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled,
                size: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                '${restaurant.estimatedDeliveryMinutes} mins',
                style: AppTypography.bodySmallMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),

          // Divider dot
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
          ),

          // 3. Delivery Fee Metric
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delivery_dining,
                size: 18,
                color: restaurant.deliveryFee == 0
                    ? (isDark ? AppColors.successDark : AppColors.successLight)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.deliveryFee == 0
                    ? 'Free'
                    : '${AppConstants.defaultCurrencySymbol}${restaurant.deliveryFee.toInt()}',
                style: AppTypography.bodySmallMedium.copyWith(
                  fontWeight: restaurant.deliveryFee == 0 ? FontWeight.w700 : FontWeight.w500,
                  color: restaurant.deliveryFee == 0
                      ? (isDark ? AppColors.successDark : AppColors.successLight)
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

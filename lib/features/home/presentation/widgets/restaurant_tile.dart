import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/rating_chip.dart';
import '../../domain/models/restaurant_model.dart';

class RestaurantTile extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback? onTap;

  const RestaurantTile({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 96x96 Left Image Thumbnail
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? AppColors.borderDark : AppColors.canvasLight,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: restaurant.coverImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Icons.restaurant,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    if (!restaurant.isOpenNow)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'CLOSED',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.m),

                // Content Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deal Ribbon (At most ONE orange element per card)
                      if (restaurant.hasActiveDeal && restaurant.dealDescription != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.accentDark : AppColors.accentLight).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark ? AppColors.accentDark : AppColors.accentLight,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            restaurant.dealDescription!,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.accentDark : AppColors.accentStrongLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Restaurant Name (Title S)
                      Text(
                        restaurant.name,
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Cuisines Snippet
                      if (restaurant.cuisines.isNotEmpty) ...[
                        Text(
                          restaurant.cuisines.join(' • '),
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Bottom Info Row: Rating Chip + Delivery Time + Fee
                      Row(
                        children: [
                          RatingChip(
                            rating: restaurant.rating,
                            reviewCount: restaurant.reviewCount > 0 ? restaurant.reviewCount : null,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${restaurant.estimatedDeliveryMinutes}m',
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.deliveryFee == 0
                                ? 'Free'
                                : '${AppConstants.defaultCurrencySymbol}${restaurant.deliveryFee.toInt()}',
                            style: AppTypography.caption.copyWith(
                              color: restaurant.deliveryFee == 0
                                  ? (isDark ? AppColors.successDark : AppColors.successLight)
                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              fontWeight: restaurant.deliveryFee == 0 ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

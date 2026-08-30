import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/price_text.dart';
import '../../domain/models/menu_item_model.dart';
import 'quantity_stepper.dart';

class ItemTile extends StatelessWidget {
  final MenuItemModel item;
  final int cartQuantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onCustomize;

  const ItemTile({
    super.key,
    required this.item,
    this.cartQuantity = 0,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = (locale == 'bn' && item.nameBn != null) ? item.nameBn! : item.name;

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
          onTap: item.isAvailable ? (item.hasCustomizations ? onCustomize : onAdd) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Content: Title, Description, Price, Customization hint
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.isPopular) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, size: 14, color: AppColors.accentLight),
                            const SizedBox(width: 2),
                            Text(
                              'POPULAR',
                              style: AppTypography.overline.copyWith(
                                color: AppColors.accentLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        displayName,
                        style: AppTypography.titleSmall.copyWith(
                          color: item.isAvailable
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      PriceText(
                        amount: item.price,
                        originalAmount: item.originalPrice,
                      ),
                      if (item.hasCustomizations) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: onCustomize,
                          child: Text(
                            'Customizable',
                            style: AppTypography.caption.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.m),

                // Right Content: Image Thumbnail + Lower-Right Stepper (Thumb Zone)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 80x80 Thumbnail
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? AppColors.borderDark : AppColors.canvasLight,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Icons.fastfood,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Thumb-zone Add button / Stepper
                    if (!item.isAvailable)
                      Text(
                        'Out of Stock',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (cartQuantity > 0)
                      QuantityStepper(
                        quantity: cartQuantity,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                        isCompact: true,
                      )
                    else
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accentDark : AppColors.accentLight).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.accentDark : AppColors.accentLight,
                            width: 1.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (item.hasCustomizations && item.optionGroups.any((g) => g.isRequired)) {
                                onCustomize?.call();
                              } else {
                                onAdd();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 16,
                                    color: isDark ? AppColors.accentDark : AppColors.accentStrongLight,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'ADD',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark ? AppColors.accentDark : AppColors.accentStrongLight,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

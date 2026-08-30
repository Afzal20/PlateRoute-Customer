import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class RatingChip extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final bool isFilled;

  const RatingChip({
    super.key,
    required this.rating,
    this.reviewCount,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(
          color: primaryColor,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 14,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.caption.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 3),
            Text(
              '($reviewCount)',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

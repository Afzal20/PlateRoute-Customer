import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isCompact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final height = isCompact ? 32.0 : 36.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: primaryColor,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement (-)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(height / 2)),
              onTap: () {
                HapticFeedback.lightImpact();
                onDecrement();
              },
              child: SizedBox(
                width: height,
                height: height,
                child: Icon(
                  quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                  size: 16,
                  color: quantity == 1
                      ? (isDark ? AppColors.dangerDark : AppColors.dangerLight)
                      : primaryColor,
                ),
              ),
            ),
          ),

          // Quantity Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              quantity.toString(),
              style: AppTypography.bodySmallMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),

          // Increment (+)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(height / 2)),
              onTap: () {
                HapticFeedback.lightImpact();
                onIncrement();
              },
              child: SizedBox(
                width: height,
                height: height,
                child: Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

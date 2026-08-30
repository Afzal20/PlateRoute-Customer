import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PriceText extends StatelessWidget {
  final double amount;
  final double? originalAmount;
  final TextStyle? style;
  final Color? color;
  final String currencySymbol;
  final bool isLarge;

  const PriceText({
    super.key,
    required this.amount,
    this.originalAmount,
    this.style,
    this.color,
    this.currencySymbol = AppConstants.defaultCurrencySymbol,
    this.isLarge = false,
  });

  const PriceText.large({
    super.key,
    required this.amount,
    this.originalAmount,
    this.style,
    this.color,
    this.currencySymbol = AppConstants.defaultCurrencySymbol,
  }) : isLarge = true;

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final baseStyle = isLarge
        ? AppTypography.titleLarge.copyWith(
            color: defaultColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          )
        : AppTypography.titleSmall.copyWith(
            color: defaultColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          );

    final effectiveStyle = style != null ? baseStyle.merge(style) : baseStyle;

    final priceWidget = Text(
      '$currencySymbol${_formatAmount(amount)}',
      style: effectiveStyle,
    );

    if (originalAmount != null && originalAmount! > amount) {
      final originalStyle = (isLarge ? AppTypography.body : AppTypography.bodySmall).copyWith(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        decoration: TextDecoration.lineThrough,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          priceWidget,
          const SizedBox(width: 6),
          Text(
            '$currencySymbol${_formatAmount(originalAmount!)}',
            style: originalStyle,
          ),
        ],
      );
    }

    return priceWidget;
  }
}

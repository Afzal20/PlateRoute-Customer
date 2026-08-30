import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum StatusPillType {
  info, // Plate Blue
  success, // Green
  warning, // Amber
  danger, // Red
  neutral, // Gray/border
}

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillType type;
  final IconData? icon;
  final bool isSolid;

  const StatusPill({
    super.key,
    required this.label,
    this.type = StatusPillType.info,
    this.icon,
    this.isSolid = false,
  });

  const StatusPill.success({
    super.key,
    required this.label,
    this.icon,
    this.isSolid = false,
  }) : type = StatusPillType.success;

  const StatusPill.warning({
    super.key,
    required this.label,
    this.icon,
    this.isSolid = false,
  }) : type = StatusPillType.warning;

  const StatusPill.danger({
    super.key,
    required this.label,
    this.icon,
    this.isSolid = false,
  }) : type = StatusPillType.danger;

  const StatusPill.neutral({
    super.key,
    required this.label,
    this.icon,
    this.isSolid = false,
  }) : type = StatusPillType.neutral;

  (Color, Color) _getColors(bool isDark) {
    switch (type) {
      case StatusPillType.info:
        return (
          isDark ? AppColors.primaryDark : AppColors.primaryLight,
          (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.12),
        );
      case StatusPillType.success:
        return (
          isDark ? AppColors.successDark : AppColors.successLight,
          (isDark ? AppColors.successDark : AppColors.successLight).withValues(alpha: 0.12),
        );
      case StatusPillType.warning:
        return (
          isDark ? AppColors.warningDark : AppColors.warningLight,
          (isDark ? AppColors.warningDark : AppColors.warningLight).withValues(alpha: 0.12),
        );
      case StatusPillType.danger:
        return (
          isDark ? AppColors.dangerDark : AppColors.dangerLight,
          (isDark ? AppColors.dangerDark : AppColors.dangerLight).withValues(alpha: 0.12),
        );
      case StatusPillType.neutral:
        return (
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.4),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (textColor, bgColor) = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? textColor : bgColor,
        borderRadius: AppSpacing.roundedPill,
        border: isSolid
            ? null
            : Border.all(
                color: textColor.withValues(alpha: 0.4),
                width: 1.0,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: isSolid ? AppColors.white : textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSolid ? AppColors.white : textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

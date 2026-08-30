import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  primary, // Flame orange conversion CTA (Add to cart, Checkout, Apply)
  plateBlue, // Plate blue trust actions (Track, Login, Submit)
  secondary, // Outlined with 1px border
  danger, // Red destructive actions
  ghost, // Text only
}

enum AppButtonSize {
  prominent, // 56dp
  standard, // 48dp
  compact, // 36dp
}

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enableHaptics;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.standard,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enableHaptics = true,
  });

  const AppButton.prominent({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enableHaptics = true,
  }) : size = AppButtonSize.prominent;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.standard,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enableHaptics = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.plateBlue({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.standard,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.enableHaptics = true,
  }) : variant = AppButtonVariant.plateBlue;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  double get _height => switch (widget.size) {
        AppButtonSize.prominent => AppSpacing.buttonHeightProminent,
        AppButtonSize.standard => AppSpacing.buttonHeightStandard,
        AppButtonSize.compact => 36.0,
      };

  TextStyle _getTextStyle(bool isDark) {
    final baseStyle = switch (widget.size) {
      AppButtonSize.prominent => const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      AppButtonSize.standard => const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      AppButtonSize.compact => AppTypography.bodySmallMedium,
    };

    Color textColor;
    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.plateBlue:
      case AppButtonVariant.danger:
        textColor = AppColors.white;
        break;
      case AppButtonVariant.secondary:
        textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        break;
      case AppButtonVariant.ghost:
        textColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
        break;
    }

    return baseStyle.copyWith(color: textColor);
  }

  Color _getBackgroundColor(bool isDark) {
    if (widget.onPressed == null && !widget.isLoading) {
      return (isDark ? AppColors.surfaceDark : AppColors.borderLight).withValues(alpha: 0.5);
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _isPressed
            ? (isDark ? AppColors.accentStrongDark : AppColors.accentStrongLight)
            : (isDark ? AppColors.accentDark : AppColors.accentLight);

      case AppButtonVariant.plateBlue:
        return _isPressed
            ? const Color(0xFF1D4ED8)
            : (isDark ? AppColors.primaryButtonDark : AppColors.primaryLight);

      case AppButtonVariant.danger:
        return _isPressed
            ? (isDark ? AppColors.dangerDeepDark : AppColors.dangerDeepLight)
            : (isDark ? AppColors.dangerDark : AppColors.dangerLight);

      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return _isPressed
            ? (isDark ? AppColors.borderDark : AppColors.canvasLight)
            : Colors.transparent;
    }
  }

  Border? _getBorder(bool isDark) {
    if (widget.variant == AppButtonVariant.secondary) {
      return Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1.0,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == AppButtonVariant.secondary ||
                        widget.variant == AppButtonVariant.ghost
                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    : AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else ...[
          if (widget.leadingIcon != null) ...[
            widget.leadingIcon!,
            const SizedBox(width: AppSpacing.xs),
          ],
        ],
        Text(
          widget.label,
          style: _getTextStyle(isDark),
        ),
        if (!widget.isLoading && widget.trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.xs),
          widget.trailingIcon!,
        ],
      ],
    );

    return AnimatedContainer(
      duration: AppConstants.microAnimDuration,
      height: _height,
      width: widget.isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        borderRadius: AppSpacing.roundedButton,
        border: _getBorder(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedButton,
          onTap: isEnabled
              ? () {
                  if (widget.enableHaptics) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onPressed?.call();
                }
              : null,
          onHighlightChanged: (pressed) {
            if (mounted) setState(() => _isPressed = pressed);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: content,
          ),
        ),
      ),
    );
  }
}

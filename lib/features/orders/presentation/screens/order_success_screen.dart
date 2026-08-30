import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderUuid;
  final String? restaurantName;
  final double? totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderUuid,
    this.restaurantName,
    this.totalAmount,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Success Checkmark Ring
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.successDark : AppColors.successLight).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.successDark : AppColors.successLight,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 64,
                      color: isDark ? AppColors.successDark : AppColors.successLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Title & Subtitle
              Text(
                l10n.orderSuccessTitle,
                style: AppTypography.titleLarge.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your meal is being prepared with high kitchen hygiene standards.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Order Summary Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Restaurant',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          widget.restaurantName ?? 'Chillox - Banani',
                          style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Arrival',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          '25 - 35 mins',
                          style: AppTypography.bodySmallMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order ID',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.orderUuid));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order ID copied')),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${widget.orderUuid.substring(0, widget.orderUuid.length > 8 ? 8 : widget.orderUuid.length)}',
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.copy_rounded, size: 14, color: primaryColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Action: Track Live Order
              AppButton.prominent(
                label: l10n.viewLiveTracking,
                variant: AppButtonVariant.primary,
                onPressed: () {
                  context.pushReplacement(RoutePaths.orderDetailUri(widget.orderUuid));
                },
              ),
              const SizedBox(height: AppSpacing.s),

              // Secondary Action: Continue Exploring
              TextButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text(
                  'Back to Home Feed',
                  style: AppTypography.bodySmallMedium.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

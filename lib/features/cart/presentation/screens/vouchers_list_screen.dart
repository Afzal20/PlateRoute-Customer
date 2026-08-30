import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/voucher_provider.dart';

class VouchersListScreen extends ConsumerWidget {
  const VouchersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final vouchersAsync = ref.watch(availableVouchersProvider(null));

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.availableVouchers),
      ),
      body: vouchersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load vouchers'),
              const SizedBox(height: 10),
              AppButton(
                label: l10n.retry,
                variant: AppButtonVariant.secondary,
                onPressed: () => ref.refresh(availableVouchersProvider(null)),
              ),
            ],
          ),
        ),
        data: (vouchers) {
          if (vouchers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 64,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'No Vouchers Available',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Stay tuned for upcoming festival deals and special discounts.',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            itemCount: vouchers.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
            itemBuilder: (context, index) {
              final voucher = vouchers[index];

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Promo Code Badge + Copy Action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor, width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_number_rounded, size: 16, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  voucher.code,
                                  style: AppTypography.bodySmallMedium.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            icon: Icon(Icons.copy_rounded, size: 16, color: primaryColor),
                            label: Text(
                              'Copy',
                              style: AppTypography.caption.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: voucher.code));
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Coupon code "${voucher.code}" copied to clipboard!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.m),

                      // Title & Description
                      Text(
                        voucher.title,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (voucher.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          voucher.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s),
                      const Divider(),
                      const SizedBox(height: 6),

                      // Footer Details: Min order & CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (voucher.minOrderAmount > 0)
                            Text(
                              'Min. order ${AppConstants.defaultCurrencySymbol}${voucher.minOrderAmount.toInt()}',
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          TextButton(
                            onPressed: () => context.go(RoutePaths.home),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Food',
                                  style: AppTypography.caption.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

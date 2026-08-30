import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../restaurant/presentation/widgets/quantity_stepper.dart';
import '../providers/cart_provider.dart';
import '../widgets/voucher_selection_sheet.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _showVoucherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const VoucherSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final cartState = ref.watch(cartProvider);

    if (cartState.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
        appBar: AppBar(title: Text(l10n.cart)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  l10n.cartEmpty,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.cartEmptyPrompt,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: 200,
                  child: AppButton(
                    label: l10n.exploreRestaurants,
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.go(RoutePaths.home),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final breakdown = cartState.breakdown;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
            },
            child: Text(
              'Clear',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Restaurant Header Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.s,
              ),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront, color: primaryColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartState.restaurantName ?? 'Restaurant',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Estimated Delivery: 25-35 mins',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (cartState.restaurantUuid != null)
                    TextButton(
                      onPressed: () {
                        context.push(RoutePaths.restaurantDetailUri(cartState.restaurantUuid!));
                      },
                      child: Text(
                        'Add Items',
                        style: AppTypography.caption.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Items List Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartState.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final cartItem = cartState.items[index];

                  // Build options summary
                  final optStrings = <String>[];
                  for (final opts in cartItem.selectedOptions.values) {
                    for (final o in opts) {
                      optStrings.add(o.name);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.item.name,
                                style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (optStrings.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  optStrings.join(', '),
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              if (cartItem.specialInstructions.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Note: "${cartItem.specialInstructions}"',
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              PriceText(amount: cartItem.totalPrice),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        QuantityStepper(
                          quantity: cartItem.quantity,
                          isCompact: true,
                          onIncrement: () {
                            ref.read(cartProvider.notifier).incrementItem(cartItem.id);
                          },
                          onDecrement: () {
                            ref.read(cartProvider.notifier).decrementItem(cartItem.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Coupon / Voucher Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.s,
              ),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(
                  color: cartState.voucherCode != null
                      ? (isDark ? AppColors.successDark : AppColors.successLight)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.0,
                ),
              ),
              child: InkWell(
                onTap: () => _showVoucherSheet(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      color: cartState.voucherCode != null
                          ? (isDark ? AppColors.successDark : AppColors.successLight)
                          : primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cartState.voucherCode != null) ...[
                            Text(
                              'Coupon "${cartState.voucherCode}" Applied',
                              style: AppTypography.bodySmallMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.successDark : AppColors.successLight,
                              ),
                            ),
                            Text(
                              'Saved ${AppConstants.defaultCurrencySymbol}${cartState.discountAmount.toInt()}',
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ] else ...[
                            Text(
                              l10n.enterVoucherCode,
                              style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Check available discount coupons',
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      cartState.voucherCode != null ? 'Change' : 'Apply',
                      style: AppTypography.caption.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bill Breakdown Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenGutter,
                vertical: AppSpacing.xs,
              ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill Details',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Subtotal
                  _buildBillRow(
                    l10n.subtotal,
                    '${AppConstants.defaultCurrencySymbol}${breakdown.subtotal.toInt()}',
                    isDark,
                  ),
                  const SizedBox(height: 8),

                  // Delivery Fee
                  _buildBillRow(
                    l10n.deliveryFee,
                    breakdown.deliveryFee == 0
                        ? 'Free'
                        : '${AppConstants.defaultCurrencySymbol}${breakdown.deliveryFee.toInt()}',
                    isDark,
                    isSuccess: breakdown.deliveryFee == 0,
                  ),
                  const SizedBox(height: 8),

                  // VAT (5%)
                  _buildBillRow(
                    'VAT (5%)',
                    '${AppConstants.defaultCurrencySymbol}${breakdown.vatAmount.toInt()}',
                    isDark,
                  ),
                  const SizedBox(height: 8),

                  // Platform fee
                  _buildBillRow(
                    'Platform Fee',
                    '${AppConstants.defaultCurrencySymbol}${breakdown.platformFee.toInt()}',
                    isDark,
                  ),

                  // Voucher Discount
                  if (breakdown.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildBillRow(
                      l10n.voucherSavings,
                      '-${AppConstants.defaultCurrencySymbol}${breakdown.discountAmount.toInt()}',
                      isDark,
                      isSuccess: true,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.m),
                  const Divider(),
                  const SizedBox(height: 6),

                  // Grand Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '${AppConstants.defaultCurrencySymbol}${breakdown.totalAmount.toInt()}',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 90), // Bottom CTA padding
          ),
        ],
      ),

      // Sticky Checkout CTA
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.s,
          AppSpacing.screenGutter,
          AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: AppButton.prominent(
            label: '${l10n.proceedToCheckout} • ${AppConstants.defaultCurrencySymbol}${breakdown.totalAmount.toInt()}',
            variant: AppButtonVariant.primary,
            onPressed: () => context.push(RoutePaths.checkout),
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, bool isDark, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmallMedium.copyWith(
            color: isSuccess
                ? (isDark ? AppColors.successDark : AppColors.successLight)
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            fontWeight: isSuccess ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

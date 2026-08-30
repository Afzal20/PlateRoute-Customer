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
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/quote_expiry_pill.dart';
import '../../../address/domain/models/delivery_address_model.dart';
import '../../../address/presentation/providers/address_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/models/payment_method_model.dart';
import '../providers/quote_provider.dart';
import '../widgets/payment_selector.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethodType _paymentMethod = PaymentMethodType.bkash;
  late final TextEditingController _riderNotesController;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _riderNotesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialQuote();
    });
  }

  void _fetchInitialQuote() {
    final cartState = ref.read(cartProvider);
    final addressState = ref.read(addressProvider);
    final selectedAddress = addressState.selectedAddress;

    if (cartState.isNotEmpty && selectedAddress != null) {
      ref.read(quoteProvider.notifier).fetchQuote(
            restaurantUuid: cartState.restaurantUuid ?? '',
            deliveryAddressId: selectedAddress.id,
            items: cartState.items,
            deliveryFee: cartState.deliveryFee,
            voucherCode: cartState.voucherCode,
            discountAmount: cartState.discountAmount,
          );
    }
  }

  @override
  void dispose() {
    _riderNotesController.dispose();
    super.dispose();
  }

  void _showAddressPickerSheet(BuildContext context, List<DeliveryAddressModel> addresses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSheet),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
              vertical: AppSpacing.m,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: AppSpacing.sheetGrabHandleWidth,
                    height: AppSpacing.sheetGrabHandleHeight,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Select Delivery Address', style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.s),

                ...addresses.map((addr) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      addr.label == AddressLabel.home
                          ? Icons.home_rounded
                          : (addr.label == AddressLabel.work ? Icons.work_rounded : Icons.location_on_rounded),
                      color: primaryColor,
                    ),
                    title: Text(
                      addr.formattedLabel,
                      style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${addr.addressLine}, ${addr.area}',
                      style: AppTypography.caption,
                    ),
                    onTap: () {
                      ref.read(addressProvider.notifier).selectAddress(addr);
                      Navigator.pop(ctx);
                      _fetchInitialQuote();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartProvider);
    final addressState = ref.read(addressProvider);
    final quoteState = ref.read(quoteProvider);

    if (addressState.selectedAddress == null || cartState.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    // Simulate placing order via API
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final orderUuid = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final restaurantName = cartState.restaurantName ?? 'Restaurant';
    final total = quoteState.quote?.totalAmount ?? cartState.totalAmount;

    // Clear cart on successful order creation
    ref.read(cartProvider.notifier).clearCart();

    setState(() => _isPlacingOrder = false);

    // Navigate to Order Success & Tracking screen (S12)
    context.go(
      '${RoutePaths.orderDetailUri(orderUuid)}?newOrder=true&restaurant=$restaurantName&total=$total',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final cartState = ref.watch(cartProvider);
    final addressState = ref.watch(addressProvider);
    final quoteState = ref.watch(quoteProvider);

    final selectedAddress = addressState.selectedAddress;
    final totalAmount = quoteState.quote?.totalAmount ?? cartState.totalAmount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Quote Expiry Countdown Banner
          if (quoteState.quote != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.s,
                  AppSpacing.screenGutter,
                  AppSpacing.xs,
                ),
                child: Center(
                  child: QuoteExpiryPill(
                    expiresAt: quoteState.quote!.expiresAt,
                    onExpired: () {
                      ref.read(quoteProvider.notifier).refreshActiveQuote();
                    },
                  ),
                ),
              ),
            ),

          // 2. Delivery Address Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            l10n.deliveryAddress,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _showAddressPickerSheet(context, addressState.addresses),
                        child: Text(
                          'Change',
                          style: AppTypography.caption.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedAddress != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedAddress.formattedLabel,
                      style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${selectedAddress.addressLine}, ${selectedAddress.area}',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (selectedAddress.floorApt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedAddress.floorApt!,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // 3. Rider Delivery Notes
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
                    l10n.orderNotes,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    hintText: 'e.g. Leave with gate security, knock don\'t ring',
                    controller: _riderNotesController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),

          // 4. Payment Method
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenGutter,
                AppSpacing.m,
                AppSpacing.screenGutter,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.paymentMethod,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  PaymentSelector(
                    selectedMethod: _paymentMethod,
                    onMethodSelected: (method) => setState(() => _paymentMethod = method),
                  ),
                ],
              ),
            ),
          ),

          // 5. Bill Summary Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary (${cartState.totalItemCount} items)',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  ...cartState.items.map((ci) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${ci.quantity}x ${ci.item.name}',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              '${AppConstants.defaultCurrencySymbol}${ci.totalPrice.toInt()}',
                              style: AppTypography.bodySmallMedium,
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSpacing.s),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${AppConstants.defaultCurrencySymbol}${totalAmount.toInt()}',
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
            child: SizedBox(height: 90),
          ),
        ],
      ),

      // Sticky Bottom Place Order CTA
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
            label: '${l10n.placeOrder} • ${AppConstants.defaultCurrencySymbol}${totalAmount.toInt()}',
            variant: AppButtonVariant.primary,
            isLoading: _isPlacingOrder,
            onPressed: quoteState.isExpired ? null : _placeOrder,
          ),
        ),
      ),
    );
  }
}

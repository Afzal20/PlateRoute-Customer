import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/cart_provider.dart';
import '../providers/voucher_provider.dart';

class VoucherSelectionSheet extends ConsumerStatefulWidget {
  const VoucherSelectionSheet({super.key});

  @override
  ConsumerState<VoucherSelectionSheet> createState() => _VoucherSelectionSheetState();
}

class _VoucherSelectionSheetState extends ConsumerState<VoucherSelectionSheet> {
  late final TextEditingController _promoController;
  String? _errorMessage;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _promoController = TextEditingController();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyCode(String code) async {
    if (code.trim().isEmpty) return;

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    final cartState = ref.read(cartProvider);
    final repo = ref.read(voucherRepositoryProvider);

    final result = await repo.validateVoucher(
      code,
      subtotal: cartState.subtotal,
      deliveryFee: cartState.deliveryFee,
      restaurantUuid: cartState.restaurantUuid,
    );

    if (!mounted) return;

    setState(() => _isChecking = false);

    if (result.isValid) {
      HapticFeedback.mediumImpact();
      ref.read(cartProvider.notifier).applyVoucher(
            result.voucher?.code ?? code.toUpperCase(),
            result.discountAmount,
          );
      Navigator.pop(context);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errorMessage = result.failureReason ?? 'Voucher is not applicable to this order';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final cartState = ref.watch(cartProvider);
    final vouchersAsync = ref.watch(availableVouchersProvider(cartState.restaurantUuid));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenGutter,
            vertical: AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
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

              Text('Apply Coupon / Voucher', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.m),

              // Manual Code Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: 'Enter coupon code',
                      controller: _promoController,
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  SizedBox(
                    height: 52,
                    child: AppButton(
                      label: 'APPLY',
                      variant: AppButtonVariant.primary,
                      isLoading: _isChecking,
                      onPressed: () => _applyCode(_promoController.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(),
              const SizedBox(height: AppSpacing.xs),

              Text(
                'Available Coupons',
                style: AppTypography.overline.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              // Vouchers list
              Expanded(
                child: vouchersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => const Center(child: Text('Could not load vouchers')),
                  data: (vouchers) {
                    if (vouchers.isEmpty) {
                      return const Center(child: Text('No vouchers available at this time'));
                    }

                    return ListView.separated(
                      itemCount: vouchers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        final isApplied = cartState.voucherCode == voucher.code;

                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.canvasDark : AppColors.canvasLight,
                            borderRadius: AppSpacing.roundedCard,
                            border: Border.all(
                              color: isApplied
                                  ? primaryColor
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isApplied ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: primaryColor, width: 0.8),
                                    ),
                                    child: Text(
                                      voucher.code,
                                      style: AppTypography.caption.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  if (isApplied)
                                    TextButton(
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).removeVoucher();
                                      },
                                      child: Text(
                                        'REMOVE',
                                        style: AppTypography.caption.copyWith(
                                          color: isDark ? AppColors.dangerDark : AppColors.dangerLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  else
                                    TextButton(
                                      onPressed: () => _applyCode(voucher.code),
                                      child: Text(
                                        'APPLY',
                                        style: AppTypography.caption.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                voucher.title,
                                style: AppTypography.titleSmall.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              if (voucher.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  voucher.description,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                              if (voucher.minOrderAmount > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Min order: ${AppConstants.defaultCurrencySymbol}${voucher.minOrderAmount.toInt()}',
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

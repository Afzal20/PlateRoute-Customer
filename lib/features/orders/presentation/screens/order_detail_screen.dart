import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/models/order_model.dart';
import '../providers/orders_provider.dart';
import '../widgets/cancellation_reason_sheet.dart';

final orderDetailProvider = FutureProvider.family<OrderModel, String>((ref, orderUuid) async {
  final repo = ref.watch(orderRepositoryProvider);
  return await repo.getOrderDetails(orderUuid);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderUuid;

  const OrderDetailScreen({
    super.key,
    required this.orderUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final orderAsync = ref.watch(orderDetailProvider(orderUuid));

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Support',
            onPressed: () => context.push(RoutePaths.issueReportUri(orderUuid)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load order details'),
              const SizedBox(height: 10),
              AppButton(
                label: l10n.retry,
                variant: AppButtonVariant.secondary,
                onPressed: () => ref.refresh(orderDetailProvider(orderUuid)),
              ),
            ],
          ),
        ),
        data: (order) {
          final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            children: [
              // 1. Status Header Card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.uuid.substring(0, order.uuid.length > 8 ? 8 : order.uuid.length)}',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        StatusPill(
                          label: order.status.displayName,
                          type: order.status == OrderStatus.delivered
                              ? StatusPillType.success
                              : (order.status == OrderStatus.cancelled
                                  ? StatusPillType.neutral
                                  : StatusPillType.warning),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatted,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // 2. Track Order Shortcut (If active)
              if (order.isActive) ...[
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: AppButton(
                    label: 'VIEW LIVE TRACKING & MAP',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      context.push(RoutePaths.liveTrackingUri(order.uuid));
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              // 3. Restaurant & Delivery Address Cards
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          order.restaurantName,
                          style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivering to ${order.deliveryAddress.formattedLabel}',
                                style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${order.deliveryAddress.addressLine}, ${order.deliveryAddress.area}',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              // 4. Itemized Bill Receipt
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items Ordered (${order.items.length})',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    ...order.items.map((it) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${it.quantity}x',
                              style: AppTypography.bodySmallMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(it.name, style: AppTypography.bodySmallMedium),
                                  if (it.optionsSummary.isNotEmpty)
                                    Text(
                                      it.optionsSummary,
                                      style: AppTypography.caption.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${AppConstants.defaultCurrencySymbol}${it.totalPrice.toInt()}',
                              style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.m),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildReceiptRow('Subtotal', '${AppConstants.defaultCurrencySymbol}${order.subtotal.toInt()}', isDark),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Delivery Fee', '${AppConstants.defaultCurrencySymbol}${order.deliveryFee.toInt()}', isDark),
                    const SizedBox(height: 6),
                    _buildReceiptRow('VAT (5%)', '${AppConstants.defaultCurrencySymbol}${order.vatAmount.toInt()}', isDark),
                    const SizedBox(height: 6),
                    _buildReceiptRow('Platform Fee', '${AppConstants.defaultCurrencySymbol}${order.platformFee.toInt()}', isDark),

                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      _buildReceiptRow(
                        'Voucher Discount',
                        '-${AppConstants.defaultCurrencySymbol}${order.discountAmount.toInt()}',
                        isDark,
                        isSuccess: true,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.s),
                    const Divider(),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Paid', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${AppConstants.defaultCurrencySymbol}${order.totalAmount.toInt()}',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment: ${order.paymentMethod.displayName} (${order.paymentStatus.toUpperCase()})',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // 5. Reorder Button
              AppButton.prominent(
                label: 'Reorder All Items',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  context.push(RoutePaths.restaurantDetailUri(order.restaurantUuid));
                },
              ),
              const SizedBox(height: AppSpacing.s),

              // Cancel Order Button (If active)
              if (order.isActive) ...[
                AppButton(
                  label: 'Cancel Order',
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSheet),
                      builder: (ctx) => CancellationReasonSheet(
                        orderUuid: order.uuid,
                        isPostPreparation: order.status == OrderStatus.preparing ||
                            order.status == OrderStatus.outForDelivery,
                        onCancelled: () => ref.refresh(orderDetailProvider(orderUuid)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s),
              ],

              // 6. Review & Rating (If delivered)
              if (order.status == OrderStatus.delivered) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('Write a Review'),
                  onPressed: () => context.push(RoutePaths.reviewComposerUri(order.uuid)),
                ),
                const SizedBox(height: AppSpacing.s),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {bool isSuccess = false}) {
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
          style: AppTypography.bodySmall.copyWith(
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

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
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/models/order_model.dart';
import '../providers/orders_provider.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final ordersState = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Text(l10n.orders),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () => ref.read(ordersListProvider.notifier).loadOrders(),
        child: ordersState.isLoading
            ? ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                itemCount: 4,
                itemBuilder: (context, index) => const SkeletonRestaurantCard(),
              )
            : (ordersState.activeOrders.isEmpty && ordersState.pastOrders.isEmpty)
                ? _buildEmptyState(context, isDark, l10n)
                : CustomScrollView(
                    slivers: [
                      // Active Orders Section
                      if (ordersState.activeOrders.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenGutter,
                              AppSpacing.m,
                              AppSpacing.screenGutter,
                              AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.accentDark : AppColors.accentLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Orders',
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final order = ordersState.activeOrders[index];
                              return _buildActiveOrderCard(context, order, isDark, primaryColor);
                            },
                            childCount: ordersState.activeOrders.length,
                          ),
                        ),
                      ],

                      // Past Orders Section
                      if (ordersState.pastOrders.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenGutter,
                              AppSpacing.l,
                              AppSpacing.screenGutter,
                              AppSpacing.xs,
                            ),
                            child: Text(
                              'Past Orders',
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final order = ordersState.pastOrders[index];
                              return _buildPastOrderCard(context, order, isDark, primaryColor);
                            },
                            childCount: ordersState.pastOrders.length,
                          ),
                        ),
                      ],

                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildActiveOrderCard(
    BuildContext context,
    OrderModel order,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.restaurantName,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusPill(
                  label: order.status.displayName,
                  type: StatusPillType.warning,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${order.items.length} items • ${AppConstants.defaultCurrencySymbol}${order.totalAmount.toInt()}',
              style: AppTypography.bodySmallMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: AppButton(
                label: 'TRACK LIVE ORDER',
                variant: AppButtonVariant.primary,
                onPressed: () {
                  context.push(RoutePaths.orderDetailUri(order.uuid));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastOrderCard(
    BuildContext context,
    OrderModel order,
    bool isDark,
    Color primaryColor,
  ) {
    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenGutter,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedCard,
          onTap: () {
            context.push(RoutePaths.orderDetailUri(order.uuid));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.restaurantName,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusPill(
                      label: order.status == OrderStatus.delivered ? 'Delivered' : 'Cancelled',
                      type: order.status == OrderStatus.delivered
                          ? StatusPillType.success
                          : StatusPillType.neutral,
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
                const SizedBox(height: 6),
                Text(
                  order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConstants.defaultCurrencySymbol}${order.totalAmount.toInt()}',
                      style: AppTypography.bodySmallMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            context.push(RoutePaths.restaurantDetailUri(order.restaurantUuid));
                          },
                          child: Text(
                            'Reorder',
                            style: AppTypography.caption.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No Orders Yet',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'When you place food orders, they will show up here for live tracking and receipts.',
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/map_pane.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/timeline_strip.dart';
import '../../../orders/domain/models/order_model.dart';
import '../providers/tracking_provider.dart';
import '../widgets/tracking_map_overlays.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderUuid;

  const OrderTrackingScreen({
    super.key,
    required this.orderUuid,
  });

  TimelineStage _mapStatusToTimelineStage(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return TimelineStage.placed;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return TimelineStage.accepted;
      case OrderStatus.outForDelivery:
        return TimelineStage.picked;
      case OrderStatus.delivered:
        return TimelineStage.delivered;
      case OrderStatus.cancelled:
        return TimelineStage.cancelled;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final trackingState = ref.watch(orderTrackingProvider(orderUuid));

    if (trackingState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
        appBar: AppBar(title: Text(l10n.trackOrder)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final order = trackingState.order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.noResultsFound)),
      );
    }

    final restaurantPos = const LatLng(23.7920, 90.4050);
    final customerPos = LatLng(order.deliveryAddress.latitude, order.deliveryAddress.longitude);
    final riderPos = trackingState.riderPosition ?? restaurantPos;

    final markers = [
      TrackingMapOverlays.buildRestaurantMarker(position: restaurantPos, isDark: isDark),
      TrackingMapOverlays.buildCustomerMarker(position: customerPos, isDark: isDark),
      TrackingMapOverlays.buildRiderMarker(position: riderPos, isDark: isDark),
    ];

    final polylines = [
      TrackingMapOverlays.buildRoutePolyline(
        points: [restaurantPos, riderPos, customerPos],
        isDark: isDark,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.trackOrder, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            Text(
              '#${order.uuid.substring(0, order.uuid.length > 8 ? 8 : order.uuid.length)}',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'View Receipt',
            onPressed: () => context.push(RoutePaths.orderDetailUri(order.uuid)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // 1. Top Map Pane (38% height)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            child: MapPane(
              initialCenter: riderPos,
              initialZoom: AppConstants.trackingMapZoom,
              markers: markers,
              polylines: polylines,
            ),
          ),

          // 2. Bottom Scrollable Tracking Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.canvasDark : AppColors.canvasLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenGutter,
                  vertical: AppSpacing.m,
                ),
                children: [
                  // Status & ETA Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackingState.currentStatus.displayName,
                            style: AppTypography.titleLarge.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estimated Arrival in ${trackingState.remainingMinutes} mins',
                            style: AppTypography.bodySmallMedium.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      StatusPill(
                        label: trackingState.currentStatus == OrderStatus.delivered
                            ? 'Delivered'
                            : 'Live Tracking',
                        type: trackingState.currentStatus == OrderStatus.delivered
                            ? StatusPillType.success
                            : StatusPillType.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // 4-Stage Timeline Strip
                  TimelineStrip(
                    currentStage: _mapStatusToTimelineStage(trackingState.currentStatus),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Driver / Courier Contact Card
                  if (order.riderName != null) ...[
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: primaryColor.withValues(alpha: 0.12),
                            child: Icon(Icons.sports_motorsports_rounded, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.riderName!,
                                  style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Delivery Rider • 4.9 ★',
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (order.riderPhone != null)
                            IconButton(
                              icon: Icon(Icons.phone_rounded, color: primaryColor),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: order.riderPhone!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Rider phone ${order.riderPhone} copied')),
                                );
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline_rounded, color: primaryColor),
                            onPressed: () => context.push(RoutePaths.orderChatUri(order.uuid)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // Delivery Destination Card
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
                            Icon(Icons.location_on_rounded, color: primaryColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Delivering to ${order.deliveryAddress.formattedLabel}',
                              style: AppTypography.bodySmallMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.deliveryAddress.addressLine}, ${order.deliveryAddress.area}',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Need Help / Support CTA
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.help_outline_rounded, size: 18, color: primaryColor),
                    label: Text(
                      'Need help with this order?',
                      style: AppTypography.bodySmallMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    onPressed: () => context.push(RoutePaths.issueReportUri(order.uuid)),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

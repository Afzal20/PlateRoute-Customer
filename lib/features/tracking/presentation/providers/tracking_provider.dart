import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/network/websocket_client.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../data/services/live_tracking_service.dart';
import '../../domain/models/tracking_update_model.dart';

class OrderTrackingState {
  final bool isLoading;
  final OrderModel? order;
  final OrderStatus currentStatus;
  final LatLng? riderPosition;
  final int remainingMinutes;
  final String? statusMessage;
  final String? errorMessage;

  const OrderTrackingState({
    this.isLoading = true,
    this.order,
    this.currentStatus = OrderStatus.placed,
    this.riderPosition,
    this.remainingMinutes = 25,
    this.statusMessage,
    this.errorMessage,
  });

  OrderTrackingState copyWith({
    bool? isLoading,
    OrderModel? order,
    OrderStatus? currentStatus,
    LatLng? riderPosition,
    int? remainingMinutes,
    String? statusMessage,
    String? errorMessage,
  }) {
    return OrderTrackingState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      currentStatus: currentStatus ?? this.currentStatus,
      riderPosition: riderPosition ?? this.riderPosition,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final orderTrackingProvider = StateNotifierProvider.autoDispose
    .family<OrderTrackingNotifier, OrderTrackingState, String>((ref, orderUuid) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  final wsClient = ref.watch(webSocketClientProvider);

  return OrderTrackingNotifier(
    orderUuid: orderUuid,
    orderRepository: orderRepo,
    wsClient: wsClient,
  );
});

class OrderTrackingNotifier extends StateNotifier<OrderTrackingState> {
  final String orderUuid;
  final dynamic orderRepository;
  final dynamic wsClient;
  LiveTrackingService? _trackingService;

  OrderTrackingNotifier({
    required this.orderUuid,
    required this.orderRepository,
    required this.wsClient,
  }) : super(const OrderTrackingState()) {
    initTracking();
  }

  Future<void> initTracking() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final order = await orderRepository.getOrderDetails(orderUuid) as OrderModel;

      final initialRiderPos = order.riderLatitude != null && order.riderLongitude != null
          ? LatLng(order.riderLatitude!, order.riderLongitude!)
          : const LatLng(23.7920, 90.4050);

      state = state.copyWith(
        isLoading: false,
        order: order,
        currentStatus: order.status,
        riderPosition: initialRiderPos,
        remainingMinutes: 25,
      );

      _trackingService = LiveTrackingService(
        orderUuid: orderUuid,
        wsClient: wsClient,
        orderRepository: orderRepository,
      );

      _trackingService?.startTracking();
      _trackingService?.updates.listen(_handleTrackingUpdate);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _handleTrackingUpdate(OrderTrackingUpdate update) {
    LatLng? newPos = state.riderPosition;
    if (update.riderLatitude != null && update.riderLongitude != null) {
      newPos = LatLng(update.riderLatitude!, update.riderLongitude!);
    }

    state = state.copyWith(
      currentStatus: update.status,
      riderPosition: newPos,
      remainingMinutes: update.remainingMinutes ?? state.remainingMinutes,
      statusMessage: update.message,
    );
  }

  @override
  void dispose() {
    _trackingService?.dispose();
    super.dispose();
  }
}

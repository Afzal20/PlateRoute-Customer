import 'dart:async';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/websocket_client.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../domain/models/tracking_update_model.dart';

class LiveTrackingService {
  final String orderUuid;
  final WebSocketClient wsClient;
  final OrderRepository orderRepository;

  final _updateController = StreamController<OrderTrackingUpdate>.broadcast();
  Stream<OrderTrackingUpdate> get updates => _updateController.stream;

  StreamSubscription? _wsSubscription;
  StreamSubscription? _statusSubscription;
  Timer? _pollingTimer;
  Timer? _simulatedRiderTimer;

  LiveTrackingService({
    required this.orderUuid,
    required this.wsClient,
    required this.orderRepository,
  });

  void startTracking() {
    _connectWebSocket();
    _startSimulatedProgression();
  }

  void _connectWebSocket() {
    final wsPath = '/ws/orders/$orderUuid/tracking/';
    wsClient.connect(wsPath);

    _wsSubscription = wsClient.messageStream.listen((msg) {
      final event = msg['event'] as String?;
      if (event == 'tracking.update' || event == 'order.status_updated' || event != null) {
        final data = msg['data'] as Map<String, dynamic>? ?? msg;
        final update = OrderTrackingUpdate.fromJson(data, defaultUuid: orderUuid);
        _updateController.add(update);
      }
    });

    // If socket connection enters degraded status, start polling every 15s
    _statusSubscription = wsClient.stateStream.listen((status) {
      if (status == WsConnectionState.degraded) {
        _startPollingFallback();
      } else if (status == WsConnectionState.connected) {
        _pollingTimer?.cancel();
      }
    });
  }

  void _startPollingFallback() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(AppConstants.trackingPollInterval, (_) async {
      try {
        final order = await orderRepository.getOrderDetails(orderUuid);
        final update = OrderTrackingUpdate(
          orderUuid: orderUuid,
          status: order.status,
          riderLatitude: order.riderLatitude,
          riderLongitude: order.riderLongitude,
          remainingMinutes: 15,
          timestamp: DateTime.now(),
        );
        _updateController.add(update);
      } catch (_) {}
    });
  }

  void _startSimulatedProgression() {
    // Smooth demonstration: move rider toward destination over time
    double currentLat = 23.7920;
    double currentLng = 90.4050;
    int step = 0;

    _simulatedRiderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      step++;
      currentLat += 0.0005;
      currentLng += 0.0003;

      OrderStatus status = OrderStatus.preparing;
      if (step > 2 && step <= 6) {
        status = OrderStatus.outForDelivery;
      } else if (step > 6) {
        status = OrderStatus.delivered;
        timer.cancel();
      }

      final simulatedUpdate = OrderTrackingUpdate(
        orderUuid: orderUuid,
        status: status,
        riderLatitude: currentLat,
        riderLongitude: currentLng,
        remainingMinutes: (20 - (step * 2)).clamp(1, 30),
        message: status == OrderStatus.outForDelivery
            ? 'Rider picked up order and heading to your location'
            : (status == OrderStatus.delivered ? 'Order delivered safely' : 'Kitchen is packing your meal'),
        timestamp: DateTime.now(),
      );

      _updateController.add(simulatedUpdate);
    });
  }

  void dispose() {
    _wsSubscription?.cancel();
    _statusSubscription?.cancel();
    _pollingTimer?.cancel();
    _simulatedRiderTimer?.cancel();
    wsClient.disconnect();
    _updateController.close();
  }
}

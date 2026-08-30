import 'package:customer/core/widgets/timeline_strip.dart';
import 'package:customer/features/orders/domain/models/order_model.dart';
import 'package:customer/features/orders/presentation/widgets/cancellation_reason_sheet.dart';
import 'package:customer/features/tracking/domain/models/tracking_update_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live Tracking Model Tests', () {
    test('OrderTrackingUpdate JSON deserialization and coordinate extraction', () {
      final json = {
        'order_uuid': 'ord_live_99',
        'status': 'out_for_delivery',
        'rider_lat': 23.7937,
        'rider_lng': 90.4066,
        'remaining_minutes': 12,
        'message': 'Rider is 1 km away',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final update = OrderTrackingUpdate.fromJson(json);

      expect(update.orderUuid, 'ord_live_99');
      expect(update.status, OrderStatus.outForDelivery);
      expect(update.riderLatitude, 23.7937);
      expect(update.riderLongitude, 90.4066);
      expect(update.remainingMinutes, 12);
      expect(update.message, 'Rider is 1 km away');
    });

    test('TimelineStage stepIndex values match 4-stage progression', () {
      expect(TimelineStage.placed.stepIndex, 0);
      expect(TimelineStage.accepted.stepIndex, 1);
      expect(TimelineStage.picked.stepIndex, 2);
      expect(TimelineStage.delivered.stepIndex, 3);
      expect(TimelineStage.cancelled.stepIndex, -1);
    });

    test('CancellationReason definitions and label mappings', () {
      expect(CancellationReason.values.length, 5);
      expect(CancellationReason.changedMind.label, 'Changed my mind');
      expect(CancellationReason.tooLong.label, 'Delivery time is longer than expected');
    });
  });
}

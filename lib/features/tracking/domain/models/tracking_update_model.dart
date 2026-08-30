import '../../../orders/domain/models/order_model.dart';

class OrderTrackingUpdate {
  final String orderUuid;
  final OrderStatus status;
  final double? riderLatitude;
  final double? riderLongitude;
  final int? remainingMinutes;
  final String? message;
  final DateTime timestamp;

  const OrderTrackingUpdate({
    required this.orderUuid,
    required this.status,
    this.riderLatitude,
    this.riderLongitude,
    this.remainingMinutes,
    this.message,
    required this.timestamp,
  });

  factory OrderTrackingUpdate.fromJson(Map<String, dynamic> json, {String defaultUuid = ''}) {
    return OrderTrackingUpdate(
      orderUuid: (json['order_uuid'] ?? json['order_id'] ?? defaultUuid).toString(),
      status: OrderStatus.fromString((json['status'] ?? 'placed').toString()),
      riderLatitude: json['rider_lat'] != null
          ? (json['rider_lat'] as num).toDouble()
          : (json['latitude'] != null ? (json['latitude'] as num).toDouble() : null),
      riderLongitude: json['rider_lng'] != null
          ? (json['rider_lng'] as num).toDouble()
          : (json['longitude'] != null ? (json['longitude'] as num).toDouble() : null),
      remainingMinutes: json['remaining_minutes'] as int? ?? json['eta_minutes'] as int?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
    );
  }
}

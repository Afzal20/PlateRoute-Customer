import '../models/order_model.dart';

abstract class OrderRepository {
  Future<OrderModel> createOrder({
    required String quoteId,
    required String paymentMethod,
    String? riderNotes,
    required String idempotencyKey,
  });

  Future<OrderModel> getOrderDetails(String uuid);
  Future<List<OrderModel>> getActiveOrders();
  Future<List<OrderModel>> getOrderHistory({int page = 1});
  Future<void> cancelOrder(String uuid, {String? reason});
}

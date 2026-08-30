import '../../domain/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderModel> createOrder({
    required String quoteId,
    required String paymentMethod,
    String? riderNotes,
    required String idempotencyKey,
  }) async {
    return await remoteDataSource.createOrder(
      quoteId: quoteId,
      paymentMethod: paymentMethod,
      riderNotes: riderNotes,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<OrderModel> getOrderDetails(String uuid) async {
    return await remoteDataSource.fetchOrderDetails(uuid);
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    return await remoteDataSource.fetchActiveOrders();
  }

  @override
  Future<List<OrderModel>> getOrderHistory({int page = 1}) async {
    return await remoteDataSource.fetchOrderHistory(page: page);
  }

  @override
  Future<void> cancelOrder(String uuid, {String? reason}) async {
    await remoteDataSource.cancelOrder(uuid, reason: reason);
  }
}

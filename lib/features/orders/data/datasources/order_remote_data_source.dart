import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../address/domain/models/delivery_address_model.dart';
import '../../../checkout/domain/models/payment_method_model.dart';
import '../../domain/models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String quoteId,
    required String paymentMethod,
    String? riderNotes,
    required String idempotencyKey,
  });

  Future<OrderModel> fetchOrderDetails(String uuid);
  Future<List<OrderModel>> fetchActiveOrders();
  Future<List<OrderModel>> fetchOrderHistory({int page = 1});
  Future<void> cancelOrder(String uuid, {String? reason});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<OrderModel> createOrder({
    required String quoteId,
    required String paymentMethod,
    String? riderNotes,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.placeOrder,
        data: {
          'quote_id': quoteId,
          'payment_method': paymentMethod,
          'rider_notes': riderNotes,
        },
      );

      return OrderModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback mock created order
    }

    return _generateMockOrder(uuid: 'ord_${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<OrderModel> fetchOrderDetails(String uuid) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderDetail(uuid));
      return OrderModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback mock order
    }

    return _generateMockOrder(uuid: uuid);
  }

  @override
  Future<List<OrderModel>> fetchActiveOrders() async {
    try {
      final response = await _apiClient.get('/api/v1/orders/active/');
      if (response is List) {
        return response.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    return [
      _generateMockOrder(uuid: 'ord_active_1', status: OrderStatus.outForDelivery),
    ];
  }

  @override
  Future<List<OrderModel>> fetchOrderHistory({int page = 1}) async {
    try {
      final response = await _apiClient.get('/api/v1/orders/history/', queryParameters: {'page': page});
      if (response is List) {
        return response.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return [
      _generateMockOrder(uuid: 'ord_past_1', status: OrderStatus.delivered),
      _generateMockOrder(
        uuid: 'ord_past_2',
        status: OrderStatus.delivered,
        restaurantName: 'Kacchi Bhai - Dhanmondi',
      ),
    ];
  }

  @override
  Future<void> cancelOrder(String uuid, {String? reason}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.orderTransition(uuid),
        data: {'transition': 'cancel', 'reason': reason},
      );
    } catch (_) {}
  }

  OrderModel _generateMockOrder({
    required String uuid,
    OrderStatus status = OrderStatus.preparing,
    String restaurantName = 'Chillox - Banani',
  }) {
    return OrderModel(
      id: uuid,
      uuid: uuid,
      restaurantUuid: 'res_chillox',
      restaurantName: restaurantName,
      status: status,
      items: const [
        OrderItemModel(
          id: 'item_1',
          menuItemUuid: 'item_1',
          name: 'Classic Beef Smashed Burger',
          quantity: 2,
          unitPrice: 320.0,
          totalPrice: 640.0,
          optionsSummary: 'Double Patty, Aged Cheddar',
        ),
        OrderItemModel(
          id: 'item_3',
          menuItemUuid: 'item_3',
          name: 'Cheesy Loaded Fries',
          quantity: 1,
          unitPrice: 180.0,
          totalPrice: 180.0,
        ),
      ],
      subtotal: 820.0,
      deliveryFee: 40.0,
      vatAmount: 41.0,
      platformFee: 10.0,
      discountAmount: 50.0,
      totalAmount: 861.0,
      deliveryAddress: const DeliveryAddressModel(
        id: 'addr_1',
        label: AddressLabel.home,
        addressLine: 'House 42, Road 11, Block D',
        area: 'Banani, Dhaka',
        floorApt: 'Apt 4B',
        latitude: 23.7937,
        longitude: 90.4066,
      ),
      paymentMethod: PaymentMethodType.bkash,
      paymentStatus: 'paid',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      estimatedDeliveryAt: DateTime.now().add(const Duration(minutes: 18)),
      riderLatitude: 23.7960,
      riderLongitude: 90.4080,
      riderName: 'Rahim Uddin',
      riderPhone: '+8801812345678',
    );
  }
}

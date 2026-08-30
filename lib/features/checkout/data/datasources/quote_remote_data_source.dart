import '../../../../core/network/api_client.dart';
import '../../../cart/domain/models/cart_item_model.dart';
import '../../domain/models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<QuoteModel> requestQuote({
    required String restaurantUuid,
    required String deliveryAddressId,
    required List<CartItemModel> items,
    required double deliveryFee,
    String? voucherCode,
    double discountAmount = 0.0,
  });

  Future<QuoteModel> refreshQuote(String quoteId);
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final ApiClient _apiClient;

  QuoteRemoteDataSourceImpl(this._apiClient);

  @override
  Future<QuoteModel> requestQuote({
    required String restaurantUuid,
    required String deliveryAddressId,
    required List<CartItemModel> items,
    required double deliveryFee,
    String? voucherCode,
    double discountAmount = 0.0,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/checkout/quote/',
        data: {
          'restaurant_uuid': restaurantUuid,
          'address_id': deliveryAddressId,
          'items': items.map((e) => e.toJson()).toList(),
          'voucher_code': voucherCode,
        },
      );

      return QuoteModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      // Fallback quote generation
    }

    return QuoteModel.generateClientQuote(
      restaurantUuid: restaurantUuid,
      addressId: deliveryAddressId,
      items: items,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
    );
  }

  @override
  Future<QuoteModel> refreshQuote(String quoteId) async {
    try {
      final response = await _apiClient.post('/api/v1/checkout/quote/$quoteId/refresh/');
      return QuoteModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return QuoteModel(
        quoteId: quoteId,
        restaurantUuid: '',
        deliveryAddressId: '',
        subtotal: 0,
        deliveryFee: 50,
        vatAmount: 0,
        platformFee: 10,
        discountAmount: 0,
        totalAmount: 60,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    }
  }
}

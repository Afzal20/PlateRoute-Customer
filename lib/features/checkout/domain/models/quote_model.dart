import '../../../cart/domain/models/cart_item_model.dart';
import '../../../cart/domain/services/price_calculator.dart';

class QuoteModel {
  final String quoteId;
  final String restaurantUuid;
  final String deliveryAddressId;
  final double subtotal;
  final double deliveryFee;
  final double vatAmount;
  final double platformFee;
  final double discountAmount;
  final double totalAmount;
  final DateTime expiresAt;

  const QuoteModel({
    required this.quoteId,
    required this.restaurantUuid,
    required this.deliveryAddressId,
    required this.subtotal,
    required this.deliveryFee,
    required this.vatAmount,
    required this.platformFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.expiresAt,
  });

  Duration get remainingDuration {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isExpired => remainingDuration == Duration.zero;

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quoteId: (json['quote_id'] ?? json['id'] ?? '').toString(),
      restaurantUuid: (json['restaurant_uuid'] ?? json['restaurant'] ?? '').toString(),
      deliveryAddressId: (json['delivery_address_id'] ?? json['address_id'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 50.0).toDouble(),
      vatAmount: (json['vat_amount'] ?? json['tax'] ?? 0.0).toDouble(),
      platformFee: (json['platform_fee'] ?? PriceCalculator.standardPlatformFee).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? json['total'] ?? 0.0).toDouble(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'].toString())
          : DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quote_id': quoteId,
      'restaurant_uuid': restaurantUuid,
      'delivery_address_id': deliveryAddressId,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'vat_amount': vatAmount,
      'platform_fee': platformFee,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  static QuoteModel generateClientQuote({
    required String restaurantUuid,
    required String addressId,
    required List<CartItemModel> items,
    required double deliveryFee,
    double discountAmount = 0.0,
  }) {
    final breakdown = PriceCalculator.calculate(
      items: items,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
    );

    return QuoteModel(
      quoteId: 'quote_${DateTime.now().millisecondsSinceEpoch}',
      restaurantUuid: restaurantUuid,
      deliveryAddressId: addressId,
      subtotal: breakdown.subtotal,
      deliveryFee: breakdown.deliveryFee,
      vatAmount: breakdown.vatAmount,
      platformFee: breakdown.platformFee,
      discountAmount: breakdown.discountAmount,
      totalAmount: breakdown.totalAmount,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}

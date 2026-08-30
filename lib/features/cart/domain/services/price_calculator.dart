import '../models/cart_item_model.dart';

class CartPriceBreakdown {
  final double subtotal;
  final double deliveryFee;
  final double vatAmount;
  final double platformFee;
  final double discountAmount;
  final double totalAmount;

  const CartPriceBreakdown({
    required this.subtotal,
    required this.deliveryFee,
    required this.vatAmount,
    required this.platformFee,
    required this.discountAmount,
    required this.totalAmount,
  });
}

class PriceCalculator {
  static const double vatRate = 0.05; // 5% VAT
  static const double standardPlatformFee = 10.0; // ৳10 platform fee

  static CartPriceBreakdown calculate({
    required List<CartItemModel> items,
    required double deliveryFee,
    double discountAmount = 0.0,
    double platformFee = standardPlatformFee,
  }) {
    double subtotal = 0.0;
    for (final cartItem in items) {
      subtotal += cartItem.totalPrice;
    }

    final effectivePlatformFee = items.isEmpty ? 0.0 : platformFee;
    final effectiveDeliveryFee = items.isEmpty ? 0.0 : deliveryFee;
    final vatAmount = subtotal * vatRate;

    final grossTotal = subtotal + effectiveDeliveryFee + vatAmount + effectivePlatformFee;
    final totalAmount = (grossTotal - discountAmount).clamp(0.0, double.infinity);

    return CartPriceBreakdown(
      subtotal: subtotal,
      deliveryFee: effectiveDeliveryFee,
      vatAmount: vatAmount,
      platformFee: effectivePlatformFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
    );
  }
}

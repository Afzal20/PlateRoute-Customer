import '../services/price_calculator.dart';
import 'cart_item_model.dart';

class CartState {
  final String? restaurantUuid;
  final String? restaurantName;
  final String? restaurantLogo;
  final double deliveryFee;
  final List<CartItemModel> items;
  final String? voucherCode;
  final double discountAmount;
  final String? specialInstructions;

  const CartState({
    this.restaurantUuid,
    this.restaurantName,
    this.restaurantLogo,
    this.deliveryFee = 50.0,
    this.items = const [],
    this.voucherCode,
    this.discountAmount = 0.0,
    this.specialInstructions,
  });

  int get totalItemCount {
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int getQuantityForMenuItem(String itemUuid) {
    int total = 0;
    for (final item in items) {
      if (item.item.uuid == itemUuid || item.item.id == itemUuid) {
        total += item.quantity;
      }
    }
    return total;
  }

  CartPriceBreakdown get breakdown {
    return PriceCalculator.calculate(
      items: items,
      deliveryFee: deliveryFee,
      discountAmount: discountAmount,
    );
  }

  double get subtotal => breakdown.subtotal;
  double get vatAmount => breakdown.vatAmount;
  double get platformFee => breakdown.platformFee;
  double get totalAmount => breakdown.totalAmount;

  CartState copyWith({
    String? restaurantUuid,
    String? restaurantName,
    String? restaurantLogo,
    double? deliveryFee,
    List<CartItemModel>? items,
    String? voucherCode,
    double? discountAmount,
    String? specialInstructions,
    bool clearVoucher = false,
  }) {
    return CartState(
      restaurantUuid: restaurantUuid ?? this.restaurantUuid,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantLogo: restaurantLogo ?? this.restaurantLogo,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      items: items ?? this.items,
      voucherCode: clearVoucher ? null : (voucherCode ?? this.voucherCode),
      discountAmount: clearVoucher ? 0.0 : (discountAmount ?? this.discountAmount),
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

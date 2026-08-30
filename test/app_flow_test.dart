import 'package:customer/core/widgets/timeline_strip.dart';
import 'package:customer/features/cart/domain/models/voucher_model.dart';
import 'package:customer/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer/features/home/domain/models/restaurant_model.dart';
import 'package:customer/features/orders/domain/models/order_model.dart';
import 'package:customer/features/restaurant/domain/models/menu_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Customer App End-to-End State & Computation Flow', () {
    test('Cart state correctly computes subtotal, VAT, delivery fee, and grand total', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const restaurant = RestaurantModel(
        id: 'res_kfc',
        uuid: 'res_kfc',
        name: 'KFC Bangladesh',
        coverImageUrl: 'https://example.com/kfc.jpg',
        deliveryFee: 50.0,
        estimatedDeliveryMinutes: 30,
        rating: 4.6,
        reviewCount: 320,
      );

      const item1 = MenuItemModel(
        id: 'd1',
        uuid: 'd1',
        restaurantUuid: 'res_kfc',
        name: 'Zinger Burger',
        description: 'Crispy fried chicken fillet',
        price: 350.0,
        imageUrl: 'https://example.com/zinger.jpg',
      );

      const item2 = MenuItemModel(
        id: 'd2',
        uuid: 'd2',
        restaurantUuid: 'res_kfc',
        name: 'Large French Fries',
        description: 'Golden salted fries',
        price: 150.0,
        imageUrl: 'https://example.com/fries.jpg',
      );

      final notifier = container.read(cartProvider.notifier);

      // 1. Add 2 Zinger Burgers
      notifier.addItem(restaurant: restaurant, item: item1, quantity: 2);

      // 2. Add 1 Large Fries
      notifier.addItem(restaurant: restaurant, item: item2, quantity: 1);

      final state = container.read(cartProvider);

      expect(state.totalItemCount, 3);
      expect(state.subtotal, 850.0); // 350 * 2 + 150
      expect(state.vatAmount, 850.0 * 0.05); // 5% = 42.50
      expect(state.deliveryFee, 50.0);
      expect(state.platformFee, 10.0);
      expect(state.totalAmount, 850.0 + 42.50 + 50.0 + 10.0); // 952.50
    });

    test('Voucher percentage discount is correctly capped at maxDiscountAmount', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const restaurant = RestaurantModel(
        id: 'res_kfc',
        uuid: 'res_kfc',
        name: 'KFC Bangladesh',
        coverImageUrl: 'https://example.com/kfc.jpg',
        deliveryFee: 50.0,
        estimatedDeliveryMinutes: 30,
        rating: 4.6,
        reviewCount: 320,
      );

      const highPriceDish = MenuItemModel(
        id: 'd_feast',
        uuid: 'd_feast',
        restaurantUuid: 'res_kfc',
        name: 'Mega Family Feast',
        description: '12 pcs chicken bucket',
        price: 2000.0,
        imageUrl: 'https://example.com/bucket.jpg',
      );

      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(restaurant: restaurant, item: highPriceDish); // Subtotal = 2000.0

      // Voucher: 20% off up to max 150 BDT
      const voucher = VoucherModel(
        code: 'SAVE20',
        title: '20% Mega Savings',
        type: VoucherType.percentage,
        discountValue: 20.0,
        maxDiscountAmount: 150.0,
        minOrderAmount: 500.0,
      );

      final calculatedDiscount = voucher.calculateDiscount(subtotal: 2000.0, deliveryFee: 50.0);
      expect(calculatedDiscount, 150.0); // Capped at 150 instead of 400

      notifier.applyVoucher(voucher.code, calculatedDiscount);
      final state = container.read(cartProvider);

      expect(state.discountAmount, 150.0);
      expect(state.totalAmount, (2000.0 - 150.0) + (2000.0 * 0.05) + 50.0 + 10.0);
    });

    test('Order timeline stages progression and status values', () {
      expect(TimelineStage.placed.stepIndex, 0);
      expect(TimelineStage.accepted.stepIndex, 1);
      expect(TimelineStage.picked.stepIndex, 2);
      expect(TimelineStage.delivered.stepIndex, 3);
      expect(TimelineStage.cancelled.stepIndex, -1);

      expect(OrderStatus.placed.displayName, 'Order Placed');
      expect(OrderStatus.outForDelivery.displayName, 'Rider on the Way');
      expect(OrderStatus.delivered.displayName, 'Delivered');
    });
  });
}

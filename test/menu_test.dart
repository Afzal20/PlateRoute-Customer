import 'package:customer/features/cart/domain/models/cart_item_model.dart';
import 'package:customer/features/cart/domain/services/price_calculator.dart';
import 'package:customer/features/cart/presentation/providers/cart_provider.dart';
import 'package:customer/features/home/domain/models/restaurant_model.dart';
import 'package:customer/features/restaurant/domain/models/menu_category_model.dart';
import 'package:customer/features/restaurant/domain/models/menu_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Menu & Option Models Tests', () {
    test('MenuItemModel fromJson / toJson with option groups', () {
      final json = {
        'id': 'itm_1',
        'uuid': 'uuid_itm_1',
        'name': 'Smash Burger',
        'price': 320.0,
        'image_url': 'https://example.com/burger.jpg',
        'is_popular': true,
        'option_groups': [
          {
            'id': 'grp_1',
            'name': 'Cheese Level',
            'min_selections': 1,
            'max_selections': 1,
            'is_required': true,
            'options': [
              {'id': 'opt_1', 'name': 'Single Cheese', 'price_modifier': 30.0, 'is_default': true},
              {'id': 'opt_2', 'name': 'Double Cheese', 'price_modifier': 60.0},
            ],
          }
        ],
      };

      final item = MenuItemModel.fromJson(json, restaurantUuid: 'res_1');
      expect(item.name, 'Smash Burger');
      expect(item.price, 320.0);
      expect(item.hasCustomizations, true);
      expect(item.optionGroups.first.options.length, 2);
      expect(item.optionGroups.first.options.first.priceModifier, 30.0);
    });

    test('MenuCategoryModel fromJson', () {
      final json = {
        'id': 'cat_1',
        'name': 'Burgers',
        'items': [
          {
            'id': 'itm_1',
            'name': 'Chicken Burger',
            'price': 250.0,
            'image_url': 'https://example.com/c.jpg',
          }
        ],
      };

      final cat = MenuCategoryModel.fromJson(json);
      expect(cat.name, 'Burgers');
      expect(cat.items.length, 1);
      expect(cat.items.first.name, 'Chicken Burger');
    });
  });

  group('Cart & Price Calculator Tests', () {
    test('CartItem deterministic ID generation', () {
      final id1 = CartItemModel.generateCartItemId(
        'item_1',
        {
          'g1': [const OptionItemModel(id: 'opt_a', name: 'A'), const OptionItemModel(id: 'opt_b', name: 'B')]
        },
        'no onions',
      );
      final id2 = CartItemModel.generateCartItemId(
        'item_1',
        {
          'g1': [const OptionItemModel(id: 'opt_b', name: 'B'), const OptionItemModel(id: 'opt_a', name: 'A')]
        },
        'no onions',
      );

      expect(id1, id2);
    });

    test('PriceCalculator calculates subtotal, 5% VAT, platform fee, and discount', () {
      const item = MenuItemModel(
        id: '1',
        uuid: 'itm_1',
        name: 'Burger',
        price: 200.0,
        imageUrl: '',
        restaurantUuid: 'res_1',
      );

      final cartItems = [
        const CartItemModel(
          id: '1',
          item: item,
          quantity: 2, // 2 * 200 = 400 subtotal
          unitPrice: 200.0,
        ),
      ];

      final breakdown = PriceCalculator.calculate(
        items: cartItems,
        deliveryFee: 50.0,
        discountAmount: 30.0,
      );

      expect(breakdown.subtotal, 400.0);
      expect(breakdown.deliveryFee, 50.0);
      expect(breakdown.vatAmount, 20.0); // 5% of 400 = 20
      expect(breakdown.platformFee, 10.0); // 10
      // Gross: 400 + 50 + 20 + 10 = 480 - 30 discount = 450
      expect(breakdown.totalAmount, 450.0);
    });

    test('CartNotifier single-restaurant isolation and item management', () {
      final notifier = CartNotifier();
      const res1 = RestaurantModel(
        id: 'res_1',
        uuid: 'res_1',
        name: 'Chillox',
        coverImageUrl: '',
        deliveryFee: 40.0,
      );
      const res2 = RestaurantModel(
        id: 'res_2',
        uuid: 'res_2',
        name: 'Kacchi Bhai',
        coverImageUrl: '',
        deliveryFee: 50.0,
      );

      const item1 = MenuItemModel(
        id: 'itm_1',
        uuid: 'itm_1',
        name: 'Burger',
        price: 250.0,
        imageUrl: '',
        restaurantUuid: 'res_1',
      );

      const item2 = MenuItemModel(
        id: 'itm_2',
        uuid: 'itm_2',
        name: 'Kacchi',
        price: 300.0,
        imageUrl: '',
        restaurantUuid: 'res_2',
      );

      notifier.addItem(restaurant: res1, item: item1, quantity: 2);
      expect(notifier.state.restaurantUuid, 'res_1');
      expect(notifier.state.totalItemCount, 2);

      // Adding item from res2 should replace cart items
      notifier.addItem(restaurant: res2, item: item2, quantity: 1);
      expect(notifier.state.restaurantUuid, 'res_2');
      expect(notifier.state.totalItemCount, 1);
      expect(notifier.state.items.first.item.name, 'Kacchi');
    });
  });
}

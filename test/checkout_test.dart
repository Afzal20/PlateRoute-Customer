import 'package:customer/features/address/domain/models/delivery_address_model.dart';
import 'package:customer/features/cart/domain/models/voucher_model.dart';
import 'package:customer/features/checkout/domain/models/payment_method_model.dart';
import 'package:customer/features/checkout/domain/models/quote_model.dart';
import 'package:customer/features/orders/domain/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Voucher Model Tests', () {
    test('Percentage voucher with max discount cap', () {
      const voucher = VoucherModel(
        code: 'SAVE20',
        title: '20% Off',
        type: VoucherType.percentage,
        discountValue: 20.0,
        minOrderAmount: 200.0,
        maxDiscountAmount: 100.0,
      );

      // Subtotal 400 * 20% = 80 (< 100 max)
      expect(voucher.calculateDiscount(subtotal: 400.0, deliveryFee: 50.0), 80.0);

      // Subtotal 1000 * 20% = 200 (> 100 max -> capped at 100)
      expect(voucher.calculateDiscount(subtotal: 1000.0, deliveryFee: 50.0), 100.0);

      // Below min spend (150 < 200) -> 0 discount
      expect(voucher.calculateDiscount(subtotal: 150.0, deliveryFee: 50.0), 0.0);
    });

    test('Free delivery voucher discount', () {
      const voucher = VoucherModel(
        code: 'FREEDEL',
        title: 'Free Delivery',
        type: VoucherType.freeDelivery,
        discountValue: 100.0,
        minOrderAmount: 250.0,
      );

      expect(voucher.calculateDiscount(subtotal: 300.0, deliveryFee: 60.0), 60.0);
      expect(voucher.calculateDiscount(subtotal: 200.0, deliveryFee: 60.0), 0.0);
    });
  });

  group('Address & Quote Models Tests', () {
    test('DeliveryAddressModel formattedLabel and serialization', () {
      final json = {
        'id': 'addr_99',
        'label': 'work',
        'address_line': 'Concord Tower, Road 11',
        'area': 'Banani',
        'floor_apt': '8th Floor',
        'latitude': 23.7937,
        'longitude': 90.4066,
        'is_default': true,
      };

      final addr = DeliveryAddressModel.fromJson(json);
      expect(addr.label, AddressLabel.work);
      expect(addr.formattedLabel, 'Work');
      expect(addr.isDefault, true);

      final encoded = addr.toJson();
      expect(encoded['address_line'], 'Concord Tower, Road 11');
    });

    test('QuoteModel TTL and expiry detection', () {
      final activeQuote = QuoteModel(
        quoteId: 'q_1',
        restaurantUuid: 'res_1',
        deliveryAddressId: 'addr_1',
        subtotal: 300.0,
        deliveryFee: 40.0,
        vatAmount: 15.0,
        platformFee: 10.0,
        discountAmount: 0.0,
        totalAmount: 365.0,
        expiresAt: DateTime.now().add(const Duration(minutes: 4)),
      );

      expect(activeQuote.isExpired, false);
      expect(activeQuote.remainingDuration.inMinutes >= 3, true);

      final expiredQuote = QuoteModel(
        quoteId: 'q_2',
        restaurantUuid: 'res_1',
        deliveryAddressId: 'addr_1',
        subtotal: 300.0,
        deliveryFee: 40.0,
        vatAmount: 15.0,
        platformFee: 10.0,
        discountAmount: 0.0,
        totalAmount: 365.0,
        expiresAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );

      expect(expiredQuote.isExpired, true);
    });
  });

  group('Order Model Tests', () {
    test('OrderModel status stage index mapping', () {
      expect(OrderStatus.placed.stageIndex, 0);
      expect(OrderStatus.confirmed.stageIndex, 1);
      expect(OrderStatus.preparing.stageIndex, 1);
      expect(OrderStatus.outForDelivery.stageIndex, 2);
      expect(OrderStatus.delivered.stageIndex, 3);
      expect(OrderStatus.cancelled.stageIndex, -1);
    });

    test('OrderModel serialization with payment methods', () {
      final json = {
        'id': 'ord_123',
        'uuid': 'uuid_123',
        'restaurant_uuid': 'res_chillox',
        'restaurant_name': 'Chillox',
        'status': 'out_for_delivery',
        'subtotal': 500.0,
        'delivery_fee': 40.0,
        'vat_amount': 25.0,
        'platform_fee': 10.0,
        'discount_amount': 50.0,
        'total_amount': 525.0,
        'payment_method': 'bkash',
        'payment_status': 'paid',
        'created_at': DateTime.now().toIso8601String(),
        'items': [
          {
            'id': 'itm_1',
            'name': 'Beef Burger',
            'quantity': 1,
            'unit_price': 300.0,
            'total_price': 300.0,
          }
        ],
      };

      final order = OrderModel.fromJson(json);
      expect(order.restaurantName, 'Chillox');
      expect(order.status, OrderStatus.outForDelivery);
      expect(order.paymentMethod, PaymentMethodType.bkash);
      expect(order.isActive, true);
      expect(order.items.length, 1);
    });
  });
}

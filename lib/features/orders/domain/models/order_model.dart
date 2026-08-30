import '../../../address/domain/models/delivery_address_model.dart';
import '../../../checkout/domain/models/payment_method_model.dart';

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  static OrderStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'placed':
      case 'pending':
        return OrderStatus.placed;
      case 'confirmed':
      case 'accepted':
        return OrderStatus.confirmed;
      case 'preparing':
      case 'in_kitchen':
      case 'cooking':
        return OrderStatus.preparing;
      case 'out_for_delivery':
      case 'on_the_way':
      case 'picked_up':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'rejected':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing Food';
      case OrderStatus.outForDelivery:
        return 'Rider on the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stageIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class OrderItemModel {
  final String id;
  final String menuItemUuid;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String optionsSummary;
  final String specialInstructions;

  const OrderItemModel({
    required this.id,
    required this.menuItemUuid,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.optionsSummary = '',
    this.specialInstructions = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      menuItemUuid: (json['menu_item_uuid'] ?? json['menu_item'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['item_name'] ?? '').toString(),
      quantity: (json['quantity'] ?? 1) as int,
      unitPrice: (json['unit_price'] ?? json['price'] ?? 0.0).toDouble(),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      optionsSummary: (json['options_summary'] ?? json['customizations'] ?? '').toString(),
      specialInstructions: (json['special_instructions'] ?? json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_uuid': menuItemUuid,
      'name': name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'options_summary': optionsSummary,
      'special_instructions': specialInstructions,
    };
  }
}

class OrderModel {
  final String id;
  final String uuid;
  final String restaurantUuid;
  final String restaurantName;
  final String? restaurantLogo;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double vatAmount;
  final double platformFee;
  final double discountAmount;
  final double totalAmount;
  final DeliveryAddressModel deliveryAddress;
  final String? riderNotes;
  final PaymentMethodType paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime estimatedDeliveryAt;
  final double? riderLatitude;
  final double? riderLongitude;
  final String? riderName;
  final String? riderPhone;

  const OrderModel({
    required this.id,
    required this.uuid,
    required this.restaurantUuid,
    required this.restaurantName,
    this.restaurantLogo,
    required this.status,
    this.items = const [],
    required this.subtotal,
    required this.deliveryFee,
    required this.vatAmount,
    required this.platformFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.deliveryAddress,
    this.riderNotes,
    this.paymentMethod = PaymentMethodType.bkash,
    this.paymentStatus = 'paid',
    required this.createdAt,
    required this.estimatedDeliveryAt,
    this.riderLatitude,
    this.riderLongitude,
    this.riderName,
    this.riderPhone,
  });

  bool get isActive =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['order_items'];
    final List<OrderItemModel> itemList = [];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          itemList.add(OrderItemModel.fromJson(it));
        }
      }
    }

    final rawAddr = json['delivery_address'] ?? json['address'];
    final address = rawAddr is Map<String, dynamic>
        ? DeliveryAddressModel.fromJson(rawAddr)
        : const DeliveryAddressModel(
            id: 'addr',
            addressLine: 'Road 11, Block D',
            area: 'Banani, Dhaka',
            latitude: 23.7937,
            longitude: 90.4066,
          );

    return OrderModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      uuid: (json['uuid'] ?? json['id'] ?? '').toString(),
      restaurantUuid: (json['restaurant_uuid'] ?? json['restaurant'] ?? '').toString(),
      restaurantName: (json['restaurant_name'] ?? 'Restaurant').toString(),
      restaurantLogo: json['restaurant_logo'] as String?,
      status: OrderStatus.fromString((json['status'] ?? 'placed').toString()),
      items: itemList,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 50.0).toDouble(),
      vatAmount: (json['vat_amount'] ?? json['tax'] ?? 0.0).toDouble(),
      platformFee: (json['platform_fee'] ?? 10.0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0.0).toDouble(),
      totalAmount: (json['total_amount'] ?? json['total'] ?? 0.0).toDouble(),
      deliveryAddress: address,
      riderNotes: json['rider_notes'] as String?,
      paymentMethod: PaymentMethodType.values.firstWhere(
        (p) => p.apiValue == (json['payment_method'] ?? 'bkash'),
        orElse: () => PaymentMethodType.bkash,
      ),
      paymentStatus: (json['payment_status'] ?? 'paid').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      estimatedDeliveryAt: json['estimated_delivery_at'] != null
          ? DateTime.parse(json['estimated_delivery_at'].toString())
          : DateTime.now().add(const Duration(minutes: 30)),
      riderLatitude: json['rider_lat'] != null ? (json['rider_lat'] as num).toDouble() : null,
      riderLongitude: json['rider_lng'] != null ? (json['rider_lng'] as num).toDouble() : null,
      riderName: json['rider_name'] as String?,
      riderPhone: json['rider_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'restaurant_uuid': restaurantUuid,
      'restaurant_name': restaurantName,
      'restaurant_logo': restaurantLogo,
      'status': status.name,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'vat_amount': vatAmount,
      'platform_fee': platformFee,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
      'delivery_address': deliveryAddress.toJson(),
      'rider_notes': riderNotes,
      'payment_method': paymentMethod.apiValue,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery_at': estimatedDeliveryAt.toIso8601String(),
      'rider_lat': riderLatitude,
      'rider_lng': riderLongitude,
      'rider_name': riderName,
      'rider_phone': riderPhone,
    };
  }

  OrderModel copyWith({
    OrderStatus? status,
    double? riderLatitude,
    double? riderLongitude,
    String? riderName,
    String? riderPhone,
  }) {
    return OrderModel(
      id: id,
      uuid: uuid,
      restaurantUuid: restaurantUuid,
      restaurantName: restaurantName,
      restaurantLogo: restaurantLogo,
      status: status ?? this.status,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      vatAmount: vatAmount,
      platformFee: platformFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      riderNotes: riderNotes,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      estimatedDeliveryAt: estimatedDeliveryAt,
      riderLatitude: riderLatitude ?? this.riderLatitude,
      riderLongitude: riderLongitude ?? this.riderLongitude,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/domain/models/restaurant_model.dart';
import '../../../restaurant/domain/models/menu_item_model.dart';
import '../models/order_model.dart';

class ReorderService {
  static void reorderToCart({
    required WidgetRef ref,
    required OrderModel order,
  }) {
    final cartNotifier = ref.read(cartProvider.notifier);

    // Clear existing cart
    cartNotifier.clearCart();

    final restaurant = RestaurantModel(
      id: order.restaurantUuid,
      uuid: order.restaurantUuid,
      name: order.restaurantName,
      logoUrl: order.restaurantLogo,
      coverImageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80',
      rating: 4.8,
      reviewCount: 250,
      deliveryFee: order.deliveryFee,
      estimatedDeliveryMinutes: 30,
      isOpenNow: true,
    );

    // Reconstruct items from order
    for (final itm in order.items) {
      final menuItem = MenuItemModel(
        id: itm.menuItemUuid,
        uuid: itm.menuItemUuid,
        restaurantUuid: order.restaurantUuid,
        name: itm.name,
        description: '',
        price: itm.unitPrice,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80',
      );

      cartNotifier.addItem(
        item: menuItem,
        restaurant: restaurant,
        quantity: itm.quantity,
        specialInstructions: itm.specialInstructions,
      );
    }
  }
}

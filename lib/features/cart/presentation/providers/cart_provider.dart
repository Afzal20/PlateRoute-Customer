import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item_model.dart';
import '../../domain/models/cart_state.dart';
import '../../../restaurant/domain/models/menu_item_model.dart';
import '../../../home/domain/models/restaurant_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void setRestaurant(RestaurantModel restaurant) {
    if (state.restaurantUuid != restaurant.uuid && state.isNotEmpty) {
      // Cart already has items from another restaurant
      return;
    }

    state = state.copyWith(
      restaurantUuid: restaurant.uuid,
      restaurantName: restaurant.name,
      restaurantLogo: restaurant.logoUrl,
      deliveryFee: restaurant.deliveryFee,
    );
  }

  bool canAddItemFromRestaurant(String restaurantUuid) {
    return state.isEmpty || state.restaurantUuid == restaurantUuid;
  }

  void addItem({
    required RestaurantModel restaurant,
    required MenuItemModel item,
    int quantity = 1,
    Map<String, List<OptionItemModel>> selectedOptions = const {},
    String specialInstructions = '',
  }) {
    // If different restaurant, clear previous cart
    if (state.isNotEmpty && state.restaurantUuid != restaurant.uuid) {
      state = CartState(
        restaurantUuid: restaurant.uuid,
        restaurantName: restaurant.name,
        restaurantLogo: restaurant.logoUrl,
        deliveryFee: restaurant.deliveryFee,
      );
    } else if (state.isEmpty) {
      state = state.copyWith(
        restaurantUuid: restaurant.uuid,
        restaurantName: restaurant.name,
        restaurantLogo: restaurant.logoUrl,
        deliveryFee: restaurant.deliveryFee,
      );
    }

    double unitPrice = item.price;
    for (final list in selectedOptions.values) {
      for (final opt in list) {
        unitPrice += opt.priceModifier;
      }
    }

    final cartItemId = CartItemModel.generateCartItemId(
      item.uuid,
      selectedOptions,
      specialInstructions,
    );

    final existingIndex = state.items.indexWhere((ci) => ci.id == cartItemId);
    final updatedList = List<CartItemModel>.from(state.items);

    if (existingIndex >= 0) {
      final existing = updatedList[existingIndex];
      updatedList[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      updatedList.add(
        CartItemModel(
          id: cartItemId,
          item: item,
          quantity: quantity,
          selectedOptions: selectedOptions,
          specialInstructions: specialInstructions,
          unitPrice: unitPrice,
        ),
      );
    }

    state = state.copyWith(items: updatedList);
  }

  void incrementItem(String cartItemId) {
    final updatedList = List<CartItemModel>.from(state.items);
    final index = updatedList.indexWhere((ci) => ci.id == cartItemId);
    if (index >= 0) {
      final current = updatedList[index];
      updatedList[index] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updatedList);
    }
  }

  void decrementItem(String cartItemId) {
    final updatedList = List<CartItemModel>.from(state.items);
    final index = updatedList.indexWhere((ci) => ci.id == cartItemId);
    if (index >= 0) {
      final current = updatedList[index];
      if (current.quantity > 1) {
        updatedList[index] = current.copyWith(quantity: current.quantity - 1);
      } else {
        updatedList.removeAt(index);
      }

      if (updatedList.isEmpty) {
        state = const CartState();
      } else {
        state = state.copyWith(items: updatedList);
      }
    }
  }

  void incrementMenuItem(MenuItemModel item, RestaurantModel restaurant) {
    final firstMatching = state.items.firstWhere(
      (ci) => ci.item.uuid == item.uuid,
      orElse: () => CartItemModel(
        id: '',
        item: item,
        quantity: 0,
        unitPrice: item.price,
      ),
    );

    if (firstMatching.id.isNotEmpty) {
      incrementItem(firstMatching.id);
    } else {
      addItem(restaurant: restaurant, item: item);
    }
  }

  void decrementMenuItem(MenuItemModel item) {
    final firstMatching = state.items.firstWhere(
      (ci) => ci.item.uuid == item.uuid,
      orElse: () => CartItemModel(
        id: '',
        item: item,
        quantity: 0,
        unitPrice: item.price,
      ),
    );

    if (firstMatching.id.isNotEmpty) {
      decrementItem(firstMatching.id);
    }
  }

  void applyVoucher(String code, double discount) {
    state = state.copyWith(
      voucherCode: code,
      discountAmount: discount,
    );
  }

  void removeVoucher() {
    state = state.copyWith(clearVoucher: true);
  }

  void setSpecialInstructions(String notes) {
    state = state.copyWith(specialInstructions: notes);
  }

  void clearCart() {
    state = const CartState();
  }
}

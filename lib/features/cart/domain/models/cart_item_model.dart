import '../../../restaurant/domain/models/menu_item_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel item;
  final int quantity;
  final Map<String, List<OptionItemModel>> selectedOptions;
  final String specialInstructions;
  final double unitPrice;

  const CartItemModel({
    required this.id,
    required this.item,
    required this.quantity,
    this.selectedOptions = const {},
    this.specialInstructions = '',
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItemModel(
      id: id,
      item: item,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      unitPrice: unitPrice,
    );
  }

  static String generateCartItemId(
    String itemUuid,
    Map<String, List<OptionItemModel>> selectedOptions,
    String instructions,
  ) {
    final optionIds = <String>[];
    for (final list in selectedOptions.values) {
      for (final opt in list) {
        optionIds.add(opt.id);
      }
    }
    optionIds.sort();
    return '${itemUuid}_${optionIds.join('-')}_$instructions';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': item.uuid,
      'name': item.name,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'special_instructions': specialInstructions,
      'selected_options': selectedOptions.map(
        (key, list) => MapEntry(
          key,
          list.map((o) => {'id': o.id, 'name': o.name, 'price_modifier': o.priceModifier}).toList(),
        ),
      ),
    };
  }
}

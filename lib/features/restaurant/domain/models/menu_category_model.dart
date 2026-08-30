import 'menu_item_model.dart';

class MenuCategoryModel {
  final String id;
  final String name;
  final String? nameBn;
  final String? description;
  final List<MenuItemModel> items;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    this.nameBn,
    this.description,
    this.items = const [],
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json, {String restaurantUuid = ''}) {
    final rawItems = json['items'] ?? json['menu_items'];
    final List<MenuItemModel> itemList = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          itemList.add(MenuItemModel.fromJson(item, restaurantUuid: restaurantUuid));
        }
      }
    }

    return MenuCategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameBn: json['name_bn'] as String?,
      description: json['description'] as String?,
      items: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_bn': nameBn,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

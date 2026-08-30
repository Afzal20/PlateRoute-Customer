import '../../../../core/network/api_client.dart';
import '../../domain/models/menu_category_model.dart';
import '../../domain/models/menu_item_model.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuCategoryModel>> fetchMenuCategories(String restaurantUuid);
  Future<MenuItemModel> fetchMenuItem(String itemUuid, {String restaurantUuid = ''});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final ApiClient _apiClient;

  MenuRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<MenuCategoryModel>> fetchMenuCategories(String restaurantUuid) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/restaurants/$restaurantUuid/menu/',
      );

      if (response is List) {
        return response.map((e) => MenuCategoryModel.fromJson(e as Map<String, dynamic>, restaurantUuid: restaurantUuid)).toList();
      }
      if (response is Map && response.containsKey('categories') && response['categories'] is List) {
        return (response['categories'] as List)
            .map((e) => MenuCategoryModel.fromJson(e as Map<String, dynamic>, restaurantUuid: restaurantUuid))
            .toList();
      }
    } catch (_) {
      // Fallback mock menu
    }

    return _getFallbackMenu(restaurantUuid);
  }

  @override
  Future<MenuItemModel> fetchMenuItem(String itemUuid, {String restaurantUuid = ''}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/menu/items/$itemUuid/',
      );
      return MenuItemModel.fromJson(response as Map<String, dynamic>, restaurantUuid: restaurantUuid);
    } catch (_) {
      final categories = _getFallbackMenu(restaurantUuid);
      for (final cat in categories) {
        for (final item in cat.items) {
          if (item.uuid == itemUuid || item.id == itemUuid) {
            return item;
          }
        }
      }
      return categories.first.items.first;
    }
  }

  List<MenuCategoryModel> _getFallbackMenu(String restaurantUuid) {
    return [
      MenuCategoryModel(
        id: 'cat_popular',
        name: 'Popular & Signature',
        nameBn: 'জনপ্রিয় আইটেম',
        description: 'Most loved customer favorites',
        items: [
          MenuItemModel(
            id: 'item_1',
            uuid: 'item_1',
            name: 'Classic Beef Smashed Burger',
            nameBn: 'ক্লাসিক বিফ স্ম্যাশড বার্গার',
            description: 'Juicy 150g smashed beef patty, melted cheddar cheese, house relish in a toasted brioche bun.',
            price: 320.0,
            originalPrice: 380.0,
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
            isPopular: true,
            restaurantUuid: restaurantUuid,
            optionGroups: const [
              OptionGroupModel(
                id: 'grp_patty',
                name: 'Patty Choice',
                nameBn: 'প্যাটির সংখ্যা',
                minSelections: 1,
                maxSelections: 1,
                isRequired: true,
                options: [
                  OptionItemModel(id: 'opt_single', name: 'Single Patty (150g)', isDefault: true, priceModifier: 0),
                  OptionItemModel(id: 'opt_double', name: 'Double Patty (300g)', priceModifier: 160),
                ],
              ),
              OptionGroupModel(
                id: 'grp_cheese',
                name: 'Extra Cheese',
                nameBn: 'অতিরিক্ত চিজ',
                minSelections: 0,
                maxSelections: 2,
                options: [
                  OptionItemModel(id: 'opt_extra_cheddar', name: 'Aged Cheddar Slice', priceModifier: 40),
                  OptionItemModel(id: 'opt_extra_mozzarella', name: 'Melted Mozzarella', priceModifier: 50),
                ],
              ),
              OptionGroupModel(
                id: 'grp_spice',
                name: 'Spiciness Level',
                nameBn: 'ঝালের মাত্রা',
                minSelections: 1,
                maxSelections: 1,
                isRequired: true,
                options: [
                  OptionItemModel(id: 'opt_mild', name: 'Mild', priceModifier: 0),
                  OptionItemModel(id: 'opt_regular', name: 'Regular Spicy', isDefault: true, priceModifier: 0),
                  OptionItemModel(id: 'opt_extra_spicy', name: 'Naga Hot (Extra Spicy)', priceModifier: 20),
                ],
              ),
            ],
          ),
          MenuItemModel(
            id: 'item_2',
            uuid: 'item_2',
            name: 'Crispy Buffalo Chicken Burger',
            nameBn: 'ক্রিস্পি বাফেলো চিকেন বার্গার',
            description: 'Deep-fried golden chicken thigh tossed in tangy buffalo sauce with garlic mayo.',
            price: 290.0,
            imageUrl: 'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?w=500&q=80',
            isPopular: true,
            restaurantUuid: restaurantUuid,
            optionGroups: const [
              OptionGroupModel(
                id: 'grp_sauce',
                name: 'Sauce Choice',
                minSelections: 1,
                maxSelections: 1,
                isRequired: true,
                options: [
                  OptionItemModel(id: 'opt_buffalo', name: 'Buffalo Tangy', isDefault: true, priceModifier: 0),
                  OptionItemModel(id: 'opt_bbq', name: 'Smoky BBQ', priceModifier: 0),
                  OptionItemModel(id: 'opt_honey_mustard', name: 'Honey Mustard', priceModifier: 0),
                ],
              ),
            ],
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'cat_sides',
        name: 'Sides & Appetizers',
        nameBn: 'সাইডস ও অ্যাপেটাইজার',
        description: 'Crispy sides to complete your meal',
        items: [
          MenuItemModel(
            id: 'item_3',
            uuid: 'item_3',
            name: 'Cheesy Peri-Peri Loaded Fries',
            nameBn: 'পেরি-পেরি লোডেড ফ্রাইজ',
            description: 'Crispy skin-on french fries seasoned with peri peri salt and hot cheese sauce.',
            price: 180.0,
            imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&q=80',
            restaurantUuid: restaurantUuid,
          ),
          MenuItemModel(
            id: 'item_4',
            uuid: 'item_4',
            name: 'Crispy Garlic Parmesan Wings (6pcs)',
            nameBn: 'গার্লিক পারমেসান উইংস',
            description: 'Fried wings tossed in rich melted garlic butter and aged parmesan.',
            price: 260.0,
            imageUrl: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&q=80',
            restaurantUuid: restaurantUuid,
          ),
        ],
      ),
      MenuCategoryModel(
        id: 'cat_drinks',
        name: 'Drinks & Shakes',
        nameBn: 'ড্রিংকস ও শেক',
        items: [
          MenuItemModel(
            id: 'item_5',
            uuid: 'item_5',
            name: 'Chocolate Fudge Thick Shake',
            nameBn: 'চকলেট ফাজ শেক',
            description: 'Rich Belgian dark chocolate blended with whole milk and vanilla ice cream.',
            price: 190.0,
            imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&q=80',
            restaurantUuid: restaurantUuid,
          ),
          MenuItemModel(
            id: 'item_6',
            uuid: 'item_6',
            name: 'Fresh Mint Limeade',
            nameBn: 'পুদিনা লেমনেড',
            description: 'Chilled sparkling lemonade with crushed fresh mint leaves and black salt.',
            price: 110.0,
            imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&q=80',
            restaurantUuid: restaurantUuid,
          ),
        ],
      ),
    ];
  }
}

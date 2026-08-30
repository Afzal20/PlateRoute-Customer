import '../../domain/models/menu_category_model.dart';
import '../../domain/models/menu_item_model.dart';

abstract class MenuRepository {
  Future<List<MenuCategoryModel>> getMenuCategories(String restaurantUuid);
  Future<MenuItemModel> getMenuItem(String itemUuid, {String restaurantUuid = ''});
}

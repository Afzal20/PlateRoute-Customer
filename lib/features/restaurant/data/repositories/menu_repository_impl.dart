import '../../domain/models/menu_category_model.dart';
import '../../domain/models/menu_item_model.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MenuCategoryModel>> getMenuCategories(String restaurantUuid) async {
    return await remoteDataSource.fetchMenuCategories(restaurantUuid);
  }

  @override
  Future<MenuItemModel> getMenuItem(String itemUuid, {String restaurantUuid = ''}) async {
    return await remoteDataSource.fetchMenuItem(itemUuid, restaurantUuid: restaurantUuid);
  }
}

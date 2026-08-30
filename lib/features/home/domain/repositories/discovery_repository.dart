import '../../domain/models/banner_model.dart';
import '../../domain/models/cuisine_model.dart';
import '../../domain/models/restaurant_model.dart';

abstract class DiscoveryRepository {
  Future<List<BannerModel>> getBanners();
  Future<List<CuisineModel>> getCuisines();
  Future<List<RestaurantModel>> getRestaurants({
    double? latitude,
    double? longitude,
    String? cuisine,
    bool openNow = true,
    String? query,
    String? sortBy,
    int page = 1,
  });
  Future<List<RestaurantModel>> getFeaturedRestaurants();
  Future<RestaurantModel> getRestaurantDetails(String uuid);
}

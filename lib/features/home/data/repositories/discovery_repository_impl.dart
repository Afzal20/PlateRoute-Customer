import '../../domain/models/banner_model.dart';
import '../../domain/models/cuisine_model.dart';
import '../../domain/models/restaurant_model.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_remote_data_source.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BannerModel>> getBanners() async {
    return await remoteDataSource.fetchBanners();
  }

  @override
  Future<List<CuisineModel>> getCuisines() async {
    return await remoteDataSource.fetchCuisines();
  }

  @override
  Future<List<RestaurantModel>> getRestaurants({
    double? latitude,
    double? longitude,
    String? cuisine,
    bool openNow = true,
    String? query,
    String? sortBy,
    int page = 1,
  }) async {
    return await remoteDataSource.fetchRestaurants(
      latitude: latitude,
      longitude: longitude,
      cuisine: cuisine,
      openNow: openNow,
      query: query,
      sortBy: sortBy,
      page: page,
    );
  }

  @override
  Future<List<RestaurantModel>> getFeaturedRestaurants() async {
    final list = await remoteDataSource.fetchRestaurants(openNow: false);
    return list.where((r) => r.isFeatured).toList();
  }

  @override
  Future<RestaurantModel> getRestaurantDetails(String uuid) async {
    return await remoteDataSource.fetchRestaurantDetails(uuid);
  }
}

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/banner_model.dart';
import '../../domain/models/cuisine_model.dart';
import '../../domain/models/restaurant_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<BannerModel>> fetchBanners();
  Future<List<CuisineModel>> fetchCuisines();
  Future<List<RestaurantModel>> fetchRestaurants({
    double? latitude,
    double? longitude,
    String? cuisine,
    bool openNow = true,
    String? query,
    String? sortBy,
    int page = 1,
  });
  Future<RestaurantModel> fetchRestaurantDetails(String uuid);
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final ApiClient _apiClient;

  DiscoveryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _apiClient.get('/api/v1/discovery/banners/');
      if (response is List) {
        return response.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback mock banners
    }

    return _getFallbackBanners();
  }

  @override
  Future<List<CuisineModel>> fetchCuisines() async {
    try {
      final response = await _apiClient.get('/api/v1/discovery/cuisines/');
      if (response is List) {
        return response.map((e) => CuisineModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => CuisineModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback mock cuisines
    }

    return _getFallbackCuisines();
  }

  @override
  Future<List<RestaurantModel>> fetchRestaurants({
    double? latitude,
    double? longitude,
    String? cuisine,
    bool openNow = true,
    String? query,
    String? sortBy,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'lat': ?latitude,
        'lng': ?longitude,
        if (cuisine != null && cuisine.isNotEmpty) 'cuisine': cuisine,
        if (openNow) 'is_open': true,
        if (query != null && query.isNotEmpty) 'search': query,
        if (sortBy != null && sortBy.isNotEmpty) 'ordering': sortBy,
        'page': page,
      };

      final response = await _apiClient.get(
        ApiEndpoints.restaurants,
        queryParameters: queryParams,
      );

      if (response is List) {
        return response.map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map && response.containsKey('results') && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback mock restaurants
    }

    return _getFallbackRestaurants(query: query, cuisine: cuisine, openNow: openNow);
  }

  @override
  Future<RestaurantModel> fetchRestaurantDetails(String uuid) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.restaurantDetails(uuid));
      return RestaurantModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      final list = _getFallbackRestaurants();
      return list.firstWhere(
        (r) => r.uuid == uuid || r.id == uuid,
        orElse: () => list.first,
      );
    }
  }

  List<BannerModel> _getFallbackBanners() {
    return const [
      BannerModel(
        id: 'ban_1',
        title: '30% OFF on Weekend Biryani',
        subtitle: 'Use code BIRYANI30 at checkout',
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&q=80',
        targetRestaurantUuid: 'res_chillox',
      ),
      BannerModel(
        id: 'ban_2',
        title: 'Free Delivery from Chillox',
        subtitle: 'Burgers, shakes, and sides at your door',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
        targetRestaurantUuid: 'res_chillox',
      ),
      BannerModel(
        id: 'ban_3',
        title: 'Fresh Wood-Fired Pizza',
        subtitle: 'Authentic Italian recipes in under 30 mins',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
        targetRestaurantUuid: 'res_pizza_roma',
      ),
    ];
  }

  List<CuisineModel> _getFallbackCuisines() {
    return const [
      CuisineModel(
        id: 'c1',
        name: 'Biryani',
        nameBn: 'বিরিয়ানি',
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=200&q=80',
        slug: 'biryani',
      ),
      CuisineModel(
        id: 'c2',
        name: 'Burgers',
        nameBn: 'বার্গার',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&q=80',
        slug: 'burgers',
      ),
      CuisineModel(
        id: 'c3',
        name: 'Pizza',
        nameBn: 'পিজ্জা',
        imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80',
        slug: 'pizza',
      ),
      CuisineModel(
        id: 'c4',
        name: 'Kebab',
        nameBn: 'কাবাব',
        imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&q=80',
        slug: 'kebab',
      ),
      CuisineModel(
        id: 'c5',
        name: 'Desserts',
        nameBn: 'মিষ্টান্ন',
        imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=200&q=80',
        slug: 'desserts',
      ),
      CuisineModel(
        id: 'c6',
        name: 'Beverages',
        nameBn: 'পানীয়',
        imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=200&q=80',
        slug: 'beverages',
      ),
    ];
  }

  List<RestaurantModel> _getFallbackRestaurants({
    String? query,
    String? cuisine,
    bool openNow = false,
  }) {
    final list = [
      const RestaurantModel(
        id: 'res_chillox',
        uuid: 'res_chillox',
        name: 'Chillox - Banani',
        coverImageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80',
        rating: 4.8,
        reviewCount: 420,
        cuisines: ['Burgers', 'Fast Food', 'Beverages'],
        estimatedDeliveryMinutes: 25,
        deliveryFee: 40.0,
        minOrderAmount: 150.0,
        hasActiveDeal: true,
        dealDescription: '৳50 OFF on orders above ৳300',
        isOpenNow: true,
        isFeatured: true,
        about: 'Home of the juiciest gourmet smashed beef burgers and crispy wings in Dhaka.',
      ),
      const RestaurantModel(
        id: 'res_kacchi_bhai',
        uuid: 'res_kacchi_bhai',
        name: 'Kacchi Bhai - Dhanmondi',
        coverImageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80',
        rating: 4.7,
        reviewCount: 980,
        cuisines: ['Biryani', 'Traditional', 'Kebab'],
        estimatedDeliveryMinutes: 35,
        deliveryFee: 50.0,
        minOrderAmount: 200.0,
        hasActiveDeal: true,
        dealDescription: 'Free Borhani with Platter',
        isOpenNow: true,
        isFeatured: true,
        about: 'Authentic Basmati mutton kacchi cooked over slow wood fire.',
      ),
      const RestaurantModel(
        id: 'res_pizza_roma',
        uuid: 'res_pizza_roma',
        name: 'Pizza Roma - Gulshan',
        coverImageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&q=80',
        rating: 4.6,
        reviewCount: 310,
        cuisines: ['Pizza', 'Italian', 'Pasta'],
        estimatedDeliveryMinutes: 30,
        deliveryFee: 60.0,
        minOrderAmount: 250.0,
        hasActiveDeal: false,
        isOpenNow: true,
        isFeatured: false,
        about: 'Hand-tossed sourdough artisan pizzas baked in stone ovens.',
      ),
      const RestaurantModel(
        id: 'res_star_kabab',
        uuid: 'res_star_kabab',
        name: 'Star Kabab & Restaurant',
        coverImageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
        rating: 4.5,
        reviewCount: 1540,
        cuisines: ['Kebab', 'Traditional', 'Curry'],
        estimatedDeliveryMinutes: 20,
        deliveryFee: 30.0,
        minOrderAmount: 100.0,
        hasActiveDeal: false,
        isOpenNow: true,
        isFeatured: true,
        about: 'Iconic Dhaka heritage restaurant serving fresh reshmi kabab and mutton chaap.',
      ),
    ];

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      return list.where((r) => r.name.toLowerCase().contains(q) || r.cuisines.any((c) => c.toLowerCase().contains(q))).toList();
    }

    if (cuisine != null && cuisine.isNotEmpty) {
      final c = cuisine.toLowerCase();
      return list.where((r) => r.cuisines.any((item) => item.toLowerCase() == c)).toList();
    }

    return list;
  }
}

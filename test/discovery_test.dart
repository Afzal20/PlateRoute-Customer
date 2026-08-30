import 'package:customer/core/location/location_service.dart';
import 'package:customer/features/home/data/datasources/discovery_remote_data_source.dart';
import 'package:customer/features/home/data/repositories/discovery_repository_impl.dart';
import 'package:customer/features/home/domain/models/banner_model.dart';
import 'package:customer/features/home/domain/models/cuisine_model.dart';
import 'package:customer/features/home/domain/models/restaurant_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDiscoveryRemoteDataSource implements DiscoveryRemoteDataSource {
  @override
  Future<List<BannerModel>> fetchBanners() async {
    return [
      const BannerModel(
        id: 'ban_1',
        title: 'Special Biryani Offer',
        imageUrl: 'https://example.com/banner.jpg',
      ),
    ];
  }

  @override
  Future<List<CuisineModel>> fetchCuisines() async {
    return [
      const CuisineModel(
        id: 'c1',
        name: 'Biryani',
        imageUrl: 'https://example.com/biryani.jpg',
        slug: 'biryani',
      ),
      const CuisineModel(
        id: 'c2',
        name: 'Burgers',
        imageUrl: 'https://example.com/burgers.jpg',
        slug: 'burgers',
      ),
    ];
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
    final all = [
      const RestaurantModel(
        id: '1',
        uuid: 'res_1',
        name: 'Chillox Banani',
        coverImageUrl: 'https://example.com/chillox.jpg',
        rating: 4.8,
        reviewCount: 150,
        cuisines: ['Burgers'],
        isOpenNow: true,
        isFeatured: true,
      ),
      const RestaurantModel(
        id: '2',
        uuid: 'res_2',
        name: 'Kacchi Bhai',
        coverImageUrl: 'https://example.com/kacchi.jpg',
        rating: 4.6,
        reviewCount: 320,
        cuisines: ['Biryani'],
        isOpenNow: true,
        isFeatured: false,
      ),
    ];

    if (query != null && query.isNotEmpty) {
      return all.where((r) => r.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (cuisine != null && cuisine.isNotEmpty) {
      return all.where((r) => r.cuisines.contains(cuisine)).toList();
    }
    return all;
  }

  @override
  Future<RestaurantModel> fetchRestaurantDetails(String uuid) async {
    return const RestaurantModel(
      id: '1',
      uuid: 'res_1',
      name: 'Chillox Banani',
      coverImageUrl: 'https://example.com/chillox.jpg',
      rating: 4.8,
      cuisines: ['Burgers'],
    );
  }
}

void main() {
  group('Discovery Domain Models Tests', () {
    test('RestaurantModel fromJson / toJson', () {
      final json = {
        'id': 'res_123',
        'uuid': 'uuid_123',
        'name': 'Sultan\'s Dine',
        'cover_image_url': 'https://example.com/sultans.jpg',
        'rating': 4.9,
        'review_count': 500,
        'cuisines': ['Biryani', 'Traditional'],
        'min_order_amount': 250.0,
        'delivery_fee': 40.0,
        'estimated_delivery_minutes': 30,
        'has_active_deal': true,
        'deal_description': '20% OFF',
        'is_open_now': true,
        'is_featured': true,
      };

      final restaurant = RestaurantModel.fromJson(json);
      expect(restaurant.name, 'Sultan\'s Dine');
      expect(restaurant.rating, 4.9);
      expect(restaurant.cuisines.length, 2);
      expect(restaurant.hasActiveDeal, true);

      final encoded = restaurant.toJson();
      expect(encoded['name'], 'Sultan\'s Dine');
      expect(encoded['rating'], 4.9);
    });

    test('CuisineModel fromJson / toJson', () {
      final json = {
        'id': 'c_1',
        'name': 'Kebab',
        'name_bn': 'কাবাব',
        'image_url': 'https://example.com/kebab.jpg',
        'slug': 'kebab',
      };

      final cuisine = CuisineModel.fromJson(json);
      expect(cuisine.name, 'Kebab');
      expect(cuisine.nameBn, 'কাবাব');
      expect(cuisine.slug, 'kebab');
    });

    test('LocationModel default values', () {
      expect(LocationModel.defaultDhaka.areaName, 'Banani, Dhaka');
      expect(LocationModel.defaultDhaka.latitude, 23.8103);
    });
  });

  group('Discovery Repository Tests', () {
    late MockDiscoveryRemoteDataSource mockDataSource;
    late DiscoveryRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockDiscoveryRemoteDataSource();
      repository = DiscoveryRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('getBanners returns banners list', () async {
      final banners = await repository.getBanners();
      expect(banners.length, 1);
      expect(banners.first.title, 'Special Biryani Offer');
    });

    test('getCuisines returns cuisines list', () async {
      final cuisines = await repository.getCuisines();
      expect(cuisines.length, 2);
      expect(cuisines.first.slug, 'biryani');
    });

    test('getRestaurants with search query filters correctly', () async {
      final results = await repository.getRestaurants(query: 'Chillox');
      expect(results.length, 1);
      expect(results.first.name, 'Chillox Banani');
    });

    test('getFeaturedRestaurants returns only featured restaurants', () async {
      final featured = await repository.getFeaturedRestaurants();
      expect(featured.length, 1);
      expect(featured.first.isFeatured, true);
    });
  });
}

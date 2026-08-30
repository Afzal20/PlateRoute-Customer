import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/location/location_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/discovery_remote_data_source.dart';
import '../../data/repositories/discovery_repository_impl.dart';
import '../../domain/models/banner_model.dart';
import '../../domain/models/cuisine_model.dart';
import '../../domain/models/restaurant_model.dart';
import '../../domain/repositories/discovery_repository.dart';

final discoveryRemoteDataSourceProvider = Provider<DiscoveryRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DiscoveryRemoteDataSourceImpl(apiClient);
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  final remoteDataSource = ref.watch(discoveryRemoteDataSourceProvider);
  return DiscoveryRepositoryImpl(remoteDataSource: remoteDataSource);
});

class HomeFeedState {
  final bool isLoading;
  final List<BannerModel> banners;
  final List<CuisineModel> cuisines;
  final List<RestaurantModel> featuredRestaurants;
  final List<RestaurantModel> allRestaurants;
  final String? selectedCuisine;
  final bool openNowOnly;
  final String? errorMessage;

  const HomeFeedState({
    this.isLoading = true,
    this.banners = const [],
    this.cuisines = const [],
    this.featuredRestaurants = const [],
    this.allRestaurants = const [],
    this.selectedCuisine,
    this.openNowOnly = true, // Default ON per MOB-USR-02
    this.errorMessage,
  });

  HomeFeedState copyWith({
    bool? isLoading,
    List<BannerModel>? banners,
    List<CuisineModel>? cuisines,
    List<RestaurantModel>? featuredRestaurants,
    List<RestaurantModel>? allRestaurants,
    String? selectedCuisine,
    bool? openNowOnly,
    String? errorMessage,
    bool clearCuisine = false,
  }) {
    return HomeFeedState(
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      cuisines: cuisines ?? this.cuisines,
      featuredRestaurants: featuredRestaurants ?? this.featuredRestaurants,
      allRestaurants: allRestaurants ?? this.allRestaurants,
      selectedCuisine: clearCuisine ? null : (selectedCuisine ?? this.selectedCuisine),
      openNowOnly: openNowOnly ?? this.openNowOnly,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final homeFeedProvider = StateNotifierProvider<HomeFeedNotifier, HomeFeedState>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  final location = ref.watch(locationProvider);
  return HomeFeedNotifier(repository, location.latitude, location.longitude);
});

class HomeFeedNotifier extends StateNotifier<HomeFeedState> {
  final DiscoveryRepository _repository;
  final double _lat;
  final double _lng;

  HomeFeedNotifier(this._repository, this._lat, this._lng) : super(const HomeFeedState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bannersFuture = _repository.getBanners();
      final cuisinesFuture = _repository.getCuisines();
      final featuredFuture = _repository.getFeaturedRestaurants();
      final restaurantsFuture = _repository.getRestaurants(
        latitude: _lat,
        longitude: _lng,
        cuisine: state.selectedCuisine,
        openNow: state.openNowOnly,
      );

      final results = await Future.wait([
        bannersFuture,
        cuisinesFuture,
        featuredFuture,
        restaurantsFuture,
      ]);

      state = state.copyWith(
        isLoading: false,
        banners: results[0] as List<BannerModel>,
        cuisines: results[1] as List<CuisineModel>,
        featuredRestaurants: results[2] as List<RestaurantModel>,
        allRestaurants: results[3] as List<RestaurantModel>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void filterByCuisine(String? cuisineSlug) {
    if (cuisineSlug == null) {
      state = state.copyWith(clearCuisine: true);
    } else {
      state = state.copyWith(selectedCuisine: cuisineSlug);
    }
    _reloadRestaurants();
  }

  void toggleOpenNow(bool value) {
    state = state.copyWith(openNowOnly: value);
    _reloadRestaurants();
  }

  Future<void> _reloadRestaurants() async {
    try {
      final restaurants = await _repository.getRestaurants(
        latitude: _lat,
        longitude: _lng,
        cuisine: state.selectedCuisine,
        openNow: state.openNowOnly,
      );
      state = state.copyWith(allRestaurants: restaurants);
    } catch (_) {}
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/domain/models/restaurant_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/datasources/menu_remote_data_source.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/models/menu_category_model.dart';
import '../../domain/repositories/menu_repository.dart';

final menuRemoteDataSourceProvider = Provider<MenuRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MenuRemoteDataSourceImpl(apiClient);
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final remoteDataSource = ref.watch(menuRemoteDataSourceProvider);
  return MenuRepositoryImpl(remoteDataSource: remoteDataSource);
});

class RestaurantDetailState {
  final bool isLoading;
  final RestaurantModel? restaurant;
  final List<MenuCategoryModel> categories;
  final int selectedCategoryIndex;
  final String? errorMessage;

  const RestaurantDetailState({
    this.isLoading = true,
    this.restaurant,
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.errorMessage,
  });

  RestaurantDetailState copyWith({
    bool? isLoading,
    RestaurantModel? restaurant,
    List<MenuCategoryModel>? categories,
    int? selectedCategoryIndex,
    String? errorMessage,
  }) {
    return RestaurantDetailState(
      isLoading: isLoading ?? this.isLoading,
      restaurant: restaurant ?? this.restaurant,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final restaurantDetailProvider = StateNotifierProvider.autoDispose.family<
    RestaurantDetailNotifier, RestaurantDetailState, String>((ref, restaurantUuid) {
  final discoveryRepo = ref.watch(discoveryRepositoryProvider);
  final menuRepo = ref.watch(menuRepositoryProvider);
  return RestaurantDetailNotifier(discoveryRepo, menuRepo, restaurantUuid);
});

class RestaurantDetailNotifier extends StateNotifier<RestaurantDetailState> {
  final dynamic _discoveryRepo;
  final MenuRepository _menuRepo;
  final String _restaurantUuid;

  RestaurantDetailNotifier(this._discoveryRepo, this._menuRepo, this._restaurantUuid)
      : super(const RestaurantDetailState()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final restaurant = await _discoveryRepo.getRestaurantDetails(_restaurantUuid);
      final categories = await _menuRepo.getMenuCategories(_restaurantUuid);

      state = state.copyWith(
        isLoading: false,
        restaurant: restaurant as RestaurantModel,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSelectedCategoryIndex(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/location/location_provider.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../home/domain/models/restaurant_model.dart';
import '../../../home/presentation/providers/home_provider.dart';

class SearchState {
  final String query;
  final bool isLoading;
  final List<RestaurantModel> results;
  final List<String> recentSearches;
  final String? selectedCuisine;
  final String? sortBy;
  final bool openNowOnly;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.results = const [],
    this.recentSearches = const [],
    this.selectedCuisine,
    this.sortBy,
    this.openNowOnly = true,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<RestaurantModel>? results,
    List<String>? recentSearches,
    String? selectedCuisine,
    String? sortBy,
    bool? openNowOnly,
    String? errorMessage,
    bool clearCuisine = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      selectedCuisine: clearCuisine ? null : (selectedCuisine ?? this.selectedCuisine),
      sortBy: sortBy ?? this.sortBy,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  final location = ref.watch(locationProvider);
  return SearchNotifier(repository, location.latitude, location.longitude);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final dynamic _repository;
  final double _lat;
  final double _lng;
  PreferencesService? _prefs;
  Timer? _debounceTimer;

  SearchNotifier(this._repository, this._lat, this._lng) : super(const SearchState()) {
    _initHistory();
  }

  Future<void> _initHistory() async {
    _prefs = await PreferencesService.create();
    final history = _prefs?.getSearchHistory() ?? [];
    state = state.copyWith(recentSearches: history);
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      executeSearch(query);
    });
  }

  Future<void> executeSearch(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Persist search history
    await _prefs?.addSearchQuery(query.trim());
    final history = _prefs?.getSearchHistory() ?? [];

    try {
      final results = await _repository.getRestaurants(
        latitude: _lat,
        longitude: _lng,
        query: query.trim(),
        cuisine: state.selectedCuisine,
        openNow: state.openNowOnly,
        sortBy: state.sortBy,
      );

      state = state.copyWith(
        isLoading: false,
        results: results as List<RestaurantModel>,
        recentSearches: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void applyFilter({
    String? cuisine,
    String? sortBy,
    bool? openNowOnly,
  }) {
    state = state.copyWith(
      selectedCuisine: cuisine,
      sortBy: sortBy,
      openNowOnly: openNowOnly ?? state.openNowOnly,
    );

    if (state.query.isNotEmpty) {
      executeSearch(state.query);
    }
  }

  Future<void> clearRecentSearches() async {
    await _prefs?.clearSearchHistory();
    state = state.copyWith(recentSearches: []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

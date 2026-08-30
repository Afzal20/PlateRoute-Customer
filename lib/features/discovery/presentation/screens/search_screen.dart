import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../home/presentation/widgets/restaurant_tile.dart';
import '../providers/search_provider.dart';

import '../widgets/cuisine_pivot_grid.dart';
import '../widgets/search_filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final searchState = ref.read(searchProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedSheet,
      ),
      builder: (ctx) => SearchFilterSheet(
        initialCuisine: searchState.selectedCuisine,
        initialSortBy: searchState.sortBy,
        initialOpenNow: searchState.openNowOnly,
        onApply: ({cuisine, sortBy, openNow}) {
          ref.read(searchProvider.notifier).applyFilter(
                cuisine: cuisine,
                sortBy: sortBy,
                openNowOnly: openNow,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: AppTextField(
          hintText: l10n.searchPlaceholder,
          controller: _searchController,
          autofocus: true,
          showClearButton: true,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          onChanged: (val) {
            ref.read(searchProvider.notifier).onQueryChanged(val);
          },
          onSubmitted: (val) {
            ref.read(searchProvider.notifier).executeSearch(val);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: searchState.selectedCuisine != null || searchState.sortBy != null
                  ? primaryColor
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            tooltip: l10n.filters,
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, searchState, isDark, primaryColor, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchState state,
    bool isDark,
    Color primaryColor,
    dynamic l10n,
  ) {
    // 1. Loading state
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) => const SkeletonRestaurantCard(),
      );
    }

    // 2. Search Results
    if (state.query.trim().isNotEmpty) {
      if (state.results.isEmpty) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 56,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      l10n.noResultsFound,
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.noResultsSuggestion,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              CuisinePivotGrid(
                onPivotSelected: (cuisine) {
                  _searchController.text = cuisine;
                  ref.read(searchProvider.notifier).onQueryChanged(cuisine);
                  ref.read(searchProvider.notifier).executeSearch(cuisine);
                },
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: state.results.length,
        itemBuilder: (context, index) {
          final restaurant = state.results[index];
          return RestaurantTile(
            restaurant: restaurant,
            onTap: () {
              context.push(RoutePaths.restaurantDetailUri(restaurant.uuid));
            },
          );
        },
      );
    }

    // 3. Search History State
    if (state.recentSearches.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter, vertical: AppSpacing.m),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.searchHistory,
                style: AppTypography.titleSmall.copyWith(fontSize: 16),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchProvider.notifier).clearRecentSearches();
                },
                child: Text(
                  l10n.clearHistory,
                  style: AppTypography.caption.copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.recentSearches.map((query) {
              return ActionChip(
                avatar: Icon(
                  Icons.history,
                  size: 16,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                label: Text(
                  query,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  _searchController.text = query;
                  ref.read(searchProvider.notifier).onQueryChanged(query);
                  ref.read(searchProvider.notifier).executeSearch(query);
                },
              );
            }).toList(),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Type to search restaurants or dishes',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

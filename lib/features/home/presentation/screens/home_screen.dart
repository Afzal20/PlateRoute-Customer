import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/cuisine_rail.dart';
import '../widgets/location_header.dart';
import '../widgets/restaurant_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final homeState = ref.watch(homeFeedProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      appBar: AppBar(
        titleSpacing: AppSpacing.screenGutter,
        title: const LocationHeader(),
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            tooltip: l10n.availableVouchers,
            onPressed: () => context.push(RoutePaths.vouchers),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await ref.read(homeFeedProvider.notifier).loadHomeData();
        },
        child: CustomScrollView(
          slivers: [
            // Search Entry Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.xs,
                  AppSpacing.screenGutter,
                  AppSpacing.m,
                ),
                child: GestureDetector(
                  onTap: () => context.push(RoutePaths.search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: AppSpacing.roundedInput,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.searchPlaceholder,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (homeState.isLoading) ...[
              const SliverToBoxAdapter(child: SkeletonBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const SkeletonRestaurantCard(),
                  childCount: 4,
                ),
              ),
            ] else ...[
              // Promo Banners Carousel
              if (homeState.banners.isNotEmpty)
                SliverToBoxAdapter(
                  child: BannerCarousel(
                    banners: homeState.banners,
                    onBannerTap: (banner) {
                      if (banner.targetRestaurantUuid != null) {
                        context.push(RoutePaths.restaurantDetailUri(banner.targetRestaurantUuid!));
                      }
                    },
                  ),
                ),

              // Cuisines Rail
              if (homeState.cuisines.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenGutter,
                      AppSpacing.l,
                      AppSpacing.screenGutter,
                      AppSpacing.s,
                    ),
                    child: Text(
                      l10n.popularCuisines,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CuisineRail(
                    cuisines: homeState.cuisines,
                    selectedSlug: homeState.selectedCuisine,
                    onCuisineSelected: (slug) {
                      ref.read(homeFeedProvider.notifier).filterByCuisine(slug);
                    },
                  ),
                ),
              ],

              // Filter & Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenGutter,
                    AppSpacing.l,
                    AppSpacing.screenGutter,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.allRestaurants,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Open-Now Toggle Chip
                      FilterChip(
                        selected: homeState.openNowOnly,
                        showCheckmark: false,
                        avatar: Icon(
                          Icons.access_time_filled,
                          size: 14,
                          color: homeState.openNowOnly
                              ? AppColors.white
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        label: Text(
                          l10n.openNow,
                          style: AppTypography.caption.copyWith(
                            color: homeState.openNowOnly
                                ? AppColors.white
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        selectedColor: primaryColor,
                        side: BorderSide(
                          color: homeState.openNowOnly
                              ? primaryColor
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: 1.0,
                        ),
                        onSelected: (selected) {
                          ref.read(homeFeedProvider.notifier).toggleOpenNow(selected);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Restaurant List
              if (homeState.allRestaurants.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 48,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          l10n.noResultsFound,
                          style: AppTypography.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'No restaurants found matching current filter',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final restaurant = homeState.allRestaurants[index];
                      return RestaurantTile(
                        restaurant: restaurant,
                        onTap: () {
                          context.push(RoutePaths.restaurantDetailUri(restaurant.uuid));
                        },
                      );
                    },
                    childCount: homeState.allRestaurants.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Persistent cart bar spacing
              ),
            ],
          ],
        ),
      ),
    );
  }
}

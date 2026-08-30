import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/models/menu_item_model.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/category_chip_scroller.dart';
import '../widgets/item_customization_sheet.dart';
import '../widgets/item_tile.dart';
import '../widgets/trust_strip.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantUuid;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantUuid,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openCustomizationSheet(BuildContext context, MenuItemModel item) {
    final detailState = ref.read(restaurantDetailProvider(widget.restaurantUuid));
    final restaurant = detailState.restaurant;
    if (restaurant == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemCustomizationSheet(
        item: item,
        onAddToCart: (result) {
          ref.read(cartProvider.notifier).addItem(
                restaurant: restaurant,
                item: result.item,
                quantity: result.quantity,
                selectedOptions: result.selectedOptions,
                specialInstructions: result.specialInstructions,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final l10n = context.l10n;
    final detailState = ref.watch(restaurantDetailProvider(widget.restaurantUuid));
    final cartState = ref.watch(cartProvider);

    if (detailState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
        body: const Center(child: SkeletonBanner()),
      );
    }

    final restaurant = detailState.restaurant;
    if (restaurant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.noResultsFound, style: AppTypography.titleSmall),
        ),
      );
    }

    final hasCartItems = cartState.isNotEmpty && cartState.restaurantUuid == restaurant.uuid;

    return Scaffold(
      backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 1. Collapsible Hero Banner App Bar
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: restaurant.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.screenGutter,
                        bottom: AppSpacing.m,
                        right: AppSpacing.screenGutter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              restaurant.name,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (restaurant.cuisines.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                restaurant.cuisines.join(' • '),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Trust Metrics Strip
              SliverToBoxAdapter(
                child: TrustStrip(restaurant: restaurant),
              ),

              // 3. Category Chips Scroller
              if (detailState.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: CategoryChipScroller(
                    categories: detailState.categories,
                    selectedIndex: detailState.selectedCategoryIndex,
                    onCategorySelected: (index) {
                      ref
                          .read(restaurantDetailProvider(widget.restaurantUuid).notifier)
                          .setSelectedCategoryIndex(index);
                    },
                  ),
                ),

              // 4. Menu Items by Category
              ...detailState.categories.map((category) {
                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenGutter,
                          AppSpacing.l,
                          AppSpacing.screenGutter,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          category.name,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, itemIndex) {
                          final item = category.items[itemIndex];
                          final quantity = cartState.getQuantityForMenuItem(item.uuid);

                          return ItemTile(
                            item: item,
                            cartQuantity: quantity,
                            onAdd: () {
                              ref.read(cartProvider.notifier).addItem(
                                    restaurant: restaurant,
                                    item: item,
                                  );
                            },
                            onIncrement: () {
                              ref.read(cartProvider.notifier).incrementMenuItem(item, restaurant);
                            },
                            onDecrement: () {
                              ref.read(cartProvider.notifier).decrementMenuItem(item);
                            },
                            onCustomize: () => _openCustomizationSheet(context, item),
                          );
                        },
                        childCount: category.items.length,
                      ),
                    ),
                  ],
                );
              }),

              // Bottom safe padding for cart bar
              SliverToBoxAdapter(
                child: SizedBox(height: hasCartItems ? 90 : 30),
              ),
            ],
          ),

          // Persistent Floating Cart Bar
          if (hasCartItems)
            Positioned(
              left: AppSpacing.screenGutter,
              right: AppSpacing.screenGutter,
              bottom: AppSpacing.m,
              child: SafeArea(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => context.push(RoutePaths.cart),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${cartState.totalItemCount}',
                                style: AppTypography.bodySmallMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'View Cart',
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.defaultCurrencySymbol}${cartState.subtotal.toInt()}',
                              style: AppTypography.bodySmallMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

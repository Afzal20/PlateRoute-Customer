import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/cuisine_model.dart';

class CuisineRail extends StatelessWidget {
  final List<CuisineModel> cuisines;
  final String? selectedSlug;
  final ValueChanged<String?> onCuisineSelected;

  const CuisineRail({
    super.key,
    required this.cuisines,
    this.selectedSlug,
    required this.onCuisineSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (cuisines.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final locale = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
        itemCount: cuisines.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (context, index) {
          final cuisine = cuisines[index];
          final isSelected = selectedSlug == cuisine.slug;
          final displayName = (locale == 'bn' && cuisine.nameBn != null)
              ? cuisine.nameBn!
              : cuisine.name;

          return GestureDetector(
            onTap: () {
              if (isSelected) {
                onCuisineSelected(null); // Deselect
              } else {
                onCuisineSelected(cuisine.slug);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: cuisine.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                        Icons.fastfood_outlined,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 68,
                  child: Text(
                    displayName,
                    style: AppTypography.caption.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

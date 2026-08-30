import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/menu_category_model.dart';

class CategoryChipScroller extends StatelessWidget {
  final List<MenuCategoryModel> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const CategoryChipScroller({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == selectedIndex;
          final displayName = (locale == 'bn' && cat.nameBn != null) ? cat.nameBn! : cat.name;

          return ChoiceChip(
            label: Text(displayName),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: primaryColor,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            labelStyle: AppTypography.caption.copyWith(
              color: isSelected
                  ? AppColors.white
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: BorderSide(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) => onCategorySelected(index),
          );
        },
      ),
    );
  }
}

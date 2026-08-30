import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class SearchFilterSheet extends StatefulWidget {
  final String? initialCuisine;
  final String? initialSortBy;
  final bool initialOpenNow;
  final Function({String? cuisine, String? sortBy, bool? openNow}) onApply;

  const SearchFilterSheet({
    super.key,
    this.initialCuisine,
    this.initialSortBy,
    required this.initialOpenNow,
    required this.onApply,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String? _selectedCuisine;
  late String? _selectedSortBy;
  late bool _openNow;

  final List<String> _sortOptions = [
    'top_rated',
    'fastest_delivery',
    'lowest_fee',
  ];

  final Map<String, String> _sortLabels = {
    'top_rated': 'Top Rated',
    'fastest_delivery': 'Fastest Delivery',
    'lowest_fee': 'Lowest Delivery Fee',
  };

  final List<String> _cuisines = [
    'Biryani',
    'Burgers',
    'Pizza',
    'Kebab',
    'Desserts',
    'Beverages',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCuisine = widget.initialCuisine;
    _selectedSortBy = widget.initialSortBy;
    _openNow = widget.initialOpenNow;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter,
          vertical: AppSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: AppSpacing.sheetGrabHandleWidth,
                height: AppSpacing.sheetGrabHandleHeight,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Filters',
                  style: AppTypography.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCuisine = null;
                      _selectedSortBy = null;
                      _openNow = true;
                    });
                  },
                  child: Text(
                    'Reset',
                    style: AppTypography.caption.copyWith(color: primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),

            // Open Now toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Open Now Only',
                style: AppTypography.bodySmallMedium,
              ),
              subtitle: Text(
                'Show only restaurants accepting orders right now',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              value: _openNow,
              activeThumbColor: primaryColor,
              onChanged: (val) => setState(() => _openNow = val),
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.s),

            // Sort By
            Text(
              'Sort By',
              style: AppTypography.overline.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sortOptions.map((opt) {
                final isSelected = _selectedSortBy == opt;
                return FilterChip(
                  label: Text(_sortLabels[opt] ?? opt),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: primaryColor,
                  labelStyle: AppTypography.caption.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.0,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedSortBy = selected ? opt : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.m),

            // Cuisines
            Text(
              'Cuisine',
              style: AppTypography.overline.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cuisines.map((cuisine) {
                final isSelected = _selectedCuisine?.toLowerCase() == cuisine.toLowerCase();
                return FilterChip(
                  label: Text(cuisine),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: primaryColor,
                  labelStyle: AppTypography.caption.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.0,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCuisine = selected ? cuisine : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Apply Button
            AppButton.prominent(
              label: 'Apply Filters',
              variant: AppButtonVariant.primary,
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(
                  cuisine: _selectedCuisine,
                  sortBy: _selectedSortBy,
                  openNow: _openNow,
                );
              },
            ),
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

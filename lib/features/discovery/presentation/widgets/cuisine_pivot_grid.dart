import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CuisinePivotGrid extends StatelessWidget {
  final ValueChanged<String> onPivotSelected;

  const CuisinePivotGrid({
    super.key,
    required this.onPivotSelected,
  });

  static const List<(String, String, IconData)> _pivots = [
    ('Biryani', 'Kacchi, Tehari & Rice', Icons.rice_bowl_rounded),
    ('Burgers', 'Beef, Chicken & Smashed', Icons.lunch_dining_rounded),
    ('Pizza', 'Wood-fired & Cheese burst', Icons.local_pizza_rounded),
    ('Kebab', 'Grills, Chaap & Naan', Icons.outdoor_grill_rounded),
    ('Desserts', 'Sweets, Waffles & Cakes', Icons.cake_rounded),
    ('Beverages', 'Shakes, Coffee & Juices', Icons.local_cafe_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          child: Text(
            'Explore other popular cuisines instead',
            style: AppTypography.bodySmallMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: _pivots.length,
          itemBuilder: (context, index) {
            final (name, subtitle, icon) = _pivots[index];

            return InkWell(
              borderRadius: AppSpacing.roundedCard,
              onTap: () => onPivotSelected(name),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: AppTypography.bodySmallMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

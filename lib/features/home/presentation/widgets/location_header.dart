import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/location/location_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LocationHeader extends ConsumerWidget {
  const LocationHeader({super.key});

  void _showAreaPickerSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final currentLocation = ref.read(locationProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedSheet,
      ),
      builder: (ctx) {
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
                Text(
                  l10n.selectAddress,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.m),

                // GPS Current Location option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.my_location, color: primaryColor, size: 20),
                  ),
                  title: Text(
                    l10n.currentLocation,
                    style: AppTypography.bodySmallMedium,
                  ),
                  subtitle: Text(
                    'Use GPS to find nearby restaurants',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(locationProvider.notifier).requestDeviceLocation();
                  },
                ),
                const Divider(),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Popular Delivery Areas',
                  style: AppTypography.overline.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                ...LocationNotifier.popularAreasInDhaka.map((loc) {
                  final isSelected = currentLocation.areaName == loc.areaName;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      size: 20,
                    ),
                    title: Text(
                      loc.areaName,
                      style: AppTypography.bodySmallMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    subtitle: Text(
                      loc.formattedAddress,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: primaryColor, size: 18)
                        : null,
                    onTap: () {
                      ref.read(locationProvider.notifier).setLocation(
                            latitude: loc.latitude,
                            longitude: loc.longitude,
                            areaName: loc.areaName,
                            formattedAddress: loc.formattedAddress,
                          );
                      Navigator.pop(ctx);
                    },
                  );
                }),
                const SizedBox(height: AppSpacing.s),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return InkWell(
      onTap: () => _showAreaPickerSheet(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.deliveringTo,
                    style: AppTypography.overline.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          location.areaName,
                          style: AppTypography.bodySmallMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

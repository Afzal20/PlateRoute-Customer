import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LanguageSwitcherSheet extends ConsumerWidget {
  const LanguageSwitcherSheet({super.key});

  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.roundedSheet),
      builder: (ctx) => const LanguageSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final currentLocale = ref.watch(localeNotifierProvider);

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
              'Select App Language / ভাষা নির্বাচন করুন',
              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your preferred language for restaurant menus and live notifications.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // English (US) Option
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: 'English (US)',
              subtitle: 'Default international language',
              code: 'en',
              isSelected: currentLocale.languageCode == 'en',
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 8),

            // Bengali (বাংলা) Option
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: 'বাংলা (Bengali)',
              subtitle: 'স্থানীয় বাংলা ভাষা ইন্টারফেস',
              code: 'bn',
              isSelected: currentLocale.languageCode == 'bn',
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.canvasDark : AppColors.canvasLight,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedCard),
        title: Text(
          title,
          style: AppTypography.bodySmallMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          size: 20,
        ),
        onTap: () {
          ref.read(localeNotifierProvider.notifier).setLocale(code);
          Navigator.pop(context);
        },
      ),
    );
  }
}

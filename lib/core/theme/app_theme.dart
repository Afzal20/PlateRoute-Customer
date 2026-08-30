import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.canvasLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.white,
        secondary: AppColors.accentLight,
        onSecondary: AppColors.white,
        error: AppColors.dangerLight,
        onError: AppColors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
      ),
      fontFamily: AppTypography.fontEnglish,
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        titleLarge: AppTypography.titleLarge,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelSmall: AppTypography.caption,
        labelLarge: AppTypography.overline,
      ).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedCard,
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.dangerLight, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.dangerLight, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedSheet,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryButtonDark,
      scaffoldBackgroundColor: AppColors.canvasDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.white,
        secondary: AppColors.accentDark,
        onSecondary: AppColors.white,
        error: AppColors.dangerDark,
        onError: AppColors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      fontFamily: AppTypography.fontEnglish,
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        titleLarge: AppTypography.titleLarge,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelSmall: AppTypography.caption,
        labelLarge: AppTypography.overline,
      ).apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedCard,
          side: const BorderSide(color: AppColors.borderDark, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.dangerDark, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: const BorderSide(color: AppColors.dangerDark, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedSheet,
        ),
      ),
    );
  }
}

/// Application theme configuration.
///
/// This file defines the complete theme configuration for the DOER app,
/// including Material 3 color schemes, component themes, and typography.
///
/// ## Design Philosophy
/// - Professional, sharp, authority-driven aesthetic
/// - Clean and minimal with purposeful use of color
/// - Consistent spacing and typography
/// - Accessible color contrast ratios
///
/// ## Theme Components
/// - **Color Scheme**: Navy blue primary with bright blue accents
/// - **Typography**: Inter font family with hierarchical sizing
/// - **Buttons**: Consistent padding and border radius
/// - **Input Fields**: Subtle borders with clear focus states
/// - **Cards**: Minimal elevation with medium border radius
/// - **Navigation**: Clean bottom nav and tab bar styling
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// App theme configuration - Professional, Sharp, Authority-driven.
///
/// Provides static getters for light and dark theme configurations.
/// All themes use Material 3 design principles with custom overrides.
///
/// ## Light Theme
/// Primary use case. Uses navy blue primary colors with white surfaces.
///
/// ## Dark Theme
/// Alternative for low-light conditions. Uses inverted colors with
/// dark navy surfaces.
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  /// Light theme configuration.
  ///
  /// The default theme for the app. Features:
  /// - Material 3 design system
  /// - Navy blue primary color palette
  /// - White/light gray surfaces
  /// - Inter font family
  /// - Consistent border radii from [AppSpacing]
  ///
  /// ## Usage
  /// ```dart
  /// MaterialApp(
  ///   theme: AppTheme.lightTheme,
  /// )
  /// ```
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            side: const BorderSide(color: AppColors.primary),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: const OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          margin: EdgeInsets.zero,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.accent,
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      );

  /// Dark theme configuration.
  ///
  /// Alternative theme for low-light conditions. Features:
  /// - Material 3 design system
  /// - Bright blue as primary (for visibility)
  /// - Dark navy surfaces
  /// - Inter font family
  ///
  /// ## Usage
  /// ```dart
  /// MaterialApp(
  ///   darkTheme: AppTheme.darkTheme,
  ///   themeMode: ThemeMode.dark,
  /// )
  /// ```
  ///
  /// ## Note
  /// Currently a minimal implementation. Additional component themes
  /// will be added as dark mode is fully implemented.
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.accent,
          secondary: AppColors.primary,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
        ),
      );
}

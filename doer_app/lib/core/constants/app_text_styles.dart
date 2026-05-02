/// Application typography styles.
///
/// This file defines the complete text style system for the DOER app,
/// using the Inter font family with a comprehensive type scale.
///
/// ## Type Scale
/// The typography follows a hierarchical system:
/// - **Display**: Large hero text (32px, 28px, 24px)
/// - **Heading**: Section headers (22px, 20px, 18px)
/// - **Title**: Subsection titles (16px, 14px, 12px)
/// - **Body**: Main content text (16px, 14px, 12px)
/// - **Label**: UI labels and captions (14px, 12px, 10px)
/// - **Caption**: Metadata and hints (12px)
/// - **Button**: Button text (14px)
/// - **Link**: Hyperlink text (14px)
///
/// ## Font Weights
/// - Bold (700): Display and headings
/// - Semibold (600): Titles and buttons
/// - Medium (500): Labels and links
/// - Normal (400): Body text and captions
///
/// ## Line Heights
/// - 1.2: Display text (tight)
/// - 1.3-1.4: Headings (comfortable)
/// - 1.5: Body text (readable)
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App text styles following Inter font family.
///
/// Provides a complete typography system with semantic naming
/// and consistent visual hierarchy.
///
/// ## Usage
/// ```dart
/// Text(
///   'Welcome',
///   style: AppTextStyles.headingLarge,
/// )
///
/// // With color override
/// Text(
///   'Status',
///   style: AppTextStyles.labelMedium.copyWith(
///     color: AppColors.success,
///   ),
/// )
/// ```
class AppTextStyles {
  /// Private constructor to prevent instantiation.
  AppTextStyles._();

  /// Font family used throughout the app.
  static const String _fontFamily = 'Inter';

  // ---------------------------------------------------------------------------
  // Display Styles - Large hero text
  // ---------------------------------------------------------------------------

  /// Large display text style (32px, bold).
  ///
  /// Use for main screen titles and hero text.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Medium display text style (28px, bold).
  ///
  /// Use for secondary hero text and prominent titles.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  /// Small display text style (24px, bold).
  ///
  /// Use for section headers in marketing content.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Heading Styles - Section headers
  // ---------------------------------------------------------------------------

  /// Large heading text style (22px, semibold).
  ///
  /// Use for main section headers.
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Medium heading text style (20px, semibold).
  ///
  /// Use for subsection headers.
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Small heading text style (18px, semibold).
  ///
  /// Use for card headers and list group titles.
  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Title Styles - Subsection titles
  // ---------------------------------------------------------------------------

  /// Large title text style (16px, semibold).
  ///
  /// Use for list item titles and form section headers.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Medium title text style (14px, semibold).
  ///
  /// Use for compact list titles and dialog headers.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Small title text style (12px, semibold).
  ///
  /// Use for dense UI titles and badge text.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Body Styles - Main content text
  // ---------------------------------------------------------------------------

  /// Large body text style (16px, normal).
  ///
  /// Use for primary content paragraphs.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Medium body text style (14px, normal).
  ///
  /// Standard body text for most content.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Small body text style (12px, normal).
  ///
  /// Use for supporting content and descriptions.
  /// Uses secondary text color for visual hierarchy.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Label Styles - UI labels and form fields
  // ---------------------------------------------------------------------------

  /// Large label text style (14px, medium).
  ///
  /// Use for form labels and prominent UI text.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Medium label text style (12px, medium).
  ///
  /// Standard label for chips, tags, and compact UI.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// Small label text style (10px, medium).
  ///
  /// Use for badges, status indicators, and dense UI.
  /// Uses secondary text color.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Special Styles
  // ---------------------------------------------------------------------------

  /// Caption text style (12px, normal).
  ///
  /// Use for timestamps, metadata, and helper text.
  /// Uses tertiary text color for minimal emphasis.
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  /// Button text style (14px, semibold).
  ///
  /// Use for button labels. Color should be set based on button type.
  /// Includes letter spacing for improved readability.
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Link text style (14px, medium, underlined).
  ///
  /// Use for clickable text links and navigation.
  /// Uses accent color with underline decoration.
  static const TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    decoration: TextDecoration.underline,
  );
}

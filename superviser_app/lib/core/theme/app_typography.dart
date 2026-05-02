/// Typography styles for the Superviser App following the AdminX design system.
///
/// This file defines all text styles used throughout the application,
/// following Material Design 3 typography guidelines with custom adjustments
/// for the AdminX brand.
///
/// ## Typography Scale
///
/// The typography scale follows Material Design 3 with five categories:
/// - **Display**: Large, impactful text for hero sections
/// - **Headline**: Section headers and emphasis
/// - **Title**: Card titles, list headers
/// - **Body**: Primary content text
/// - **Label**: Buttons, tabs, captions
///
/// ## Font Configuration
///
/// The app uses system fonts by default. To use a custom font (e.g., Inter):
/// 1. Add font files to `assets/fonts/`
/// 2. Register fonts in `pubspec.yaml` under `flutter.fonts`
/// 3. Change [fontFamily] to your font name
///
/// ## Usage
///
/// ```dart
/// // Direct usage
/// Text('Hello', style: AppTypography.headlineMedium);
///
/// // Through theme (preferred)
/// Text('Hello', style: Theme.of(context).textTheme.headlineMedium);
/// ```
///
/// See also:
/// - [AppTheme] for complete theme configurations
/// - [AppColors] for color palette
library;

import 'package:flutter/material.dart';

/// Defines typography styles following the AdminX design system.
///
/// This abstract class serves as a namespace for [TextStyle] constants.
/// All styles are designed to work with both light and dark themes.
///
/// ## Style Categories
///
/// | Category | Sizes | Use Case |
/// |----------|-------|----------|
/// | Display | Large, Medium, Small | Hero text, splash screens |
/// | Headline | Large, Medium, Small | Section headers |
/// | Title | Large, Medium, Small | Card titles, dialogs |
/// | Body | Large, Medium, Small | Content text |
/// | Label | Large, Medium, Small | Buttons, tabs, chips |
/// | Button | Large, Medium, Small | Button text specifically |
/// | Caption | - | Small descriptive text |
/// | Overline | - | Category labels, tags |
///
/// ## Example
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     Text('Welcome', style: AppTypography.headlineLarge),
///     const SizedBox(height: 8),
///     Text('Sign in to continue', style: AppTypography.bodyMedium),
///     const SizedBox(height: 24),
///     ElevatedButton(
///       child: Text('Sign In', style: AppTypography.buttonMedium),
///       onPressed: () {},
///     ),
///   ],
/// );
/// ```
abstract class AppTypography {
  /// The font family used throughout the app.
  ///
  /// Set to `null` for system default font, or specify a custom font name
  /// (e.g., 'Inter') after adding the font to your project.
  ///
  /// ## Using Custom Fonts
  ///
  /// 1. Add font files to `assets/fonts/`
  /// 2. Update `pubspec.yaml`:
  ///    ```yaml
  ///    flutter:
  ///      fonts:
  ///        - family: Inter
  ///          fonts:
  ///            - asset: assets/fonts/Inter-Regular.ttf
  ///            - asset: assets/fonts/Inter-Medium.ttf
  ///              weight: 500
  ///            - asset: assets/fonts/Inter-SemiBold.ttf
  ///              weight: 600
  ///            - asset: assets/fonts/Inter-Bold.ttf
  ///              weight: 700
  ///    ```
  /// 3. Change this to: `static const String fontFamily = 'Inter';`
  static const String? fontFamily = null; // Uses system default

  // ============ Display Styles ============

  /// Display Large - Largest text style for hero content.
  ///
  /// - Font size: 57px
  /// - Weight: Regular (400)
  /// - Letter spacing: -0.25
  /// - Line height: 1.12
  ///
  /// Use for: Splash screens, marketing pages, large numbers.
  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium - Large display text.
  ///
  /// - Font size: 45px
  /// - Weight: Regular (400)
  /// - Line height: 1.16
  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small - Smaller display text.
  ///
  /// - Font size: 36px
  /// - Weight: Regular (400)
  /// - Line height: 1.22
  static const displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============ Headline Styles ============

  /// Headline Large - Major section headers.
  ///
  /// - Font size: 32px
  /// - Weight: Bold (700)
  /// - Letter spacing: -0.5
  /// - Line height: 1.25
  ///
  /// Use for: Page titles, major section headers.
  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
  );

  /// Headline Medium - Section headers.
  ///
  /// - Font size: 28px
  /// - Weight: Semi-bold (600)
  /// - Line height: 1.29
  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  /// Headline Small - Subsection headers.
  ///
  /// - Font size: 24px
  /// - Weight: Semi-bold (600)
  /// - Line height: 1.33
  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============ Title Styles ============

  /// Title Large - Card titles, dialog titles.
  ///
  /// - Font size: 22px
  /// - Weight: Semi-bold (600)
  /// - Line height: 1.27
  ///
  /// Use for: Card headers, dialog titles, prominent list items.
  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium - List item titles.
  ///
  /// - Font size: 16px
  /// - Weight: Semi-bold (600)
  /// - Letter spacing: 0.15
  /// - Line height: 1.5
  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small - Small titles, emphasized text.
  ///
  /// - Font size: 14px
  /// - Weight: Semi-bold (600)
  /// - Letter spacing: 0.1
  /// - Line height: 1.43
  static const titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============ Body Styles ============

  /// Body Large - Primary body text.
  ///
  /// - Font size: 16px
  /// - Weight: Regular (400)
  /// - Letter spacing: 0.5
  /// - Line height: 1.5
  ///
  /// Use for: Main content, paragraphs, descriptions.
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - Standard body text.
  ///
  /// - Font size: 14px
  /// - Weight: Regular (400)
  /// - Letter spacing: 0.25
  /// - Line height: 1.43
  ///
  /// Use for: Form labels, descriptions, secondary content.
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small - Small body text.
  ///
  /// - Font size: 12px
  /// - Weight: Regular (400)
  /// - Letter spacing: 0.4
  /// - Line height: 1.33
  ///
  /// Use for: Captions, helper text, timestamps.
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============ Label Styles ============

  /// Label Large - Large labels and tabs.
  ///
  /// - Font size: 14px
  /// - Weight: Medium (500)
  /// - Letter spacing: 0.1
  /// - Line height: 1.43
  ///
  /// Use for: Navigation tabs, form labels, prominent badges.
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium - Standard labels.
  ///
  /// - Font size: 12px
  /// - Weight: Medium (500)
  /// - Letter spacing: 0.5
  /// - Line height: 1.33
  ///
  /// Use for: Chips, badges, tab labels.
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small - Small labels.
  ///
  /// - Font size: 11px
  /// - Weight: Medium (500)
  /// - Letter spacing: 0.5
  /// - Line height: 1.45
  ///
  /// Use for: Small badges, bottom navigation labels.
  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============ Button Styles ============

  /// Button Large - Large button text.
  ///
  /// - Font size: 16px
  /// - Weight: Semi-bold (600)
  /// - Letter spacing: 0.5
  /// - Line height: 1.5
  ///
  /// Use for: Primary CTAs, large buttons.
  static const buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Button Medium - Standard button text.
  ///
  /// - Font size: 14px
  /// - Weight: Semi-bold (600)
  /// - Letter spacing: 0.5
  /// - Line height: 1.43
  ///
  /// Use for: Standard buttons, action buttons.
  static const buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.43,
  );

  /// Button Small - Small button text.
  ///
  /// - Font size: 12px
  /// - Weight: Semi-bold (600)
  /// - Letter spacing: 0.5
  /// - Line height: 1.33
  ///
  /// Use for: Compact buttons, inline actions.
  static const buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  // ============ Caption & Overline ============

  /// Caption - Small descriptive text.
  ///
  /// - Font size: 12px
  /// - Weight: Regular (400)
  /// - Letter spacing: 0.4
  /// - Line height: 1.33
  ///
  /// Use for: Image captions, helper text, metadata.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  /// Overline - Small uppercase labels.
  ///
  /// - Font size: 10px
  /// - Weight: Medium (500)
  /// - Letter spacing: 1.5
  /// - Line height: 1.6
  ///
  /// Use for: Category labels, section dividers, status tags.
  /// Typically used with `.toUpperCase()`.
  static const overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
}

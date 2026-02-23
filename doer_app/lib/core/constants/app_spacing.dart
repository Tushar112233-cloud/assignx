/// Application spacing and layout constants.
///
/// This file defines a consistent spacing system based on an 8px grid,
/// providing standardized values for padding, margins, border radii,
/// icon sizes, and avatar dimensions.
///
/// ## Design System
/// The spacing system follows an 8px base unit with multipliers:
/// - xxs: 2px (0.25x)
/// - xs: 4px (0.5x)
/// - sm: 8px (1x)
/// - md: 16px (2x)
/// - lg: 24px (3x)
/// - xl: 32px (4x)
/// - xxl: 48px (6x)
/// - xxxl: 64px (8x)
///
/// ## Benefits
/// - Consistent visual rhythm across the app
/// - Easier maintenance and global adjustments
/// - Better alignment with design specifications
library;

import 'package:flutter/material.dart';

/// App spacing constants following 8px grid system.
///
/// Provides standardized spacing values, padding presets, border radii,
/// icon sizes, and avatar dimensions for consistent layout across the app.
///
/// ## Usage
/// ```dart
/// // Using spacing values
/// SizedBox(height: AppSpacing.md);
///
/// // Using padding presets
/// Padding(
///   padding: AppSpacing.paddingMd,
///   child: Text('Padded content'),
/// );
///
/// // Using border radius
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppSpacing.borderRadiusMd,
///   ),
/// );
/// ```
class AppSpacing {
  /// Private constructor to prevent instantiation.
  AppSpacing._();

  // ---------------------------------------------------------------------------
  // Base Unit
  // ---------------------------------------------------------------------------

  /// Base spacing unit (8px).
  ///
  /// All other spacing values are derived from this base unit.
  static const double unit = 8.0;

  // ---------------------------------------------------------------------------
  // Spacing Values
  // ---------------------------------------------------------------------------

  /// Extra extra small spacing (2px).
  ///
  /// Use for tight spacing between related elements.
  static const double xxs = 2.0;

  /// Extra small spacing (4px).
  ///
  /// Use for minimal gaps between closely related items.
  static const double xs = 4.0;

  /// Small spacing (8px) - 1x base unit.
  ///
  /// Standard tight spacing for compact layouts.
  static const double sm = 8.0;

  /// Medium spacing (16px) - 2x base unit.
  ///
  /// Default spacing for most use cases.
  static const double md = 16.0;

  /// Large spacing (24px) - 3x base unit.
  ///
  /// Use for section separation and generous padding.
  static const double lg = 24.0;

  /// Extra large spacing (32px) - 4x base unit.
  ///
  /// Use for major section breaks and screen margins.
  static const double xl = 32.0;

  /// Extra extra large spacing (48px) - 6x base unit.
  ///
  /// Use for significant visual separation.
  static const double xxl = 48.0;

  /// Extra extra extra large spacing (64px) - 8x base unit.
  ///
  /// Use for hero sections and major layout divisions.
  static const double xxxl = 64.0;

  // ---------------------------------------------------------------------------
  // Padding Presets
  // ---------------------------------------------------------------------------

  /// Extra small padding on all sides (4px).
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);

  /// Small padding on all sides (8px).
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);

  /// Medium padding on all sides (16px).
  static const EdgeInsets paddingMd = EdgeInsets.all(md);

  /// Large padding on all sides (24px).
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);

  /// Extra large padding on all sides (32px).
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // ---------------------------------------------------------------------------
  // Horizontal Padding
  // ---------------------------------------------------------------------------

  /// Small horizontal padding (8px left and right).
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Medium horizontal padding (16px left and right).
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Large horizontal padding (24px left and right).
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  // ---------------------------------------------------------------------------
  // Vertical Padding
  // ---------------------------------------------------------------------------

  /// Small vertical padding (8px top and bottom).
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Medium vertical padding (16px top and bottom).
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  /// Large vertical padding (24px top and bottom).
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // ---------------------------------------------------------------------------
  // Screen Padding
  // ---------------------------------------------------------------------------

  /// Standard screen padding (16px all sides).
  ///
  /// Use for main content areas on screens.
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// Horizontal-only screen padding (16px left and right).
  ///
  /// Use when vertical padding is handled separately.
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: md);

  // ---------------------------------------------------------------------------
  // Border Radius Values
  // ---------------------------------------------------------------------------

  /// Extra small border radius (4px).
  ///
  /// Use for subtle rounding on small elements.
  static const double radiusXs = 4.0;

  /// Small border radius (8px).
  ///
  /// Standard rounding for buttons and inputs.
  static const double radiusSm = 8.0;

  /// Medium border radius (12px).
  ///
  /// Use for cards and containers.
  static const double radiusMd = 12.0;

  /// Large border radius (16px).
  ///
  /// Use for modals and prominent containers.
  static const double radiusLg = 16.0;

  /// Extra large border radius (24px).
  ///
  /// Use for hero cards and feature sections.
  static const double radiusXl = 24.0;

  /// Full/circular border radius (999px).
  ///
  /// Use for pills and circular elements.
  static const double radiusFull = 999.0;

  // ---------------------------------------------------------------------------
  // Border Radius Presets
  // ---------------------------------------------------------------------------

  /// Extra small border radius preset (4px all corners).
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));

  /// Small border radius preset (8px all corners).
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));

  /// Medium border radius preset (12px all corners).
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));

  /// Large border radius preset (16px all corners).
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));

  /// Extra large border radius preset (24px all corners).
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  // ---------------------------------------------------------------------------
  // Icon Sizes
  // ---------------------------------------------------------------------------

  /// Extra small icon size (16px).
  ///
  /// Use for inline icons and dense UIs.
  static const double iconXs = 16.0;

  /// Small icon size (20px).
  ///
  /// Use for list item icons and compact buttons.
  static const double iconSm = 20.0;

  /// Medium icon size (24px).
  ///
  /// Standard icon size for most use cases.
  static const double iconMd = 24.0;

  /// Large icon size (32px).
  ///
  /// Use for prominent icons and empty states.
  static const double iconLg = 32.0;

  /// Extra large icon size (48px).
  ///
  /// Use for hero icons and feature highlights.
  static const double iconXl = 48.0;

  // ---------------------------------------------------------------------------
  // Avatar Sizes
  // ---------------------------------------------------------------------------

  /// Small avatar size (32px).
  ///
  /// Use for compact list items and comments.
  static const double avatarSm = 32.0;

  /// Medium avatar size (48px).
  ///
  /// Standard avatar size for lists and cards.
  static const double avatarMd = 48.0;

  /// Large avatar size (64px).
  ///
  /// Use for profile headers and detailed views.
  static const double avatarLg = 64.0;

  /// Extra large avatar size (96px).
  ///
  /// Use for profile screens and hero sections.
  static const double avatarXl = 96.0;
}

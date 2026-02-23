/// Application color palette constants.
///
/// This file defines the complete color system for the DOER app,
/// following a professional, authority-driven design theme.
///
/// ## Color Categories
/// - **Primary Colors**: Main brand colors (navy blue tones)
/// - **Accent Colors**: Interactive element highlights (bright blue)
/// - **Background Colors**: Surface and container colors
/// - **Text Colors**: Typography hierarchy colors
/// - **Status Colors**: Success, warning, error, and info states
/// - **Urgency Colors**: Time-sensitive task indicators
/// - **Border Colors**: Dividers and container outlines
/// - **Dark Theme Colors**: Alternative palette for dark mode
///
/// ## Design Principles
/// - Uses a cohesive navy blue primary palette for authority
/// - Bright blue accents for actionable elements
/// - Semantic colors for status feedback
/// - Consistent opacity levels for shadows and overlays
library;

import 'package:flutter/material.dart';

/// App color palette following the professional, authority-driven theme.
///
/// All colors are defined as static constants for compile-time optimization
/// and consistent usage across the application.
///
/// ## Usage
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text(
///     'Hello',
///     style: TextStyle(color: AppColors.textOnPrimary),
///   ),
/// )
/// ```
///
/// ## Accessibility
/// Color combinations are designed to meet WCAG 2.1 contrast requirements:
/// - Primary text on background: 4.5:1+ ratio
/// - Large text on primary: 3:1+ ratio
class AppColors {
  /// Private constructor to prevent instantiation.
  AppColors._();

  // ---------------------------------------------------------------------------
  // Primary Colors
  // ---------------------------------------------------------------------------

  /// Primary brand color - deep navy blue.
  ///
  /// Used for primary buttons, app bars, and key branding elements.
  /// Hex: #1E3A5F
  static const Color primary = Color(0xFF1E3A5F);

  /// Lighter shade of primary for hover states and secondary emphasis.
  ///
  /// Hex: #2D4A6F
  static const Color primaryLight = Color(0xFF2D4A6F);

  /// Darker shade of primary for pressed states and emphasis.
  ///
  /// Hex: #0F2A4F
  static const Color primaryDark = Color(0xFF0F2A4F);

  // ---------------------------------------------------------------------------
  // Accent Colors
  // ---------------------------------------------------------------------------

  /// Accent color - bright blue for interactive elements.
  ///
  /// Used for links, secondary buttons, and call-to-action elements.
  /// Hex: #3B82F6
  static const Color accent = Color(0xFF3B82F6);

  /// Lighter shade of accent for hover states.
  ///
  /// Hex: #60A5FA
  static const Color accentLight = Color(0xFF60A5FA);

  /// Darker shade of accent for pressed states.
  ///
  /// Hex: #2563EB
  static const Color accentDark = Color(0xFF2563EB);

  // ---------------------------------------------------------------------------
  // Background Colors
  // ---------------------------------------------------------------------------

  /// Main background color - light gray-blue.
  ///
  /// Used for screen backgrounds and main content areas.
  /// Hex: #F8FAFC
  static const Color background = Color(0xFFF8FAFC);

  /// Surface color for cards and elevated containers.
  ///
  /// Pure white for maximum contrast with background.
  static const Color surface = Colors.white;

  /// Variant surface for subtle differentiation.
  ///
  /// Slightly darker than surface for nested containers.
  /// Hex: #F1F5F9
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Text Colors
  // ---------------------------------------------------------------------------

  /// Primary text color for headings and body text.
  ///
  /// Near-black for maximum readability.
  /// Hex: #1E293B
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text color for supporting content.
  ///
  /// Medium gray for less prominent text.
  /// Hex: #64748B
  static const Color textSecondary = Color(0xFF64748B);

  /// Tertiary text color for captions and hints.
  ///
  /// Light gray for minimal emphasis text.
  /// Hex: #94A3B8
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Text color for content on primary-colored backgrounds.
  ///
  /// White for contrast on dark backgrounds.
  static const Color textOnPrimary = Colors.white;

  // ---------------------------------------------------------------------------
  // Status Colors
  // ---------------------------------------------------------------------------

  /// Success state color - green.
  ///
  /// Used for success messages, completed states, and positive indicators.
  /// Hex: #22C55E
  static const Color success = Color(0xFF22C55E);

  /// Light success background for success banners.
  ///
  /// Hex: #DCFCE7
  static const Color successLight = Color(0xFFDCFCE7);

  /// Warning state color - amber/orange.
  ///
  /// Used for warning messages and caution indicators.
  /// Hex: #F59E0B
  static const Color warning = Color(0xFFF59E0B);

  /// Light warning background for warning banners.
  ///
  /// Hex: #FEF3C7
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Error state color - red.
  ///
  /// Used for error messages, destructive actions, and alerts.
  /// Hex: #EF4444
  static const Color error = Color(0xFFEF4444);

  /// Light error background for error banners.
  ///
  /// Hex: #FEE2E2
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Info state color - cyan/sky blue.
  ///
  /// Used for informational messages and tips.
  /// Hex: #0EA5E9
  static const Color info = Color(0xFF0EA5E9);

  /// Light info background for info banners.
  ///
  /// Hex: #E0F2FE
  static const Color infoLight = Color(0xFFE0F2FE);

  // ---------------------------------------------------------------------------
  // Urgency Colors
  // ---------------------------------------------------------------------------

  /// High urgency indicator - bright red.
  ///
  /// Used for tasks due within 6 hours.
  /// Hex: #DC2626
  static const Color urgencyHigh = Color(0xFFDC2626);

  /// Medium urgency indicator - amber.
  ///
  /// Used for tasks due within 24 hours.
  /// Hex: #F59E0B
  static const Color urgencyMedium = Color(0xFFF59E0B);

  /// Low urgency indicator - green.
  ///
  /// Used for tasks with comfortable deadlines.
  /// Hex: #22C55E
  static const Color urgencyLow = Color(0xFF22C55E);

  /// Urgent badge/tag color - orange.
  ///
  /// Hex: #FF6B35
  static const Color urgent = Color(0xFFFF6B35);

  /// Urgent badge background - light orange.
  ///
  /// Hex: #FFF3E0
  static const Color urgentBg = Color(0xFFFFF3E0);

  // ---------------------------------------------------------------------------
  // Border Colors
  // ---------------------------------------------------------------------------

  /// Default border color for containers.
  ///
  /// Hex: #E2E8F0
  static const Color border = Color(0xFFE2E8F0);

  /// Light border for subtle separation.
  ///
  /// Hex: #F1F5F9
  static const Color borderLight = Color(0xFFF1F5F9);

  /// Dark border for emphasis.
  ///
  /// Hex: #CBD5E1
  static const Color borderDark = Color(0xFFCBD5E1);

  // ---------------------------------------------------------------------------
  // Divider
  // ---------------------------------------------------------------------------

  /// Standard divider color.
  ///
  /// Hex: #E2E8F0
  static const Color divider = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // Shadow
  // ---------------------------------------------------------------------------

  /// Shadow color with 10% opacity.
  ///
  /// Hex: #1A000000 (10% black)
  static const Color shadow = Color(0x1A000000);

  // ---------------------------------------------------------------------------
  // Dark Theme Colors
  // ---------------------------------------------------------------------------

  /// Dark theme background color.
  ///
  /// Deep navy for dark mode screens.
  /// Hex: #0F172A
  static const Color darkBackground = Color(0xFF0F172A);

  /// Dark theme surface color.
  ///
  /// Slightly lighter than background for cards.
  /// Hex: #1E293B
  static const Color darkSurface = Color(0xFF1E293B);

  /// Dark theme surface variant.
  ///
  /// For nested containers in dark mode.
  /// Hex: #334155
  static const Color darkSurfaceVariant = Color(0xFF334155);
}

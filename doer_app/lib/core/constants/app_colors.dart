/// Application color palette constants.
///
/// This file defines the complete color system for the DOER app,
/// following a warm-professional teal design theme.
///
/// ## Color Categories
/// - **Primary Colors**: Main brand colors (deep teal tones)
/// - **Accent Colors**: Interactive element highlights (vivid cyan)
/// - **Background Colors**: Surface and container colors
/// - **Gradient Colors**: Teal-to-cyan gradient stops
/// - **Mesh Gradient Colors**: Soft pastels for corner gradients
/// - **Text Colors**: Typography hierarchy colors
/// - **Status Colors**: Success, warning, error, and info states
/// - **Urgency Colors**: Time-sensitive task indicators
/// - **Border Colors**: Dividers and container outlines
/// - **Dark Theme Colors**: Alternative palette for dark mode
///
/// ## Design Principles
/// - Uses a cohesive deep teal primary palette for warmth and authority
/// - Vivid cyan accents for actionable, earning-focused elements
/// - Semantic colors for status feedback
/// - Consistent opacity levels for shadows and overlays
library;

import 'package:flutter/material.dart';

/// App color palette following the warm-professional teal theme.
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
  // Primary Colors - Deep Teal (warmer than navy)
  // ---------------------------------------------------------------------------

  /// Primary brand color - deep teal.
  ///
  /// Used for primary buttons, app bars, and key branding elements.
  /// Hex: #1A4B5F
  static const Color primary = Color(0xFF1A4B5F);

  /// Lighter shade of primary for hover states and secondary emphasis.
  ///
  /// Hex: #2A5B6F
  static const Color primaryLight = Color(0xFF2A5B6F);

  /// Darker shade of primary for pressed states and emphasis.
  ///
  /// Hex: #0A3B4F
  static const Color primaryDark = Color(0xFF0A3B4F);

  // ---------------------------------------------------------------------------
  // Accent Colors - Vivid Cyan (energetic, earning-focused)
  // ---------------------------------------------------------------------------

  /// Accent color - vivid cyan for interactive elements.
  ///
  /// Used for links, secondary buttons, and call-to-action elements.
  /// Hex: #06B6D4
  static const Color accent = Color(0xFF06B6D4);

  /// Lighter shade of accent for hover states.
  ///
  /// Hex: #22D3EE
  static const Color accentLight = Color(0xFF22D3EE);

  /// Darker shade of accent for pressed states.
  ///
  /// Hex: #0891B2
  static const Color accentDark = Color(0xFF0891B2);

  // ---------------------------------------------------------------------------
  // Background Colors - Warmer off-whites
  // ---------------------------------------------------------------------------

  /// Main background color - warm off-white.
  ///
  /// Used for screen backgrounds and main content areas.
  /// Hex: #FAFBFC
  static const Color background = Color(0xFFFAFBFC);

  /// Surface color for cards and elevated containers.
  ///
  /// Pure white for maximum contrast with background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Variant surface for subtle differentiation.
  ///
  /// Slightly darker than surface for nested containers.
  /// Hex: #F1F5F9
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Gradient Colors - Teal to Cyan
  // ---------------------------------------------------------------------------

  /// Gradient start color - darkest teal.
  ///
  /// Hex: #0A3B4F
  static const Color gradientStart = Color(0xFF0A3B4F);

  /// Gradient middle color - primary teal.
  ///
  /// Hex: #1A4B5F
  static const Color gradientMiddle = Color(0xFF1A4B5F);

  /// Gradient end color - vivid cyan.
  ///
  /// Hex: #06B6D4
  static const Color gradientEnd = Color(0xFF06B6D4);

  // ---------------------------------------------------------------------------
  // Text Colors
  // ---------------------------------------------------------------------------

  /// Primary text color for headings and body text.
  ///
  /// Deep teal-gray for warm readability.
  /// Hex: #1A2B3B
  static const Color textPrimary = Color(0xFF1A2B3B);

  /// Secondary text color for supporting content.
  ///
  /// Teal-tinted gray for less prominent text.
  /// Hex: #5A7A8A
  static const Color textSecondary = Color(0xFF5A7A8A);

  /// Tertiary text color for captions and hints.
  ///
  /// Light teal-gray for minimal emphasis text.
  /// Hex: #8AA3B0
  static const Color textTertiary = Color(0xFF8AA3B0);

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

  /// Info state color - teal-cyan.
  ///
  /// Used for informational messages and tips.
  /// Hex: #06B6D4
  static const Color info = Color(0xFF06B6D4);

  /// Light info background for info banners.
  ///
  /// Hex: #CFFAFE
  static const Color infoLight = Color(0xFFCFFAFE);

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
  /// Hex: #D5E0E5
  static const Color border = Color(0xFFD5E0E5);

  /// Light border for subtle separation.
  ///
  /// Hex: #E8F0F3
  static const Color borderLight = Color(0xFFE8F0F3);

  /// Dark border for emphasis.
  ///
  /// Hex: #B0C4CE
  static const Color borderDark = Color(0xFFB0C4CE);

  // ---------------------------------------------------------------------------
  // Divider
  // ---------------------------------------------------------------------------

  /// Standard divider color.
  ///
  /// Hex: #D5E0E5
  static const Color divider = Color(0xFFD5E0E5);

  // ---------------------------------------------------------------------------
  // Shadow
  // ---------------------------------------------------------------------------

  /// Shadow color with 10% opacity.
  ///
  /// Hex: #1A000000 (10% black)
  static const Color shadow = Color(0x1A000000);

  // ---------------------------------------------------------------------------
  // Glass Effect Colors
  // ---------------------------------------------------------------------------

  /// Glass background - White with opacity for glass morphism.
  static Color get glassBackground => Colors.white.withValues(alpha: 0.85);

  /// Glass border - Subtle white border for glass effect.
  static Color get glassBorder => Colors.white.withValues(alpha: 0.3);

  /// Glass background dark - For dark theme glass effects.
  static Color get glassBackgroundDark => Colors.black.withValues(alpha: 0.6);

  /// Glass border dark - For dark theme glass borders.
  static Color get glassBorderDark => Colors.white.withValues(alpha: 0.1);

  // ---------------------------------------------------------------------------
  // Mesh Gradient Colors - Soft pastels for corner gradients
  // ---------------------------------------------------------------------------

  /// Mesh Teal - Soft pastel teal.
  ///
  /// Hex: #CCFBF1
  static const Color meshTeal = Color(0xFFCCFBF1);

  /// Mesh Cyan - Soft pastel cyan.
  ///
  /// Hex: #CFFAFE
  static const Color meshCyan = Color(0xFFCFFAFE);

  /// Mesh Mint - Soft pastel mint green.
  ///
  /// Hex: #D1FAE5
  static const Color meshMint = Color(0xFFD1FAE5);

  /// Mesh Lavender - Soft pastel lavender.
  ///
  /// Hex: #E0E7FF
  static const Color meshLavender = Color(0xFFE0E7FF);

  /// Mesh Peach - Soft pastel peach.
  ///
  /// Hex: #FFEDD5
  static const Color meshPeach = Color(0xFFFFEDD5);

  /// Mesh Pink - Soft pastel pink.
  ///
  /// Hex: #FFE4E6
  static const Color meshPink = Color(0xFFFFE4E6);

  // ---------------------------------------------------------------------------
  // Shimmer Colors
  // ---------------------------------------------------------------------------

  /// Shimmer base color.
  static const Color shimmerBase = Color(0xFFD5E0E5);

  /// Shimmer highlight color.
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // ---------------------------------------------------------------------------
  // Category Colors
  // ---------------------------------------------------------------------------

  /// Discussion category - Orange.
  static const Color categoryOrange = Color(0xFFE07B4C);

  /// Portfolio category - Indigo.
  static const Color categoryIndigo = Color(0xFF5C6BC0);

  /// Skill Exchange category - Teal.
  static const Color categoryTeal = Color(0xFF009688);

  /// Freelance/Gig category - Green.
  static const Color categoryGreen = Color(0xFF4CAF50);

  /// Event category - Amber.
  static const Color categoryAmber = Color(0xFFF5A623);

  /// News/Resource category - Blue.
  static const Color categoryBlue = Color(0xFF2196F3);

  // ---------------------------------------------------------------------------
  // Neutral Colors
  // ---------------------------------------------------------------------------

  /// Light gray background for icon areas.
  static const Color neutralLight = Color(0xFFF5F5F5);

  /// Gray for disabled icons/placeholders.
  static const Color neutralGray = Color(0xFFBDBDBD);

  /// Light surface for subtle backgrounds.
  static const Color surfaceLight = Color(0xFFF1F5F9);

  /// Light gray for avatar backgrounds.
  static const Color avatarGray = Color(0xFFE0E0E0);

  /// Warm avatar background - teal-tinted.
  static const Color avatarWarm = Color(0xFFCCE5E8);

  // ---------------------------------------------------------------------------
  // Dark Theme Colors
  // ---------------------------------------------------------------------------

  /// Dark theme background color.
  ///
  /// Deep teal-navy for dark mode screens.
  /// Hex: #0B1E28
  static const Color darkBackground = Color(0xFF0B1E28);

  /// Dark theme surface color.
  ///
  /// Slightly lighter than background for cards.
  /// Hex: #142E3A
  static const Color darkSurface = Color(0xFF142E3A);

  /// Dark theme surface variant.
  ///
  /// For nested containers in dark mode.
  /// Hex: #1E3E4D
  static const Color darkSurfaceVariant = Color(0xFF1E3E4D);
}

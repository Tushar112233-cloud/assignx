/// Application color palette constants.
///
/// This file defines the complete color system for the DOER app,
/// following a modern indigo-blue design theme matching the doer-web portal.
///
/// ## Color Categories
/// - **Primary Colors**: Main brand colors (indigo/blue tones)
/// - **Accent Colors**: Interactive element highlights (cyan)
/// - **Background Colors**: Surface and container colors
/// - **Gradient Colors**: Dark navy-to-indigo gradient stops
/// - **Mesh Gradient Colors**: Soft pastels for corner gradients
/// - **Text Colors**: Typography hierarchy colors
/// - **Status Colors**: Success, warning, error, and info states
/// - **Urgency Colors**: Time-sensitive task indicators
/// - **Border Colors**: Dividers and container outlines
/// - **Dark Theme Colors**: Alternative palette for dark mode
///
/// ## Design Principles
/// - Uses a cohesive indigo/blue primary palette for clarity and trust
/// - Cyan accents for actionable, earning-focused elements
/// - Semantic colors for status feedback
/// - Consistent opacity levels for shadows and overlays
library;

import 'package:flutter/material.dart';

/// App color palette following the indigo-blue theme from doer-web.
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
  // Primary Colors - Indigo/Blue
  // ---------------------------------------------------------------------------

  /// Primary brand color - indigo blue.
  ///
  /// Used for primary buttons, app bars, and key branding elements.
  /// Hex: #5A7CFF
  static const Color primary = Color(0xFF5A7CFF);

  /// Lighter shade of primary for hover states and secondary emphasis.
  ///
  /// Hex: #7B96FF
  static const Color primaryLight = Color(0xFF7B96FF);

  /// Darker shade of primary for pressed states and emphasis.
  ///
  /// Hex: #4A6AEF
  static const Color primaryDark = Color(0xFF4A6AEF);

  // ---------------------------------------------------------------------------
  // Accent Colors - Cyan (energetic, earning-focused)
  // ---------------------------------------------------------------------------

  /// Accent color - cyan for interactive elements.
  ///
  /// Used for links, secondary buttons, and call-to-action elements.
  /// Hex: #49C5FF
  static const Color accent = Color(0xFF49C5FF);

  /// Lighter shade of accent for hover states.
  ///
  /// Hex: #6DD5FF
  static const Color accentLight = Color(0xFF6DD5FF);

  /// Darker shade of accent for pressed states.
  ///
  /// Hex: #2BB5F0
  static const Color accentDark = Color(0xFF2BB5F0);

  // ---------------------------------------------------------------------------
  // Background Colors - Clean off-whites
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
  // Gradient Colors - Dark Navy to Indigo
  // ---------------------------------------------------------------------------

  /// Gradient start color - dark navy.
  ///
  /// Hex: #0B0F1A
  static const Color gradientStart = Color(0xFF0B0F1A);

  /// Gradient middle color - dark indigo.
  ///
  /// Hex: #1A1F3A
  static const Color gradientMiddle = Color(0xFF1A1F3A);

  /// Gradient end color - indigo blue.
  ///
  /// Hex: #5A7CFF
  static const Color gradientEnd = Color(0xFF5A7CFF);

  // ---------------------------------------------------------------------------
  // Text Colors
  // ---------------------------------------------------------------------------

  /// Primary text color for headings and body text.
  ///
  /// Slate-800 for crisp readability.
  /// Hex: #1E293B
  static const Color textPrimary = Color(0xFF1E293B);

  /// Secondary text color for supporting content.
  ///
  /// Slate-500 for less prominent text.
  /// Hex: #64748B
  static const Color textSecondary = Color(0xFF64748B);

  /// Tertiary text color for captions and hints.
  ///
  /// Slate-400 for minimal emphasis text.
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
  /// Hex: #E2E8F0
  static const Color border = Color(0xFFE2E8F0);

  /// Light border for subtle separation.
  ///
  /// Hex: #EEF2FF
  static const Color borderLight = Color(0xFFEEF2FF);

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
  /// Deep dark navy for dark mode screens.
  /// Hex: #0B0F1A
  static const Color darkBackground = Color(0xFF0B0F1A);

  /// Dark theme surface color.
  ///
  /// Slightly lighter than background for cards.
  /// Hex: #131729
  static const Color darkSurface = Color(0xFF131729);

  /// Dark theme surface variant.
  ///
  /// For nested containers in dark mode.
  /// Hex: #1E2340
  static const Color darkSurfaceVariant = Color(0xFF1E2340);
}

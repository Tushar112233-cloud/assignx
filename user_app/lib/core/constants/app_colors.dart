import 'package:flutter/material.dart';

/// App color constants following the Coffee Bean Design System.
///
/// Palette: Pitch Black to Warm Brown
/// #14110F | #54442B | #765341 | #9D7B65 | #E4E1C7
///
/// Theme: Professionalism, Warmth, Trust
class AppColors {
  AppColors._();

  // ============================================================
  // PRIMARY COLORS - Coffee Bean
  // ============================================================

  /// Primary brand color - Coffee Bean (#765341)
  static const Color primary = Color(0xFF765341);

  /// Lighter variant of primary for hover states
  static const Color primaryLight = Color(0xFF8D6A58);

  /// Darker variant of primary for pressed states
  static const Color primaryDark = Color(0xFF5F4334);

  // ============================================================
  // ACCENT COLORS - Warm Brown
  // ============================================================

  /// Accent color - Warm Brown (#9D7B65)
  static const Color accent = Color(0xFF9D7B65);

  /// Lighter variant of accent
  static const Color accentLight = Color(0xFFB39580);

  /// Darker variant of accent
  static const Color accentDark = Color(0xFF87654F);

  // ============================================================
  // CORE PALETTE COLORS
  // ============================================================

  /// Dark Brown (#54442B) - For gradients and dark accents
  static const Color darkBrown = Color(0xFF54442B);

  /// Pitch Black (#14110F) - Deepest dark color
  static const Color pitchBlack = Color(0xFF14110F);

  /// Vanilla Cream (#E4E1C7) - Light accent color
  static const Color vanillaCream = Color(0xFFE4E1C7);

  // ============================================================
  // GRADIENT COLORS
  // ============================================================

  /// Gradient start - Pitch Black (#14110F)
  static const Color gradientStart = Color(0xFF14110F);

  /// Gradient middle - Dark Brown (#54442B)
  static const Color gradientMiddle = Color(0xFF54442B);

  /// Gradient end - Warm Brown (#9D7B65)
  static const Color gradientEnd = Color(0xFF9D7B65);

  /// Primary gradient for buttons and highlights
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  /// Subtle gradient for cards and surfaces
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFEFDFB), Color(0xFFFAF9F7)],
  );

  // ============================================================
  // BACKGROUND COLORS - Light Theme
  // ============================================================

  /// Main background - Warm White (#FEFDFB)
  static const Color background = Color(0xFFFEFDFB);

  /// Surface color - Light Surface (#FAF9F7)
  static const Color surface = Color(0xFFFAF9F7);

  /// Muted surface - Warm Gray (#F1EEEA)
  static const Color surfaceVariant = Color(0xFFF1EEEA);

  /// Card background
  static const Color card = Color(0xFFFEFDFB);

  /// Light surface for subtle backgrounds (pills, chips)
  static const Color surfaceLight = Color(0xFFF5F2ED);

  // ============================================================
  // BACKGROUND COLORS - Dark Theme
  // ============================================================

  /// Dark background - Pitch Black (#14110F)
  static const Color backgroundDark = Color(0xFF14110F);

  /// Dark surface - Dark Surface (#1C1815)
  static const Color surfaceDark = Color(0xFF1C1815);

  /// Dark muted surface - Dark Brown variant (#2D261F)
  static const Color surfaceVariantDark = Color(0xFF2D261F);

  /// Dark card background
  static const Color cardDark = Color(0xFF1C1815);

  // ============================================================
  // TEXT COLORS - Light Theme
  // ============================================================

  /// Primary text - Pitch Black (#14110F)
  static const Color textPrimary = Color(0xFF14110F);

  /// Secondary text - Warm brown-gray (#6B5D4D)
  static const Color textSecondary = Color(0xFF6B5D4D);

  /// Tertiary text - Lighter brown-gray (#8F826F)
  /// Meets WCAG 2.1 AA contrast ratio (4.5:1) against light backgrounds
  static const Color textTertiary = Color(0xFF8F826F);

  /// Text on primary/accent colors
  static const Color textOnPrimary = Color(0xFFFEFDFB);

  // ============================================================
  // TEXT COLORS - Dark Theme
  // ============================================================

  /// Primary text for dark theme - Light warm (#F0ECE4)
  static const Color textPrimaryDark = Color(0xFFF0ECE4);

  /// Secondary text for dark theme
  static const Color textSecondaryDark = Color(0xFFB8AD99);

  /// Tertiary text for dark theme
  static const Color textTertiaryDark = Color(0xFF8A8170);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  /// Success - Sage Green (#259369) - Earthy, natural feel
  static const Color success = Color(0xFF259369);

  /// Success light background
  static const Color successLight = Color(0xFFD4F5E5);

  /// Warning - Warm Amber (#F59E0B)
  static const Color warning = Color(0xFFF59E0B);

  /// Warning light background
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Error/Destructive - Warm Red (#DC352F)
  static const Color error = Color(0xFFDC352F);

  /// Error light background
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Info - Balanced Blue (#2B93BE)
  static const Color info = Color(0xFF2B93BE);

  /// Info light background
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============================================================
  // PROJECT STATUS COLORS
  // ============================================================

  /// Analyzing status - Gold
  static const Color analyzing = Color(0xFFEAB308);

  /// Analyzing light background
  static const Color analyzingLight = Color(0xFFFEF9C3);

  /// Payment pending status - Warm Amber
  static const Color paymentPending = Color(0xFFF59E0B);

  /// In progress status - Uses primary (Coffee Bean)
  static const Color inProgress = Color(0xFF765341);

  /// For review status - Accent (Warm Brown)
  static const Color forReview = Color(0xFF9D7B65);

  /// Completed status - Success (Sage Green)
  static const Color completed = Color(0xFF259369);

  /// Revision required status - Error (Warm Red)
  static const Color revision = Color(0xFFDC352F);

  /// Archived status - Muted gray
  static const Color archived = Color(0xFF6B5D4D);

  // ============================================================
  // BORDER COLORS
  // ============================================================

  /// Default border - Warm gray (#DDD7CD)
  static const Color border = Color(0xFFDDD7CD);

  /// Focused border - Uses primary (Coffee Bean)
  static const Color borderFocused = Color(0xFF765341);

  /// Error border - Warm Red
  static const Color borderError = Color(0xFFDC352F);

  /// Dark theme border
  static const Color borderDark = Color(0xFF4D4333);

  // ============================================================
  // DIVIDER & OVERLAY
  // ============================================================

  /// Divider color - matches border
  static const Color divider = Color(0xFFDDD7CD);

  /// Dark theme divider
  static const Color dividerDark = Color(0xFF4D4333);

  /// Overlay - Semi-transparent black
  static const Color overlay = Color(0x80000000);

  /// Light overlay for dark surfaces
  static const Color overlayLight = Color(0x1AFFFFFF);

  // ============================================================
  // GLASS EFFECT COLORS
  // ============================================================

  /// Glass background - White with opacity for glass morphism
  static Color get glassBackground => Colors.white.withValues(alpha: 0.85);

  /// Glass border - Subtle white border for glass effect
  static Color get glassBorder => Colors.white.withValues(alpha: 0.3);

  /// Glass background dark - For dark theme glass effects
  static Color get glassBackgroundDark => Colors.black.withValues(alpha: 0.6);

  /// Glass border dark - For dark theme glass borders
  static Color get glassBorderDark => Colors.white.withValues(alpha: 0.1);

  // ============================================================
  // MESH GRADIENT COLORS - Pastel variants for backgrounds
  // ============================================================

  /// Mesh Pink - Soft pastel pink
  static const Color meshPink = Color(0xFFFBE8E8);

  /// Mesh Peach - Soft pastel peach
  static const Color meshPeach = Color(0xFFFCEDE8);

  /// Mesh Orange - Soft pastel orange
  static const Color meshOrange = Color(0xFFFEF3E8);

  /// Mesh Yellow - Soft pastel yellow
  static const Color meshYellow = Color(0xFFFEF9E8);

  /// Mesh Green - Soft pastel green
  static const Color meshGreen = Color(0xFFE8F5EC);

  /// Mesh Blue - Soft pastel blue
  static const Color meshBlue = Color(0xFFE8F0F8);

  /// Mesh Purple - Soft pastel purple
  static const Color meshPurple = Color(0xFFF0E8F8);

  /// Mesh gradient for decorative backgrounds
  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [meshPink, meshPeach, meshYellow, meshGreen, meshBlue],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // ============================================================
  // MODERN GRADIENT COLORS - Vibrant for modern app style
  // ============================================================

  /// Modern Pink - Vibrant pink for gradients
  static const Color modernPink = Color(0xFFFF6B9D);

  /// Modern Magenta - Deep magenta/pink
  static const Color modernMagenta = Color(0xFFE91E8C);

  /// Modern Purple - Soft purple for gradients
  static const Color modernPurple = Color(0xFFC471ED);

  /// Modern Blue - Bright blue
  static const Color modernBlue = Color(0xFF12C2E9);

  /// Modern Cyan - Light cyan
  static const Color modernCyan = Color(0xFF00D4FF);

  /// Modern gradient for auth screens (pink to blue)
  static const LinearGradient modernAuthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFB6C1), // Light pink
      Color(0xFFE991CF), // Medium pink
      Color(0xFFC471ED), // Purple
      Color(0xFF8EC5FC), // Light blue
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  /// Subtle modern gradient (very light, for backgrounds)
  static const LinearGradient subtleModernGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF5F7), // Very light pink
      Color(0xFFFAF5FF), // Very light purple
      Color(0xFFF5FAFF), // Very light blue
      Color(0xFFFFFFFF), // White
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  // ============================================================
  // SHIMMER COLORS - Loading States
  // ============================================================

  /// Shimmer base color - Light theme
  static const Color shimmerBase = Color(0xFFE8E3DA);

  /// Shimmer highlight color - Light theme
  static const Color shimmerHighlight = Color(0xFFF5F2ED);

  /// Shimmer base color - Dark theme
  static const Color shimmerBaseDark = Color(0xFF2D261F);

  /// Shimmer highlight color - Dark theme
  static const Color shimmerHighlightDark = Color(0xFF4D4333);

  // ============================================================
  // INPUT COLORS
  // ============================================================

  /// Input background
  static const Color inputBackground = Color(0xFFF1EEEA);

  /// Input background dark
  static const Color inputBackgroundDark = Color(0xFF2D261F);

  // ============================================================
  // CATEGORY COLORS - For Campus Connect and post types
  // ============================================================

  /// Community category - Orange/Coral
  static const Color categoryOrange = Color(0xFFE07B4C);

  /// Help category - Blue
  static const Color categoryBlue = Color(0xFF2196F3);

  /// Event category - Indigo/Purple
  static const Color categoryIndigo = Color(0xFF5C6BC0);

  /// Product category - Green
  static const Color categoryGreen = Color(0xFF4CAF50);

  /// Housing category - Amber
  static const Color categoryAmber = Color(0xFFF5A623);

  /// Opportunities category - Teal
  static const Color categoryTeal = Color(0xFF009688);

  // ============================================================
  // NEUTRAL COLORS - Grays for UI elements
  // ============================================================

  /// Light gray background for icon areas
  static const Color neutralLight = Color(0xFFF5F5F5);

  /// Gray for disabled icons/placeholders
  static const Color neutralGray = Color(0xFFBDBDBD);

  /// Muted gray for secondary icons
  static const Color neutralMuted = Color(0xFF9B9B9B);

  /// Light gray for avatar backgrounds
  static const Color avatarGray = Color(0xFFE0E0E0);

  /// Warm avatar background
  static const Color avatarWarm = Color(0xFFE8E0D8);

  /// Pink/Mauve for status indicators
  static const Color statusPink = Color(0xFFDDB8D8);

  /// Badge background - Light gray
  static const Color badgeBackground = Color(0xFFF0F0F0);

  // ============================================================
  // CHART COLORS - Earthy palette for data visualization
  // ============================================================

  /// Chart color 1 - Coffee Bean (Primary)
  static const Color chart1 = Color(0xFF765341);

  /// Chart color 2 - Warm Brown (Accent)
  static const Color chart2 = Color(0xFF9D7B65);

  /// Chart color 3 - Dark Brown
  static const Color chart3 = Color(0xFF54442B);

  /// Chart color 4 - Sage Green
  static const Color chart4 = Color(0xFF259369);

  /// Chart color 5 - Balanced Blue
  static const Color chart5 = Color(0xFF2B93BE);

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Get shimmer colors based on theme brightness
  static List<Color> getShimmerColors(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [shimmerBaseDark, shimmerHighlightDark, shimmerBaseDark];
    }
    return [shimmerBase, shimmerHighlight, shimmerBase];
  }

  /// Get appropriate text color for a given background
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate relative luminance
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textPrimaryDark;
  }

  /// Get glass background based on theme brightness
  static Color getGlassBackground(Brightness brightness) {
    return brightness == Brightness.dark ? glassBackgroundDark : glassBackground;
  }

  /// Get glass border based on theme brightness
  static Color getGlassBorder(Brightness brightness) {
    return brightness == Brightness.dark ? glassBorderDark : glassBorder;
  }
}

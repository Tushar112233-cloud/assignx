import 'package:flutter/material.dart';

/// App shadow definitions following the Premium Earthy Design System.
///
/// Shadow system matching web implementation with warm undertones.
/// Sizes: xs, sm, md, lg, xl, 2xl
class AppShadows {
  AppShadows._();

  // ============================================================
  // SHADOW COLORS
  // ============================================================

  /// Base shadow color with warm undertone
  static const Color shadowColor = Color(0xFF54442B);

  /// Light shadow for subtle elevation
  static const Color shadowColorLight = Color(0x0A54442B);

  /// Medium shadow for cards
  static const Color shadowColorMedium = Color(0x1454442B);

  /// Dark shadow for dropdowns and modals
  static const Color shadowColorDark = Color(0x2054442B);

  // ============================================================
  // SHADOW DEFINITIONS - Matching Web Design System
  // ============================================================

  /// Extra small shadow - Subtle elevation for small elements
  /// Web equivalent: shadow-xs
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Small shadow - Light elevation for buttons, chips
  /// Web equivalent: shadow-sm
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A54442B),
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0654442B),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow - Standard elevation for cards
  /// Web equivalent: shadow-md
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0A54442B),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0654442B),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  /// Large shadow - Elevated cards, dropdowns
  /// Web equivalent: shadow-lg
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x0A54442B),
      blurRadius: 15,
      offset: Offset(0, 10),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Extra large shadow - Modals, floating elements
  /// Web equivalent: shadow-xl
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x0A54442B),
      blurRadius: 25,
      offset: Offset(0, 20),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 10,
      offset: Offset(0, 8),
      spreadRadius: -5,
    ),
  ];

  /// 2X Extra large shadow - Popovers, large modals
  /// Web equivalent: shadow-2xl
  static const List<BoxShadow> xl2 = [
    BoxShadow(
      color: Color(0x1454442B),
      blurRadius: 50,
      offset: Offset(0, 25),
      spreadRadius: -12,
    ),
  ];

  // ============================================================
  // SPECIAL SHADOWS
  // ============================================================

  /// Inner shadow for pressed states
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Glow effect for focus states - uses primary color
  static List<BoxShadow> focusRing = [
    const BoxShadow(
      color: Color(0x40A9714B),
      blurRadius: 0,
      offset: Offset.zero,
      spreadRadius: 3,
    ),
  ];

  /// Glow effect for accent elements
  static List<BoxShadow> accentGlow = [
    const BoxShadow(
      color: Color(0x40E8985E),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Primary button shadow
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x30A9714B),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Card hover shadow - elevated state
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x1054442B),
      blurRadius: 20,
      offset: Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Bottom navigation shadow
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x0A54442B),
      blurRadius: 20,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  /// Top app bar shadow (when scrolled)
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0854442B),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // ============================================================
  // DARK THEME SHADOWS
  // ============================================================

  /// Dark theme base shadow color
  static const Color shadowColorDarkTheme = Color(0xFF000000);

  /// Extra small shadow - Dark theme
  static const List<BoxShadow> xsDark = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Small shadow - Dark theme
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow - Dark theme
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  /// Large shadow - Dark theme
  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 15,
      offset: Offset(0, 10),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Extra large shadow - Dark theme
  static const List<BoxShadow> xlDark = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 25,
      offset: Offset(0, 20),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 10,
      offset: Offset(0, 8),
      spreadRadius: -5,
    ),
  ];

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Get shadow based on size and theme brightness
  static List<BoxShadow> getShadow(
    ShadowSize size, {
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;

    switch (size) {
      case ShadowSize.xs:
        return isDark ? xsDark : xs;
      case ShadowSize.sm:
        return isDark ? smDark : sm;
      case ShadowSize.md:
        return isDark ? mdDark : md;
      case ShadowSize.lg:
        return isDark ? lgDark : lg;
      case ShadowSize.xl:
        return isDark ? xlDark : xl;
      case ShadowSize.xl2:
        return xl2;
      case ShadowSize.none:
        return [];
    }
  }

  /// Create a custom box decoration with shadow
  static BoxDecoration decorationWithShadow({
    required ShadowSize shadowSize,
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    Brightness brightness = Brightness.light,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: border,
      boxShadow: getShadow(shadowSize, brightness: brightness),
    );
  }
}

/// Shadow size enumeration
enum ShadowSize {
  none,
  xs,
  sm,
  md,
  lg,
  xl,
  xl2,
}

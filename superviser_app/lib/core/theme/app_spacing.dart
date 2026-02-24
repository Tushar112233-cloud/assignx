library;

import 'package:flutter/material.dart';

/// Spacing constants following an 8px grid system.
///
/// Provides consistent spacing, border radii, padding presets,
/// icon sizes, and avatar sizes for the superviser app.
abstract class AppSpacing {
  // ============ Spacing Scale (8px grid) ============

  /// Extra extra small spacing: 2px
  static const double xxs = 2;

  /// Extra small spacing: 4px
  static const double xs = 4;

  /// Small spacing: 8px
  static const double sm = 8;

  /// Medium spacing: 16px
  static const double md = 16;

  /// Large spacing: 24px
  static const double lg = 24;

  /// Extra large spacing: 32px
  static const double xl = 32;

  /// Extra extra large spacing: 48px
  static const double xxl = 48;

  /// Extra extra extra large spacing: 64px
  static const double xxxl = 64;

  // ============ Border Radii ============

  /// Extra small radius: 4px
  static const double radiusXs = 4;

  /// Small radius: 8px
  static const double radiusSm = 8;

  /// Medium radius: 12px
  static const double radiusMd = 12;

  /// Large radius: 16px
  static const double radiusLg = 16;

  /// Extra large radius: 24px
  static const double radiusXl = 24;

  /// Full/pill radius: 999px
  static const double radiusFull = 999;

  // ============ BorderRadius Presets ============

  /// Small border radius preset.
  static final borderRadiusSm = BorderRadius.circular(radiusSm);

  /// Medium border radius preset.
  static final borderRadiusMd = BorderRadius.circular(radiusMd);

  /// Large border radius preset.
  static final borderRadiusLg = BorderRadius.circular(radiusLg);

  /// Extra large border radius preset.
  static final borderRadiusXl = BorderRadius.circular(radiusXl);

  // ============ Padding Presets ============

  /// Extra small padding: 4px all sides.
  static const paddingXs = EdgeInsets.all(xs);

  /// Small padding: 8px all sides.
  static const paddingSm = EdgeInsets.all(sm);

  /// Medium padding: 16px all sides.
  static const paddingMd = EdgeInsets.all(md);

  /// Large padding: 24px all sides.
  static const paddingLg = EdgeInsets.all(lg);

  /// Extra large padding: 32px all sides.
  static const paddingXl = EdgeInsets.all(xl);

  /// Horizontal small padding: 8px left/right.
  static const paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal medium padding: 16px left/right.
  static const paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal large padding: 24px left/right.
  static const paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical small padding: 8px top/bottom.
  static const paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical medium padding: 16px top/bottom.
  static const paddingVerticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical large padding: 24px top/bottom.
  static const paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Standard screen padding: 20px horizontal, 16px vertical.
  static const screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: md);

  /// Standard card padding: 16px all sides.
  static const cardPadding = EdgeInsets.all(md);

  // ============ Icon Sizes ============

  /// Small icon size: 16px.
  static const double iconSm = 16;

  /// Medium icon size: 24px.
  static const double iconMd = 24;

  /// Large icon size: 32px.
  static const double iconLg = 32;

  /// Extra large icon size: 48px.
  static const double iconXl = 48;

  // ============ Avatar Sizes ============

  /// Small avatar size: 32px.
  static const double avatarSm = 32;

  /// Medium avatar size: 48px.
  static const double avatarMd = 48;

  /// Large avatar size: 64px.
  static const double avatarLg = 64;

  /// Extra large avatar size: 96px.
  static const double avatarXl = 96;
}

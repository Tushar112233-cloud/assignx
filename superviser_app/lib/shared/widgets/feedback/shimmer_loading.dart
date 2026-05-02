import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

/// {@template shimmer_loading}
/// A widget that applies a shimmer effect to its child.
///
/// Wraps any widget with an animated shimmer effect to indicate
/// loading state. Commonly used for skeleton loading patterns.
///
/// ## Appearance
/// - Animated shimmer gradient moving across the child
/// - Adapts to light/dark theme automatically
/// - Uses app-defined shimmer colors from [AppColors]
///
/// ## Usage
///
/// Wrap any placeholder widget:
/// ```dart
/// ShimmerLoading(
///   child: Container(
///     width: 200,
///     height: 20,
///     color: Colors.grey,
///   ),
/// )
/// ```
///
/// Conditionally enable shimmer:
/// ```dart
/// ShimmerLoading(
///   enabled: isLoading,
///   child: MyPlaceholderWidget(),
/// )
/// ```
///
/// See also:
/// - [ShimmerBox] for rectangular placeholders
/// - [ShimmerCircle] for circular placeholders
/// - [ShimmerListItem] for list item placeholders
/// - [ShimmerList] for a complete loading list
/// {@endtemplate}
class ShimmerLoading extends StatelessWidget {
  /// Creates a shimmer loading wrapper.
  const ShimmerLoading({
    super.key,
    required this.child,
    this.enabled = true,
  });

  /// The child widget to apply the shimmer effect to.
  ///
  /// The child should typically be a container or placeholder
  /// widget with a solid color.
  final Widget child;

  /// Whether the shimmer effect is enabled.
  ///
  /// When false, the child is rendered without any shimmer effect.
  /// Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlightLight,
      child: child,
    );
  }
}

/// {@template shimmer_box}
/// A rectangular placeholder for shimmer loading effects.
///
/// Use to represent text lines, titles, buttons, or other
/// rectangular content while loading.
///
/// ## Appearance
/// - Rectangular shape with rounded corners
/// - Uses theme-appropriate shimmer colors
/// - Customizable width, height, and border radius
///
/// ## Usage
/// ```dart
/// // Fixed width text placeholder
/// ShimmerBox(width: 200, height: 16)
///
/// // Full width placeholder
/// ShimmerBox(height: 20)
///
/// // Button-like placeholder
/// ShimmerBox(width: 100, height: 40, borderRadius: 20)
/// ```
///
/// See also:
/// - [ShimmerCircle] for circular placeholders
/// - [ShimmerLoading] to apply shimmer animation
/// {@endtemplate}
class ShimmerBox extends StatelessWidget {
  /// Creates a rectangular shimmer placeholder.
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  /// The width of the placeholder.
  ///
  /// If null, the box will expand to fill available width.
  final double? width;

  /// The height of the placeholder.
  ///
  /// Defaults to 16 pixels (typical text line height).
  final double height;

  /// The corner radius of the placeholder.
  ///
  /// Defaults to 4 pixels.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// {@template shimmer_circle}
/// A circular placeholder for shimmer loading effects.
///
/// Use to represent avatars, profile pictures, icons, or other
/// circular content while loading.
///
/// ## Appearance
/// - Perfect circle shape
/// - Uses theme-appropriate shimmer colors
/// - Customizable size
///
/// ## Usage
/// ```dart
/// // Avatar placeholder
/// ShimmerCircle(size: 48)
///
/// // Small icon placeholder
/// ShimmerCircle(size: 24)
/// ```
///
/// See also:
/// - [ShimmerBox] for rectangular placeholders
/// - [ShimmerLoading] to apply shimmer animation
/// {@endtemplate}
class ShimmerCircle extends StatelessWidget {
  /// Creates a circular shimmer placeholder.
  const ShimmerCircle({
    super.key,
    this.size = 40,
  });

  /// The diameter of the circle.
  ///
  /// Defaults to 40 pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// {@template shimmer_list_item}
/// A shimmer placeholder for a single list item.
///
/// Provides a complete skeleton for a typical list item with
/// optional leading avatar, multiple text lines, and trailing content.
///
/// ## Appearance
/// - Optional 48px circular leading element (avatar)
/// - Multiple text lines (configurable via [lines])
/// - Optional trailing element
/// - Standard list item padding
///
/// ## Usage
/// ```dart
/// // Basic list item with avatar and 2 lines
/// ShimmerListItem()
///
/// // List item without avatar
/// ShimmerListItem(hasLeading: false)
///
/// // List item with trailing badge
/// ShimmerListItem(hasTrailing: true, lines: 3)
/// ```
///
/// See also:
/// - [ShimmerList] for multiple list items
/// - [ShimmerCard] for card placeholders
/// {@endtemplate}
class ShimmerListItem extends StatelessWidget {
  /// Creates a shimmer list item placeholder.
  const ShimmerListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  /// Whether to show a leading avatar circle.
  ///
  /// Defaults to true.
  final bool hasLeading;

  /// Whether to show a trailing element.
  ///
  /// Defaults to false.
  final bool hasTrailing;

  /// Number of text lines to display (1-3).
  ///
  /// Defaults to 2. The first line is wider than subsequent lines.
  final int lines;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (hasLeading) ...[
              const ShimmerCircle(size: 48),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 200, height: 16),
                  if (lines > 1) ...[
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 150, height: 12),
                  ],
                  if (lines > 2) ...[
                    const SizedBox(height: 6),
                    const ShimmerBox(width: 100, height: 12),
                  ],
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 16),
              const ShimmerBox(width: 60, height: 24, borderRadius: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// {@template shimmer_card}
/// A shimmer placeholder for a card.
///
/// Provides a simple rectangular card placeholder with
/// rounded corners and standard card margins.
///
/// ## Appearance
/// - Rectangular shape with 12px rounded corners
/// - Standard horizontal margin (16px) and vertical margin (8px)
/// - Customizable height
///
/// ## Usage
/// ```dart
/// // Standard card placeholder
/// ShimmerCard()
///
/// // Taller card placeholder
/// ShimmerCard(height: 200)
/// ```
///
/// See also:
/// - [ShimmerListItem] for list item placeholders
/// - [ShimmerList] for multiple list items
/// {@endtemplate}
class ShimmerCard extends StatelessWidget {
  /// Creates a shimmer card placeholder.
  const ShimmerCard({
    super.key,
    this.height = 120,
  });

  /// The height of the card placeholder.
  ///
  /// Defaults to 120 pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.shimmerBaseDark
              : AppColors.shimmerBaseLight,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// {@template shimmer_list}
/// A shimmer placeholder for a list of items.
///
/// Renders multiple [ShimmerListItem] widgets to simulate
/// a loading list view.
///
/// ## Appearance
/// - Multiple list items with shimmer effect
/// - Non-scrollable (use in place of actual list)
/// - Shrink-wrapped to fit content
///
/// ## Usage
/// ```dart
/// // Default 5 items with avatars
/// ShimmerList()
///
/// // 10 items without avatars
/// ShimmerList(itemCount: 10, hasLeading: false)
///
/// // Items with trailing elements
/// ShimmerList(hasTrailing: true, lines: 3)
/// ```
///
/// See also:
/// - [ShimmerListItem] for single list items
/// - [ShimmerCard] for card placeholders
/// {@endtemplate}
class ShimmerList extends StatelessWidget {
  /// Creates a shimmer list placeholder.
  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  /// The number of list items to display.
  ///
  /// Defaults to 5.
  final int itemCount;

  /// Whether each item should have a leading avatar.
  ///
  /// Defaults to true.
  final bool hasLeading;

  /// Whether each item should have a trailing element.
  ///
  /// Defaults to false.
  final bool hasTrailing;

  /// Number of text lines per item (1-3).
  ///
  /// Defaults to 2.
  final int lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerListItem(
        hasLeading: hasLeading,
        hasTrailing: hasTrailing,
        lines: lines,
      ),
    );
  }
}

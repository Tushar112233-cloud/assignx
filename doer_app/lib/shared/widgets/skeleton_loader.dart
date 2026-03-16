/// Shimmer skeleton loader widgets for loading states.
///
/// Provides a reusable skeleton loader system with shimmer animation
/// for displaying placeholder UI while content is being loaded.
///
/// ## Widgets
/// - [SkeletonLoader] - Base skeleton with configurable dimensions
/// - [SkeletonLine] - Single text-line placeholder
/// - [SkeletonCircle] - Circular avatar placeholder
/// - [SkeletonCard] - Card-shaped placeholder matching [AppCard] shape
/// - [SkeletonProjectCard] - Mimics a project card layout
/// - [SkeletonStatCard] - Mimics a stat card layout
/// - [SkeletonListView] - Convenience widget showing N skeleton cards
///
/// ## Example
/// ```dart
/// // Show skeleton while loading
/// if (isLoading)
///   const SkeletonListView(itemCount: 5)
/// else
///   ProjectListView(projects: projects),
/// ```
///
/// See also:
/// - [GlassContainer] for the glass morphism styling reference
/// - [AppCard] for the card shape these skeletons mimic
/// - [AppColors.shimmerBase] and [AppColors.shimmerHighlight] for colors
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Base shimmer skeleton loader for loading states.
///
/// Displays a placeholder rectangle with an animated shimmer effect
/// sweeping left to right. Supports configurable dimensions and
/// border radius.
///
/// Uses [AppColors.surfaceVariant] as the base color and a teal-tinted
/// highlight for the shimmer sweep.
///
/// Example:
/// ```dart
/// SkeletonLoader(
///   width: 200,
///   height: 20,
///   borderRadius: 8,
/// )
/// ```
class SkeletonLoader extends StatelessWidget {
  /// Width of the skeleton. Defaults to double.infinity.
  final double? width;

  /// Height of the skeleton. Required.
  final double height;

  /// Border radius. Default is 8.
  final double borderRadius;

  /// Base color for the skeleton. Default is [AppColors.surfaceVariant].
  final Color? baseColor;

  /// Highlight color for shimmer effect. Default uses a teal-tinted highlight.
  final Color? highlightColor;

  /// Animation duration. Default is 1500ms.
  final Duration duration;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? AppColors.surfaceVariant;
    final highlight = highlightColor ?? AppColors.shimmerHighlight;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: highlight.withAlpha(128),
        );
  }
}

/// Single text-line skeleton placeholder.
///
/// A thin rectangle mimicking a line of text. Default height is 16
/// with full available width and rounded corners (radius 8).
///
/// Example:
/// ```dart
/// const SkeletonLine()
/// const SkeletonLine(width: 150) // shorter line
/// ```
class SkeletonLine extends StatelessWidget {
  /// Width of the line. Defaults to full width.
  final double? width;

  /// Height of the line. Default is 16.
  final double height;

  /// Border radius. Default is 8.
  final double borderRadius;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Circular avatar skeleton placeholder.
///
/// A circle mimicking an avatar or profile image. Default size is 48.
///
/// Example:
/// ```dart
/// const SkeletonCircle()
/// const SkeletonCircle(size: 64) // larger avatar
/// ```
class SkeletonCircle extends StatelessWidget {
  /// Diameter of the circle. Default is 48.
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = AppSpacing.avatarMd,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Card-shaped skeleton placeholder.
///
/// Matches the [AppCard] shape with 20px border radius, 120px height,
/// and glass-like styling (blur background, translucent border).
///
/// Example:
/// ```dart
/// const SkeletonCard()
/// const SkeletonCard(height: 160) // taller card
/// ```
class SkeletonCard extends StatelessWidget {
  /// Height of the card. Default is 120.
  final double height;

  /// Width of the card. Defaults to full width.
  final double? width;

  /// Border radius. Default is 20 (matches AppCard).
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.shimmerHighlight.withAlpha(128),
        );
  }
}

/// Project card skeleton that mimics a project card layout.
///
/// Displays an avatar circle, three text lines of varying widths,
/// and a small badge placeholder. Uses glass-container styling for
/// visual consistency with the real project cards.
///
/// Example:
/// ```dart
/// const SkeletonProjectCard()
/// ```
class SkeletonProjectCard extends StatelessWidget {
  /// Border radius. Default is 20 (matches AppCard).
  final double borderRadius;

  const SkeletonProjectCard({
    super.key,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + title + badge
              Row(
                children: [
                  // Avatar placeholder
                  SkeletonCircle(size: 40),
                  SizedBox(width: AppSpacing.md),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(
                          width: 160,
                          height: 16,
                          borderRadius: AppSpacing.radiusXs,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        SkeletonLoader(
                          width: 100,
                          height: 12,
                          borderRadius: AppSpacing.radiusXs,
                        ),
                      ],
                    ),
                  ),
                  // Badge placeholder
                  SkeletonLoader(
                    width: 60,
                    height: 24,
                    borderRadius: AppSpacing.radiusFull,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              // Description line
              SkeletonLoader(
                height: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
              SizedBox(height: AppSpacing.xs),
              SkeletonLoader(
                width: 220,
                height: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
              SizedBox(height: AppSpacing.md),
              // Bottom row: third line (date/info)
              SkeletonLoader(
                width: 140,
                height: 12,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.shimmerHighlight.withAlpha(128),
        );
  }
}

/// Stat card skeleton that mimics a stat card layout.
///
/// Displays an icon circle placeholder, a value line, and a label line,
/// matching the [AppStatCard] layout with glass-container styling.
///
/// Example:
/// ```dart
/// const SkeletonStatCard()
/// ```
class SkeletonStatCard extends StatelessWidget {
  /// Border radius. Default is 20 (matches AppStatCard).
  final double borderRadius;

  const SkeletonStatCard({
    super.key,
    this.borderRadius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient accent strip (matches AppStatCard)
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.shimmerBase,
                  AppColors.shimmerBase.withAlpha(150),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
              ),
            ),
          ),
          // Card content
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon circle placeholder
                SkeletonCircle(size: 40),
                SizedBox(width: AppSpacing.md),
                // Value and label lines
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: 60,
                        height: 12,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonLoader(
                        width: 80,
                        height: 18,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.shimmerHighlight.withAlpha(128),
        );
  }
}

/// Convenience widget that displays N skeleton cards in a scrollable list.
///
/// Uses [SkeletonProjectCard] by default to mimic a typical project list
/// loading state. Supports custom item builders for flexibility.
///
/// Example:
/// ```dart
/// const SkeletonListView(itemCount: 5)
///
/// // With custom builder
/// SkeletonListView(
///   itemCount: 3,
///   itemBuilder: (context, index) => const SkeletonStatCard(),
/// )
/// ```
class SkeletonListView extends StatelessWidget {
  /// Number of skeleton items to display.
  final int itemCount;

  /// Spacing between items. Default is 12.
  final double spacing;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Custom item builder. Defaults to [SkeletonProjectCard].
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Whether the list should shrink-wrap its content.
  /// Default is true (for embedding in scrollable parents).
  final bool shrinkWrap;

  /// Scroll physics. Default is [NeverScrollableScrollPhysics].
  final ScrollPhysics? physics;

  const SkeletonListView({
    super.key,
    this.itemCount = 5,
    this.spacing = AppSpacing.radiusMd,
    this.padding,
    this.itemBuilder,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder:
          itemBuilder ?? (context, index) => const SkeletonProjectCard(),
    );
  }
}

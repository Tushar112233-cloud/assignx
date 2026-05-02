import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Basic shimmer skeleton loader for loading states.
///
/// Displays a placeholder with animated shimmer effect while
/// content is being loaded. Supports configurable dimensions
/// and border radius.
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

  /// Base color for the skeleton. Default is shimmerBase.
  final Color? baseColor;

  /// Highlight color for shimmer effect. Default is shimmerHighlight.
  final Color? highlightColor;

  /// Animation duration. Default is 1.5 seconds.
  final Duration duration;

  /// Whether to show as circle. Overrides width/height to be equal.
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.isCircle = false,
  });

  /// Creates a circular skeleton loader.
  const SkeletonLoader.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  })  : width = size,
        height = size,
        borderRadius = 999,
        isCircle = true;

  /// Creates a text-line skeleton loader.
  const SkeletonLoader.text({
    super.key,
    this.width,
    double? height,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  })  : height = height ?? 16,
        borderRadius = 4,
        isCircle = false;

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? AppColors.shimmerBase;
    final highlight = highlightColor ?? AppColors.shimmerHighlight;

    return Container(
      width: isCircle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(isCircle ? height / 2 : borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: duration,
          color: highlight.withAlpha(128),
        );
  }
}

/// Card skeleton loader for loading card-based content.
///
/// Provides a complete card placeholder with image area,
/// title, and description skeletons.
class CardSkeleton extends StatelessWidget {
  /// Card width. Defaults to double.infinity.
  final double? width;

  /// Card height. Default is 200.
  final double height;

  /// Border radius. Default is 16.
  final double borderRadius;

  /// Whether to show image placeholder. Default is true.
  final bool showImage;

  /// Image height as fraction of total height. Default is 0.5.
  final double imageHeightRatio;

  /// Number of text lines to show. Default is 2.
  final int textLines;

  /// Padding inside the card. Default is 12.
  final EdgeInsetsGeometry padding;

  const CardSkeleton({
    super.key,
    this.width,
    this.height = 200,
    this.borderRadius = AppSpacing.radiusLg,
    this.showImage = true,
    this.imageHeightRatio = 0.5,
    this.textLines = 2,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = showImage ? height * imageHeightRatio : 0.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage)
            SkeletonLoader(
              width: double.infinity,
              height: imageHeight,
              borderRadius: 0,
            ),
          Expanded(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title skeleton
                  SkeletonLoader(
                    width: width != null ? width! * 0.7 : null,
                    height: 18,
                  ),
                  const SizedBox(height: 8),
                  // Description lines
                  ...List.generate(
                    textLines,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SkeletonLoader(
                        width: index == textLines - 1
                            ? (width != null ? width! * 0.5 : null)
                            : null,
                        height: 14,
                      ),
                    ),
                  ),
                ],
              ),
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

/// Item card skeleton for list item loading states.
///
/// Horizontal layout with avatar, title, and subtitle placeholders.
class ItemCardSkeleton extends StatelessWidget {
  /// Card height. Default is 72.
  final double height;

  /// Border radius. Default is 12.
  final double borderRadius;

  /// Whether to show leading avatar. Default is true.
  final bool showAvatar;

  /// Avatar size. Default is 48.
  final double avatarSize;

  /// Whether to show trailing element. Default is false.
  final bool showTrailing;

  /// Trailing element width. Default is 60.
  final double trailingWidth;

  /// Padding inside the card.
  final EdgeInsetsGeometry padding;

  const ItemCardSkeleton({
    super.key,
    this.height = 72,
    this.borderRadius = AppSpacing.radiusMd,
    this.showAvatar = true,
    this.avatarSize = 48,
    this.showTrailing = false,
    this.trailingWidth = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      padding: padding,
      child: Row(
        children: [
          if (showAvatar) ...[
            SkeletonLoader.circle(size: avatarSize),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkeletonLoader(
                  width: 140,
                  height: 16,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: showTrailing ? 100 : 200,
                  height: 12,
                ),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 12),
            SkeletonLoader(
              width: trailingWidth,
              height: 32,
            ),
          ],
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

/// Grid of skeleton items for loading grid layouts.
class SkeletonGrid extends StatelessWidget {
  /// Number of items in the grid.
  final int itemCount;

  /// Number of columns. Default is 2.
  final int crossAxisCount;

  /// Spacing between items. Default is 16.
  final double spacing;

  /// Child aspect ratio. Default is 1.0.
  final double childAspectRatio;

  /// Padding around the grid.
  final EdgeInsetsGeometry? padding;

  const SkeletonGrid({
    super.key,
    required this.itemCount,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => CardSkeleton(
        height: 150,
        borderRadius: AppSpacing.radiusMd,
      ),
    );
  }
}

/// List of skeleton items for loading list layouts.
class SkeletonList extends StatelessWidget {
  /// Number of items in the list.
  final int itemCount;

  /// Spacing between items. Default is 12.
  final double spacing;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Whether to show dividers. Default is false.
  final bool showDividers;

  /// Custom item builder.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  const SkeletonList({
    super.key,
    required this.itemCount,
    this.spacing = 12,
    this.padding,
    this.showDividers = false,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => showDividers
          ? const Divider(height: 1)
          : SizedBox(height: spacing),
      itemBuilder: itemBuilder ?? (context, index) => const ItemCardSkeleton(),
    );
  }
}

/// Profile skeleton for user profile loading state.
class ProfileSkeleton extends StatelessWidget {
  /// Avatar size. Default is 80.
  final double avatarSize;

  /// Whether to show stats row. Default is true.
  final bool showStats;

  /// Number of stat items. Default is 3.
  final int statsCount;

  const ProfileSkeleton({
    super.key,
    this.avatarSize = 80,
    this.showStats = true,
    this.statsCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        SkeletonLoader.circle(size: avatarSize),
        const SizedBox(height: 16),
        // Name
        const SkeletonLoader(width: 150, height: 20),
        const SizedBox(height: 8),
        // Subtitle
        const SkeletonLoader(width: 200, height: 14),
        if (showStats) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              statsCount,
              (index) => Column(
                children: [
                  const SkeletonLoader(width: 40, height: 24),
                  const SizedBox(height: 4),
                  const SkeletonLoader(width: 60, height: 12),
                ],
              ),
            ),
          ),
        ],
      ],
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.shimmerHighlight.withAlpha(128),
        );
  }
}

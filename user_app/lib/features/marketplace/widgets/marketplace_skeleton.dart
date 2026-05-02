import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the Marketplace/CampusConnect screen.
///
/// Matches the layout of CampusConnectScreen with:
/// - Hero section
/// - Search bar
/// - Filter tabs (horizontal scroll)
/// - Listings count
/// - Staggered grid of listing cards (masonry style)
class MarketplaceSkeleton extends StatelessWidget {
  const MarketplaceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section skeleton
          const _HeroSectionSkeleton(),

          // Search bar skeleton
          const _SearchBarSkeleton(),

          // Filter tabs skeleton
          const _FilterTabsSkeleton(),

          // Listings count skeleton
          const _ListingsCountSkeleton(),

          // Staggered grid skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _StaggeredGridSkeleton(),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

/// Hero section skeleton with gradient background and icon.
class _HeroSectionSkeleton extends StatelessWidget {
  const _HeroSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(30),
            AppColors.primaryDark.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 22,
                  width: 160,
                  borderRadius: AppSpacing.radiusMd,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: 14,
                  width: 200,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  height: 14,
                  width: 140,
                  borderRadius: AppSpacing.radiusSm,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SkeletonLoader(
            height: 60,
            width: 60,
            borderRadius: 16,
          ),
        ],
      ),
    );
  }
}

/// Search bar skeleton with filter button.
class _SearchBarSkeleton extends StatelessWidget {
  const _SearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SkeletonLoader(
                    height: 20,
                    width: 20,
                    borderRadius: AppSpacing.radiusSm,
                  ),
                  const SizedBox(width: 12),
                  SkeletonLoader(
                    height: 14,
                    width: 150,
                    borderRadius: AppSpacing.radiusXs,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SkeletonLoader(
            height: 48,
            width: 48,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}

/// Filter tabs skeleton (horizontal scrollable).
class _FilterTabsSkeleton extends StatelessWidget {
  const _FilterTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          final widths = [50.0, 70.0, 80.0, 90.0, 100.0];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SkeletonLoader(
              height: 36,
              width: widths[index],
              borderRadius: 20,
            ),
          );
        }),
      ),
    );
  }
}

/// Listings count skeleton.
class _ListingsCountSkeleton extends StatelessWidget {
  const _ListingsCountSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SkeletonLoader(
          height: 13,
          width: 120,
          borderRadius: AppSpacing.radiusXs,
        ),
      ),
    );
  }
}

/// Staggered grid skeleton matching Pinterest-style masonry layout.
class _StaggeredGridSkeleton extends StatelessWidget {
  const _StaggeredGridSkeleton();

  @override
  Widget build(BuildContext context) {
    // Simulate a 2-column masonry grid
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          child: Column(
            children: [
              _GridItemSkeleton(height: 180),
              const SizedBox(height: 12),
              _GridItemSkeleton(height: 220),
              const SizedBox(height: 12),
              _GridItemSkeleton(height: 160),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right column (offset for masonry effect)
        Expanded(
          child: Column(
            children: [
              _GridItemSkeleton(height: 220),
              const SizedBox(height: 12),
              _GridItemSkeleton(height: 160),
              const SizedBox(height: 12),
              _GridItemSkeleton(height: 200),
            ],
          ),
        ),
      ],
    );
  }
}

/// Grid item skeleton for individual cards in the staggered grid.
class _GridItemSkeleton extends StatelessWidget {
  final double height;

  const _GridItemSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    // Calculate content area height
    final iconAreaHeight = height * 0.5;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Image area
          Container(
            height: iconAreaHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: SkeletonLoader(
                height: 40,
                width: 40,
                borderRadius: 12,
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      SkeletonLoader(
                        height: 14,
                        width: double.infinity,
                        borderRadius: AppSpacing.radiusSm,
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      SkeletonLoader(
                        height: 12,
                        width: 80,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                    ],
                  ),
                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonLoader(
                        height: 12,
                        width: 50,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                      SkeletonLoader(
                        height: 12,
                        width: 40,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact list item skeleton for alternative list view.
class MarketplaceListItemSkeleton extends StatelessWidget {
  const MarketplaceListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          SkeletonLoader(
            height: 70,
            width: 70,
            borderRadius: 12,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                SkeletonLoader(
                  height: 20,
                  width: 60,
                  borderRadius: 10,
                ),
                const SizedBox(height: 6),
                // Title
                SkeletonLoader(
                  height: 14,
                  width: double.infinity,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 4),
                // Subtitle
                SkeletonLoader(
                  height: 12,
                  width: 100,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price/action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoader(
                height: 16,
                width: 50,
                borderRadius: AppSpacing.radiusSm,
              ),
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 12,
                width: 40,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Housing card skeleton for housing-specific listings.
class HousingCardSkeleton extends StatelessWidget {
  const HousingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          SkeletonLoader(
            height: 120,
            width: double.infinity,
            borderRadius: 0,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price badge
                SkeletonLoader(
                  height: 24,
                  width: 80,
                  borderRadius: 12,
                ),
                const SizedBox(height: 8),
                // Title
                SkeletonLoader(
                  height: 16,
                  width: double.infinity,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 6),
                // Location
                Row(
                  children: [
                    SkeletonLoader(
                      height: 14,
                      width: 14,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                    const SizedBox(width: 6),
                    SkeletonLoader(
                      height: 12,
                      width: 100,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Features row
                Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        child: SkeletonLoader(
                          height: 30,
                          borderRadius: 8,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Event card skeleton for event-specific listings.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event type badge
          SkeletonLoader(
            height: 24,
            width: 70,
            borderRadius: 12,
          ),
          const SizedBox(height: 12),
          // Title
          SkeletonLoader(
            height: 16,
            width: double.infinity,
            borderRadius: AppSpacing.radiusSm,
          ),
          const SizedBox(height: 8),
          // Date and time row
          Row(
            children: [
              SkeletonLoader(
                height: 14,
                width: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
              const SizedBox(width: 6),
              SkeletonLoader(
                height: 12,
                width: 120,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Location row
          Row(
            children: [
              SkeletonLoader(
                height: 14,
                width: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
              const SizedBox(width: 6),
              SkeletonLoader(
                height: 12,
                width: 100,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // RSVP button
          SkeletonLoader(
            height: 36,
            width: double.infinity,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the Experts screen.
///
/// Matches the layout of ExpertsScreen with:
/// - Hero section with search and stats
/// - Filter chips row (horizontal scroll)
/// - Featured experts section (horizontal scroll)
/// - All experts list (vertical cards)
class ExpertsSkeleton extends StatelessWidget {
  const ExpertsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),

          // Hero section skeleton
          const _ExpertsHeroSkeleton(),

          // Filter tabs skeleton
          const _FilterTabsSkeleton(),

          // Featured section skeleton
          const _FeaturedSectionSkeleton(),

          // All experts header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(
                  height: 16,
                  width: 90,
                  borderRadius: AppSpacing.radiusSm,
                ),
                SkeletonLoader(
                  height: 12,
                  width: 70,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),

          // Expert cards list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < 3 ? 12 : 0),
                  child: const _ExpertCardSkeleton(),
                );
              }),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

/// Hero section skeleton with title, search bar, and stats.
class _ExpertsHeroSkeleton extends StatelessWidget {
  const _ExpertsHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title row
          Row(
            children: [
              SkeletonLoader(
                height: 48,
                width: 48,
                borderRadius: 14,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 22,
                      width: 180,
                      borderRadius: AppSpacing.radiusMd,
                    ),
                    const SizedBox(height: 6),
                    SkeletonLoader(
                      height: 14,
                      width: 220,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search bar skeleton
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withAlpha(77)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SkeletonLoader(
                  height: 22,
                  width: 22,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(width: 12),
                SkeletonLoader(
                  height: 14,
                  width: 180,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats row (3 items)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoader(
                      height: 28,
                      width: 28,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(
                          height: 14,
                          width: 40,
                          borderRadius: AppSpacing.radiusXs,
                        ),
                        const SizedBox(height: 2),
                        SkeletonLoader(
                          height: 10,
                          width: 50,
                          borderRadius: AppSpacing.radiusXs,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(6, (index) {
          final widths = [50.0, 120.0, 140.0, 100.0, 90.0, 110.0];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SkeletonLoader(
              height: 38,
              width: widths[index],
              borderRadius: 20,
            ),
          );
        }),
      ),
    );
  }
}

/// Featured section skeleton with horizontal scroll cards.
class _FeaturedSectionSkeleton extends StatelessWidget {
  const _FeaturedSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              SkeletonLoader(
                height: 20,
                width: 20,
                borderRadius: AppSpacing.radiusSm,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                height: 16,
                width: 130,
                borderRadius: AppSpacing.radiusSm,
              ),
              const Spacer(),
              SkeletonLoader(
                height: 12,
                width: 50,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
        ),
        // Horizontal cards
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const SizedBox(
              width: 260,
              child: _FeaturedExpertCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Featured expert card skeleton (compact variant).
class _FeaturedExpertCardSkeleton extends StatelessWidget {
  const _FeaturedExpertCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and info row
          Row(
            children: [
              SkeletonLoader.circle(size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 16,
                      width: 100,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      height: 12,
                      width: 80,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Specialty tags
          Row(
            children: [
              SkeletonLoader(
                height: 24,
                width: 70,
                borderRadius: 12,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                height: 24,
                width: 60,
                borderRadius: 12,
              ),
            ],
          ),
          const Spacer(),
          // Rating and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                height: 14,
                width: 60,
                borderRadius: AppSpacing.radiusXs,
              ),
              SkeletonLoader(
                height: 14,
                width: 70,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Book button
          SkeletonLoader(
            height: 40,
            width: double.infinity,
            borderRadius: AppSpacing.radiusMd,
          ),
        ],
      ),
    );
  }
}

/// Expert card skeleton for the list view.
class _ExpertCardSkeleton extends StatelessWidget {
  const _ExpertCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(50)),
      ),
      child: Row(
        children: [
          // Avatar
          SkeletonLoader.circle(size: 56),
          const SizedBox(width: 14),
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                SkeletonLoader(
                  height: 16,
                  width: 120,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 6),
                // Specialization
                SkeletonLoader(
                  height: 12,
                  width: 90,
                  borderRadius: AppSpacing.radiusXs,
                ),
                const SizedBox(height: 10),
                // Rating row
                Row(
                  children: [
                    SkeletonLoader(
                      height: 12,
                      width: 50,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                    const SizedBox(width: 12),
                    SkeletonLoader(
                      height: 12,
                      width: 70,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and button column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoader(
                height: 18,
                width: 60,
                borderRadius: AppSpacing.radiusSm,
              ),
              const SizedBox(height: 8),
              SkeletonLoader(
                height: 32,
                width: 60,
                borderRadius: AppSpacing.radiusSm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

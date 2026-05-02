import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the Dashboard screen.
///
/// Matches the layout of DashboardScreen with:
/// - Greeting section placeholder
/// - Quick stats row (3 cards)
/// - Services grid (2x2)
/// - Recent projects section (horizontal scroll cards)
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Greeting section skeleton
          const _GreetingSkeleton(),

          const SizedBox(height: 16),

          // Quick stats row skeleton (3 cards)
          const _QuickStatsRowSkeleton(),

          const SizedBox(height: 28),

          // Services grid skeleton (2x2)
          const _ServicesGridSkeleton(),

          const SizedBox(height: 28),

          // Recent projects section skeleton
          const _RecentProjectsSkeleton(),

          const SizedBox(height: 28),

          // Campus pulse section skeleton
          const _CampusPulseSkeleton(),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

/// Greeting section skeleton.
class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Good Morning" text
        SkeletonLoader(
          height: 14,
          width: 100,
          borderRadius: AppSpacing.radiusSm,
        ),
        const SizedBox(height: 8),
        // User name
        SkeletonLoader(
          height: 28,
          width: 180,
          borderRadius: AppSpacing.radiusMd,
        ),
      ],
    );
  }
}

/// Quick stats row skeleton (3 stat cards).
class _QuickStatsRowSkeleton extends StatelessWidget {
  const _QuickStatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? 10 : 0,
            ),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(
                    height: 24,
                    width: 50,
                    borderRadius: AppSpacing.radiusSm,
                  ),
                  SkeletonLoader(
                    height: 12,
                    width: 60,
                    borderRadius: AppSpacing.radiusXs,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Services grid skeleton (2x2 grid).
class _ServicesGridSkeleton extends StatelessWidget {
  const _ServicesGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        SkeletonLoader(
          height: 18,
          width: 120,
          borderRadius: AppSpacing.radiusSm,
        ),
        const SizedBox(height: 16),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon placeholder
                  SkeletonLoader(
                    height: 40,
                    width: 40,
                    borderRadius: AppSpacing.radiusMd,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        height: 14,
                        width: 80,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                      const SizedBox(height: 4),
                      SkeletonLoader(
                        height: 10,
                        width: 100,
                        borderRadius: AppSpacing.radiusXs,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Recent projects section skeleton.
class _RecentProjectsSkeleton extends StatelessWidget {
  const _RecentProjectsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonLoader(
              height: 18,
              width: 140,
              borderRadius: AppSpacing.radiusSm,
            ),
            SkeletonLoader(
              height: 14,
              width: 60,
              borderRadius: AppSpacing.radiusXs,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal scroll cards
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    SkeletonLoader(
                      height: 20,
                      width: 70,
                      borderRadius: AppSpacing.radiusMd,
                    ),
                    const SizedBox(height: 12),
                    // Title
                    SkeletonLoader(
                      height: 16,
                      width: 180,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    SkeletonLoader(
                      height: 12,
                      width: 120,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                    const Spacer(),
                    // Progress bar
                    SkeletonLoader(
                      height: 6,
                      width: double.infinity,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Campus pulse section skeleton.
class _CampusPulseSkeleton extends StatelessWidget {
  const _CampusPulseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              SkeletonLoader.circle(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 16,
                      width: 120,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      height: 12,
                      width: 160,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action button
          SkeletonLoader(
            height: 44,
            width: double.infinity,
            borderRadius: AppSpacing.radiusMd,
          ),
        ],
      ),
    );
  }
}

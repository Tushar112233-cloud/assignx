import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the MyProjects screen.
///
/// Matches the layout of MyProjectsScreen with:
/// - Projects overview card with stats
/// - Filter tabs (horizontal scroll)
/// - Search bar
/// - Project cards list (3-4 cards)
class ProjectsSkeleton extends StatelessWidget {
  const ProjectsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projects overview card skeleton
          const _ProjectsOverviewSkeleton(),

          const SizedBox(height: 20),

          // Filter tabs skeleton
          const _FilterTabsSkeleton(),

          const SizedBox(height: 16),

          // Search bar skeleton
          const _SearchBarSkeleton(),

          const SizedBox(height: 20),

          // Project cards list skeleton
          ...List.generate(4, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < 3 ? 12 : 0),
              child: const _ProjectCardSkeleton(),
            );
          }),
        ],
      ),
    );
  }
}

/// Projects overview card skeleton with stats and button.
class _ProjectsOverviewSkeleton extends StatelessWidget {
  const _ProjectsOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon
          Row(
            children: [
              SkeletonLoader(
                height: 36,
                width: 36,
                borderRadius: AppSpacing.radiusMd,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    height: 16,
                    width: 130,
                    borderRadius: AppSpacing.radiusSm,
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    height: 12,
                    width: 180,
                    borderRadius: AppSpacing.radiusXs,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row (4 items)
          Row(
            children: List.generate(7, (index) {
              // Odd indices are dividers
              if (index.isOdd) {
                return Container(
                  height: 30,
                  width: 1,
                  color: AppColors.border,
                );
              }
              return Expanded(
                child: Column(
                  children: [
                    SkeletonLoader(
                      height: 22,
                      width: 30,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      height: 12,
                      width: 40,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // New project button
          SkeletonLoader(
            height: 48,
            width: double.infinity,
            borderRadius: AppSpacing.radiusMd,
          ),
        ],
      ),
    );
  }
}

/// Filter tabs skeleton (horizontal scrollable chips).
class _FilterTabsSkeleton extends StatelessWidget {
  const _FilterTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(4, (index) {
          final widths = [90.0, 100.0, 85.0, 70.0];
          return Padding(
            padding: EdgeInsets.only(right: index < 3 ? 10 : 0),
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

/// Search bar skeleton.
class _SearchBarSkeleton extends StatelessWidget {
  const _SearchBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            width: 120,
            borderRadius: AppSpacing.radiusXs,
          ),
        ],
      ),
    );
  }
}

/// Project card skeleton matching the actual card layout.
class _ProjectCardSkeleton extends StatelessWidget {
  const _ProjectCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon placeholder
          SkeletonLoader(
            height: 44,
            width: 44,
            borderRadius: AppSpacing.radiusMd,
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and badge row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLoader(
                            height: 16,
                            width: 160,
                            borderRadius: AppSpacing.radiusSm,
                          ),
                          const SizedBox(height: 6),
                          SkeletonLoader(
                            height: 12,
                            width: 100,
                            borderRadius: AppSpacing.radiusXs,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SkeletonLoader(
                      height: 24,
                      width: 80,
                      borderRadius: 12,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Project number and type row
                Row(
                  children: [
                    SkeletonLoader(
                      height: 12,
                      width: 70,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoader(
                      height: 12,
                      width: 90,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar placeholder (optional)
                SkeletonLoader(
                  height: 6,
                  width: double.infinity,
                  borderRadius: AppSpacing.radiusXs,
                ),

                const SizedBox(height: 12),

                // Bottom row: time and action button
                Row(
                  children: [
                    SkeletonLoader(
                      height: 12,
                      width: 80,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                    const Spacer(),
                    SkeletonLoader(
                      height: 30,
                      width: 70,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

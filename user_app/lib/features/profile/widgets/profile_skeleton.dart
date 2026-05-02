import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the Profile screen.
///
/// Matches the layout of ProfileScreen with:
/// - Profile card with avatar and info
/// - Stats grid (2x2)
/// - Add money banner
/// - Referral card
/// - Settings list items
class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Profile card skeleton
          const _ProfileCardSkeleton(),

          const SizedBox(height: 16),

          // Stats grid skeleton (2x2)
          const _StatsGridSkeleton(),

          const SizedBox(height: 16),

          // Add money banner skeleton
          const _AddMoneyBannerSkeleton(),

          const SizedBox(height: 16),

          // Referral card skeleton
          const _ReferralCardSkeleton(),

          const SizedBox(height: 24),

          // Settings section skeleton
          const _SettingsSectionSkeleton(),
        ],
      ),
    );
  }
}

/// Profile card skeleton with avatar, name, and edit button.
class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with camera overlay
          Stack(
            children: [
              SkeletonLoader.circle(size: 110),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: SkeletonLoader.circle(size: 28),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name row with badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonLoader(
                height: 20,
                width: 140,
                borderRadius: AppSpacing.radiusMd,
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                height: 24,
                width: 70,
                borderRadius: 16,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Email row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonLoader(
                height: 16,
                width: 16,
                borderRadius: AppSpacing.radiusXs,
              ),
              const SizedBox(width: 6),
              SkeletonLoader(
                height: 14,
                width: 160,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Join date row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonLoader(
                height: 14,
                width: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
              const SizedBox(width: 6),
              SkeletonLoader(
                height: 13,
                width: 120,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Edit Profile button
          SkeletonLoader(
            height: 40,
            width: 130,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}

/// Stats grid skeleton (2x2).
class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat card skeleton.
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with icon and arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                height: 40,
                width: 40,
                borderRadius: 10,
              ),
              SkeletonLoader(
                height: 14,
                width: 14,
                borderRadius: AppSpacing.radiusXs,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value
          SkeletonLoader(
            height: 22,
            width: 70,
            borderRadius: AppSpacing.radiusSm,
          ),
          const SizedBox(height: 4),
          // Label
          SkeletonLoader(
            height: 12,
            width: 60,
            borderRadius: AppSpacing.radiusXs,
          ),
        ],
      ),
    );
  }
}

/// Add money banner skeleton.
class _AddMoneyBannerSkeleton extends StatelessWidget {
  const _AddMoneyBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Plus icon
          SkeletonLoader(
            height: 36,
            width: 36,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 15,
                  width: 140,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  height: 12,
                  width: 120,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),
          // Top Up button
          SkeletonLoader(
            height: 38,
            width: 80,
            borderRadius: 8,
          ),
        ],
      ),
    );
  }
}

/// Referral card skeleton.
class _ReferralCardSkeleton extends StatelessWidget {
  const _ReferralCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              SkeletonLoader(
                height: 40,
                width: 40,
                borderRadius: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 17,
                      width: 100,
                      borderRadius: AppSpacing.radiusSm,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      height: 13,
                      width: 120,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Referral code display
          SkeletonLoader(
            height: 48,
            width: double.infinity,
            borderRadius: 10,
          ),

          const SizedBox(height: 12),

          // Action buttons row
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  height: 44,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SkeletonLoader(
                  height: 44,
                  borderRadius: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Referral stats row
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  height: 48,
                  borderRadius: 10,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  height: 48,
                  borderRadius: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Settings section skeleton.
class _SettingsSectionSkeleton extends StatelessWidget {
  const _SettingsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          SkeletonLoader(
            height: 18,
            width: 80,
            borderRadius: AppSpacing.radiusSm,
          ),
          const SizedBox(height: 12),
          // Settings items
          ...List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < 5 ? 10 : 0),
              child: const _SettingsItemSkeleton(),
            );
          }),
        ],
      ),
    );
  }
}

/// Settings item skeleton.
class _SettingsItemSkeleton extends StatelessWidget {
  const _SettingsItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonLoader.circle(size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 15,
                  width: 140,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  height: 13,
                  width: 100,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),
          SkeletonLoader(
            height: 20,
            width: 20,
            borderRadius: AppSpacing.radiusXs,
          ),
        ],
      ),
    );
  }
}

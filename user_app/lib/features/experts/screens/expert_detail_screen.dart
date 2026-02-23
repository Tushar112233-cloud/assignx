import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Expert detail screen showing full profile information.
///
/// Displays expert's credentials, bio, specializations, reviews,
/// availability preview, and booking button.
class ExpertDetailScreen extends ConsumerWidget {
  /// Expert ID to display.
  final String expertId;

  const ExpertDetailScreen({
    super.key,
    required this.expertId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expertAsync = ref.watch(expertDetailProvider(expertId));
    final reviewsAsync = ref.watch(expertReviewsProvider(expertId));

    return SubtleGradientScaffold(
      body: expertAsync.when(
        data: (expert) {
          if (expert == null) {
            return const Center(child: Text('Expert not found'));
          }

          return CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Share expert profile
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              // Expert header
              SliverToBoxAdapter(
                child: _ExpertHeader(expert: expert),
              ),

              // Stats section
              SliverToBoxAdapter(
                child: _StatsSection(expert: expert),
              ),

              // About section
              SliverToBoxAdapter(
                child: _AboutSection(expert: expert),
              ),

              // Specializations
              SliverToBoxAdapter(
                child: _SpecializationsSection(expert: expert),
              ),

              // Qualifications
              SliverToBoxAdapter(
                child: _QualificationsSection(expert: expert),
              ),

              // Reviews section
              SliverToBoxAdapter(
                child: reviewsAsync.when(
                  data: (reviews) => _ReviewsSection(
                    reviews: reviews,
                    totalReviews: expert.reviewCount,
                    avgRating: expert.rating,
                  ),
                  loading: () => const _ReviewsSectionSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
        loading: () => const _LoadingSkeleton(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load expert details',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(expertDetailProvider(expertId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: expertAsync.whenData(
        (expert) {
          if (expert == null) return const SizedBox.shrink();
          return _BookingBar(expert: expert);
        },
      ).valueOrNull,
    );
  }
}

/// Expert header with avatar and basic info.
class _ExpertHeader extends StatelessWidget {
  final Expert expert;

  const _ExpertHeader({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryLight.withAlpha(50),
                  backgroundImage: expert.avatar != null
                      ? NetworkImage(expert.avatar!)
                      : null,
                  child: expert.avatar == null
                      ? Text(
                          expert.initials,
                          style: AppTextStyles.displaySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
              ),
              if (expert.verified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and designation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  expert.name,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (expert.verified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.verified,
                  size: 22,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            expert.designation,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (expert.institution != null) ...[
            const SizedBox(height: 2),
            Text(
              expert.institution!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),

          // Availability badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getAvailabilityColor(expert.availability).withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getAvailabilityColor(expert.availability).withAlpha(50),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getAvailabilityColor(expert.availability),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  expert.availability.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getAvailabilityColor(expert.availability),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvailabilityColor(ExpertAvailability availability) {
    switch (availability) {
      case ExpertAvailability.available:
        return AppColors.success;
      case ExpertAvailability.busy:
        return AppColors.warning;
      case ExpertAvailability.offline:
        return AppColors.neutralGray;
    }
  }
}

/// Stats section with rating, sessions, experience.
class _StatsSection extends StatelessWidget {
  final Expert expert;

  const _StatsSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        blur: 10,
        opacity: 0.8,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.star,
              value: expert.ratingString,
              label: '${expert.reviewCount} reviews',
              iconColor: AppColors.warning,
            ),
            _StatDivider(),
            _StatItem(
              icon: Icons.video_call,
              value: '${expert.totalSessions}',
              label: 'Sessions',
              iconColor: AppColors.primary,
            ),
            _StatDivider(),
            _StatItem(
              icon: Icons.work_history,
              value: '${expert.experienceYears}+',
              label: 'Years exp.',
              iconColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.border.withAlpha(100),
    );
  }
}

/// About section with bio.
class _AboutSection extends StatelessWidget {
  final Expert expert;

  const _AboutSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    if (expert.bio == null || expert.bio!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            blur: 10,
            opacity: 0.8,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(14),
            child: Text(
              expert.bio!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Specializations section.
class _SpecializationsSection extends StatelessWidget {
  final Expert expert;

  const _SpecializationsSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    if (expert.specializations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specializations',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: expert.specializations.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(40),
                  ),
                ),
                child: Text(
                  spec.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Qualifications section.
class _QualificationsSection extends StatelessWidget {
  final Expert expert;

  const _QualificationsSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    if (expert.qualifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qualifications',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            blur: 10,
            opacity: 0.8,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: expert.qualifications.map((qual) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          qual,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reviews section.
class _ReviewsSection extends StatelessWidget {
  final List<ExpertReview> reviews;
  final int totalReviews;
  final double avgRating;

  const _ReviewsSection({
    required this.reviews,
    required this.totalReviews,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalReviews > reviews.length)
                GestureDetector(
                  onTap: () {
                    // See all reviews
                  },
                  child: Text(
                    'See all ($totalReviews)',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (reviews.isEmpty)
            GlassCard(
              blur: 10,
              opacity: 0.8,
              padding: const EdgeInsets.all(24),
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: Text(
                  'No reviews yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...reviews.take(3).map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewCard(review: review),
                )),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ExpertReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.8,
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight.withAlpha(50),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.warning,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    if (diff < 30) return '${diff ~/ 7}w ago';
    return '${diff ~/ 30}mo ago';
  }
}

/// Reviews section skeleton.
class _ReviewsSectionSkeleton extends StatelessWidget {
  const _ReviewsSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(height: 20, width: 100),
          const SizedBox(height: 12),
          ...List.generate(
            2,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonLoader(height: 80),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom booking bar.
class _BookingBar extends StatelessWidget {
  final Expert expert;

  const _BookingBar({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert.priceString,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'per session',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Material(
                color: AppColors.darkBrown,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.push('/experts/${expert.id}/book'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      'Book Session',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading skeleton.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const SkeletonLoader.circle(size: 100),
          const SizedBox(height: 16),
          const SkeletonLoader(height: 24, width: 200),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 16, width: 150),
          const SizedBox(height: 24),
          const SkeletonLoader(height: 80),
          const SizedBox(height: 24),
          const SkeletonLoader(height: 100),
          const SizedBox(height: 24),
          const SkeletonLoader(height: 60),
        ],
      ),
    );
  }
}

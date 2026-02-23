import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Doctors carousel widget showing medical/health experts.
///
/// Features:
/// - Horizontal scrolling carousel
/// - Filters experts with medical specializations
/// - Card-based display with avatar, name, specialty, rating
/// - Book button on each card
/// - Glassmorphic styling
class DoctorsCarousel extends ConsumerWidget {
  /// Called when an expert card is tapped.
  final void Function(Expert expert)? onExpertTap;

  /// Called when the book button is pressed.
  final void Function(Expert expert)? onBookTap;

  /// Title for the section.
  final String title;

  /// Whether to show the "See All" button.
  final bool showSeeAll;

  /// Called when "See All" is pressed.
  final VoidCallback? onSeeAllTap;

  /// Card height.
  final double cardHeight;

  /// Card width.
  final double cardWidth;

  const DoctorsCarousel({
    super.key,
    this.onExpertTap,
    this.onBookTap,
    this.title = 'Health & Medical Experts',
    this.showSeeAll = true,
    this.onSeeAllTap,
    this.cardHeight = 200,
    this.cardWidth = 170,
  });

  /// Health-related terms to filter experts.
  static const _healthTerms = [
    'medicine',
    'medical',
    'health',
    'doctor',
    'physician',
    'psychiatry',
    'psychology',
    'therapy',
    'counseling',
    'nutrition',
    'fitness',
    'wellness',
    'nursing',
    'pharmacy',
    'dental',
    'physiotherapy',
  ];

  /// Filter experts to only include medical/health experts.
  List<Expert> _filterMedicalExperts(List<Expert> experts) {
    return experts.where((expert) {
      // Check specializations
      for (final spec in expert.specializations) {
        if (spec == ExpertSpecialization.medicine ||
            spec == ExpertSpecialization.careerCounseling) {
          return true;
        }
        final specLabel = spec.label.toLowerCase();
        for (final term in _healthTerms) {
          if (specLabel.contains(term)) {
            return true;
          }
        }
      }

      // Check designation
      final designation = expert.designation.toLowerCase();
      for (final term in _healthTerms) {
        if (designation.contains(term)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expertsAsync = ref.watch(expertsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 18,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (showSeeAll)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Text(
                    'See All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Carousel
        SizedBox(
          height: cardHeight,
          child: expertsAsync.when(
            data: (experts) {
              final medicalExperts = _filterMedicalExperts(experts);

              if (medicalExperts.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: medicalExperts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final expert = medicalExperts[index];
                  return _DoctorCard(
                    expert: expert,
                    width: cardWidth,
                    onTap: () => onExpertTap?.call(expert),
                    onBook: () => onBookTap?.call(expert),
                  );
                },
              );
            },
            loading: () => _buildLoadingSkeleton(),
            error: (_, __) => _buildErrorState(ref),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 40,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No medical experts available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => SkeletonLoader(
        width: cardWidth,
        height: cardHeight,
        borderRadius: 20,
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load experts',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(expertsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Individual doctor card widget.
class _DoctorCard extends StatelessWidget {
  final Expert expert;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onBook;

  const _DoctorCard({
    required this.expert,
    required this.width,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        blur: 12,
        opacity: 0.85,
        elevation: 2,
        padding: const EdgeInsets.all(14),
        borderRadius: BorderRadius.circular(20),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with availability indicator
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.success.withAlpha(30),
                    backgroundImage: expert.avatar != null
                        ? NetworkImage(expert.avatar!)
                        : null,
                    child: expert.avatar == null
                        ? Text(
                            expert.initials,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                ),
                // Availability indicator
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getAvailabilityColor(),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    expert.name,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (expert.verified) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.verified,
                    size: 14,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),

            // Specialty
            Text(
              expert.primarySpecialization ?? expert.designation,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Rating
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    expert.ratingString,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  if (expert.reviewCount > 0) ...[
                    Text(
                      ' (${expert.reviewCount})',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),

            // Book button
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onBook,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    child: Text(
                      'Book',
                      style: AppTextStyles.labelSmall.copyWith(
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

  Color _getAvailabilityColor() {
    switch (expert.availability) {
      case ExpertAvailability.available:
        return AppColors.success;
      case ExpertAvailability.busy:
        return AppColors.warning;
      case ExpertAvailability.offline:
        return AppColors.neutralGray;
    }
  }
}

/// Compact version for smaller displays.
class DoctorsCarouselCompact extends ConsumerWidget {
  final void Function(Expert expert)? onExpertTap;
  final void Function(Expert expert)? onBookTap;

  const DoctorsCarouselCompact({
    super.key,
    this.onExpertTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DoctorsCarousel(
      onExpertTap: onExpertTap,
      onBookTap: onBookTap,
      cardHeight: 180,
      cardWidth: 150,
      showSeeAll: false,
    );
  }
}

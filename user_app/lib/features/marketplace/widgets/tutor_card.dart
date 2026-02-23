import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/tutor_model.dart';

/// Card widget displaying tutor information in a compact format.
///
/// Shows tutor photo, name, expertise, rating, and hourly rate.
/// Includes a quick "Book" button and tap action for profile view.
class TutorCard extends StatelessWidget {
  /// The tutor data to display.
  final Tutor tutor;

  /// Callback when the card is tapped (opens profile).
  final VoidCallback? onTap;

  /// Callback when the Book button is pressed.
  final VoidCallback? onBook;

  const TutorCard({
    super.key,
    required this.tutor,
    this.onTap,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar and info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutor avatar
                  _buildAvatar(),
                  const SizedBox(width: AppSpacing.sm),

                  // Tutor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name with verified badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tutor.name,
                                style: AppTextStyles.labelLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tutor.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.info,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Primary subject
                        if (tutor.primarySubject != null)
                          Text(
                            tutor.primarySubject!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 4),

                        // Rating and reviews
                        _buildRatingRow(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subjects chips
              if (tutor.subjects.isNotEmpty) ...[
                _buildSubjectChips(),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Bottom row: Price and Book button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rate
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor.hourlyRateString,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (tutor.sessionsCompleted > 0)
                        Text(
                          '${tutor.sessionsCompleted} sessions',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),

                  // Book button
                  ElevatedButton(
                    onPressed: tutor.isAvailable ? onBook : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      tutor.isAvailable ? 'Book' : 'Unavailable',
                      style: AppTextStyles.buttonSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the tutor avatar with online indicator.
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
            child: tutor.avatar != null
                ? CachedNetworkImage(
                    imageUrl: tutor.avatar!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.shimmerBase,
                      child: Center(
                        child: Text(
                          tutor.initials,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildAvatarFallback(),
                  )
                : _buildAvatarFallback(),
          ),
        ),
        // Online indicator
        if (tutor.isAvailable)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build avatar fallback with initials.
  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.primaryLight.withAlpha(50),
      child: Center(
        child: Text(
          tutor.initials,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// Build rating row with stars.
  Widget _buildRatingRow() {
    return Row(
      children: [
        // Star icon
        const Icon(
          Icons.star,
          size: 14,
          color: AppColors.warning,
        ),
        const SizedBox(width: 2),
        // Rating value
        Text(
          tutor.ratingString,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // Review count
        if (tutor.hasReviews) ...[
          const SizedBox(width: 4),
          Text(
            '(${tutor.reviewCount})',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  /// Build subject chips row.
  Widget _buildSubjectChips() {
    // Show max 3 subjects
    final displaySubjects = tutor.subjects.take(3).toList();
    final remaining = tutor.subjects.length - 3;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...displaySubjects.map((subject) => _buildChip(subject)),
        if (remaining > 0) _buildChip('+$remaining', isMore: true),
      ],
    );
  }

  /// Build individual subject chip.
  Widget _buildChip(String label, {bool isMore = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isMore ? AppColors.surfaceVariant : AppColors.primaryLight.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: isMore ? AppColors.textSecondary : AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Horizontal compact tutor card for list views.
class CompactTutorCard extends StatelessWidget {
  final Tutor tutor;
  final VoidCallback? onTap;

  const CompactTutorCard({
    super.key,
    required this.tutor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                color: AppColors.primaryLight.withAlpha(50),
              ),
              child: tutor.avatar != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      child: CachedNetworkImage(
                        imageUrl: tutor.avatar!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        tutor.initials,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tutor.name,
                          style: AppTextStyles.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tutor.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: AppColors.info,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        tutor.ratingString,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      Text(
                        tutor.hourlyRateString,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

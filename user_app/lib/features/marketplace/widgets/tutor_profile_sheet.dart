import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/tutor_model.dart';

/// Bottom sheet displaying detailed tutor profile information.
///
/// Shows full bio, qualifications, subjects, reviews, and booking option.
class TutorProfileSheet extends StatelessWidget {
  /// The tutor to display.
  final Tutor tutor;

  /// Callback when the Book Session button is pressed.
  final VoidCallback? onBookSession;

  /// Callback when the Ask Question button is pressed.
  final VoidCallback? onAskQuestion;

  const TutorProfileSheet({
    super.key,
    required this.tutor,
    this.onBookSession,
    this.onAskQuestion,
  });

  /// Show the tutor profile sheet as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Tutor tutor,
    VoidCallback? onBookSession,
    VoidCallback? onAskQuestion,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TutorProfileSheet(
        tutor: tutor,
        onBookSession: onBookSession,
        onAskQuestion: onAskQuestion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              _buildDragHandle(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with avatar and basic info
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.lg),

                      // Stats row
                      _buildStatsRow(),
                      const SizedBox(height: AppSpacing.lg),

                      // Bio section
                      if (tutor.bio != null && tutor.bio!.isNotEmpty) ...[
                        _buildSection(
                          title: 'About',
                          child: Text(
                            tutor.bio!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Subjects section
                      if (tutor.subjects.isNotEmpty) ...[
                        _buildSection(
                          title: 'Subjects',
                          child: _buildSubjectsList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Qualifications section
                      if (tutor.qualifications.isNotEmpty) ...[
                        _buildSection(
                          title: 'Qualifications',
                          child: _buildQualificationsList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Availability info
                      _buildAvailabilitySection(),
                      const SizedBox(height: AppSpacing.lg),

                      // Reviews placeholder
                      _buildSection(
                        title: 'Reviews',
                        trailing: tutor.hasReviews
                            ? TextButton(
                                onPressed: () {
                                  // TODO: Navigate to all reviews
                                },
                                child: const Text('See all'),
                              )
                            : null,
                        child: tutor.hasReviews
                            ? _buildReviewsPreview()
                            : Text(
                                'No reviews yet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                      ),

                      // Bottom spacing for fixed buttons
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Fixed bottom buttons
              _buildBottomButtons(context),
            ],
          ),
        );
      },
    );
  }

  /// Build the drag handle indicator.
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Build the header section with avatar and basic info.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
              child: tutor.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: tutor.avatar!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.primaryLight.withAlpha(50),
                      child: Center(
                        child: Text(
                          tutor.initials,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info column
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
                        style: AppTextStyles.headingSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tutor.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.info,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // University
                if (tutor.university != null)
                  Text(
                    tutor.university!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                const SizedBox(height: 8),

                // Rating row
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tutor.ratingString,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tutor.hasReviews) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${tutor.reviewCount} reviews)',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Rate
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    tutor.hourlyRateString,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the stats row.
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: '${tutor.sessionsCompleted}',
            label: 'Sessions',
            icon: Icons.event_available,
          ),
          _buildDivider(),
          _buildStatItem(
            value: tutor.ratingString,
            label: 'Rating',
            icon: Icons.star,
          ),
          _buildDivider(),
          _buildStatItem(
            value: tutor.responseTimeString ?? 'Quick',
            label: 'Response',
            icon: Icons.schedule,
            isSmallText: true,
          ),
        ],
      ),
    );
  }

  /// Build individual stat item.
  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    bool isSmallText = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: isSmallText
              ? AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600)
              : AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  /// Build vertical divider for stats.
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border,
    );
  }

  /// Build section with title.
  Widget _buildSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  /// Build subjects list with chips.
  Widget _buildSubjectsList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tutor.subjects.map((subject) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withAlpha(30),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: AppColors.primary.withAlpha(30),
            ),
          ),
          child: Text(
            subject,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build qualifications list.
  Widget _buildQualificationsList() {
    return Column(
      children: tutor.qualifications.map((qualification) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  qualification,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build availability section.
  Widget _buildAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tutor.isAvailable
            ? AppColors.successLight
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: tutor.isAvailable
              ? AppColors.success.withAlpha(50)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            tutor.isAvailable ? Icons.check_circle : Icons.schedule,
            size: 20,
            color: tutor.isAvailable ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tutor.isAvailable
                      ? 'Available for sessions'
                      : 'Currently unavailable',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: tutor.isAvailable
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                if (tutor.responseTimeString != null)
                  Text(
                    tutor.responseTimeString!,
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build reviews preview.
  Widget _buildReviewsPreview() {
    // Placeholder for reviews - would be populated from actual data
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withAlpha(50),
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student', style: AppTextStyles.labelSmall),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 5 ? Icons.star : Icons.star_border,
                          size: 12,
                          color: AppColors.warning,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Great tutor! Very helpful and explains concepts clearly.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the fixed bottom buttons.
  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Ask Question button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAskQuestion,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Ask Question'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Book Session button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: tutor.isAvailable ? onBookSession : null,
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  tutor.isAvailable ? 'Book Session' : 'Unavailable',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rating Breakdown widget for displaying detailed rating metrics.
///
/// Shows overall rating with breakdown by category (Quality, Timeliness,
/// Communication) with progress bars and review counts.
///
/// ## Features
/// - Overall rating with star display
/// - Category-wise breakdown (Quality, Timeliness, Communication)
/// - Progress bars for each category
/// - Total reviews count
/// - Rating distribution chart
///
/// ## Usage
/// ```dart
/// RatingBreakdown(
///   overallRating: 4.5,
///   qualityRating: 4.7,
///   timelinessRating: 4.3,
///   communicationRating: 4.5,
///   totalReviews: 42,
/// )
/// ```
///
/// See also:
/// - [ProfileScreen] for profile display
/// - [ReviewsScreen] for detailed reviews
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';

/// Rating category model.
class RatingCategory {
  /// Category name.
  final String name;

  /// Category icon.
  final IconData icon;

  /// Rating value (0-5).
  final double rating;

  /// Category color.
  final Color color;

  const RatingCategory({
    required this.name,
    required this.icon,
    required this.rating,
    required this.color,
  });
}

/// Rating distribution data.
class RatingDistribution {
  /// 5-star count.
  final int fiveStar;

  /// 4-star count.
  final int fourStar;

  /// 3-star count.
  final int threeStar;

  /// 2-star count.
  final int twoStar;

  /// 1-star count.
  final int oneStar;

  const RatingDistribution({
    this.fiveStar = 0,
    this.fourStar = 0,
    this.threeStar = 0,
    this.twoStar = 0,
    this.oneStar = 0,
  });

  /// Total number of reviews.
  int get total => fiveStar + fourStar + threeStar + twoStar + oneStar;

  /// Get count for a specific star rating.
  int getCount(int stars) {
    switch (stars) {
      case 5:
        return fiveStar;
      case 4:
        return fourStar;
      case 3:
        return threeStar;
      case 2:
        return twoStar;
      case 1:
        return oneStar;
      default:
        return 0;
    }
  }

  /// Get percentage for a specific star rating.
  double getPercentage(int stars) {
    if (total == 0) return 0;
    return getCount(stars) / total;
  }
}

/// Rating Breakdown widget.
class RatingBreakdown extends StatelessWidget {
  /// Overall rating (0-5).
  final double overallRating;

  /// Quality rating (0-5).
  final double qualityRating;

  /// Timeliness rating (0-5).
  final double timelinessRating;

  /// Communication rating (0-5).
  final double communicationRating;

  /// Total number of reviews.
  final int totalReviews;

  /// Rating distribution data.
  final RatingDistribution? distribution;

  const RatingBreakdown({
    super.key,
    required this.overallRating,
    required this.qualityRating,
    required this.timelinessRating,
    required this.communicationRating,
    required this.totalReviews,
    this.distribution,
  });

  /// Gets the rating categories.
  List<RatingCategory> get _categories => [
        RatingCategory(
          name: 'Quality',
          icon: Icons.workspace_premium,
          rating: qualityRating,
          color: AppColors.success,
        ),
        RatingCategory(
          name: 'Timeliness',
          icon: Icons.schedule,
          rating: timelinessRating,
          color: AppColors.info,
        ),
        RatingCategory(
          name: 'Communication',
          icon: Icons.chat,
          rating: communicationRating,
          color: AppColors.accent,
        ),
      ];

  /// Returns the provided distribution or an empty one with all zeros.
  RatingDistribution get _distribution =>
      distribution ?? const RatingDistribution();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.star_rate,
                  size: 20,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  'Rating Breakdown'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Overall rating section
            _buildOverallRating(context),

            const SizedBox(height: AppSpacing.lg),

            // Divider
            const Divider(),

            const SizedBox(height: AppSpacing.md),

            // Category breakdown
            Text(
              'By Category'.tr(context),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            ..._categories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildCategoryRow(category),
                )),

            const SizedBox(height: AppSpacing.sm),

            // Rating distribution
            const Divider(),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Rating Distribution'.tr(context),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _buildDistribution(),
          ],
        ),
      ),
    );
  }

  /// Builds the overall rating section.
  Widget _buildOverallRating(BuildContext context) {
    return Row(
      children: [
        // Large rating number
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  overallRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/5',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Star row
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                if (overallRating >= starValue) {
                  return const Icon(
                    Icons.star,
                    size: 20,
                    color: AppColors.warning,
                  );
                } else if (overallRating >= starValue - 0.5) {
                  return const Icon(
                    Icons.star_half,
                    size: 20,
                    color: AppColors.warning,
                  );
                } else {
                  return const Icon(
                    Icons.star_border,
                    size: 20,
                    color: AppColors.warning,
                  );
                }
              }),
            ),
          ],
        ),

        const Spacer(),

        // Review count
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                totalReviews.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Reviews'.tr(context),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a category rating row.
  Widget _buildCategoryRow(RatingCategory category) {
    return Row(
      children: [
        // Icon
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.icon,
            size: 18,
            color: category.color,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Name and progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: category.color,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        category.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: category.rating / 5,
                  backgroundColor: category.color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the rating distribution section.
  Widget _buildDistribution() {
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final percentage = _distribution.getPercentage(stars);
        final count = _distribution.getCount(stars);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Star count
              SizedBox(
                width: 20,
                child: Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons.star,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getDistributionColor(stars),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Count
              SizedBox(
                width: 30,
                child: Text(
                  count.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Gets color for distribution bar based on star rating.
  Color _getDistributionColor(int stars) {
    switch (stars) {
      case 5:
        return AppColors.success;
      case 4:
        return const Color(0xFF8BC34A);
      case 3:
        return AppColors.warning;
      case 2:
        return const Color(0xFFFF9800);
      case 1:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

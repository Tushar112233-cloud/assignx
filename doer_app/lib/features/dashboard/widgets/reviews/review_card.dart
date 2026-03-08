import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';

/// Reusable review card showing reviewer info, ratings, and review text.
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isFeatured;
  final int animationIndex;

  const ReviewCard({
    super.key,
    required this.review,
    this.isFeatured = false,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: isFeatured
            ? Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1.5,
              )
            : Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: isFeatured ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar, name, date, overall rating
            Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(review.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingBadge(review.rating),
              ],
            ),

            // Project title
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      review.projectTitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Star row
            const SizedBox(height: AppSpacing.sm),
            _buildStarRow(review.rating),

            // Category ratings if available
            if (_hasCategoryRatings) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildCategoryRatings(),
            ],

            // Review text
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                review.comment!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                maxLines: isFeatured ? 6 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 50 * animationIndex),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: 50 * animationIndex),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  bool get _hasCategoryRatings =>
      review.qualityRating != null ||
      review.timelinessRating != null ||
      review.communicationRating != null;

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: isFeatured ? 22 : 18,
      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
      backgroundImage: review.reviewerAvatarUrl != null
          ? NetworkImage(review.reviewerAvatarUrl!)
          : null,
      child: review.reviewerAvatarUrl == null
          ? Text(
              review.reviewerName.isNotEmpty
                  ? review.reviewerName[0].toUpperCase()
                  : 'A',
              style: TextStyle(
                fontSize: isFeatured ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            )
          : null,
    );
  }

  Widget _buildRatingBadge(double rating) {
    final color = _getRatingColor(rating);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16, color: color),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star_rounded,
              color: AppColors.warning, size: 16);
        } else if (index < rating.ceil() && rating % 1 != 0) {
          return const Icon(Icons.star_half_rounded,
              color: AppColors.warning, size: 16);
        } else {
          return Icon(Icons.star_outline_rounded,
              color: AppColors.border, size: 16);
        }
      }),
    );
  }

  Widget _buildCategoryRatings() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 4,
      children: [
        if (review.qualityRating != null)
          _buildCategoryChip('Quality', review.qualityRating!,
              const Color(0xFF22C55E)),
        if (review.timelinessRating != null)
          _buildCategoryChip('Timeliness', review.timelinessRating!,
              AppColors.accent),
        if (review.communicationRating != null)
          _buildCategoryChip('Communication', review.communicationRating!,
              const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildCategoryChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '$label ${value.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF22C55E);
    if (rating >= 3.5) return AppColors.warning;
    if (rating >= 2.5) return const Color(0xFFF97316);
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}

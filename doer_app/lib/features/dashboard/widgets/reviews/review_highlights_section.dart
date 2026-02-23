import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';
import 'review_card.dart';

/// Bento-grid highlights section showing featured and recent reviews.
class ReviewHighlightsSection extends StatelessWidget {
  final List<ReviewModel> reviews;

  const ReviewHighlightsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    // Featured = highest rated review
    final sorted = List<ReviewModel>.from(reviews)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final featured = sorted.first;

    // Recent = most recent reviews excluding the featured one
    final recent = reviews.where((r) => r.id != featured.id).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 18, color: AppColors.warning),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Highlights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // Bento grid
        LayoutBuilder(
          builder: (context, constraints) {
            // Single column on narrow screens
            if (constraints.maxWidth < 400) {
              return Column(
                children: [
                  ReviewCard(
                      review: featured, isFeatured: true, animationIndex: 0),
                  ...recent.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: ReviewCard(
                          review: entry.value,
                          animationIndex: entry.key + 1,
                        ),
                      )),
                ],
              );
            }

            // Two-column bento layout
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: Featured (larger)
                  Expanded(
                    flex: 1,
                    child: ReviewCard(
                      review: featured,
                      isFeatured: true,
                      animationIndex: 0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Right: Recent cards stacked
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: recent.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: entry.key > 0 ? AppSpacing.sm : 0),
                          child: ReviewCard(
                            review: entry.value,
                            animationIndex: entry.key + 1,
                          ),
                        );
                      }).toList(),
                    ),
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

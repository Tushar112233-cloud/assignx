import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';

/// Analytics dashboard showing rating distribution and category performance.
class RatingAnalyticsDashboard extends StatelessWidget {
  final List<ReviewModel> reviews;

  const RatingAnalyticsDashboard({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5A7CFF).withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Icon(Icons.analytics_outlined,
                    size: 18, color: Color(0xFF5A7CFF)),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Rating Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Rating distribution (35%)
              Expanded(
                flex: 35,
                child: _buildRatingDistribution(),
              ),

              const SizedBox(width: AppSpacing.md),

              // Right: Category performance (65%)
              Expanded(
                flex: 65,
                child: _buildCategoryPerformance(),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.05, end: 0, duration: 500.ms);
  }

  Widget _buildRatingDistribution() {
    final distribution = _getDistribution();
    final maxCount =
        distribution.values.fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (int star = 5; star >= 1; star--)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _buildDistributionBar(
              star,
              distribution[star] ?? 0,
              maxCount,
            ),
          ),
      ],
    );
  }

  Widget _buildDistributionBar(int star, int count, int maxCount) {
    final fraction = maxCount > 0 ? count / maxCount : 0.0;
    final color = _getStarColor(star);

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            '$star',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ),
        const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
        const SizedBox(width: 4),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                height: 8,
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 18,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPerformance() {
    final qualityAvg = _averageCategory((r) => r.qualityRating);
    final timelinessAvg = _averageCategory((r) => r.timelinessRating);
    final communicationAvg = _averageCategory((r) => r.communicationRating);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Performance',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryBar(
          'Quality',
          qualityAvg,
          const Color(0xFF22C55E),
          Icons.workspace_premium_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryBar(
          'Timeliness',
          timelinessAvg,
          const Color(0xFF3B82F6),
          Icons.schedule_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildCategoryBar(
          'Communication',
          communicationAvg,
          const Color(0xFF8B5CF6),
          Icons.chat_bubble_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildCategoryBar(
      String label, double value, Color color, IconData icon) {
    final fraction = value / 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary),
            ),
            const Spacer(),
            Text(
              value > 0 ? value.toStringAsFixed(1) : 'N/A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: value > 0 ? color : AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.6),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<int, int> _getDistribution() {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      final star = review.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }
    return dist;
  }

  double _averageCategory(double? Function(ReviewModel) selector) {
    final values = reviews
        .map(selector)
        .where((v) => v != null)
        .cast<double>()
        .toList();
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Color _getStarColor(int star) {
    switch (star) {
      case 5:
        return const Color(0xFF22C55E);
      case 4:
        return const Color(0xFF84CC16);
      case 3:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFF97316);
      case 1:
        return const Color(0xFFEF4444);
      default:
        return AppColors.textTertiary;
    }
  }
}

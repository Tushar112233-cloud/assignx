import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';

/// Hero banner for reviews screen with overall rating, total reviews,
/// 5-star percentage, and trending indicator.
class ReviewsHeroBanner extends StatelessWidget {
  final DoerStats stats;
  final List<ReviewModel> reviews;

  const ReviewsHeroBanner({
    super.key,
    required this.stats,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    final fiveStarCount =
        reviews.where((r) => r.rating >= 4.5).length;
    final fiveStarPercent =
        reviews.isNotEmpty ? (fiveStarCount / reviews.length * 100) : 0.0;

    // Determine trend from recent reviews (last 5 vs previous 5)
    final trending = _calculateTrend();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A7CFF), Color(0xFF49C5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A7CFF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusXl,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: rating and stats
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large rating display
                      _buildGlassCard(
                        child: Column(
                          children: [
                            Text(
                              stats.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildStars(stats.rating),
                            const SizedBox(height: 4),
                            Text(
                              '${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(width: AppSpacing.md),

                      // Right side stats
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatRow(
                              icon: Icons.star_rounded,
                              label: '5-Star',
                              value: '${fiveStarPercent.toStringAsFixed(0)}%',
                              iconColor: const Color(0xFFFFD700),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildStatRow(
                              icon: trending >= 0
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              label: 'Trend',
                              value: trending >= 0
                                  ? '+${trending.toStringAsFixed(1)}'
                                  : trending.toStringAsFixed(1),
                              iconColor: trending >= 0
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFFF87171),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildStatRow(
                              icon: Icons.verified_rounded,
                              label: 'Success',
                              value:
                                  '${stats.onTimeDeliveryRate > 1 ? stats.onTimeDeliveryRate.toStringAsFixed(0) : (stats.onTimeDeliveryRate * 100).toStringAsFixed(0)}%',
                              iconColor: const Color(0xFF4ADE80),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideX(begin: 0.1, end: 0, duration: 400.ms),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // CTA buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildCTAButton(
                          icon: Icons.rate_review_outlined,
                          label: 'Request Reviews',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildCTAButton(
                          icon: Icons.insights_rounded,
                          label: 'View Insights',
                          onTap: () {},
                          filled: true,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.15, end: 0, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16);
        } else if (index < rating.ceil() && rating % 1 != 0) {
          return const Icon(Icons.star_half_rounded,
              color: Color(0xFFFFD700), size: 16);
        }
        return Icon(Icons.star_outline_rounded,
            color: Colors.white.withValues(alpha: 0.4), size: 16);
      }),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusMd,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: filled
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTrend() {
    if (reviews.length < 2) return 0;
    final recent = reviews.take(5).toList();
    final older = reviews.skip(5).take(5).toList();
    if (older.isEmpty) return 0;

    final recentAvg =
        recent.map((r) => r.rating).reduce((a, b) => a + b) / recent.length;
    final olderAvg =
        older.map((r) => r.rating).reduce((a, b) => a + b) / older.length;
    return recentAvg - olderAvg;
  }
}

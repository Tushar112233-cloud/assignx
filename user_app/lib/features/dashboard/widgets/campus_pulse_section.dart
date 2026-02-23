import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Campus Pulse section for dashboard preview.
///
/// Shows a preview of campus marketplace/community with
/// a call-to-action to explore the full marketplace.
/// Matches web dashboard's CampusPulse component.
///
/// Example:
/// ```dart
/// CampusPulseSection(
///   onExploreMarketplace: () => context.go('/connect'),
/// )
/// ```
class CampusPulseSection extends StatelessWidget {
  /// Callback when "Explore" is tapped.
  final VoidCallback? onExploreMarketplace;

  const CampusPulseSection({
    super.key,
    this.onExploreMarketplace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Pulse',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Trending at your campus',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // See all button
              GestureDetector(
                onTap: onExploreMarketplace,
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Preview card
          _CampusPulsePreviewCard(
            onExplore: onExploreMarketplace,
          ),
        ],
      ),
    );
  }
}

/// Preview card showing campus marketplace categories.
class _CampusPulsePreviewCard extends StatelessWidget {
  final VoidCallback? onExplore;

  const _CampusPulsePreviewCard({
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onExplore,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category pills row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryPill(
                        icon: Icons.inventory_2_outlined,
                        label: 'For Sale',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        icon: Icons.home_outlined,
                        label: 'Housing',
                        color: const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        icon: Icons.work_outline,
                        label: 'Opportunities',
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        icon: Icons.people_outline,
                        label: 'Community',
                        color: const Color(0xFFB45309),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // CTA row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Campus Connect',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Buy, sell, and discover at your campus',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Category pill for campus pulse preview.
class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

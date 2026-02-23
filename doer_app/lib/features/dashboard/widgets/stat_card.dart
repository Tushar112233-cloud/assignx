/// Statistics display widgets for dashboards and profiles.
///
/// This file provides various components for displaying numeric statistics,
/// ratings, and scorecard grids throughout the application.
///
/// ## Features
/// - Stat card with icon and value display
/// - Compact stat row for inline display
/// - Scorecard grid for profile stats
/// - Rating display with star icons
///
/// ## Example
/// ```dart
/// StatCard(
///   icon: Icons.assignment,
///   title: 'Active Projects',
///   value: '5',
///   color: AppColors.info,
///   onTap: () => viewProjects(),
/// )
/// ```
///
/// See also:
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A card widget for displaying statistics with an icon.
///
/// Shows a metric value prominently with a colored icon indicator.
/// Supports optional subtitle and tap interaction.
///
/// ## Usage
/// ```dart
/// StatCard(
///   icon: Icons.assignment,
///   title: 'Active Projects',
///   value: '5',
///   color: AppColors.info,
///   subtitle: 'This month',
///   onTap: () => viewProjects(),
/// )
/// ```
///
/// ## Layout
/// - Top: Icon in colored container, optional chevron for tappable cards
/// - Center: Large value text
/// - Bottom: Title and optional subtitle
///
/// See also:
/// - [StatRow] for inline stat display
/// - [ScorecardGrid] for multiple stats
class StatCard extends StatelessWidget {
  /// Creates a stat card with the specified properties.
  ///
  /// [title], [value], and [icon] are required.
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  /// The label describing the statistic.
  final String title;

  /// The main value to display prominently.
  final String value;

  /// The icon displayed in a colored container.
  final IconData icon;

  /// The theme color for the icon and value.
  ///
  /// Defaults to [AppColors.primary].
  final Color? color;

  /// Optional subtitle below the title.
  final String? subtitle;

  /// Callback invoked when the card is tapped.
  ///
  /// When provided, shows a chevron indicator.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: cardColor,
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact inline stat display widget.
///
/// Shows a label and value in a horizontal row format,
/// suitable for use within cards or lists.
///
/// ## Usage
/// ```dart
/// StatRow(
///   label: 'Total Earnings',
///   value: 'Rs25,000',
///   icon: Icons.currency_rupee,
///   valueColor: AppColors.success,
/// )
/// ```
///
/// See also:
/// - [StatCard] for card-based stats
class StatRow extends StatelessWidget {
  /// Creates a stat row with the specified properties.
  ///
  /// [label] and [value] are required.
  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  /// The label describing the statistic.
  final String label;

  /// The value to display.
  final String value;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Color for the value text.
  ///
  /// Defaults to [AppColors.textPrimary].
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// A grid of score items for profile display.
///
/// Shows multiple statistics in a 2-column grid format,
/// commonly used for user profile scorecards.
///
/// ## Usage
/// ```dart
/// ScorecardGrid(
///   activeProjects: 3,
///   completedProjects: 25,
///   totalEarnings: 'Rs50K',
///   rating: 4.8,
///   successRate: 95.0,
///   onTimeRate: 92.0,
/// )
/// ```
///
/// ## Grid Items
/// - Active projects (blue)
/// - Completed projects (green)
/// - Total earnings (accent)
/// - Average rating (yellow)
/// - Success rate (optional, green)
/// - On-time rate (optional, primary)
///
/// See also:
/// - [StatCard] for individual stat cards
class ScorecardGrid extends StatelessWidget {
  /// Creates a scorecard grid with the specified statistics.
  ///
  /// Required stats: [activeProjects], [completedProjects],
  /// [totalEarnings], [rating].
  const ScorecardGrid({
    super.key,
    required this.activeProjects,
    required this.completedProjects,
    required this.totalEarnings,
    required this.rating,
    this.successRate,
    this.onTimeRate,
  });

  /// Number of currently active projects.
  final int activeProjects;

  /// Total number of completed projects.
  final int completedProjects;

  /// Total earnings as a formatted string.
  final String totalEarnings;

  /// Average rating (0-5 scale).
  final double rating;

  /// Optional success rate percentage.
  final double? successRate;

  /// Optional on-time delivery rate percentage.
  final double? onTimeRate;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: [
        _buildScoreItem(
          icon: Icons.assignment,
          value: activeProjects.toString(),
          label: 'Active',
          color: AppColors.info,
        ),
        _buildScoreItem(
          icon: Icons.check_circle,
          value: completedProjects.toString(),
          label: 'Completed',
          color: AppColors.success,
        ),
        _buildScoreItem(
          icon: Icons.currency_rupee,
          value: totalEarnings,
          label: 'Earnings',
          color: AppColors.accent,
        ),
        _buildScoreItem(
          icon: Icons.star,
          value: rating.toStringAsFixed(1),
          label: 'Rating',
          color: AppColors.warning,
        ),
        if (successRate != null)
          _buildScoreItem(
            icon: Icons.trending_up,
            value: '${successRate!.toStringAsFixed(1)}%',
            label: 'Success Rate',
            color: AppColors.success,
          ),
        if (onTimeRate != null)
          _buildScoreItem(
            icon: Icons.schedule,
            value: '${onTimeRate!.toStringAsFixed(1)}%',
            label: 'On-Time',
            color: AppColors.primary,
          ),
      ],
    );
  }

  /// Builds a single score item widget.
  Widget _buildScoreItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A star-based rating display widget.
///
/// Shows a rating value with optional star icons and review count.
/// Supports half-star ratings for fractional values.
///
/// ## Usage
/// ```dart
/// RatingDisplay(
///   rating: 4.5,
///   reviewCount: 28,
///   showStars: true,
///   size: 16,
/// )
/// ```
///
/// ## Star Display
/// - Full stars for whole rating values
/// - Half star for fractional values
/// - Empty stars for remaining positions
class RatingDisplay extends StatelessWidget {
  /// Creates a rating display with the specified properties.
  ///
  /// [rating] is required.
  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.showStars = true,
    this.size = 16,
  });

  /// The rating value (0-5 scale).
  final double rating;

  /// Optional number of reviews.
  final int? reviewCount;

  /// Whether to display star icons.
  ///
  /// Defaults to true.
  final bool showStars;

  /// The size of the star icons and text.
  ///
  /// Defaults to 16.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStars) ...[
          ...List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Icons.star, color: AppColors.warning, size: size);
            } else if (index < rating.ceil() && rating % 1 != 0) {
              return Icon(Icons.star_half, color: AppColors.warning, size: size);
            } else {
              return Icon(Icons.star_border, color: AppColors.border, size: size);
            }
          }),
          const SizedBox(width: 4),
        ],
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 2,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size - 4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

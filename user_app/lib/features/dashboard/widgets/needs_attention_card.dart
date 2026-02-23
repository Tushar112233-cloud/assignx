import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/widgets/glass_container.dart';

/// Card widget for projects that need attention.
///
/// Displays project title, status badge, and chevron indicator.
/// Used in horizontal scrolling lists for quick access to actionable projects.
///
/// Example:
/// ```dart
/// NeedsAttentionCard(
///   project: myProject,
///   onTap: () => context.push('/projects/${project.id}'),
///   animationDelay: Duration(milliseconds: 100),
/// )
/// ```
class NeedsAttentionCard extends StatelessWidget {
  /// Project data to display.
  final Project project;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Card width. Defaults to 260.
  final double width;

  /// Card height. Defaults to 90.
  final double height;

  /// Animation delay for staggered entrance.
  final Duration? animationDelay;

  const NeedsAttentionCard({
    super.key,
    required this.project,
    this.onTap,
    this.width = 260,
    this.height = 90,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = GlassCard(
      width: width,
      height: height,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: project.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              project.status.icon,
              color: project.status.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Project title
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: project.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.status.displayName,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: project.status.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chevron indicator
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );

    // Apply animation if delay is provided
    if (animationDelay != null) {
      card = card.fadeInSlideUp(
        delay: animationDelay!,
        duration: const Duration(milliseconds: 300),
      );
    }

    return card;
  }
}

/// Needs attention section widget per design spec.
///
/// Displays "NEEDS ATTENTION" header with count badge and vertical list of items.
/// Each item shows: colored dot, title, subtitle, and chevron arrow.
///
/// Example:
/// ```dart
/// NeedsAttentionSection(
///   projects: needsAttentionProjects,
///   onProjectTap: (project) => handleProjectTap(project),
/// )
/// ```
class NeedsAttentionSection extends StatelessWidget {
  /// List of projects requiring attention.
  final List<Project> projects;

  /// Callback when a project card is tapped.
  final void Function(Project project)? onProjectTap;

  const NeedsAttentionSection({
    super.key,
    required this.projects,
    this.onProjectTap,
  });

  /// Returns subtitle text based on project status.
  String _getSubtitle(Project project) {
    switch (project.status) {
      case ProjectStatus.paymentPending:
        return 'Payment Due';
      case ProjectStatus.delivered:
        return 'Delivered';
      case ProjectStatus.quoted:
        return 'Quote Ready';
      default:
        return project.status.displayName;
    }
  }

  /// Returns dot color based on project status.
  Color _getDotColor(Project project) {
    switch (project.status) {
      case ProjectStatus.paymentPending:
        return AppColors.statusPink; // Pink/Mauve
      case ProjectStatus.delivered:
        return AppColors.textPrimary; // Dark/Black
      case ProjectStatus.quoted:
        return AppColors.accent; // Warm brown
      default:
        return project.status.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // "NEEDS ATTENTION" in all caps
              Text(
                'NEEDS ATTENTION',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.badgeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${projects.length}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Vertical list of items
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: projects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < projects.length - 1 ? 12 : 0),
                child: _NeedsAttentionListItem(
                  project: project,
                  subtitle: _getSubtitle(project),
                  dotColor: _getDotColor(project),
                  onTap: () => onProjectTap?.call(project),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Single list item for needs attention section.
class _NeedsAttentionListItem extends StatelessWidget {
  final Project project;
  final String subtitle;
  final Color dotColor;
  final VoidCallback? onTap;

  const _NeedsAttentionListItem({
    required this.project,
    required this.subtitle,
    required this.dotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Colored dot indicator
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron arrow
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

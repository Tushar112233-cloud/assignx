import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Recent projects section for dashboard.
///
/// Displays a horizontal scrollable list of recent projects
/// with status indicators and time stamps.
/// Matches web dashboard's RecentProjects component.
///
/// Example:
/// ```dart
/// RecentProjectsSection(
///   projects: recentProjects,
///   onProjectTap: (project) => context.push('/projects/${project.id}'),
///   onViewAll: () => context.go('/projects'),
/// )
/// ```
class RecentProjectsSection extends StatelessWidget {
  /// List of recent projects to display.
  final List<Project> projects;

  /// Callback when a project card is tapped.
  final void Function(Project project)? onProjectTap;

  /// Callback when "View All" is tapped.
  final VoidCallback? onViewAll;

  /// Whether to show loading skeleton.
  final bool isLoading;

  const RecentProjectsSection({
    super.key,
    required this.projects,
    this.onProjectTap,
    this.onViewAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and View All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Projects',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${projects.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              // View All button
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal scrolling list
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final project = projects[index];
              return _RecentProjectCard(
                project: project,
                onTap: () => onProjectTap?.call(project),
                animationDelay: index * 50,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SkeletonLoader(width: 36, height: 36, borderRadius: 10),
              const SizedBox(width: 12),
              SkeletonLoader(width: 120, height: 16, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => CardSkeleton(
              width: 200,
              height: 100,
              borderRadius: 14,
              showImage: false,
              textLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual recent project card.
class _RecentProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final int animationDelay;

  const _RecentProjectCard({
    required this.project,
    this.onTap,
    this.animationDelay = 0,
  });

  /// Formats a DateTime as a relative time string.
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years${years == 1 ? 'y' : 'y'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months${months == 1 ? 'mo' : 'mo'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  /// Returns dot color based on project status.
  Color _getDotColor() {
    switch (project.status) {
      case ProjectStatus.completed:
      case ProjectStatus.qcApproved:
      case ProjectStatus.paid:
        return AppColors.success;
      case ProjectStatus.inProgress:
      case ProjectStatus.assigned:
      case ProjectStatus.delivered:
        return AppColors.info;
      case ProjectStatus.analyzing:
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return AppColors.accent;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(16 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: Ink(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Status dot + Title
                  Row(
                    children: [
                      // Status dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getDotColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Title
                      Expanded(
                        child: Text(
                          project.title,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Bottom: Project number + Time
                  Row(
                    children: [
                      // Project number
                      Text(
                        project.projectNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\u2022',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time ago
                      Icon(
                        Icons.schedule_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatTimeAgo(project.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual project card widget for the My Projects list.
///
/// Displays project title, topic/subject, status badge, deadline countdown,
/// payout amount, and urgency indicator with a status-colored left border.
/// Polished with consistent 16px border radius, subtle shadows, and spacing.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../core/translation/translation_extensions.dart';

/// A card representing a single project in the My Projects list.
class ProjectListCard extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onTap;

  const ProjectListCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);
    final remaining = project.timeRemaining;
    final urgencyColor = _getUrgencyColor(remaining);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status-colored left border
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusLg),
                    bottomLeft: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              // Card content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: title + urgency badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              project.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (project.isUrgent) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.urgentBg,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    size: 12,
                                    color: AppColors.urgent,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Urgent'.tr(context),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.urgent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Subject and topic row
                      Row(
                        children: [
                          if (project.subjectName != null) ...[
                            const Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                project.subjectName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accent,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (project.topic != null &&
                              project.subjectName != null) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                '\u00B7',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (project.topic != null)
                            Flexible(
                              child: Text(
                                project.topic!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Bottom row: status badge, deadline, payout
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              project.status.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          // Deadline countdown
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: urgencyColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatDeadline(remaining),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: urgencyColor,
                            ),
                          ),

                          const Spacer(),

                          // Payout amount
                          Text(
                            project.formattedPayout,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Arrow indicator
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DoerProjectStatus status) {
    switch (status) {
      case DoerProjectStatus.inProgress:
        return AppColors.info;
      case DoerProjectStatus.assigned:
        return AppColors.accent;
      case DoerProjectStatus.revisionRequested:
      case DoerProjectStatus.inRevision:
        return AppColors.error;
      case DoerProjectStatus.delivered:
      case DoerProjectStatus.submittedForQc:
        return AppColors.warning;
      case DoerProjectStatus.completed:
      case DoerProjectStatus.autoApproved:
        return AppColors.success;
      case DoerProjectStatus.cancelled:
      case DoerProjectStatus.refunded:
        return AppColors.textTertiary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getUrgencyColor(Duration remaining) {
    if (remaining.isNegative) return AppColors.error;
    if (remaining.inHours < 24) return AppColors.error;
    if (remaining.inHours < 72) return AppColors.warning;
    return AppColors.success;
  }

  String _formatDeadline(Duration remaining) {
    if (remaining.isNegative) {
      final overdue = remaining.abs();
      if (overdue.inDays > 0) return '${overdue.inDays}d overdue';
      return '${overdue.inHours}h overdue';
    }
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h left';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    }
    return '${remaining.inMinutes}m left';
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import 'deadline_countdown.dart';

/// Enhanced project card for assigned tasks.
///
/// Shows title, topic, deadline countdown timer, urgency coloring,
/// progress indicator, payout, and status badge. Designed for the
/// "Assigned Tasks" section of the dashboard.
class AssignedTaskCard extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onTap;

  const AssignedTaskCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _getUrgencyColor();
    final urgencyLabel = _getUrgencyLabel();

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: project.hasRevision
            ? const BorderSide(color: AppColors.error, width: 1.5)
            : BorderSide(
                color: urgencyColor.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency strip at top
            Container(
              width: double.infinity,
              height: 4,
              decoration: BoxDecoration(
                color: urgencyColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusMd),
                  topRight: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revision banner
                  if (project.hasRevision) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.error),
                          SizedBox(width: 6),
                          Text(
                            'Revision Requested',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Title + urgency badge row
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
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (urgencyLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: urgencyColor.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(
                              color: urgencyColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                urgencyLabel == 'Hot'
                                    ? Icons.local_fire_department
                                    : Icons.schedule,
                                size: 12,
                                color: urgencyColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                urgencyLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: urgencyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Topic badge
                  if (project.topic != null || project.subject != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        project.topic ?? project.subject ?? 'General',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // Progress bar
                  if (project.progressPercentage > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: AppSpacing.borderRadiusSm,
                            child: LinearProgressIndicator(
                              value: project.progressPercentage / 100,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                project.progressPercentage >= 80
                                    ? AppColors.success
                                    : AppColors.accent,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${project.progressPercentage}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Payout + Status row
                  Row(
                    children: [
                      // Payout
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 16, color: AppColors.success),
                          Text(
                            project.doerPayout.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Status badge
                      _buildStatusBadge(),
                      const Spacer(),
                      // Supervisor
                      if (project.supervisorName != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline,
                                size: 13, color: AppColors.textTertiary),
                            const SizedBox(width: 3),
                            Text(
                              project.supervisorName!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Deadline countdown
                  DeadlineCountdown(
                    deadline: project.deadline,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (project.status) {
      case DoerProjectStatus.inProgress:
        color = AppColors.info;
      case DoerProjectStatus.revisionRequested:
      case DoerProjectStatus.inRevision:
        color = AppColors.error;
      case DoerProjectStatus.delivered:
      case DoerProjectStatus.submittedForQc:
        color = AppColors.warning;
      case DoerProjectStatus.assigned:
        color = AppColors.accent;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        project.status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getUrgencyColor() {
    if (project.hasRevision) return AppColors.error;
    final hours = project.hoursUntilDeadline;
    if (hours < 0) return AppColors.error;
    if (hours < 24) return AppColors.urgencyHigh;
    if (hours < 72) return AppColors.urgencyMedium;
    return AppColors.urgencyLow;
  }

  String? _getUrgencyLabel() {
    if (project.hasRevision) return null; // revision banner shown instead
    final hours = project.hoursUntilDeadline;
    if (hours < 0) return 'Overdue';
    if (hours < 24) return 'Hot';
    if (hours < 72) return 'Soon';
    return null;
  }
}

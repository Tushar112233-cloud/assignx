/// Project card widgets for displaying project information.
///
/// This file provides card components for displaying project/assignment
/// data in dashboard lists, with support for different display modes
/// and interactive actions.
///
/// ## Widgets
/// - [ProjectCard] - Full-featured project card for main lists
/// - [CompactProjectCard] - Condensed card for smaller displays
///
/// ## Features
/// - Project title, subject, and price display
/// - Deadline countdown timer
/// - Urgency badge for time-sensitive projects
/// - Revision warning banner
/// - Status indicators with color coding
/// - Accept button for open pool projects
/// - Supervisor name display
///
/// ## Example
/// ```dart
/// // Full project card with tap handler
/// ProjectCard(
///   project: project,
///   onTap: () => navigateToDetail(project.id),
/// )
///
/// // Card with accept button for open pool
/// ProjectCard(
///   project: project,
///   showAcceptButton: true,
///   onAccept: () => acceptProject(project.id),
/// )
///
/// // Compact card for smaller spaces
/// CompactProjectCard(
///   project: project,
///   onTap: () => navigateToDetail(project.id),
/// )
/// ```
///
/// See also:
/// - [DoerProjectModel] for the data structure
/// - [DeadlineCountdown] for deadline display
/// - [UrgencyBadge] for urgency indicator
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../shared/widgets/app_button.dart';
import 'urgency_badge.dart';
import 'deadline_countdown.dart';

/// Project card widget for dashboard lists.
///
/// Displays comprehensive project information including title, subject,
/// price, word count, deadline, and status. Supports tap interactions
/// and optional accept button for open pool projects.
///
/// ## Props
/// - [project]: The project data to display
/// - [onTap]: Callback when card is tapped
/// - [onAccept]: Callback when accept button is pressed
/// - [showAcceptButton]: Whether to show the accept button
///
/// ## Visual States
/// - Normal: Standard card appearance
/// - Revision: Red border with warning banner
/// - Urgent: Shows urgency badge
class ProjectCard extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final bool showAcceptButton;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onAccept,
    this.showAcceptButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: project.hasRevision
            ? const BorderSide(color: AppColors.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revision banner
              if (project.hasRevision) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Revision Requested',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Header row: Title + Urgency
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (project.isUrgent)
                    const UrgencyBadge(),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subject badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  project.subject ?? 'General',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Info row: Price + Word count
              Row(
                children: [
                  // Price
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 18,
                        color: AppColors.success,
                      ),
                      Text(
                        project.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: AppSpacing.lg),

                  // Word count
                  if (project.wordCount != null) ...[
                    const Icon(
                      Icons.article_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.wordCount} words',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Reference style
                  if (project.referenceStyle != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.border,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        project.referenceStyle!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Deadline countdown
              DeadlineCountdown(deadline: project.deadline),

              // Accept button
              if (showAcceptButton && onAccept != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: 'Accept Task',
                  onPressed: onAccept,
                  isFullWidth: true,
                  size: AppButtonSize.medium,
                ),
              ],

              // Status badge for assigned projects
              if (!showAcceptButton && project.status != DoerProjectStatus.assigning) ...[
                const SizedBox(height: AppSpacing.md),
                _buildStatusRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow() {
    Color statusColor;
    String statusText = project.status.displayName;

    switch (project.status) {
      case DoerProjectStatus.inProgress:
        statusColor = AppColors.info;
        break;
      case DoerProjectStatus.delivered:
      case DoerProjectStatus.submittedForQc:
        statusColor = AppColors.warning;
        break;
      case DoerProjectStatus.completed:
      case DoerProjectStatus.paid:
        statusColor = AppColors.success;
        break;
      case DoerProjectStatus.revisionRequested:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ),
        if (project.supervisorName != null)
          Row(
            children: [
              const Icon(
                Icons.supervisor_account_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                project.supervisorName!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Compact project card for smaller displays.
///
/// A condensed version of [ProjectCard] that shows minimal information
/// in a horizontal layout, suitable for secondary lists or space-constrained
/// areas.
///
/// ## Props
/// - [project]: The project data to display
/// - [onTap]: Callback when card is tapped
///
/// ## Display Elements
/// - Project title (single line, ellipsized)
/// - Subject and price in a row
/// - Urgency badge (if applicable)
class CompactProjectCard extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onTap;

  const CompactProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingSm,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          project.subject ?? 'General',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.currency_rupee,
                              size: 12,
                              color: AppColors.success,
                            ),
                            Text(
                              project.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (project.isUrgent)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: UrgencyBadge(compact: true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Project information card widgets for workspace display.
///
/// This file provides card components for displaying project details
/// in the workspace, including collapsible full info and compact headers.
///
/// ## Widgets
/// - [ProjectInfoCard] - Expandable card with full project details
/// - [CompactProjectHeader] - Slim header for workspace navigation
///
/// ## Features
/// - Collapsible/expandable project details
/// - Subject, price, and word count chips
/// - Deadline countdown integration
/// - Urgency badge for time-sensitive projects
/// - Description and reference style display
/// - Supervisor information
///
/// ## Example
/// ```dart
/// // Full expandable card
/// ProjectInfoCard(
///   project: project,
///   expanded: _showDetails,
///   onToggleExpand: () => setState(() => _showDetails = !_showDetails),
/// )
///
/// // Compact header for workspace
/// CompactProjectHeader(
///   project: project,
///   onInfoTap: () => context.push('/project/${project.id}'),
/// )
/// ```
///
/// See also:
/// - [WorkspaceScreen] for usage context
/// - [ProjectCard] for dashboard display
/// - [DeadlineCountdown] for deadline widget
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import '../../dashboard/widgets/deadline_countdown.dart';
import '../../dashboard/widgets/urgency_badge.dart';

/// Expandable project information card.
///
/// Displays project title, subject, price, deadline, and optional
/// expanded details including description, reference style, and
/// supervisor info. Used in workspace for quick project reference.
///
/// ## Props
/// - [project]: The [DoerProjectModel] to display
/// - [expanded]: Whether details section is visible
/// - [onToggleExpand]: Callback to toggle expanded state
class ProjectInfoCard extends StatelessWidget {
  final DoerProjectModel project;
  final bool expanded;
  final VoidCallback? onToggleExpand;

  const ProjectInfoCard({
    super.key,
    required this.project,
    this.expanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onToggleExpand,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (project.isUrgent)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: UrgencyBadge(compact: true),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Subject and price row
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.category,
                        label: project.subject ?? 'General',
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildInfoChip(
                        icon: Icons.currency_rupee,
                        label: project.price.toStringAsFixed(0),
                        color: AppColors.success,
                      ),
                      if (project.wordCount != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _buildInfoChip(
                          icon: Icons.article,
                          label: '${project.wordCount} words',
                          color: AppColors.info,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Deadline countdown
                  DeadlineCountdown(deadline: project.deadline),

                  // Expand indicator
                  if (onToggleExpand != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expandable content
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      project.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  if (project.referenceStyle != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildDetailRow(
                      'Reference Style',
                      project.referenceStyle!,
                      Icons.format_quote,
                    ),
                  ],

                  if (project.supervisorName != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildDetailRow(
                      'Supervisor',
                      project.supervisorName!,
                      Icons.person,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Status',
                    project.status.displayName,
                    Icons.info_outline,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Compact project header for workspace screens.
///
/// Slim header bar showing essential project info with navigation
/// controls. Displays title, subject, deadline countdown, and
/// urgency badge when applicable.
///
/// ## Props
/// - [project]: The [DoerProjectModel] to display
/// - [onInfoTap]: Callback for info button (opens project details)
class CompactProjectHeader extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onInfoTap;

  const CompactProjectHeader({
    super.key,
    required this.project,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textPrimary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DeadlineCountdown(
                        deadline: project.deadline,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (project.isUrgent)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: UrgencyBadge(compact: true),
              ),
            IconButton(
              onPressed: onInfoTap,
              icon: const Icon(Icons.info_outline),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/project_model.dart';
import 'deadline_timer.dart';
import 'status_badge.dart';

/// Card widget for displaying project information.
///
/// Shows project details with status, deadline, and optional actions.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onChatTap,
    this.showActions = false,
    this.onApprove,
    this.onRevision,
  });

  /// Project data
  final ProjectModel project;

  /// Called when card is tapped
  final VoidCallback onTap;

  /// Called when chat button is tapped
  final VoidCallback? onChatTap;

  /// Whether to show action buttons
  final bool showActions;

  /// Called when approve is tapped (for review cards)
  final VoidCallback? onApprove;

  /// Called when revision is tapped (for review cards)
  final VoidCallback? onRevision;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: project.isUrgent
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.textSecondaryLight.withValues(alpha: 0.1),
          width: project.isUrgent ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and project number
                        Row(
                          children: [
                            StatusBadge(status: project.status),
                            const SizedBox(width: 8),
                            Text(
                              project.projectNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            if (project.isUrgent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 12,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Urgent'.tr(context),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          project.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Deadline timer
                  if (project.deadline != null)
                    DeadlineTimer(
                      deadline: project.deadline!,
                      compact: true,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Subject tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  project.subject,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              // Info row
              Row(
                children: [
                  // Client info
                  if (project.clientName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        project.clientName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  // Doer info
                  if (project.doerName != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        project.doerName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Chat button
                  if (onChatTap != null)
                    IconButton(
                      onPressed: onChatTap,
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  const SizedBox(width: 8),
                  // Price tag
                  if (project.userQuote != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${project.userQuote!.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                ],
              ),
              // Action buttons
              if (showActions && (onApprove != null || onRevision != null)) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onRevision != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onRevision,
                          icon: const Icon(Icons.replay, size: 18),
                          label: Text('Revision'.tr(context)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                    if (onApprove != null && onRevision != null)
                      const SizedBox(width: 12),
                    if (onApprove != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Approve'.tr(context)),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact project card for list views.
class CompactProjectCard extends StatelessWidget {
  const CompactProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final ProjectModel project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: project.status.color.withValues(alpha: 0.1),
        child: Icon(
          project.status.icon,
          color: project.status.color,
          size: 20,
        ),
      ),
      title: Text(
        project.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            project.projectNumber,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(width: 8),
          if (project.deadline != null) ...[
            Icon(
              Icons.schedule,
              size: 12,
              color: project.isOverdue
                  ? AppColors.error
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 2),
            Text(
              project.formattedDeadline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: project.isOverdue
                        ? AppColors.error
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ],
      ),
      trailing: StatusBadge(
        status: project.status,
        compact: true,
      ),
    );
  }
}

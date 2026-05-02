import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/project_model.dart';
import '../../domain/entities/project_status.dart';

/// Modern project card with left accent border, status pill, and clean typography.
///
/// Displays: title (bold), status badge (colored pill), client name, subject,
/// deadline, and pricing info. Optionally shows approve/revision action buttons.
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

  /// Project data.
  final ProjectModel project;

  /// Called when card is tapped.
  final VoidCallback onTap;

  /// Called when chat button is tapped.
  final VoidCallback? onChatTap;

  /// Whether to show action buttons (approve / revision).
  final bool showActions;

  /// Called when approve is tapped (for review cards).
  final VoidCallback? onApprove;

  /// Called when revision is tapped (for review cards).
  final VoidCallback? onRevision;

  /// Returns the accent color for the left border based on project status.
  Color _accentColor() {
    switch (project.status) {
      case ProjectStatus.inProgress:
      case ProjectStatus.assigned:
        return Colors.blue;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.forReview:
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.delivered:
        return Colors.amber.shade700;
      case ProjectStatus.paid:
      case ProjectStatus.approved:
      case ProjectStatus.qcApproved:
      case ProjectStatus.deliveredToClient:
      case ProjectStatus.clientReview:
        return Colors.purple;
      case ProjectStatus.submitted:
      case ProjectStatus.analyzing:
      case ProjectStatus.quoted:
      case ProjectStatus.accepted:
      case ProjectStatus.paymentPending:
      case ProjectStatus.readyToAssign:
        return Colors.orange;
      case ProjectStatus.revisionRequested:
      case ProjectStatus.inRevision:
      case ProjectStatus.clientRevision:
        return Colors.deepOrange;
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    // Card content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Status pill + urgent badge + project number
                            _buildHeaderRow(context, theme, accent),
                            const SizedBox(height: 10),
                            // Row 2: Title
                            Text(
                              project.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            // Row 3: Subject chip
                            _buildSubjectChip(context, theme),
                            const SizedBox(height: 12),
                            // Row 4: Meta info (client, deadline, price)
                            _buildMetaRow(context, theme),
                            // Action buttons (for review tab)
                            if (showActions &&
                                (onApprove != null || onRevision != null)) ...[
                              const SizedBox(height: 12),
                              Divider(
                                height: 1,
                                color: AppColors.borderLight,
                              ),
                              const SizedBox(height: 12),
                              _buildActionButtons(context),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header row with status pill, urgent badge, and project number.
  Widget _buildHeaderRow(BuildContext context, ThemeData theme, Color accent) {
    return Row(
      children: [
        // Status pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                project.status.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Urgent badge
        if (project.isUrgent) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.priority_high, size: 12, color: AppColors.error),
                const SizedBox(width: 2),
                Text(
                  'Urgent'.tr(context),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        // Project number
        Text(
          project.projectNumber,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiaryLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Builds the subject chip.
  Widget _buildSubjectChip(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.book_outlined,
            size: 13,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 5),
          Text(
            project.subject,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom meta row with client name, deadline, and pricing.
  Widget _buildMetaRow(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Client name
        if (project.clientName != null) ...[
          Icon(
            Icons.person_outline,
            size: 14,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              project.clientName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        // Deadline
        if (project.deadline != null) ...[
          if (project.clientName != null) const SizedBox(width: 12),
          Icon(
            Icons.schedule,
            size: 14,
            color: project.isOverdue
                ? AppColors.error
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            project.formattedDeadline,
            style: theme.textTheme.bodySmall?.copyWith(
              color: project.isOverdue
                  ? AppColors.error
                  : AppColors.textSecondaryLight,
              fontWeight: project.isOverdue ? FontWeight.w600 : null,
              fontSize: 12,
            ),
          ),
        ],
        const Spacer(),
        // Chat button
        if (onChatTap != null)
          InkWell(
            onTap: onChatTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textSecondaryLight,
                size: 18,
              ),
            ),
          ),
        if (onChatTap != null) const SizedBox(width: 8),
        // Price tag
        if (project.userQuote != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '\u20B9${project.userQuote!.toStringAsFixed(0)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.successDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the approve / revision action buttons row.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onRevision != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRevision,
              icon: const Icon(Icons.replay, size: 16),
              label: Text('Revision'.tr(context)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: BorderSide(
                  color: Colors.orange.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (onApprove != null && onRevision != null) const SizedBox(width: 12),
        if (onApprove != null)
          Expanded(
            child: FilledButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check, size: 16),
              label: Text('Approve'.tr(context)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
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
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: project.status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          project.status.displayName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: project.status.color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

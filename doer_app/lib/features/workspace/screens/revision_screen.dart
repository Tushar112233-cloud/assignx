import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../dashboard/widgets/app_header.dart';
import '../../dashboard/widgets/deadline_countdown.dart';
import '../../../core/translation/translation_extensions.dart';

/// Revision request screen showing detailed revision feedback.
///
/// Displays the revision request from a reviewer including feedback,
/// required changes with priority levels, and action buttons for
/// continuing work.
///
/// ## Navigation
/// - Entry: From [DashboardScreen] when project has revision status
/// - Chat with Reviewer: Opens chat with reviewer
/// - Open Workspace: Returns to [WorkspaceScreen] for revisions
/// - Back: Returns to previous screen
///
/// ## Sections
/// 1. **Revision Alert**: Warning banner about revision request
/// 2. **Revision Deadline**: Countdown timer for revision due date
/// 3. **Reviewer Feedback**: Detailed feedback with rating
/// 4. **Required Changes**: Prioritized list of changes needed
/// 5. **Previous Submission**: Info about last submission
///
/// ## Change Priorities
/// - high: Critical changes (red indicator)
/// - medium: Important changes (yellow indicator)
/// - low: Minor improvements (blue indicator)
///
/// ## Features
/// - Visual priority indicators for required changes
/// - Reviewer rating display (e.g., 3.5/5)
/// - Previous submission date and file count
/// - Dual action buttons for chat and workspace
///
/// ## Mock Data Note
/// Currently uses mock feedback and changes data.
/// TODO: Connect to real revision API.
///
/// ## State Management
/// Uses [WorkspaceProvider] for project and revision data.
///
/// See also:
/// - [WorkspaceProvider] for workspace state
/// - [WorkspaceScreen] for making revisions
/// - [ChatScreen] for reviewer communication
class RevisionScreen extends ConsumerWidget {
  final String projectId;

  const RevisionScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceNotifier = ref.watch(workspaceProvider(projectId));
    final workspaceState = workspaceNotifier.state;
    final project = workspaceState.project;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        opacity: 0.4,
        child: Column(
          children: [
            InnerHeader(
              title: 'Revision Request',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: project == null
                  ? Center(child: Text('Project not found'.tr(context)))
                  : SingleChildScrollView(
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Revision alert
                          _buildRevisionAlert(context),

                          const SizedBox(height: AppSpacing.lg),

                          // Deadline in glass
                          GlassCard(
                            padding: AppSpacing.paddingMd,
                            borderColor: AppColors.error.withValues(alpha: 0.15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Revision Deadline'.tr(context),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                DeadlineCountdown(deadline: project.deadline),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Revision feedback in glass
                          _buildFeedbackCard(context),

                          const SizedBox(height: AppSpacing.lg),

                          // Required changes in glass
                          _buildChangesCard(context),

                          const SizedBox(height: AppSpacing.lg),

                          // Previous submission in glass
                          _buildPreviousSubmissionCard(context, workspaceState),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),

            // Action buttons
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisionAlert(BuildContext context) {
    return GlassCard(
      padding: AppSpacing.paddingMd,
      backgroundColor: AppColors.error,
      opacity: 0.08,
      borderColor: AppColors.error.withValues(alpha: 0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 24,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revision Requested'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your submission requires changes. Please review the feedback and resubmit.'.tr(context),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    // Mock feedback data
    const feedback = '''The research paper needs some improvements:

1. The introduction lacks a clear thesis statement
2. More recent citations needed (2020-2024)
3. The conclusion doesn't summarize the main findings
4. Please add page numbers to the document

Overall, the content quality is good but needs structural improvements.''';

    return GlassCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.feedback_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Reviewer Feedback'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '3.5/5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          const Text(
            feedback,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangesCard(BuildContext context) {
    // Mock required changes
    final changes = [
      {'text': 'Add clear thesis statement in introduction', 'priority': 'high'},
      {'text': 'Update citations to include recent sources', 'priority': 'high'},
      {'text': 'Revise conclusion section', 'priority': 'medium'},
      {'text': 'Add page numbers', 'priority': 'low'},
    ];

    return GlassCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Required Changes'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...changes.map((change) => _buildChangeItem(
                change['text']!,
                change['priority']!,
              )),
        ],
      ),
    );
  }

  Widget _buildChangeItem(String text, String priority) {
    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = AppColors.error;
        break;
      case 'medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.info;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        blur: 8,
        opacity: 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        borderColor: priorityColor.withValues(alpha: 0.15),
        enableHoverEffect: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                priority.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSubmissionCard(BuildContext context, WorkspaceState workspaceState) {
    return GlassCard(
      padding: AppSpacing.paddingMd,
      opacity: 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text(
                'Previous Submission'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                '${'Submitted on'.tr(context)} ${_formatDate(DateTime.now().subtract(const Duration(days: 1)))}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.attach_file,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                '${workspaceState.deliverables.length} files submitted',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.zero,
      padding: AppSpacing.paddingMd,
      borderColor: AppColors.border.withValues(alpha: 0.2),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Chat with Reviewer',
                onPressed: () => Navigator.pop(context),
                variant: AppButtonVariant.secondary,
                icon: Icons.chat_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                text: 'Open Workspace',
                onPressed: () => Navigator.pop(context),
                icon: Icons.edit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

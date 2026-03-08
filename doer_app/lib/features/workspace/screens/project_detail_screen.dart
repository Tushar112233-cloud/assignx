import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../dashboard/widgets/app_header.dart';
import '../../dashboard/widgets/deadline_countdown.dart';
import '../../dashboard/widgets/urgency_badge.dart';
import '../widgets/requirements_list.dart';
import '../../../core/translation/translation_extensions.dart';

/// Project detail screen showing comprehensive project information.
///
/// Displays all details about an assigned project including requirements,
/// deadline, description, and provides navigation to workspace and chat.
///
/// ## Navigation
/// - Entry: From [DashboardScreen] via project card tap
/// - Chat: Opens [ChatScreen] for project communication
/// - Workspace: Opens [WorkspaceScreen] for active work
/// - Back: Returns to [DashboardScreen]
///
/// ## Sections
/// 1. **Title & Urgency**: Project title with optional urgent badge
/// 2. **Info Chips**: Subject, price, word count, reference style, status
/// 3. **Deadline**: Large countdown timer with urgency coloring
/// 4. **Description**: Full project description text
/// 5. **Requirements**: Checklist of project requirements
/// 6. **Supervisor**: Supervisor contact information
///
/// ## Features
/// - Revision badge in header if project has pending revision
/// - Status-based color coding for info chips
/// - Large deadline timer with hours/minutes countdown
/// - Requirements list with completion tracking
/// - Dual action buttons for chat and workspace
///
/// ## Route Parameters
/// - [projectId]: Required project identifier
///
/// ## State Management
/// Uses [WorkspaceProvider] for project data.
///
/// See also:
/// - [WorkspaceProvider] for project state
/// - [DoerProjectModel] for project data model
/// - [WorkspaceScreen] for active work
/// - [ChatScreen] for project communication
class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(workspaceProvider(projectId));
    final workspaceState = notifier.state;
    final project = workspaceState.project;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        opacity: 0.5,
        child: LoadingOverlay(
          isLoading: workspaceState.isLoading,
          child: Column(
            children: [
              InnerHeader(
                title: 'Project Details',
                onBack: () => Navigator.pop(context),
                actions: [
                  if (project != null && project.hasRevision)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 14, color: AppColors.error),
                          SizedBox(width: 4),
                          Text(
                            'Revision'.tr(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Expanded(
                child: project == null
                    ? Center(child: Text('Project not found'.tr(context)))
                    : SingleChildScrollView(
                        padding: AppSpacing.paddingMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero card with status, earnings, deadline
                            _buildHeroCard(context, project),

                            const SizedBox(height: AppSpacing.lg),

                            // Description section
                            GlassCard(
                              padding: AppSpacing.paddingMd,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Description'.tr(context),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (project.description != null && project.description!.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      project.description!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Timeline milestones
                            _buildTimeline(context, project),

                            const SizedBox(height: AppSpacing.lg),

                            // Requirements section
                            if (project.requirements.isNotEmpty)
                              GlassCard(
                                padding: AppSpacing.paddingMd,
                                child: RequirementsList(
                                  requirements: project.requirements,
                                ),
                              ),

                            if (project.requirements.isNotEmpty)
                              const SizedBox(height: AppSpacing.lg),

                            // Supervisor info
                            if (project.supervisorName != null)
                              GlassCard(
                                padding: AppSpacing.paddingMd,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          AppColors.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        project.supervisorName![0].toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Supervisor'.tr(context),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          project.supervisorName!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
              ),

              // Bottom action bar
              if (project != null)
                _buildBottomBar(context, project),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the glass hero card with status, earnings, and deadline info.
  Widget _buildHeroCard(BuildContext context, DoerProjectModel project) {
    return GlassCard(
      padding: AppSpacing.paddingMd,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.7),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and urgency
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (project.isUrgent)
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: UrgencyBadge(),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Info chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildInfoChip(
                Icons.category,
                project.subject ?? 'General',
                AppColors.accent,
              ),
              _buildInfoChip(
                Icons.currency_rupee,
                '\u20B9${project.price.toStringAsFixed(0)}',
                AppColors.success,
              ),
              if (project.wordCount != null)
                _buildInfoChip(
                  Icons.article,
                  '${project.wordCount} words',
                  AppColors.info,
                ),
              if (project.referenceStyle != null)
                _buildInfoChip(
                  Icons.format_quote,
                  project.referenceStyle!,
                  AppColors.primary,
                ),
              _buildInfoChip(
                Icons.info_outline,
                project.status.displayName,
                _getStatusColor(project.status),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Inline deadline
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Deadline'.tr(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: LargeDeadlineTimer(deadline: project.deadline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a vertical timeline with glass milestone cards.
  Widget _buildTimeline(BuildContext context, DoerProjectModel project) {
    final milestones = <_TimelineMilestone>[
      _TimelineMilestone(
        title: 'Assigned'.tr(context),
        icon: Icons.assignment_turned_in,
        color: AppColors.success,
        isCompleted: true,
      ),
      _TimelineMilestone(
        title: 'In Progress'.tr(context),
        icon: Icons.play_circle_outline,
        color: AppColors.info,
        isCompleted: project.status.index >= DoerProjectStatus.inProgress.index,
      ),
      _TimelineMilestone(
        title: 'Submitted'.tr(context),
        icon: Icons.upload_file,
        color: AppColors.warning,
        isCompleted: project.status.index >= DoerProjectStatus.submitted.index,
      ),
      _TimelineMilestone(
        title: 'Completed'.tr(context),
        icon: Icons.check_circle,
        color: AppColors.success,
        isCompleted: project.status == DoerProjectStatus.completed ||
            project.status == DoerProjectStatus.paid,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            'Progress Timeline'.tr(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...List.generate(milestones.length, (index) {
          final milestone = milestones[index];
          final isLast = index == milestones.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical line and dot
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: milestone.isCompleted
                              ? milestone.color
                              : AppColors.border,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: milestone.isCompleted
                                ? milestone.color
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          milestone.isCompleted
                              ? Icons.check
                              : milestone.icon,
                          size: 14,
                          color: milestone.isCompleted
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: milestone.isCompleted
                                ? milestone.color.withValues(alpha: 0.3)
                                : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Milestone card
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isLast ? 0 : AppSpacing.sm,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      opacity: milestone.isCompleted ? 0.85 : 0.6,
                      elevation: milestone.isCompleted ? 2 : 1,
                      child: Row(
                        children: [
                          Icon(
                            milestone.icon,
                            size: 18,
                            color: milestone.isCompleted
                                ? milestone.color
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            milestone.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: milestone.isCompleted
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: milestone.isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          if (milestone.isCompleted)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: milestone.color,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DoerProjectStatus status) {
    switch (status) {
      case DoerProjectStatus.inProgress:
      case DoerProjectStatus.assigned:
        return AppColors.info;
      case DoerProjectStatus.submitted:
      case DoerProjectStatus.submittedForQc:
      case DoerProjectStatus.qcInProgress:
      case DoerProjectStatus.delivered:
        return AppColors.warning;
      case DoerProjectStatus.completed:
      case DoerProjectStatus.autoApproved:
      case DoerProjectStatus.paid:
      case DoerProjectStatus.qcApproved:
        return AppColors.success;
      case DoerProjectStatus.revisionRequested:
      case DoerProjectStatus.inRevision:
      case DoerProjectStatus.qcRejected:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildBottomBar(BuildContext context, DoerProjectModel project) {
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
                text: 'Chat',
                onPressed: () => context.push(RouteNames.projectChat.replaceFirst(':id', projectId)),
                variant: AppButtonVariant.secondary,
                icon: Icons.chat_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'Open Workspace',
                onPressed: () => context.push(RouteNames.workspace.replaceFirst(':id', projectId)),
                icon: Icons.work_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal data class for timeline milestones.
class _TimelineMilestone {
  final String title;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const _TimelineMilestone({
    required this.title,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
}

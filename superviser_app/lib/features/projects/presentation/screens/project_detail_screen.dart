import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/external_actions_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../providers/projects_provider.dart';
import '../widgets/deadline_timer.dart';
import '../widgets/status_badge.dart';
import '../widgets/qc_review_card.dart';
import '../widgets/revision_feedback_form.dart';

/// Screen showing detailed project information.
///
/// Displays project details, deliverables, and action buttons.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  /// Project ID from route
  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load project details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectDetailProvider.notifier).loadProject(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectDetailProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.project?.projectNumber ?? 'Project Details'.tr(context)),
        actions: [
          if (state.project?.chatRoomId != null)
            IconButton(
              onPressed: _openChat,
              icon: const Icon(Icons.chat_bubble_outline),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 12),
                    Text('Refresh'.tr(context)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 12),
                    Text('View History'.tr(context)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.project == null
              ? _ErrorView(
                  message: state.error ?? 'Project not found'.tr(context),
                  onRetry: () => ref
                      .read(projectDetailProvider.notifier)
                      .loadProject(widget.projectId),
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(projectDetailProvider.notifier)
                      .loadProject(widget.projectId),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status and deadline header
                        _HeaderSection(
                          project: state.project!,
                        ),
                        const SizedBox(height: 24),
                        // Project info
                        _InfoSection(project: state.project!),
                        const SizedBox(height: 24),
                        // People involved
                        _PeopleSection(project: state.project!),
                        const SizedBox(height: 24),
                        // Deliverables
                        if (state.deliverables.isNotEmpty) ...[
                          _SectionTitle(
                            title: 'Deliverables'.tr(context),
                            count: state.deliverables.length,
                          ),
                          const SizedBox(height: 12),
                          ...state.deliverables.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: QCReviewCard(
                                  deliverable: d,
                                  onView: () => _viewDeliverable(d.fileUrl),
                                  onDownload: () =>
                                      _downloadDeliverable(d.fileUrl),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        // Pricing breakdown
                        if (state.project!.userQuote != null)
                          _PricingSection(project: state.project!),
                        // Bottom padding for actions
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      // Action buttons
      bottomNavigationBar: state.project != null && _showActions(state)
          ? _ActionBar(
              state: state,
              onApprove: _approveDeliverable,
              onRevision: _requestRevision,
              onDeliver: _deliverToClient,
            )
          : null,
    );
  }

  bool _showActions(ProjectDetailState state) {
    return state.canApprove ||
        state.canRequestRevision ||
        state.project?.status.name == 'approved';
  }

  void _openChat() {
    context.push('${RoutePaths.chat}/${widget.projectId}');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        ref
            .read(projectDetailProvider.notifier)
            .loadProject(widget.projectId);
        break;
      case 'history':
        // Project history would show revision history and status changes
        ref.read(snackbarServiceProvider).showInfo('Project history feature coming soon');
        break;
    }
  }

  void _viewDeliverable(String url) {
    // Open file in browser or native viewer
    ref.read(externalActionsServiceProvider).openUrl(url);
  }

  void _downloadDeliverable(String url) {
    // Open URL which will trigger download in browser
    ref.read(externalActionsServiceProvider).openUrl(url);
    ref.read(snackbarServiceProvider).showInfo('Download started');
  }

  Future<void> _approveDeliverable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Approve Deliverable'.tr(ctx)),
        content: Text(
          'Are you sure you want to approve this work? The client will be notified that their project is ready.'.tr(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr(ctx)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: Text('Approve'.tr(ctx)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(projectDetailProvider.notifier)
          .approveDeliverable();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deliverable approved!'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _requestRevision() async {
    final project = ref.read(projectDetailProvider).project;
    if (project == null) return;

    final result = await RevisionFeedbackForm.show(
      context,
      projectTitle: project.title,
      onSubmit: ({required String feedback, List<String>? issues}) {
        return ref.read(projectDetailProvider.notifier).requestRevision(
              feedback: feedback,
              issues: issues,
            );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Revision requested!'.tr(context)),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deliverToClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deliver to Client'.tr(ctx)),
        content: Text(
          'Are you sure you want to deliver this project to the client? They will receive a notification with the final deliverables.'.tr(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.tr(ctx)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Deliver'.tr(ctx)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(projectDetailProvider.notifier).deliverToClient();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project delivered to client!'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

/// Header section with status and deadline.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: project.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: project.status.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge(status: project.status),
                    const SizedBox(height: 8),
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              if (project.deadline != null)
                DeadlineTimer(
                  deadline: project.deadline!,
                  compact: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Info section with project details.
class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Project Details'.tr(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _InfoRow(
                label: 'Subject'.tr(context),
                value: project.subject,
                icon: Icons.book_outlined,
              ),
              if (project.wordCount != null)
                _InfoRow(
                  label: 'Word Count'.tr(context),
                  value: '${project.wordCount} ${'words'.tr(context)}',
                  icon: Icons.text_fields,
                ),
              if (project.pageCount != null)
                _InfoRow(
                  label: 'Page Count'.tr(context),
                  value: '${project.pageCount} ${'pages'.tr(context)}',
                  icon: Icons.description_outlined,
                ),
              _InfoRow(
                label: 'Revisions'.tr(context),
                value: '${project.revisionCount}',
                icon: Icons.replay,
              ),
            ],
          ),
        ),
        if (project.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Description'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ],
    );
  }
}

/// People section showing client and doer.
class _PeopleSection extends StatelessWidget {
  const _PeopleSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'People'.tr(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            if (project.clientName != null)
              Expanded(
                child: _PersonCard(
                  name: project.clientName!,
                  role: 'Client'.tr(context),
                  email: project.clientEmail,
                  color: Colors.blue,
                ),
              ),
            if (project.clientName != null && project.doerName != null)
              const SizedBox(width: 12),
            if (project.doerName != null)
              Expanded(
                child: _PersonCard(
                  name: project.doerName!,
                  role: 'Doer'.tr(context),
                  color: Colors.purple,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Person card widget.
class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.name,
    required this.role,
    this.email,
    required this.color,
  });

  final String name;
  final String role;
  final String? email;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pricing section.
class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Pricing Breakdown'.tr(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _PricingRow(
                label: 'Client Price'.tr(context),
                amount: project.userQuote ?? 0,
                isTotal: false,
              ),
              const Divider(height: 24),
              if (project.doerAmount != null)
                _PricingRow(
                  label: 'Doer Payment'.tr(context),
                  amount: project.doerAmount!,
                  isTotal: false,
                ),
              if (project.supervisorAmount != null)
                _PricingRow(
                  label: 'Your Commission'.tr(context),
                  amount: project.supervisorAmount!,
                  isTotal: false,
                  color: AppColors.success,
                ),
              if (project.platformAmount != null)
                _PricingRow(
                  label: 'Platform Fee'.tr(context),
                  amount: project.platformAmount!,
                  isTotal: false,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pricing row.
class _PricingRow extends StatelessWidget {
  const _PricingRow({
    required this.label,
    required this.amount,
    required this.isTotal,
    this.color,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
          ),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Section title widget.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.count,
  });

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Info row widget.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Action bar at bottom.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.state,
    required this.onApprove,
    required this.onRevision,
    required this.onDeliver,
  });

  final ProjectDetailState state;
  final VoidCallback onApprove;
  final VoidCallback onRevision;
  final VoidCallback onDeliver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.canRequestRevision)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isUpdating ? null : onRevision,
                  icon: const Icon(Icons.replay),
                  label: Text('Request Revision'.tr(context)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            if (state.canRequestRevision && state.canApprove)
              const SizedBox(width: 12),
            if (state.canApprove)
              Expanded(
                child: PrimaryButton(
                  text: 'Approve'.tr(context),
                  isLoading: state.isUpdating,
                  onPressed: onApprove,
                ),
              ),
            if (state.project?.status.name == 'approved')
              Expanded(
                child: PrimaryButton(
                  text: 'Deliver to Client'.tr(context),
                  isLoading: state.isUpdating,
                  onPressed: onDeliver,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Error view widget.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('Retry'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}

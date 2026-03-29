import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/external_actions_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../data/models/project_model.dart';
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
        backgroundColor: const Color(0xFFFAF8F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8F5),
          elevation: 0,
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
                          // Glass hero card with status and deadline
                          _GlassHeroCard(
                            project: state.project!,
                          ),
                          const SizedBox(height: 24),
                          // Project info
                          _GlassInfoSection(project: state.project!),
                          const SizedBox(height: 24),
                          // Description / Brief
                          if (state.project!.description.isNotEmpty)
                            _GlassDescriptionSection(project: state.project!),
                          // Instructions
                          if (state.project!.instructions != null &&
                              state.project!.instructions!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _InstructionsSection(project: state.project!),
                          ],
                          // Focus Areas
                          if (state.project!.focusAreas != null &&
                              state.project!.focusAreas!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _FocusAreasSection(project: state.project!),
                          ],
                          const SizedBox(height: 24),
                          // People involved
                          _GlassPeopleSection(project: state.project!),
                          const SizedBox(height: 24),
                          // Live Document Link
                          if (state.project!.liveDocumentUrl != null &&
                              state.project!.liveDocumentUrl!.isNotEmpty) ...[
                            _LiveDocumentSection(
                              url: state.project!.liveDocumentUrl!,
                              onOpen: () => _openUrl(state.project!.liveDocumentUrl!),
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Client-uploaded files / attachments
                          if (state.project!.files != null &&
                              state.project!.files!.isNotEmpty) ...[
                            _FilesSection(
                              files: state.project!.files!,
                              onOpenFile: _openUrl,
                            ),
                            const SizedBox(height: 24),
                          ],
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
                          // Quality Check section
                          if (_hasQualityCheckData(state.project!)) ...[
                            _GlassQualityCheckSection(
                              project: state.project!,
                              onOpenReport: _openUrl,
                            ),
                            const SizedBox(height: 24),
                          ],
                          // Pricing breakdown
                          if (state.project!.userQuote != null)
                            _GlassPricingSection(project: state.project!),
                          if (state.project!.userQuote != null)
                            const SizedBox(height: 24),
                          // Timeline
                          _GlassTimelineSection(project: state.project!),
                          // Bottom padding for actions
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
        // Action buttons
        bottomNavigationBar: state.project != null && _showActions(state)
            ? _GlassActionBar(
                state: state,
                onApprove: _approveDeliverable,
                onRevision: _requestRevision,
                onDeliver: _deliverToClient,
              )
            : null,
    );
  }

  bool _hasQualityCheckData(ProjectModel project) {
    return project.aiScore != null ||
        project.plagiarismScore != null ||
        (project.aiReportUrl != null && project.aiReportUrl!.isNotEmpty) ||
        (project.plagiarismReportUrl != null && project.plagiarismReportUrl!.isNotEmpty);
  }

  bool _showActions(ProjectDetailState state) {
    return state.canApprove ||
        state.canRequestRevision ||
        state.project?.status.name == 'approved';
  }

  void _openChat() {
    context.push('${RoutePaths.chat}/${widget.projectId}');
  }

  void _openUrl(String url) {
    ref.read(externalActionsServiceProvider).openUrl(url);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        ref
            .read(projectDetailProvider.notifier)
            .loadProject(widget.projectId);
        break;
      case 'history':
        ref.read(snackbarServiceProvider).showInfo('Project history feature coming soon');
        break;
    }
  }

  void _viewDeliverable(String url) {
    ref.read(externalActionsServiceProvider).openUrl(url);
  }

  void _downloadDeliverable(String url) {
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

/// Glass hero card with project status, title, progress, and deadline.
class _GlassHeroCard extends StatelessWidget {
  const _GlassHeroCard({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 15,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      elevation: 2,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(status: project.status),
                        if (project.isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, size: 14, color: Colors.red),
                                const SizedBox(width: 2),
                                Text(
                                  'URGENT'.tr(context),
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (project.topic != null && project.topic!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.topic!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                    if (project.progressPercentage != null &&
                        project.progressPercentage! > 0) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: project.progressPercentage! / 100.0,
                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  project.progressPercentage! >= 100
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
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
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
          // Financials row
          if (project.userQuote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FinancialItem(
                    label: 'Client Price'.tr(context),
                    value: '\u20b9${(project.userQuote as num).toStringAsFixed(0)}',
                    color: AppColors.textPrimaryLight,
                  ),
                  if (project.supervisorAmount != null)
                    _FinancialItem(
                      label: 'Your Earnings'.tr(context),
                      value: '\u20b9${(project.supervisorAmount as num).toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small financial stat in the hero card.
class _FinancialItem extends StatelessWidget {
  const _FinancialItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Glass info section with project details.
class _GlassInfoSection extends StatelessWidget {
  const _GlassInfoSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Project Details'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          child: Column(
            children: [
              _InfoRow(
                label: 'Subject'.tr(context),
                value: project.subject,
                icon: Icons.book_outlined,
              ),
              if (project.serviceType != null &&
                  project.serviceType!.isNotEmpty)
                _InfoRow(
                  label: 'Service Type'.tr(context),
                  value: _formatServiceType(project.serviceType!),
                  icon: Icons.category_outlined,
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
              _InfoRow(
                label: 'Project #'.tr(context),
                value: project.projectNumber,
                icon: Icons.tag,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatServiceType(String type) {
    return type
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}

/// Glass description / project brief section.
class _GlassDescriptionSection extends StatelessWidget {
  const _GlassDescriptionSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Project Brief'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          width: double.infinity,
          child: Text(
            project.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }
}

/// Instructions section - shows specific instructions from the client.
class _InstructionsSection extends StatelessWidget {
  const _InstructionsSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Specific Instructions'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          borderColor: Colors.amber.withAlpha(50),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  project.instructions!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Focus areas section - shows focus areas as chips.
class _FocusAreasSection extends StatelessWidget {
  const _FocusAreasSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    final areas = project.focusAreas as List<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Focus Areas'.tr(context)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: areas.map((area) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                area,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Glass people section showing client and doer.
class _GlassPeopleSection extends StatelessWidget {
  const _GlassPeopleSection({required this.project});

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
                child: _GlassPersonCard(
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
                child: _GlassPersonCard(
                  name: project.doerName!,
                  role: 'Doer'.tr(context),
                  color: Colors.purple,
                ),
              ),
          ],
        ),
        if (project.clientName == null && project.doerName == null)
          GlassCard(
            blur: 10,
            opacity: 0.6,
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.all(16),
            elevation: 1,
            width: double.infinity,
            child: Text(
              'No participants assigned yet'.tr(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

/// Glass person card widget.
class _GlassPersonCard extends StatelessWidget {
  const _GlassPersonCard({
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
    return GlassCard(
      blur: 10,
      opacity: 0.6,
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.all(12),
      elevation: 1,
      borderColor: color.withAlpha(40),
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
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Live document link section.
class _LiveDocumentSection extends StatelessWidget {
  const _LiveDocumentSection({
    required this.url,
    required this.onOpen,
  });

  final String url;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Live Document'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          borderColor: Colors.blue.withAlpha(40),
          onTap: onOpen,
          width: double.infinity,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.open_in_new, size: 20, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Live Document'.tr(context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.blue),
            ],
          ),
        ),
      ],
    );
  }
}

/// Files/attachments section.
class _FilesSection extends StatelessWidget {
  const _FilesSection({
    required this.files,
    required this.onOpenFile,
  });

  final List<ProjectFile> files;
  final void Function(String url) onOpenFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Shared Documents'.tr(context),
          count: files.length,
        ),
        const SizedBox(height: 12),
        ...files.map((file) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FileCard(
                file: file,
                onTap: () => onOpenFile(file.fileUrl),
              ),
            )),
      ],
    );
  }
}

/// Individual file card widget.
class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.file,
    required this.onTap,
  });

  final ProjectFile file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 8,
      opacity: 0.6,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(12),
      elevation: 1,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _fileColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_fileIcon, size: 20, color: _fileColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (file.formattedSize.isNotEmpty) ...[
                      Text(
                        file.formattedSize,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                    if (file.fileCategory != null &&
                        file.fileCategory!.isNotEmpty) ...[
                      if (file.formattedSize.isNotEmpty)
                        Text(
                          '  |  ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      Text(
                        file.fileCategory!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.download_outlined,
            size: 20,
            color: AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  IconData get _fileIcon {
    final ext = file.extension;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.article;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get _fileColor {
    final ext = file.extension;
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// Glass quality check section.
class _GlassQualityCheckSection extends StatelessWidget {
  const _GlassQualityCheckSection({
    required this.project,
    required this.onOpenReport,
  });

  final ProjectModel project;
  final void Function(String url) onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Quality Check'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          child: Column(
            children: [
              if (project.aiScore != null)
                _QualityRow(
                  label: 'AI Score'.tr(context),
                  score: project.aiScore!,
                  reportUrl: project.aiReportUrl,
                  icon: Icons.smart_toy_outlined,
                  onOpenReport: onOpenReport,
                ),
              if (project.aiScore != null && project.plagiarismScore != null)
                const Divider(height: 20),
              if (project.plagiarismScore != null)
                _QualityRow(
                  label: 'Plagiarism Score'.tr(context),
                  score: project.plagiarismScore!,
                  reportUrl: project.plagiarismReportUrl,
                  icon: Icons.content_copy_outlined,
                  onOpenReport: onOpenReport,
                ),
              if (project.aiScore == null &&
                  project.aiReportUrl != null &&
                  project.aiReportUrl!.isNotEmpty)
                _ReportLink(
                  label: 'AI Report'.tr(context),
                  url: project.aiReportUrl!,
                  icon: Icons.smart_toy_outlined,
                  onOpen: () => onOpenReport(project.aiReportUrl!),
                ),
              if (project.plagiarismScore == null &&
                  project.plagiarismReportUrl != null &&
                  project.plagiarismReportUrl!.isNotEmpty)
                _ReportLink(
                  label: 'Plagiarism Report'.tr(context),
                  url: project.plagiarismReportUrl!,
                  icon: Icons.content_copy_outlined,
                  onOpen: () => onOpenReport(project.plagiarismReportUrl!),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quality score row with optional report link.
class _QualityRow extends StatelessWidget {
  const _QualityRow({
    required this.label,
    required this.score,
    this.reportUrl,
    required this.icon,
    required this.onOpenReport,
  });

  final String label;
  final double score;
  final String? reportUrl;
  final IconData icon;
  final void Function(String url) onOpenReport;

  @override
  Widget build(BuildContext context) {
    final scoreColor = score <= 15
        ? AppColors.success
        : score <= 30
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        const Spacer(),
        Text(
          '${score.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
        ),
        if (reportUrl != null && reportUrl!.isNotEmpty) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () => onOpenReport(reportUrl!),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.open_in_new,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Report link widget (when score is not available but URL is).
class _ReportLink extends StatelessWidget {
  const _ReportLink({
    required this.label,
    required this.url,
    required this.icon,
    required this.onOpen,
  });

  final String label;
  final String url;
  final IconData icon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondaryLight),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const Spacer(),
            Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// Glass pricing section.
class _GlassPricingSection extends StatelessWidget {
  const _GlassPricingSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Pricing Breakdown'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
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

/// Glass timeline section showing key dates with glass milestone cards.
class _GlassTimelineSection extends StatelessWidget {
  const _GlassTimelineSection({required this.project});

  final dynamic project;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy  h:mm a');

    // Build list of timeline events
    final events = <_TimelineEvent>[];

    if (project.createdAt != null) {
      events.add(_TimelineEvent(
        label: 'Created'.tr(context),
        date: project.createdAt,
        icon: Icons.add_circle_outline,
        color: Colors.grey,
      ));
    }
    if (project.paidAt != null) {
      events.add(_TimelineEvent(
        label: 'Payment Received'.tr(context),
        date: project.paidAt!,
        icon: Icons.payment,
        color: Colors.green,
      ));
    }
    if (project.assignedAt != null) {
      events.add(_TimelineEvent(
        label: 'Doer Assigned'.tr(context),
        date: project.assignedAt!,
        icon: Icons.person_add_outlined,
        color: Colors.blue,
      ));
    }
    if (project.startedAt != null) {
      events.add(_TimelineEvent(
        label: 'Work Started'.tr(context),
        date: project.startedAt!,
        icon: Icons.play_circle_outline,
        color: Colors.orange,
      ));
    }
    if (project.deliveredAt != null) {
      events.add(_TimelineEvent(
        label: 'Delivered'.tr(context),
        date: project.deliveredAt!,
        icon: Icons.local_shipping_outlined,
        color: Colors.purple,
      ));
    }
    if (project.completedAt != null) {
      events.add(_TimelineEvent(
        label: 'Completed'.tr(context),
        date: project.completedAt!,
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ));
    }

    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Timeline'.tr(context)),
        const SizedBox(height: 12),
        GlassCard(
          blur: 10,
          opacity: 0.6,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.all(16),
          elevation: 1,
          child: Column(
            children: events.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == events.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline line and dot
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: event.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: event.color.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Event details
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: isLast ? 0 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(event.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Timeline event data.
class _TimelineEvent {
  const _TimelineEvent({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String label;
  final DateTime date;
  final IconData icon;
  final Color color;
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
            '\u20B9${amount.toStringAsFixed(2)}',
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
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass action bar at bottom with AppButton.
class _GlassActionBar extends StatelessWidget {
  const _GlassActionBar({
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
        color: Colors.white.withAlpha(220),
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
                child: AppButton(
                  text: 'Request Revision'.tr(context),
                  variant: AppButtonVariant.secondary,
                  icon: Icons.replay,
                  onPressed: state.isUpdating ? null : onRevision,
                  isFullWidth: true,
                ),
              ),
            if (state.canRequestRevision && state.canApprove)
              const SizedBox(width: 12),
            if (state.canApprove)
              Expanded(
                child: AppButton(
                  text: 'Approve'.tr(context),
                  variant: AppButtonVariant.primary,
                  isLoading: state.isUpdating,
                  onPressed: onApprove,
                  isFullWidth: true,
                ),
              ),
            if (state.project?.status.name == 'approved')
              Expanded(
                child: AppButton(
                  text: 'Deliver to Client'.tr(context),
                  variant: AppButtonVariant.primary,
                  isLoading: state.isUpdating,
                  onPressed: onDeliver,
                  isFullWidth: true,
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
            AppButton(
              text: 'Retry'.tr(context),
              variant: AppButtonVariant.secondary,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

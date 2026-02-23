import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/routes.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_tabs.dart';
import '../widgets/revision_feedback_form.dart';

/// Screen displaying project lists organized by status.
///
/// Shows active, for review, and completed projects in tabs.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _sortMode = 'recent';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(projectsProvider.notifier).selectTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort projects',
            onSelected: (value) {
              setState(() => _sortMode = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: _sortMode == 'recent'
                          ? AppColors.accent
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent',
                      style: TextStyle(
                        color: _sortMode == 'recent'
                            ? AppColors.accent
                            : null,
                        fontWeight: _sortMode == 'recent'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'due_soon',
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: _sortMode == 'due_soon'
                          ? AppColors.accent
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due Soon',
                      style: TextStyle(
                        color: _sortMode == 'due_soon'
                            ? AppColors.accent
                            : null,
                        fontWeight: _sortMode == 'due_soon'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 18,
                      color: _sortMode == 'priority'
                          ? AppColors.accent
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Priority',
                      style: TextStyle(
                        color: _sortMode == 'priority'
                            ? AppColors.accent
                            : null,
                        fontWeight: _sortMode == 'priority'
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(projectsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _SearchBar(
            query: _searchQuery,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          // Pipeline status bar
          _PipelineBar(
            activeCount: state.activeProjects.length,
            reviewCount: state.forReviewProjects.length,
            completedCount: state.completedProjects.length,
            onTap: (index) {
              _tabController.animateTo(index);
            },
          ),
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ProjectTabs(
              tabController: _tabController,
              activeCount: state.activeProjects.length,
              forReviewCount: state.forReviewProjects.length,
              completedCount: state.completedProjects.length,
            ),
          ),
          // Error banner
          if (state.error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(projectsProvider.notifier).clearError(),
                    icon: Icon(Icons.close, color: AppColors.error, size: 18),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active projects
                _ProjectList(
                  projects: state.activeProjects,
                  isLoading: state.isLoading,
                  emptyMessage: 'No active projects',
                  emptyIcon: Icons.pending_outlined,
                  onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
                  onProjectTap: _openProjectDetail,
                  onChatTap: _openChat,
                ),
                // For review projects
                _ProjectList(
                  projects: state.forReviewProjects,
                  isLoading: state.isLoading,
                  emptyMessage: 'No projects awaiting review',
                  emptyIcon: Icons.rate_review_outlined,
                  onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
                  onProjectTap: _openProjectDetail,
                  onChatTap: _openChat,
                  showActions: true,
                  onApprove: _approveProject,
                  onRevision: _requestRevision,
                ),
                // Completed projects
                _ProjectList(
                  projects: state.completedProjects,
                  isLoading: state.isLoading,
                  emptyMessage: 'No completed projects',
                  emptyIcon: Icons.check_circle_outline,
                  onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
                  onProjectTap: _openProjectDetail,
                  onChatTap: _openChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openProjectDetail(String projectId) {
    context.push('${RoutePaths.projects}/$projectId');
  }

  void _openChat(String projectId) {
    context.push('${RoutePaths.chat}/$projectId');
  }

  Future<void> _approveProject(String projectId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Project'),
        content: const Text(
          'Are you sure you want to approve this deliverable? '
          'This will notify the client that the work is ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Approve'),
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
          const SnackBar(
            content: Text('Project approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(projectsProvider.notifier).refresh();
      }
    }
  }

  Future<void> _requestRevision(String projectId) async {
    // Load project first
    await ref.read(projectDetailProvider.notifier).loadProject(projectId);
    final project = ref.read(projectDetailProvider).project;

    if (project == null || !mounted) return;

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
        const SnackBar(
          content: Text('Revision request sent!'),
          backgroundColor: Colors.orange,
        ),
      );
      ref.read(projectsProvider.notifier).refresh();
    }
  }
}

/// Project list widget.
class _ProjectList extends StatelessWidget {
  const _ProjectList({
    required this.projects,
    required this.isLoading,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onRefresh,
    required this.onProjectTap,
    this.onChatTap,
    this.showActions = false,
    this.onApprove,
    this.onRevision,
  });

  final List projects;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final void Function(String projectId) onProjectTap;
  final void Function(String projectId)? onChatTap;
  final bool showActions;
  final void Function(String projectId)? onApprove;
  final void Function(String projectId)? onRevision;

  @override
  Widget build(BuildContext context) {
    if (isLoading && projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (projects.isEmpty) {
      return _EmptyState(
        message: emptyMessage,
        icon: emptyIcon,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ProjectCard(
            project: project,
            onTap: () => onProjectTap(project.id),
            onChatTap: onChatTap != null ? () => onChatTap!(project.id) : null,
            showActions: showActions,
            onApprove: onApprove != null ? () => onApprove!(project.id) : null,
            onRevision:
                onRevision != null ? () => onRevision!(project.id) : null,
          );
        },
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search bar widget for filtering projects by name or number.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.query,
    required this.onChanged,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(color: AppColors.textTertiaryLight),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondaryLight),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.textSecondaryLight),
                  onPressed: () => onChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Pipeline status bar showing colored count pills for each project status.
class _PipelineBar extends StatelessWidget {
  const _PipelineBar({
    required this.activeCount,
    required this.reviewCount,
    required this.completedCount,
    required this.onTap,
  });

  final int activeCount;
  final int reviewCount;
  final int completedCount;
  final void Function(int tabIndex) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _StatusPill(
            label: 'Active',
            count: activeCount,
            color: AppColors.statusInProgress,
            onTap: () => onTap(0),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: 'Review',
            count: reviewCount,
            color: AppColors.accent,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 8),
          _StatusPill(
            label: 'Completed',
            count: completedCount,
            color: AppColors.success,
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

/// Individual colored pill showing a status label and count.
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$label: $count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

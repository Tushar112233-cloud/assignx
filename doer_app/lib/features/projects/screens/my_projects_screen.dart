/// My Projects screen showing all doer projects organized by status tabs.
///
/// Displays a large header with project count, stat cards, search bar,
/// pill-shaped tab filters, and glass-morphism project cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../providers/projects_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_indicator.dart';

/// Main My Projects screen with tabbed project lists.
class MyProjectsScreen extends ConsumerStatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  ConsumerState<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends ConsumerState<MyProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(myProjectsProvider);
    final stats = projectsState.stats;
    final totalProjects = stats.totalCount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: projectsState.isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(myProjectsProvider.notifier).refresh(),
              color: AppColors.accent,
              child: CustomScrollView(
                slivers: [
                  // Top safe area padding
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.top + AppSpacing.md,
                    ),
                  ),

                  // Large header with project count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Projects'.tr(context),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$totalProjects ${'projects total'.tr(context)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // Stat cards row: Active Projects / Completed
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.rocket_launch_rounded,
                              iconColor: AppColors.info,
                              label: 'Active Projects'.tr(context),
                              value: '${stats.activeCount}',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.check_circle_rounded,
                              iconColor: AppColors.success,
                              label: 'Completed'.tr(context),
                              value: '${stats.completedCount}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // Browse Open Pool card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: _BrowseOpenPoolCard(
                        onTap: () => context.push('/open-pool'),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: _GlassSearchBar(
                        controller: _searchController,
                        onChanged: (query) => ref
                            .read(myProjectsProvider.notifier)
                            .setSearchQuery(query),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),

                  // Pill-shaped tab bar
                  SliverToBoxAdapter(
                    child: _PillTabBar(
                      tabController: _tabController,
                      activeCount:
                          projectsState.filteredActiveProjects.length,
                      reviewCount:
                          projectsState.filteredUnderReviewProjects.length,
                      completedCount:
                          projectsState.filteredCompletedProjects.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),

                  // Project list for current tab
                  _buildProjectList(projectsState),

                  // Bottom padding for nav bar clearance
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }

  /// Builds the project list sliver for the currently selected tab.
  Widget _buildProjectList(MyProjectsState projectsState) {
    final List<DoerProjectModel> projects;
    final IconData emptyIcon;
    final String emptyTitle;
    final String emptyDescription;

    switch (_tabController.index) {
      case 0:
        projects = projectsState.filteredActiveProjects;
        emptyIcon = Icons.assignment_outlined;
        emptyTitle = 'No Active Projects'.tr(context);
        emptyDescription =
            'You don\'t have any active projects right now. Check the dashboard for available projects.'
                .tr(context);
      case 1:
        projects = projectsState.filteredUnderReviewProjects;
        emptyIcon = Icons.rate_review_outlined;
        emptyTitle = 'Nothing Under Review'.tr(context);
        emptyDescription =
            'No projects are currently being reviewed. Submit your work to see them here.'
                .tr(context);
      case 2:
        projects = projectsState.filteredCompletedProjects;
        emptyIcon = Icons.check_circle_outline;
        emptyTitle = 'No Completed Projects'.tr(context);
        emptyDescription =
            'Completed projects will appear here once they are approved.'
                .tr(context);
      default:
        projects = [];
        emptyIcon = Icons.folder_open;
        emptyTitle = 'No Projects';
        emptyDescription = '';
    }

    if (projects.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          description: emptyDescription,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final project = projects[index];
          return _GlassProjectCard(
            project: project,
            onTap: () => context.push('/project/${project.id}'),
          );
        },
        childCount: projects.length,
      ),
    );
  }
}

// =============================================================================
// Stat Card
// =============================================================================

/// Stat card showing a metric inside a GlassContainer.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 12,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Browse Open Pool Card
// =============================================================================

/// Dark gradient card prompting the doer to browse the open project pool.
class _BrowseOpenPoolCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _BrowseOpenPoolCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientMiddle],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse Open Pool'.tr(context),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Find new projects to work on'.tr(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Glass Search Bar
// =============================================================================

/// Search bar inside a GlassContainer with search icon.
class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GlassSearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.75,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textTertiary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search projects...'.tr(context),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Pill Tab Bar
// =============================================================================

/// Pill-shaped tab bar with accent-filled active tab and glass inactive tabs.
class _PillTabBar extends StatelessWidget {
  final TabController tabController;
  final int activeCount;
  final int reviewCount;
  final int completedCount;

  const _PillTabBar({
    required this.tabController,
    required this.activeCount,
    required this.reviewCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _PillTab(
                label: '${'Active'.tr(context)} ($activeCount)',
                isSelected: tabController.index == 0,
                onTap: () => tabController.animateTo(0),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PillTab(
                label: '${'Review'.tr(context)} ($reviewCount)',
                isSelected: tabController.index == 1,
                onTap: () => tabController.animateTo(1),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PillTab(
                label: '${'Completed'.tr(context)} ($completedCount)',
                isSelected: tabController.index == 2,
                onTap: () => tabController.animateTo(2),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual pill tab widget.
class _PillTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.border.withAlpha(80),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Glass Project Card
// =============================================================================

/// Glass-morphism project card with status badge, title, ID, deadline,
/// and earnings.
class _GlassProjectCard extends StatelessWidget {
  final DoerProjectModel project;
  final VoidCallback? onTap;

  const _GlassProjectCard({
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(project.status);
    final remaining = project.timeRemaining;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 1,
      ),
      child: GlassCard(
        onTap: onTap,
        blur: 10,
        opacity: 0.8,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: status badge + urgent indicator
            Row(
              children: [
                // Status pill badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: statusColor.withAlpha(50),
                    ),
                  ),
                  child: Text(
                    project.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                if (project.isUrgent) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.urgentBg,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: AppColors.urgent,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Urgent'.tr(context),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.urgent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: AppSpacing.sm + 2),

            // Project title (bold)
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.xs),

            // Project ID subtitle
            Text(
              project.projectNumber,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Bottom row: deadline with icon + earnings with rupee icon
            Row(
              children: [
                // Deadline
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: _getDeadlineColor(remaining),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDeadline(remaining),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getDeadlineColor(remaining),
                  ),
                ),

                const Spacer(),

                // Earnings with rupee icon
                const Icon(
                  Icons.currency_rupee_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 2),
                Text(
                  project.doerPayout.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the color for the project status badge.
  Color _getStatusColor(DoerProjectStatus status) {
    switch (status) {
      case DoerProjectStatus.inProgress:
        return AppColors.info;
      case DoerProjectStatus.assigned:
        return AppColors.accent;
      case DoerProjectStatus.revisionRequested:
      case DoerProjectStatus.inRevision:
        return AppColors.error;
      case DoerProjectStatus.delivered:
      case DoerProjectStatus.submittedForQc:
        return AppColors.warning;
      case DoerProjectStatus.completed:
      case DoerProjectStatus.autoApproved:
        return AppColors.success;
      case DoerProjectStatus.cancelled:
      case DoerProjectStatus.refunded:
        return AppColors.textTertiary;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Returns the color for the deadline based on urgency.
  Color _getDeadlineColor(Duration remaining) {
    if (remaining.isNegative) return AppColors.error;
    if (remaining.inHours < 24) return AppColors.error;
    if (remaining.inHours < 72) return AppColors.warning;
    return AppColors.textSecondary;
  }

  /// Formats the remaining time until deadline as a human-readable string.
  String _formatDeadline(Duration remaining) {
    if (remaining.isNegative) {
      final overdue = remaining.abs();
      if (overdue.inDays > 0) return '${overdue.inDays}d overdue';
      return '${overdue.inHours}h overdue';
    }
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h left';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    }
    return '${remaining.inMinutes}m left';
  }
}

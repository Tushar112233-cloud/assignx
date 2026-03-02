/// My Projects screen showing all doer projects organized by status tabs.
///
/// Displays a hero stats banner, insights row, search/filter/sort bar,
/// and three tabs: Active Projects, Under Review, and Completed.
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
import '../../../shared/widgets/loading_indicator.dart';
import '../../dashboard/widgets/app_header.dart';
import '../widgets/project_filter_bar.dart';
import '../widgets/project_hero_banner.dart';
import '../widgets/project_insights_row.dart';
import '../widgets/project_list_card.dart';

/// Main My Projects screen with tabbed project lists.
class MyProjectsScreen extends ConsumerStatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  ConsumerState<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends ConsumerState<MyProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(myProjectsProvider);
    final stats = projectsState.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          InnerHeader(
            title: 'My Projects'.tr(context),
            onBack: () => Navigator.pop(context),
          ),

          // Scrollable content
          Expanded(
            child: projectsState.isLoading
                ? const Center(child: LoadingIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(myProjectsProvider.notifier).refresh(),
                    color: AppColors.accent,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          // Hero banner
                          SliverToBoxAdapter(
                            child: ProjectHeroBanner(stats: stats),
                          ),

                          // Insights row (collapsible)
                          SliverToBoxAdapter(
                            child: ProjectInsightsRow(stats: stats),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.md),
                          ),

                          // Filter bar with sort
                          SliverToBoxAdapter(
                            child: ProjectFilterBar(
                              searchQuery: projectsState.searchQuery,
                              selectedSubject: projectsState.subjectFilter,
                              availableSubjects:
                                  projectsState.availableSubjects,
                              sortOption: projectsState.sortOption,
                              onSearchChanged: (query) => ref
                                  .read(myProjectsProvider.notifier)
                                  .setSearchQuery(query),
                              onSubjectChanged: (subject) => ref
                                  .read(myProjectsProvider.notifier)
                                  .setSubjectFilter(subject),
                              onSortChanged: (option) => ref
                                  .read(myProjectsProvider.notifier)
                                  .setSortOption(option),
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.md),
                          ),

                          // Pipeline stats bar
                          SliverToBoxAdapter(
                            child: _PipelineStatsBar(
                              activeCount: projectsState
                                  .filteredActiveProjects.length,
                              reviewCount: projectsState
                                  .filteredUnderReviewProjects.length,
                              completedCount: projectsState
                                  .filteredCompletedProjects.length,
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.sm),
                          ),

                          // Tab bar
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _TabBarDelegate(
                              tabController: _tabController,
                              activeCount: projectsState
                                  .filteredActiveProjects.length,
                              reviewCount: projectsState
                                  .filteredUnderReviewProjects.length,
                              completedCount: projectsState
                                  .filteredCompletedProjects.length,
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          // Active projects tab
                          _ProjectList(
                            projects: projectsState.filteredActiveProjects,
                            emptyIcon: Icons.assignment_outlined,
                            emptyTitle: 'No Active Projects'.tr(context),
                            emptyDescription:
                                'You don\'t have any active projects right now. Check the dashboard for available projects.'
                                    .tr(context),
                          ),

                          // Under review tab
                          _ProjectList(
                            projects:
                                projectsState.filteredUnderReviewProjects,
                            emptyIcon: Icons.rate_review_outlined,
                            emptyTitle: 'Nothing Under Review'.tr(context),
                            emptyDescription:
                                'No projects are currently being reviewed. Submit your work to see them here.'
                                    .tr(context),
                          ),

                          // Completed tab
                          _ProjectList(
                            projects: projectsState.filteredCompletedProjects,
                            emptyIcon: Icons.check_circle_outline,
                            emptyTitle: 'No Completed Projects'.tr(context),
                            emptyDescription:
                                'Completed projects will appear here once they are approved.'
                                    .tr(context),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Pipeline stats bar showing counts per status as a visual bar.
class _PipelineStatsBar extends StatelessWidget {
  final int activeCount;
  final int reviewCount;
  final int completedCount;

  const _PipelineStatsBar({
    required this.activeCount,
    required this.reviewCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = activeCount + reviewCount + completedCount;
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual pipeline bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (activeCount > 0)
                    Expanded(
                      flex: activeCount,
                      child: Container(color: AppColors.info),
                    ),
                  if (reviewCount > 0)
                    Expanded(
                      flex: reviewCount,
                      child: Container(color: AppColors.warning),
                    ),
                  if (completedCount > 0)
                    Expanded(
                      flex: completedCount,
                      child: Container(color: AppColors.success),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Labels row
          Row(
            children: [
              _PipelineDot(
                color: AppColors.info,
                label: '$activeCount ${'Active'.tr(context)}',
              ),
              const SizedBox(width: AppSpacing.md),
              _PipelineDot(
                color: AppColors.warning,
                label: '$reviewCount ${'Review'.tr(context)}',
              ),
              const SizedBox(width: AppSpacing.md),
              _PipelineDot(
                color: AppColors.success,
                label: '$completedCount ${'Done'.tr(context)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineDot extends StatelessWidget {
  final Color color;
  final String label;

  const _PipelineDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// A list of project cards with empty state handling.
class _ProjectList extends StatelessWidget {
  final List<DoerProjectModel> projects;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;

  const _ProjectList({
    required this.projects,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        description: emptyDescription,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xxl,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectListCard(
          project: project,
          onTap: () => context.push('/project/${project.id}'),
        );
      },
    );
  }
}

/// Delegate for the pinned tab bar header inside NestedScrollView.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final int activeCount;
  final int reviewCount;
  final int completedCount;

  _TabBarDelegate({
    required this.tabController,
    required this.activeCount,
    required this.reviewCount,
    required this.completedCount,
  });

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: '${'Active'.tr(context)} ($activeCount)'),
          Tab(text: '${'Review'.tr(context)} ($reviewCount)'),
          Tab(text: '${'Completed'.tr(context)} ($completedCount)'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.activeCount != activeCount ||
        oldDelegate.reviewCount != reviewCount ||
        oldDelegate.completedCount != completedCount;
  }
}

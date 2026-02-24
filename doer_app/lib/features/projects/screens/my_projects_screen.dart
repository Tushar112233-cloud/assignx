/// My Projects screen showing all doer projects organized by status tabs.
///
/// Displays a hero stats banner, search/filter bar, and three tabs:
/// Active Projects, Under Review, and Completed.
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

                          // Filter bar
                          SliverToBoxAdapter(
                            child: ProjectFilterBar(
                              searchQuery: projectsState.searchQuery,
                              selectedSubject: projectsState.subjectFilter,
                              availableSubjects:
                                  projectsState.availableSubjects,
                              onSearchChanged: (query) => ref
                                  .read(myProjectsProvider.notifier)
                                  .setSearchQuery(query),
                              onSubjectChanged: (subject) => ref
                                  .read(myProjectsProvider.notifier)
                                  .setSubjectFilter(subject),
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppSpacing.md),
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
                                'You don\'t have any active projects right now. Check the dashboard for available projects.'.tr(context),
                          ),

                          // Under review tab
                          _ProjectList(
                            projects:
                                projectsState.filteredUnderReviewProjects,
                            emptyIcon: Icons.rate_review_outlined,
                            emptyTitle: 'Nothing Under Review'.tr(context),
                            emptyDescription:
                                'No projects are currently being reviewed. Submit your work to see them here.'.tr(context),
                          ),

                          // Completed tab
                          _ProjectList(
                            projects: projectsState.filteredCompletedProjects,
                            emptyIcon: Icons.check_circle_outline,
                            emptyTitle: 'No Completed Projects'.tr(context),
                            emptyDescription:
                                'Completed projects will appear here once they are approved.'.tr(context),
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

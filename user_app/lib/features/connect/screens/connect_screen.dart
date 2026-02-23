import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/tutor_model.dart';
import '../../../providers/connect_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../marketplace/widgets/tutor_card.dart';
import '../../marketplace/widgets/tutor_profile_sheet.dart';
import '../../marketplace/widgets/book_session_sheet.dart';
import '../widgets/advanced_filter_sheet.dart';
import '../widgets/connect_search.dart';
import '../widgets/resource_cards.dart';
import '../widgets/study_group_card.dart';

/// Main Connect screen with tabs for Tutors, Study Groups, and Resources.
///
/// Features a curved hero section, search bar, and tabbed content areas.
/// Uses the marketplace styling with glassmorphic design.
class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Clear search when switching tabs
        ref.read(connectFilterProvider.notifier).setSearchQuery(null);
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
    final filters = ref.watch(connectFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.center,
        opacity: 0.5,
        colors: [
          AppColors.meshPink,
          AppColors.meshPeach,
          AppColors.meshOrange,
        ],
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Curved dome hero section
              SliverToBoxAdapter(
                child: _CurvedDomeHero(),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: ConnectSearchBar(
                    showFilterButton: true,
                    activeFilterCount: filters.activeFilterCount,
                    onFilterTap: () => AdvancedFilterSheet.show(context),
                    onSearchSubmit: (query) {
                      // Search is handled via provider
                    },
                  ),
                ),
              ),

              // Tab bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabController: _tabController,
                  filters: filters,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _TutorsTab(),
              _StudyGroupsTab(),
              _ResourcesTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Curved dome hero section with gradient background.
class _CurvedDomeHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.darkBrown,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Learn together, grow together',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper for curved bottom edge.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Tab bar delegate for persistent header.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final ConnectFilterState filters;

  _TabBarDelegate({
    required this.tabController,
    required this.filters,
  });

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background.withAlpha(240),
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelLarge,
        tabs: const [
          Tab(text: 'Tutors'),
          Tab(text: 'Study Groups'),
          Tab(text: 'Resources'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabController != oldDelegate.tabController;
  }
}

/// Tutors tab content.
class _TutorsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorsAsync = ref.watch(connectTutorsProvider);
    final filters = ref.watch(connectFilterProvider);

    return CustomScrollView(
      slivers: [
        // Active filters display
        if (filters.hasFilters)
          SliverToBoxAdapter(
            child: _ActiveFiltersDisplay(
              onClear: () => ref.read(connectFilterProvider.notifier).clearFilters(),
            ),
          ),

        // Featured section header
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Expert Tutors',
            subtitle: 'Book 1-on-1 sessions',
            icon: Icons.school_rounded,
          ),
        ),

        // Tutors grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: tutorsAsync.when(
            data: (tutors) {
              if (tutors.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.person_search,
                    title: 'No tutors found',
                    subtitle: filters.hasFilters
                        ? 'Try adjusting your filters'
                        : 'Check back later for new tutors',
                    showClearButton: filters.hasFilters,
                    onClear: () =>
                        ref.read(connectFilterProvider.notifier).clearFilters(),
                  ),
                );
              }

              return SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: tutors.length,
                itemBuilder: (context, index) {
                  final tutor = tutors[index];
                  return TutorCard(
                    tutor: tutor,
                    onTap: () => _showTutorProfile(context, ref, tutor),
                    onBook: () => _showBookSession(context, tutor),
                  );
                },
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TutorCardSkeleton(),
                ),
                childCount: 4,
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: _ErrorState(
                error: error.toString(),
                onRetry: () => ref.invalidate(connectTutorsProvider),
              ),
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  void _showTutorProfile(BuildContext context, WidgetRef ref, Tutor tutor) {
    TutorProfileSheet.show(
      context: context,
      tutor: tutor,
      onBookSession: () {
        Navigator.of(context).pop();
        _showBookSession(context, tutor);
      },
      onAskQuestion: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ask question feature coming soon!')),
        );
      },
    );
  }

  void _showBookSession(BuildContext context, Tutor tutor) {
    BookSessionSheet.show(
      context: context,
      tutor: tutor,
      onBookingComplete: (session) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session booked with ${tutor.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }
}

/// Study Groups tab content.
class _StudyGroupsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(studyGroupsProvider);
    final userGroupsAsync = ref.watch(userStudyGroupsProvider);
    final filters = ref.watch(connectFilterProvider);

    return CustomScrollView(
      slivers: [
        // Active filters display
        if (filters.hasFilters)
          SliverToBoxAdapter(
            child: _ActiveFiltersDisplay(
              onClear: () => ref.read(connectFilterProvider.notifier).clearFilters(),
            ),
          ),

        // My groups section
        SliverToBoxAdapter(
          child: userGroupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'My Groups',
                    icon: Icons.group,
                    onSeeAll: () => context.push('/connect/groups'),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return CompactStudyGroupCard(
                          group: groups[index],
                          isJoined: true,
                          onTap: () {},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // Available groups header
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Available Groups',
            subtitle: 'Join a group to study together',
            icon: Icons.groups_rounded,
            onSeeAll: () => context.push('/connect/groups'),
          ),
        ),

        // Groups list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: groupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.group_add,
                    title: 'No groups found',
                    subtitle: filters.hasFilters
                        ? 'Try adjusting your filters'
                        : 'Be the first to create a study group!',
                    showClearButton: filters.hasFilters,
                    onClear: () =>
                        ref.read(connectFilterProvider.notifier).clearFilters(),
                  ),
                );
              }

              final userGroups = userGroupsAsync.valueOrNull ?? [];

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = groups[index];
                    final isJoined = userGroups.any((g) => g.id == group.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StudyGroupCard(
                        group: group,
                        isJoined: isJoined,
                        onTap: () {},
                        onJoinLeave: () {
                          final message = isJoined
                              ? 'Left ${group.name}'
                              : 'Joined ${group.name}!';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor:
                                  isJoined ? AppColors.textSecondary : AppColors.success,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: groups.length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupCardSkeleton(),
                ),
                childCount: 4,
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: _ErrorState(
                error: error.toString(),
                onRetry: () => ref.invalidate(studyGroupsProvider),
              ),
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

/// Resources tab content.
class _ResourcesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(sharedResourcesProvider);
    final filters = ref.watch(connectFilterProvider);

    return CustomScrollView(
      slivers: [
        // Resource type filters
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ResourceTypeChips(
              selectedType: filters.resourceType,
              onTypeSelected: (type) {
                ref.read(connectFilterProvider.notifier).setResourceType(type);
              },
            ),
          ),
        ),

        // Active filters display
        if (filters.hasFilters)
          SliverToBoxAdapter(
            child: _ActiveFiltersDisplay(
              onClear: () => ref.read(connectFilterProvider.notifier).clearFilters(),
            ),
          ),

        // Featured section header
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Study Materials',
            subtitle: 'Notes, videos, and more',
            icon: Icons.folder_open_rounded,
            onSeeAll: () => context.push('/connect/resources'),
          ),
        ),

        // Resources list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: resourcesAsync.when(
            data: (resources) {
              if (resources.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.folder_off_outlined,
                    title: 'No resources found',
                    subtitle: filters.hasFilters
                        ? 'Try adjusting your filters'
                        : 'Be the first to share study materials!',
                    showClearButton: filters.hasFilters,
                    onClear: () =>
                        ref.read(connectFilterProvider.notifier).clearFilters(),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final resource = resources[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ResourceCard(
                        resource: resource,
                        onTap: () {},
                        onSave: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved ${resource.title}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        onDownload: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${resource.title}...'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: resources.length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResourceCardSkeleton(),
                ),
                childCount: 4,
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: _ErrorState(
                error: error.toString(),
                onRetry: () => ref.invalidate(sharedResourcesProvider),
              ),
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(26),
                      AppColors.primaryLight.withAlpha(26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (onSeeAll != null)
            GlassContainer(
              blur: 8,
              opacity: 0.6,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Active filters display chip.
class _ActiveFiltersDisplay extends StatelessWidget {
  final VoidCallback onClear;

  const _ActiveFiltersDisplay({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        blur: 10,
        opacity: 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Filtered results',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Clear all',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showClearButton;
  final VoidCallback? onClear;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showClearButton = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (showClearButton && onClear != null) ...[
            const SizedBox(height: 16),
            GlassButton(
              label: 'Clear Filters',
              icon: Icons.filter_alt_off,
              onPressed: onClear,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fullWidth: false,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: onRetry,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            fullWidth: false,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for tutor card.
class _TutorCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonLoader.circle(size: 56),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 14, width: 80),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 10, width: 60),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SkeletonLoader(height: 22, width: 120),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 16, width: 60),
              SkeletonLoader(height: 32, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for group card.
class _GroupCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonLoader(height: 48, width: 48, borderRadius: 12),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 14, width: 120),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 18, width: 80),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 12, width: double.infinity),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 12, width: 100),
              SkeletonLoader(height: 28, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for resource card.
class _ResourceCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonLoader(height: 44, width: 44, borderRadius: 12),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 14, width: 140),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 18, width: 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 12, width: double.infinity),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 12, width: 200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 12, width: 80),
              SkeletonLoader(height: 32, width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

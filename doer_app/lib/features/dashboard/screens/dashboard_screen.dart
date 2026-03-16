import '../../../data/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/assigned_task_card.dart';
import '../widgets/task_pool_card.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/navigation_provider.dart';

/// Main dashboard screen matching the doer-web design.
///
/// Layout:
/// 1. Greeting header with notification bell
/// 2. Hero banner with motivational message + workspace status
/// 3. Stat cards row (Assigned, Available, Urgent, Earnings)
/// 4. Performance summary cards
/// 5. Task sections with tabs (Assigned to Me / Open Pool)
///
/// Provider watches are split into focused ConsumerWidget children
/// so that only the relevant section rebuilds when data changes.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _DashboardLoadingWrapper(
        tabController: _tabController,
        onTabChanged: (index) => setState(() => _tabController.animateTo(index)),
      ),
    );
  }
}

// =============================================================================
// Loading wrapper - watches only isLoading from dashboardProvider
// =============================================================================

class _DashboardLoadingWrapper extends ConsumerWidget {
  final TabController tabController;
  final ValueChanged<int> onTabChanged;

  const _DashboardLoadingWrapper({
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      dashboardProvider.select((s) => s.isLoading),
    );

    return LoadingOverlay(
      isLoading: isLoading,
      child: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Greeting header - watches currentUserProvider
            const SliverToBoxAdapter(child: _GreetingHeader()),

            // Hero banner - watches dashboardProvider + currentUserProvider
            const SliverToBoxAdapter(child: _HeroBannerSection()),

            // Stat cards grid - watches doerStatsProvider + dashboardProvider
            const SliverToBoxAdapter(child: _StatsGridSection()),

            // Performance + Priority row - watches doerStatsProvider + dashboardProvider
            const SliverToBoxAdapter(child: _PerformanceRowSection()),

            // Tasks section header - watches dashboardProvider
            const SliverToBoxAdapter(child: _TasksSectionHeader()),

            // Task tab bar + content - watches dashboardProvider
            SliverToBoxAdapter(
              child: _TaskTabBar(
                tabController: tabController,
                onTabChanged: onTabChanged,
              ),
            ),

            // Task content
            _TaskContentSection(
              tabIndex: tabController.index,
            ),

            // Bottom padding for floating nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Greeting Header - watches only currentUserProvider
// =============================================================================

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.fullName ?? 'Dolancer';
    final firstName = displayName.split(' ').first;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            // AX Logo badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'AX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AssignX Dolancer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Freelancer Portal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell
            _buildHeaderIcon(
              context,
              Icons.notifications_outlined,
              () => context.push('/notifications'),
              showBadge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, size: 20, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
          ),
        ),
        if (showBadge)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Hero Banner Section - watches dashboardProvider + currentUserProvider
// =============================================================================

class _HeroBannerSection extends ConsumerWidget {
  const _HeroBannerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.fullName ?? 'Dolancer').split(' ').first;
    final activeCount = dashboardState.assignedProjects
        .where((p) =>
            p.status == DoerProjectStatus.inProgress ||
            p.status == DoerProjectStatus.assigned)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2FF), // light indigo
              Color(0xFFF3F5FF), // pale blue
              Color(0xFFE9FAFA), // cyan wash
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workspace active badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Workspace active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Greeting
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  height: 1.3,
                  fontFamily: 'Inter',
                ),
                children: [
                  TextSpan(text: '${_getGreeting(context)}, '),
                  TextSpan(
                    text: firstName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your workspace is ready. Explore new opportunities and keep your momentum going.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Quick stats row
            Row(
              children: [
                _HeroPill(
                  value: '$activeCount',
                  label: 'active',
                  color: AppColors.info,
                ),
                const SizedBox(width: 16),
                _HeroPill(
                  value: '${dashboardState.openPoolProjects.length}',
                  label: 'available',
                  color: AppColors.success,
                ),
                const SizedBox(width: 16),
                _HeroPill(
                  value: '${_getUrgentCount(dashboardState)}',
                  label: 'urgent',
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // CTA buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(navigationIndexProvider.notifier).setIndex(1);
                    },
                    icon: const Icon(Icons.explore_rounded, size: 18),
                    label: const Text('Explore projects'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.push('/dashboard/statistics'),
                  child: const Text('View insights'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning'.tr(context);
    if (hour < 17) return 'Good afternoon'.tr(context);
    return 'Good evening'.tr(context);
  }

  int _getUrgentCount(DashboardState dashboardState) {
    return dashboardState.assignedProjects
        .where((p) => p.isUrgent)
        .length;
  }
}

// =============================================================================
// Stats Grid Section - watches doerStatsProvider + dashboardProvider
// =============================================================================

class _StatsGridSection extends ConsumerWidget {
  const _StatsGridSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(doerStatsProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final urgentCount = dashboardState.assignedProjects
        .where((p) => p.isUrgent)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _WebStatCard(
                  icon: Icons.assignment_rounded,
                  iconColor: AppColors.info,
                  title: 'ASSIGNED TASKS',
                  value: '${stats.activeProjects}',
                  subtitle: '${stats.activeProjects} in progress',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WebStatCard(
                  icon: Icons.group_work_rounded,
                  iconColor: AppColors.accent,
                  title: 'AVAILABLE TASKS',
                  value: '${dashboardState.openPoolProjects.length}',
                  subtitle: 'In open pool',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _WebStatCard(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.error,
                  title: 'URGENT',
                  value: '$urgentCount',
                  subtitle: 'Need attention',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WebStatCard(
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppColors.success,
                  title: 'EARNINGS',
                  value: '\u20B9${_formatEarnings(dashboardState.pendingEarnings)}',
                  subtitle: 'Total available',
                  isHighlighted: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatEarnings(double earnings) {
    if (earnings >= 100000) {
      return '${(earnings / 1000).toStringAsFixed(0)}K';
    } else if (earnings >= 1000) {
      return '${(earnings / 1000).toStringAsFixed(1)}K';
    }
    return earnings.toStringAsFixed(0);
  }
}

// =============================================================================
// Performance Row Section - watches doerStatsProvider + dashboardProvider
// =============================================================================

class _PerformanceRowSection extends ConsumerWidget {
  const _PerformanceRowSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(doerStatsProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final urgentCount = dashboardState.assignedProjects
        .where((p) => p.isUrgent)
        .length;

    final completionRate = stats.completedProjects > 0
        ? ((stats.completedProjects /
                    (stats.completedProjects + stats.activeProjects)) *
                100)
            .round()
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Performance card
          Expanded(
            child: _PerformanceCard(
              title: 'Performance',
              subtitle: 'Delivery health',
              items: [
                _PerfItem('Completion rate', '$completionRate%'),
                _PerfItem('Active tasks', '${stats.activeProjects}'),
                _PerfItem('Urgent tasks', '$urgentCount'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Priority tasks card
          Expanded(
            child: _PriorityCard(
              urgentCount: urgentCount,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tasks Section Header - watches dashboardProvider
// =============================================================================

class _TasksSectionHeader extends StatelessWidget {
  const _TasksSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your tasks',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Review assigned work and pick from the pool',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Task Tab Bar - watches dashboardProvider for pool count badge
// =============================================================================

class _TaskTabBar extends ConsumerWidget {
  final TabController tabController;
  final ValueChanged<int> onTabChanged;

  const _TaskTabBar({
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolCount = ref.watch(
      dashboardProvider.select((s) => s.openPoolProjects.length),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _TaskTab(
            icon: Icons.assignment_rounded,
            label: 'Assigned to Me',
            isActive: tabController.index == 0,
            onTap: () => onTabChanged(0),
          ),
          const SizedBox(width: 8),
          _TaskTab(
            icon: Icons.group_work_rounded,
            label: 'Open Pool',
            count: poolCount,
            isActive: tabController.index == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Task Content Section - watches dashboardProvider
// =============================================================================

class _TaskContentSection extends ConsumerWidget {
  final int tabIndex;

  const _TaskContentSection({
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    if (tabIndex == 0) {
      return _buildAssignedContent(context, ref, dashboardState);
    } else {
      return _buildPoolContent(context, ref, dashboardState);
    }
  }

  Widget _buildAssignedContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState dashboardState,
  ) {
    if (dashboardState.assignedProjects.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyAssignedTasks());
    }
    return SliverToBoxAdapter(
      child: _buildAssignedTasksList(context, dashboardState.assignedProjects),
    );
  }

  Widget _buildPoolContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState dashboardState,
  ) {
    if (dashboardState.openPoolProjects.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyTaskPool());
    }
    final sorted = _sortedPoolProjects(dashboardState.openPoolProjects);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final project = sorted[index];
            return RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TaskPoolCard(
                  project: project,
                  onTap: () => context.push('/project/${project.id}'),
                  onAccept: () => _confirmAccept(context, ref, project),
                ),
              ),
            );
          },
          childCount: sorted.length,
        ),
      ),
    );
  }

  Widget _buildAssignedTasksList(
    BuildContext context,
    List<DoerProjectModel> projects,
  ) {
    final sorted = List<DoerProjectModel>.from(projects)
      ..sort((a, b) {
        if (a.hasRevision && !b.hasRevision) return -1;
        if (!a.hasRevision && b.hasRevision) return 1;
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return a.deadline.compareTo(b.deadline);
      });

    final display = sorted.take(5).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75 < 300 ? screenWidth * 0.75 : 300.0;

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: display.length,
        itemBuilder: (context, index) {
          final project = display[index];
          return RepaintBoundary(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < display.length - 1 ? AppSpacing.md : 0,
              ),
              child: SizedBox(
                width: cardWidth,
                child: AssignedTaskCard(
                  project: project,
                  onTap: () => context.push('/project/${project.id}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<DoerProjectModel> _sortedPoolProjects(
      List<DoerProjectModel> projects) {
    return List<DoerProjectModel>.from(projects)
      ..sort((a, b) {
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return a.deadline.compareTo(b.deadline);
      });
  }

  void _confirmAccept(
    BuildContext context,
    WidgetRef ref,
    DoerProjectModel project,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Project'.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to accept this project?'.tr(context),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: AppSpacing.paddingSm,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee,
                          size: 14, color: AppColors.success),
                      Text(
                        project.price.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDeadline(context, project.deadline),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptProject(context, ref, project.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Accept'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptProject(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) async {
    final success = await ref
        .read(dashboardProvider.notifier)
        .acceptProject(projectId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project accepted successfully!'.tr(context)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatDeadline(BuildContext context, DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h ${'left'.tr(context)}';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m ${'left'.tr(context)}';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${'left'.tr(context)}';
    } else {
      return 'Due soon'.tr(context);
    }
  }
}

// =============================================================================
// Hero Pill - inline stat in the hero banner
// =============================================================================

class _HeroPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HeroPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Web-style Stat Card
// =============================================================================

class _WebStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isHighlighted;

  const _WebStatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              )
            : null,
        color: isHighlighted ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? null
            : Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.white.withValues(alpha: 0.2)
                  : iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isHighlighted ? Colors.white : iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isHighlighted
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isHighlighted ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isHighlighted
                  ? Colors.white.withValues(alpha: 0.6)
                  : AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Performance Card
// =============================================================================

class _PerfItem {
  final String label;
  final String value;
  _PerfItem(this.label, this.value);
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_PerfItem> items;

  const _PerformanceCard({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// =============================================================================
// Priority Card
// =============================================================================

class _PriorityCard extends StatelessWidget {
  final int urgentCount;

  const _PriorityCard({required this.urgentCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority tasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Needs attention',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (urgentCount == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'All clear \u2014 no priority tasks',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$urgentCount task${urgentCount > 1 ? 's' : ''} need attention',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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
// Task Tab
// =============================================================================

class _TaskTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;

  const _TaskTab({
    required this.icon,
    required this.label,
    this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Empty States
// =============================================================================

class _EmptyAssignedTasks extends StatelessWidget {
  const _EmptyAssignedTasks();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Active Projects'.tr(context),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Accept tasks from the pool to get started!'.tr(context),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTaskPool extends StatelessWidget {
  const _EmptyTaskPool();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore_outlined,
                size: 32,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Projects Available'.tr(context),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for new opportunities!'.tr(context),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

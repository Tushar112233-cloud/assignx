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
import '../widgets/app_drawer.dart';
import '../widgets/assigned_task_card.dart';
import '../widgets/task_pool_card.dart';
import '../../../core/translation/translation_extensions.dart';

/// Main dashboard screen with Welcome, Stats, Assigned Tasks and Open Pool.
///
/// The primary screen for activated users, displaying a scrollable dashboard
/// with quick stats, assigned project cards, and available work opportunities.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final stats = ref.watch(doerStatsProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: dashboardState.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // Welcome header with gradient
              SliverToBoxAdapter(
                child: _buildWelcomeHeader(context),
              ),

              // Quick stats row
              SliverToBoxAdapter(
                child: _buildQuickStats(stats, dashboardState),
              ),

              // Assigned Tasks section
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Assigned Tasks'.tr(context),
                  Icons.assignment,
                  AppColors.primary,
                  dashboardState.assignedProjects.length,
                  onSeeAll: dashboardState.assignedProjects.length > 3
                      ? () => context.push('/dashboard/projects')
                      : null,
                ),
              ),

              // Assigned Tasks content
              if (dashboardState.assignedProjects.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyAssignedTasks(),
                )
              else
                SliverToBoxAdapter(
                  child: _buildAssignedTasksList(
                    dashboardState.assignedProjects,
                  ),
                ),

              // Open Task Pool section
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Open Task Pool'.tr(context),
                  Icons.explore,
                  AppColors.accent,
                  dashboardState.openPoolProjects.length,
                  onSeeAll: null,
                ),
              ),

              // Open Pool content
              if (dashboardState.openPoolProjects.isEmpty)
                const SliverToBoxAdapter(
                  child: _EmptyTaskPool(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sorted = _sortedPoolProjects(
                          dashboardState.openPoolProjects,
                        );
                        final project = sorted[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: TaskPoolCard(
                            project: project,
                            onTap: () =>
                                context.push('/project/${project.id}'),
                            onAccept: () =>
                                _confirmAccept(context, project),
                          ),
                        );
                      },
                      childCount:
                          dashboardState.openPoolProjects.length,
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the welcome header with menu and notification buttons.
  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              // Top bar with menu + notifications
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white),
                    tooltip: 'Menu'.tr(context),
                  ),
                  const Spacer(),
                  _buildNotificationButton(context),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // User info row
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(currentUserProvider);
                  final isAvailable = ref.watch(isAvailableProvider);
                  final displayName = user?.fullName ?? 'Doer';
                  final firstName = displayName.split(' ').first;

                  return Row(
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              firstName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Availability indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? AppColors.success
                                        .withValues(alpha: 0.2)
                                    : Colors.white
                                        .withValues(alpha: 0.15),
                                borderRadius: AppSpacing.borderRadiusSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isAvailable
                                          ? AppColors.success
                                          : AppColors.textTertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isAvailable
                                        ? 'Available'.tr(context)
                                        : 'Unavailable'.tr(context),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isAvailable
                                          ? AppColors.success
                                          : Colors.white
                                              .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_outlined,
              color: Colors.white),
          tooltip: 'Notifications'.tr(context),
        ),
        Positioned(
          right: 8,
          top: 8,
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

  /// Builds the quick stats row.
  Widget _buildQuickStats(DoerStats stats, DashboardState dashboardState) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickStatCard(
              icon: Icons.assignment,
              value: stats.activeProjects.toString(),
              label: 'Active Projects'.tr(context),
              color: AppColors.info,
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickStatCard(
              icon: Icons.check_circle,
              value: stats.completedProjects.toString(),
              label: 'Completed'.tr(context),
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickStatCard(
              icon: Icons.account_balance_wallet,
              value: _formatEarnings(dashboardState.pendingEarnings),
              label: 'Pending Earnings'.tr(context),
              color: AppColors.warning,
              prefix: '\u20B9',
            ),
            const SizedBox(width: AppSpacing.sm),
            _QuickStatCard(
              icon: Icons.star,
              value: stats.rating > 0
                  ? stats.rating.toStringAsFixed(1)
                  : '--',
              label: 'Rating'.tr(context),
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section header with title, icon, count badge, and optional "See All".
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    int count, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'See All'.tr(context),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the assigned tasks as a horizontal scrollable list.
  Widget _buildAssignedTasksList(List<DoerProjectModel> projects) {
    // Sort: urgent/revision first, then by deadline
    final sorted = List<DoerProjectModel>.from(projects)
      ..sort((a, b) {
        if (a.hasRevision && !b.hasRevision) return -1;
        if (!a.hasRevision && b.hasRevision) return 1;
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return a.deadline.compareTo(b.deadline);
      });

    // Show max 5 in horizontal scroll
    final display = sorted.take(5).toList();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: display.length,
        itemBuilder: (context, index) {
          final project = display[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < display.length - 1 ? AppSpacing.md : 0,
            ),
            child: SizedBox(
              width: 300,
              child: AssignedTaskCard(
                project: project,
                onTap: () => context.push('/project/${project.id}'),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Sorts pool projects by urgency then deadline.
  List<DoerProjectModel> _sortedPoolProjects(
      List<DoerProjectModel> projects) {
    return List<DoerProjectModel>.from(projects)
      ..sort((a, b) {
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return a.deadline.compareTo(b.deadline);
      });
  }

  /// Shows confirmation dialog before accepting a project.
  void _confirmAccept(BuildContext context, DoerProjectModel project) {
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
              style: TextStyle(fontSize: 14),
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
                        _formatDeadline(project.deadline),
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
              _acceptProject(project.id);
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

  Future<void> _acceptProject(String projectId) async {
    final success = await ref
        .read(dashboardProvider.notifier)
        .acceptProject(projectId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project accepted successfully!'.tr(context)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatDeadline(DateTime deadline) {
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

  String _formatEarnings(double earnings) {
    if (earnings >= 100000) {
      return '${(earnings / 1000).toStringAsFixed(0)}K';
    } else if (earnings >= 1000) {
      return '${(earnings / 1000).toStringAsFixed(1)}K';
    }
    return earnings.toStringAsFixed(0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning'.tr(context);
    if (hour < 17) return 'Good Afternoon'.tr(context);
    return 'Good Evening'.tr(context);
  }
}

/// Quick stat card widget for horizontal scroll with gradient background.
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? prefix;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (prefix != null)
                Text(
                  prefix!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Empty state for assigned tasks section.
class _EmptyAssignedTasks extends StatelessWidget {
  const _EmptyAssignedTasks();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          const SizedBox(height: AppSpacing.md),
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
            'Accept tasks from the pool below to get started!'.tr(context),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Empty state for task pool section.
class _EmptyTaskPool extends StatelessWidget {
  const _EmptyTaskPool();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
          const SizedBox(height: AppSpacing.md),
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
    );
  }
}

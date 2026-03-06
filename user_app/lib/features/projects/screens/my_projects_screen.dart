import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../widgets/payment_prompt_modal.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/review_actions.dart';

// Note: scaffoldBackground removed - now using transparent for gradient from MainShell

/// My Projects screen with updated design matching specification.
class MyProjectsScreen extends ConsumerStatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  ConsumerState<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends ConsumerState<MyProjectsScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Filter tabs matching web: In Review, In Progress, For Review, History
  /// - In Review: submitted, analyzing, quoted, payment_pending (being reviewed by AssignX)
  /// - In Progress: paid, assigning, assigned, in_progress, qc states (expert working)
  /// - For Review: delivered (awaiting user approval)
  /// - History: completed, auto_approved, cancelled, refunded
  final _tabs = const ['In Review', 'In Progress', 'For Review', 'History'];

  /// Static flag to prevent duplicate payment modal from showing.
  /// This is needed because MyProjectsScreen is used twice in IndexedStack
  /// (for both Projects and Orders tabs), and both instances call initState.
  static bool _isPaymentModalShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingPayments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingPayments() async {
    // Prevent duplicate modals when screen is used multiple times in IndexedStack
    if (_isPaymentModalShowing) return;

    final pendingProjects = await ref.read(pendingPaymentProjectsProvider.future);
    if (pendingProjects.isNotEmpty && mounted) {
      final project = pendingProjects.first;
      _isPaymentModalShowing = true;
      PaymentPromptModal.show(
        context,
        project: project,
        onPayNow: () {
          _isPaymentModalShowing = false;
          _handlePayNow(project);
        },
        onRemindLater: () {
          _isPaymentModalShowing = false;
          _handleRemindLater(project);
        },
      ).then((_) {
        // Reset flag when modal is dismissed by any means (back button, tap outside, etc.)
        _isPaymentModalShowing = false;
      });
    }
  }

  void _handlePayNow(Project project) {
    if (!mounted) return;
    context.push(RouteNames.projectPayPath(project.id));
  }

  void _handleRemindLater(Project project) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('We\'ll remind you about payment for "${project.title}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Pay Now',
          onPressed: () => _handlePayNow(project),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent to show SubtleGradientScaffold from MainShell
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified Dashboard App Bar (dark theme)
          const DashboardAppBar(),

          // Scrollable Content with Pull-to-Refresh
          Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(projectsProvider);
                  ref.invalidate(projectCountsProvider);
                  ref.invalidate(walletProvider);
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Projects Overview Card
                      _buildProjectsOverviewCard(),

                      const SizedBox(height: 20),

                      // Filter Tabs
                      _buildFilterTabs(),

                      const SizedBox(height: 16),

                      // Search Bar
                      _buildSearchBar(),

                      const SizedBox(height: 20),

                      // Projects List
                      _ProjectsList(
                        tabIndex: _selectedTabIndex,
                        searchQuery: _searchQuery,
                        onApprove: _handleApprove,
                        onRequestChanges: _handleRequestChanges,
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

  /// Projects Overview Card with stats and New Project button.
  Widget _buildProjectsOverviewCard() {
    final countsAsync = ref.watch(projectCountsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with sparkle icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projects Overview',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track your assignment progress',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row
          countsAsync.when(
            data: (counts) {
              final total = counts[5] ?? 0;  // Total projects
              final active = counts[1] ?? 0; // In Progress
              final done = counts[4] ?? 0;   // Completed projects
              final forReview = counts[2] ?? 0; // For Review

              return Row(
                children: [
                  _buildStatItem('Total', total.toString(), AppColors.textPrimary),
                  _buildStatDivider(),
                  _buildStatItem('Active', active.toString(), AppColors.primary),
                  _buildStatDivider(),
                  _buildStatItem('Review', forReview.toString(), AppColors.warning),
                  _buildStatDivider(),
                  _buildStatItem('Done', done.toString(), AppColors.success),
                ],
              );
            },
            loading: () => Row(
              children: [
                _buildStatItem('Total', '-', AppColors.textPrimary),
                _buildStatDivider(),
                _buildStatItem('Active', '-', AppColors.primary),
                _buildStatDivider(),
                _buildStatItem('Review', '-', AppColors.warning),
                _buildStatDivider(),
                _buildStatItem('Done', '-', AppColors.success),
              ],
            ),
            error: (_, __) => Row(
              children: [
                _buildStatItem('Total', '0', AppColors.textPrimary),
                _buildStatDivider(),
                _buildStatItem('Active', '0', AppColors.primary),
                _buildStatDivider(),
                _buildStatItem('Review', '0', AppColors.warning),
                _buildStatDivider(),
                _buildStatItem('Done', '0', AppColors.success),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // New Project button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(RouteNames.projectWizard),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'New Project',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.border,
    );
  }

  /// Filter Tabs: Horizontal scrollable chips.
  Widget _buildFilterTabs() {
    final countsAsync = ref.watch(projectCountsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final label = _tabs[index];

          // Get count for this tab (indices 0-3 match tab indices)
          String countText = '';
          countsAsync.whenData((counts) {
            final count = counts[index] ?? 0;
            countText = ' ($count)';
          });

          return Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                ref.read(selectedProjectTabProvider.notifier).state = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkBrown : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.darkBrown : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$label$countText',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Search Bar with magnifying glass icon.
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Future<void> _handleApprove(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Delivery'),
        content: const Text(
          'Are you sure you want to approve this delivery? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(projectNotifierProvider.notifier).approveProject(project.id);
    }
  }

  Future<void> _handleRequestChanges(Project project) async {
    FeedbackInputModal.show(
      context,
      onSubmit: (feedback) async {
        await ref
            .read(projectNotifierProvider.notifier)
            .requestChanges(project.id, feedback);
      },
    );
  }
}

/// Projects List widget that displays filtered projects.
class _ProjectsList extends ConsumerWidget {
  final int tabIndex;
  final String searchQuery;
  final Future<void> Function(Project) onApprove;
  final Future<void> Function(Project) onRequestChanges;

  const _ProjectsList({
    required this.tabIndex,
    required this.searchQuery,
    required this.onApprove,
    required this.onRequestChanges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsByTabProvider(tabIndex));

    return projectsAsync.when(
      data: (projects) {
        // Apply search filter
        var filteredProjects = projects;
        if (searchQuery.isNotEmpty) {
          filteredProjects = projects.where((p) {
            return p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                p.projectNumber.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
        }

        if (filteredProjects.isEmpty) {
          return _EmptyState(
            tabIndex: tabIndex,
            isSearchResult: searchQuery.isNotEmpty,
          );
        }

        return Column(
          children: List.generate(filteredProjects.length, (index) {
            final project = filteredProjects[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < filteredProjects.length - 1 ? 12 : 0),
              child: _ProjectCard(
                project: project,
                onTap: () => context.push('/projects/${project.id}'),
                onApprove: () => onApprove(project),
                onRequestChanges: () => onRequestChanges(project),
              ),
            );
          }),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load projects',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(projectsByTabProvider(tabIndex)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Project card with status-based styling.
/// - Completed: green checkmark, no border
/// - Submitted/Under Review: dashed yellow/orange border, orange text
/// - Pending/Other: dashed yellow border, brown icon
class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onRequestChanges;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    this.onApprove,
    this.onRequestChanges,
  });

  @override
  Widget build(BuildContext context) {
    final cardStyle = _getCardStyle();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: cardStyle.hasDashedBorder
              ? null
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        foregroundDecoration: cardStyle.hasDashedBorder
            ? _DashedBorderDecoration(
                color: cardStyle.borderColor,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Status icon
            _buildStatusIcon(cardStyle),

            const SizedBox(width: 14),

            // Right: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status badge row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(cardStyle),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Project number and service type
                  Row(
                    children: [
                      Text(
                        '#${project.projectNumber}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        project.serviceType.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Progress bar (only for in_progress)
                  if (project.status == ProjectStatus.inProgress) ...[
                    ProjectProgressIndicator(
                      percent: project.progressPercentage,
                      showLabel: true,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Bottom row: Last updated and action
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLastUpdated(project.updatedAt ?? project.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      _buildActionButton(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CardStyle _getCardStyle() {
    switch (project.status) {
      // Completed states - green checkmark, no special border
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return _CardStyle(
          iconBgColor: AppColors.success.withAlpha(20),
          iconColor: AppColors.success,
          icon: Icons.check_circle,
          statusText: 'Completed',
          statusColor: AppColors.success,
          hasDashedBorder: false,
          borderColor: Colors.transparent,
        );

      // Submitted/Under Review - dashed orange border
      case ProjectStatus.delivered:
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.qcApproved:
        return _CardStyle(
          iconBgColor: AppColors.warning.withAlpha(20),
          iconColor: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
          statusText: 'Under Review',
          statusColor: AppColors.warning,
          hasDashedBorder: true,
          borderColor: AppColors.warning,
        );

      // Pending payment
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _CardStyle(
          iconBgColor: AppColors.warning.withAlpha(20),
          iconColor: AppColors.warning,
          icon: Icons.payment_rounded,
          statusText: 'Payment Pending',
          statusColor: AppColors.warning,
          hasDashedBorder: true,
          borderColor: AppColors.warning,
        );

      // In Progress
      case ProjectStatus.inProgress:
      case ProjectStatus.assigned:
      case ProjectStatus.assigning:
        return _CardStyle(
          iconBgColor: AppColors.primary.withAlpha(20),
          iconColor: AppColors.primary,
          icon: Icons.trending_up_rounded,
          statusText: 'In Progress',
          statusColor: AppColors.primary,
          hasDashedBorder: true,
          borderColor: AppColors.primary.withAlpha(100),
        );

      // Revision states
      case ProjectStatus.revisionRequested:
      case ProjectStatus.inRevision:
        return _CardStyle(
          iconBgColor: AppColors.error.withAlpha(20),
          iconColor: AppColors.error,
          icon: Icons.edit_note_rounded,
          statusText: 'Revision',
          statusColor: AppColors.error,
          hasDashedBorder: true,
          borderColor: AppColors.error,
        );

      // Cancelled/Refunded
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
      case ProjectStatus.qcRejected:
        return _CardStyle(
          iconBgColor: AppColors.error.withAlpha(20),
          iconColor: AppColors.error,
          icon: Icons.cancel_rounded,
          statusText: project.status.displayName,
          statusColor: AppColors.error,
          hasDashedBorder: false,
          borderColor: Colors.transparent,
        );

      // Default/Pending states
      default:
        return _CardStyle(
          iconBgColor: AppColors.primary.withAlpha(20),
          iconColor: AppColors.primary,
          icon: Icons.description_outlined,
          statusText: project.status.displayName,
          statusColor: AppColors.textSecondary,
          hasDashedBorder: true,
          borderColor: AppColors.border,
        );
    }
  }

  Widget _buildStatusIcon(_CardStyle style) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: style.iconBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        style.icon,
        color: style.iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildStatusBadge(_CardStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.statusColor.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        style.statusText,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.statusColor,
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime updatedAt) {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(updatedAt);
    }
  }

  Widget _buildActionButton(BuildContext context) {
    switch (project.status) {
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _ActionChip(
          label: 'Pay Now',
          icon: Icons.payment,
          color: AppColors.warning,
          onTap: () => context.push('/projects/${project.id}/pay'),
        );

      case ProjectStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionChip(
              label: 'Changes',
              icon: Icons.edit_note,
              color: AppColors.textSecondary,
              outlined: true,
              onTap: onRequestChanges,
            ),
            const SizedBox(width: 8),
            _ActionChip(
              label: 'Approve',
              icon: Icons.check,
              color: AppColors.success,
              onTap: onApprove,
            ),
          ],
        );

      default:
        return _ActionChip(
          label: 'View',
          icon: Icons.arrow_forward,
          color: AppColors.primary,
          outlined: true,
          onTap: onTap,
        );
    }
  }
}

/// Card style configuration.
class _CardStyle {
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;
  final String statusText;
  final Color statusColor;
  final bool hasDashedBorder;
  final Color borderColor;

  const _CardStyle({
    required this.iconBgColor,
    required this.iconColor,
    required this.icon,
    required this.statusText,
    required this.statusColor,
    required this.hasDashedBorder,
    required this.borderColor,
  });
}

/// Custom dashed border decoration.
class _DashedBorderDecoration extends Decoration {
  final Color color;
  final BorderRadius borderRadius;
  final double dashWidth;
  final double dashSpace;

  const _DashedBorderDecoration({
    required this.color,
    required this.borderRadius,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashedBorderPainter(
      color: color,
      borderRadius: borderRadius,
      dashWidth: dashWidth,
      dashSpace: dashSpace,
    );
  }
}

class _DashedBorderPainter extends BoxPainter {
  final Color color;
  final BorderRadius borderRadius;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final rrect = borderRadius.toRRect(rect);
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dest.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }
}


/// Compact action chip button.
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(8),
          border: outlined ? Border.all(color: color.withAlpha(100)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: outlined ? color : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: outlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  final bool isSearchResult;

  const _EmptyState({
    required this.tabIndex,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = isSearchResult
        ? (Icons.search_off, 'No Results Found', 'Try a different search term')
        : _getEmptyStateContent();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _getEmptyStateContent() {
    switch (tabIndex) {
      case 0:
        return (
          Icons.hourglass_empty_outlined,
          'No Projects In Review',
          'Projects awaiting AssignX review will appear here',
        );
      case 1:
        return (
          Icons.play_circle_outline,
          'No Projects In Progress',
          'Projects being worked on by experts will appear here',
        );
      case 2:
        return (
          Icons.rate_review_outlined,
          'No Projects For Review',
          'Projects awaiting your approval will appear here',
        );
      case 3:
        return (
          Icons.history,
          'No Project History',
          'Completed and cancelled projects will appear here',
        );
      default:
        return (
          Icons.folder_outlined,
          'No Projects',
          'Your projects will appear here',
        );
    }
  }
}

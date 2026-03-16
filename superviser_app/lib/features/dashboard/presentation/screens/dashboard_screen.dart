/// Main dashboard screen for the supervisor app.
///
/// This file contains:
/// - [DashboardScreen]: The main dashboard widget (layout-only)
/// - Focused ConsumerWidget children that each watch a single provider
/// - Supporting private widgets for sections, errors, and quick actions
///
/// The dashboard displays new requests awaiting quotes and paid requests
/// ready for doer assignment, with filtering and quick action capabilities.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/request_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/field_filter.dart';
import '../widgets/request_card.dart';
import '../widgets/quote_form_sheet.dart';
import '../widgets/doer_selection_sheet.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

/// The main dashboard screen for supervisors.
///
/// This is a layout-only widget that composes focused ConsumerWidget children.
/// Each child watches only the provider it needs, minimizing unnecessary rebuilds.
///
/// Children:
/// - [_UserGreetingSection]: watches [authProvider]
/// - [_NotificationButton]: watches [unreadNotificationCountProvider]
/// - [_DashboardContentSection]: watches [dashboardProvider]
///
/// ## Usage
///
/// This screen is typically used as a route destination:
/// ```dart
/// GoRoute(
///   path: '/dashboard',
///   builder: (context, state) => const DashboardScreen(),
/// )
/// ```
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a new [DashboardScreen] instance.
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

/// State class for [DashboardScreen].
///
/// Manages navigation and action sheet display. The build method is
/// layout-only -- provider watches are delegated to child ConsumerWidgets.
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Safe area top padding
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.top + 8),
            ),
            // Top bar: notification button (watches unreadNotificationCountProvider)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    _NotificationButton(onTap: _openNotifications),
                  ],
                ),
              ),
            ),
            // Greeting (watches authProvider)
            const SliverToBoxAdapter(
              child: _UserGreetingSection(),
            ),
            // All dashboard-data-dependent content (watches dashboardProvider)
            _DashboardContentSection(
              onViewRequestDetails: _viewRequestDetails,
              onShowQuoteForm: _showQuoteForm,
              onShowDoerSelection: _showDoerSelection,
              onShowQuickActions: _showQuickActions,
            ),
            // Bottom padding for floating nav bar clearance
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      // Quick action FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.bolt_rounded),
      ),
    );
  }

  /// Opens the notifications screen.
  void _openNotifications() {
    context.pushNamed(RouteNames.notifications);
  }

  /// Shows request details in a dialog.
  void _viewRequestDetails(RequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${'Subject:'.tr(context)} ${request.subject}'),
              const SizedBox(height: 8),
              Text('${'Budget:'.tr(context)} \u20b9${request.budget}'),
              const SizedBox(height: 8),
              Text('${'Deadline:'.tr(context)} ${request.deadline.toString().split(' ')[0]}'),
              const SizedBox(height: 8),
              Text('${'Status:'.tr(context)} ${request.status}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr(context)),
          ),
        ],
      ),
    );
  }

  /// Shows the quote form sheet for a request.
  Future<void> _showQuoteForm(RequestModel request) async {
    final result = await QuoteFormSheet.show(context, request);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote submitted successfully!'.tr(context)),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Shows the doer selection sheet for a request.
  Future<void> _showDoerSelection(RequestModel request) async {
    final doer = await DoerSelectionSheet.show(context, request);
    if (doer != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${doer.name} ${'assigned to project!'.tr(context)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Shows the quick actions bottom sheet.
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickActionsSheet(),
    );
  }
}

/// Notification button that watches only [unreadNotificationCountProvider].
///
/// Isolates notification badge rebuilds from the rest of the dashboard.
class _NotificationButton extends ConsumerWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadNotificationCountProvider);

    return _GlassNotificationButton(
      count: count,
      onTap: onTap,
    );
  }
}

/// User greeting section that watches only [authProvider].
///
/// Isolates auth state rebuilds from dashboard data changes.
class _UserGreetingSection extends ConsumerWidget {
  const _UserGreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.fullName ?? 'Supervisor'.tr(context);
    final firstName = userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(context),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            firstName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
          ),
        ],
      ),
    );
  }

  /// Returns greeting based on time of day.
  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,'.tr(context);
    } else if (hour < 17) {
      return 'Good Afternoon,'.tr(context);
    } else {
      return 'Good Evening,'.tr(context);
    }
  }
}

/// Dashboard content section that watches only [dashboardProvider].
///
/// Contains status pills, KPI cards, field filter, request lists, and
/// recent activity. All of these depend on the dashboard state.
class _DashboardContentSection extends ConsumerWidget {
  const _DashboardContentSection({
    required this.onViewRequestDetails,
    required this.onShowQuoteForm,
    required this.onShowDoerSelection,
    required this.onShowQuickActions,
  });

  final void Function(RequestModel) onViewRequestDetails;
  final void Function(RequestModel) onShowQuoteForm;
  final void Function(RequestModel) onShowDoerSelection;
  final VoidCallback onShowQuickActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return SliverMainAxisGroup(
      slivers: [
        // Status pills row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _GlassStatusPill(
                  label: 'Active'.tr(context),
                  count: dashboardState.filteredNewRequests.length +
                      dashboardState.filteredPaidRequests.length,
                  color: AppColors.statusInProgress,
                ),
                const SizedBox(width: 10),
                _GlassStatusPill(
                  label: 'Pending'.tr(context),
                  count: dashboardState.filteredNewRequests.length,
                  color: AppColors.statusPending,
                ),
              ],
            ),
          ),
        ),
        // Quick action CTA card
        SliverToBoxAdapter(
          child: _QuickActionCta(
            onTap: onShowQuickActions,
          ),
        ),
        // KPI stat cards
        SliverToBoxAdapter(
          child: _GlassKpiCardsRow(
            newRequestsCount: dashboardState.filteredNewRequests.length,
            paidRequestsCount: dashboardState.filteredPaidRequests.length,
          ),
        ),
        // Field filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FieldFilter(
              selectedField: dashboardState.selectedSubject,
              onFieldSelected: (field) {
                ref.read(dashboardProvider.notifier).filterBySubject(field);
              },
            ),
          ),
        ),
        // Error message
        if (dashboardState.error != null)
          SliverToBoxAdapter(
            child: _ErrorBanner(
              message: dashboardState.error!,
              onDismiss: () {
                ref.read(dashboardProvider.notifier).clearError();
              },
            ),
          ),
        // Loading indicator
        if (dashboardState.isLoading)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          ),
        // New Requests section
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'New Requests'.tr(context),
            subtitle: 'Awaiting your quote'.tr(context),
            count: dashboardState.filteredNewRequests.length,
            icon: Icons.fiber_new,
            iconColor: Colors.blue,
          ),
        ),
        if (dashboardState.filteredNewRequests.isEmpty)
          SliverToBoxAdapter(
            child: _EmptySection(
              message: 'No new requests'.tr(context),
              icon: Icons.inbox_outlined,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final request = dashboardState.filteredNewRequests[index];
                return RepaintBoundary(
                  child: RequestCard(
                    request: request,
                    onTap: () => onViewRequestDetails(request),
                    actionLabel: 'Analyze & Quote'.tr(context),
                    onAction: () => onShowQuoteForm(request),
                  ),
                );
              },
              childCount: dashboardState.filteredNewRequests.length,
            ),
          ),
        // Paid Requests section
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Ready to Assign'.tr(context),
            subtitle: 'Paid and awaiting doer'.tr(context),
            count: dashboardState.filteredPaidRequests.length,
            icon: Icons.assignment_ind,
            iconColor: AppColors.success,
          ),
        ),
        if (dashboardState.filteredPaidRequests.isEmpty)
          SliverToBoxAdapter(
            child: _EmptySection(
              message: 'No requests ready for assignment'.tr(context),
              icon: Icons.check_circle_outline,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final request = dashboardState.filteredPaidRequests[index];
                return RepaintBoundary(
                  child: RequestCard(
                    request: request,
                    onTap: () => onViewRequestDetails(request),
                    actionLabel: 'Assign Doer'.tr(context),
                    onAction: () => onShowDoerSelection(request),
                  ),
                );
              },
              childCount: dashboardState.filteredPaidRequests.length,
            ),
          ),
        // Recent Activity Feed
        SliverToBoxAdapter(
          child: _RecentActivitySection(),
        ),
      ],
    );
  }
}

/// Glass notification button with count badge.
class _GlassNotificationButton extends StatelessWidget {
  const _GlassNotificationButton({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GlassContainer(
          blur: 12,
          opacity: 0.15,
          borderRadius: BorderRadius.circular(14),
          borderColor: Colors.white.withAlpha(64),
          backgroundColor: Colors.white,
          onTap: onTap,
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimaryLight, size: 22),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Glass-morphism status pill showing a label and count.
class _GlassStatusPill extends StatelessWidget {
  const _GlassStatusPill({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.12,
      borderRadius: BorderRadius.circular(20),
      borderColor: color.withAlpha(50),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
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
          const SizedBox(width: 8),
          Text(
            '$label $count',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Quick action CTA card with dark charcoal-to-orange gradient.
class _QuickActionCta extends StatelessWidget {
  const _QuickActionCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientMiddle, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientEnd.withAlpha(40),
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
                      'Quick Actions'.tr(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search doers, view analytics, recent projects'.tr(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(180),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of glass KPI stat cards displayed at the top of the dashboard.
class _GlassKpiCardsRow extends StatelessWidget {
  const _GlassKpiCardsRow({required this.newRequestsCount, this.paidRequestsCount = 0});

  final int newRequestsCount;
  final int paidRequestsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _GlassKpiCard(
              icon: Icons.fiber_new,
              iconColor: AppColors.info,
              value: newRequestsCount.toString(),
              label: 'New Requests'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GlassKpiCard(
              icon: Icons.assignment_ind,
              iconColor: AppColors.accent,
              value: paidRequestsCount.toString(),
              label: 'Ready to Assign'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GlassKpiCard(
              icon: Icons.rate_review_outlined,
              iconColor: AppColors.warning,
              value: '--',
              label: 'Pending QC'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _GlassKpiCard(
              icon: Icons.currency_rupee,
              iconColor: AppColors.success,
              value: '--',
              label: 'Earnings'.tr(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single glass KPI stat card with a colored icon, bold value, and label.
class _GlassKpiCard extends StatelessWidget {
  const _GlassKpiCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.6,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withAlpha(50),
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Section header widget for dashboard sections.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty section placeholder widget.
class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(32),
      blur: 8,
      opacity: 0.5,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Error banner widget for displaying error messages.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: AppColors.error),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}

/// Quick actions bottom sheet widget.
class _QuickActionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions'.tr(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _QuickActionTile(
            icon: Icons.search,
            title: 'Search Doers'.tr(context),
            subtitle: 'Find available writers'.tr(context),
            onTap: () => Navigator.pop(context),
          ),
          _QuickActionTile(
            icon: Icons.analytics_outlined,
            title: 'View Analytics'.tr(context),
            subtitle: 'Check your performance'.tr(context),
            onTap: () => Navigator.pop(context),
          ),
          _QuickActionTile(
            icon: Icons.history,
            title: 'Recent Projects'.tr(context),
            subtitle: 'View project history'.tr(context),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Quick action tile widget.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Recent activity feed section showing the last few events.
class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity'.tr(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Your latest events'.tr(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Activity items in a glass card
          GlassCard(
            blur: 10,
            opacity: 0.6,
            borderRadius: BorderRadius.circular(16),
            padding: EdgeInsets.zero,
            elevation: 1,
            child: Column(
              children: [
                _ActivityItem(
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.info,
                  title: 'New project assigned'.tr(context),
                  subtitle: 'Computer Science - Data Structures'.tr(context),
                  time: '2m ago'.tr(context),
                  isFirst: true,
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.send_outlined,
                  iconColor: AppColors.accent,
                  title: 'Quote sent to client'.tr(context),
                  subtitle: 'Project #1842 - \u20b93,500'.tr(context),
                  time: '15m ago'.tr(context),
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.payment_outlined,
                  iconColor: AppColors.success,
                  title: 'Payment received'.tr(context),
                  subtitle: 'Project #1838 - \u20b95,200'.tr(context),
                  time: '1h ago'.tr(context),
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.person_add_outlined,
                  iconColor: Colors.purple,
                  title: 'Doer assigned'.tr(context),
                  subtitle: 'Rahul S. assigned to Project #1840'.tr(context),
                  time: '2h ago'.tr(context),
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  title: 'Deliverable approved'.tr(context),
                  subtitle: 'Project #1835 - Mathematics'.tr(context),
                  time: '3h ago'.tr(context),
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.rate_review_outlined,
                  iconColor: AppColors.warning,
                  title: 'Revision requested'.tr(context),
                  subtitle: 'Project #1830 - English Essay'.tr(context),
                  time: '5h ago'.tr(context),
                ),
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                _ActivityItem(
                  icon: Icons.chat_outlined,
                  iconColor: AppColors.info,
                  title: 'New message from client'.tr(context),
                  subtitle: 'Project #1837 - "When can I expect..."'.tr(context),
                  time: '6h ago'.tr(context),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single activity item in the recent activity feed.
class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 12,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

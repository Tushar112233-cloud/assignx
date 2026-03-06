/// Main dashboard screen for the supervisor app.
///
/// This file contains:
/// - [DashboardScreen]: The main dashboard widget
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
import '../../data/models/request_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/field_filter.dart';
import '../widgets/request_card.dart';
import '../widgets/quote_form_sheet.dart';
import '../widgets/doer_selection_sheet.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';

/// The main dashboard screen for supervisors.
///
/// Displays two main sections:
/// 1. **New Requests**: Projects with "submitted" status awaiting quotes
/// 2. **Ready to Assign**: Paid projects ready for doer assignment
///
/// Features include:
/// - Pull-to-refresh for reloading data
/// - Subject/field filtering via horizontal chips
/// - Quick actions FAB for common tasks
/// - Navigation to notifications
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
///
/// ## State Management
///
/// Uses [dashboardProvider] for state management. The provider
/// automatically loads data on initialization.
///
/// See also:
/// - [DashboardState] for the state structure
/// - [RequestCard] for request display
/// - [QuoteFormSheet] for creating quotes
/// - [DoerSelectionSheet] for assigning doers
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a new [DashboardScreen] instance.
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

/// State class for [DashboardScreen].
///
/// Manages the scaffold key for drawer access and handles
/// navigation and action sheet display.
class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Key for accessing the scaffold state (drawer control).
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: DashboardHeader(
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onNotificationTap: _openNotifications,
                notificationCount: unreadNotifs,
              ),
            ),
            // KPI stat cards
            SliverToBoxAdapter(
              child: _KpiCardsRow(
                newRequestsCount: dashboardState.filteredNewRequests.length,
                paidRequestsCount: dashboardState.filteredPaidRequests.length,
              ),
            ),
            // Mini analytics chart
            const SliverToBoxAdapter(
              child: _MiniChart(),
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
                    return RequestCard(
                      request: request,
                      onTap: () => _viewRequestDetails(request),
                      actionLabel: 'Analyze & Quote'.tr(context),
                      onAction: () => _showQuoteForm(request),
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
                    return RequestCard(
                      request: request,
                      onTap: () => _viewRequestDetails(request),
                      actionLabel: 'Assign Doer'.tr(context),
                      onAction: () => _showDoerSelection(request),
                    );
                  },
                  childCount: dashboardState.filteredPaidRequests.length,
                ),
              ),
            // Recent Activity Feed
            SliverToBoxAdapter(
              child: _RecentActivitySection(),
            ),
            // Bottom padding
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
  ///
  /// Displays basic information about the request including subject,
  /// budget, deadline, and status.
  ///
  /// Parameters:
  /// - [request]: The request to display details for
  void _viewRequestDetails(RequestModel request) {
    // For now, show request details in a dialog since there's no dedicated request detail screen
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
              Text('${'Budget:'.tr(context)} ₹${request.budget}'),
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
  ///
  /// Opens a modal bottom sheet for creating and submitting a quote.
  /// Shows a success snackbar if the quote is submitted successfully.
  ///
  /// Parameters:
  /// - [request]: The request to create a quote for
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
  ///
  /// Opens a modal bottom sheet for selecting and assigning a doer.
  /// Shows a success snackbar with the doer's name if assigned.
  ///
  /// Parameters:
  /// - [request]: The request to assign a doer to
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
  ///
  /// Displays common actions like searching doers, viewing analytics,
  /// and accessing recent projects.
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickActionsSheet(),
    );
  }
}

/// Section header widget for dashboard sections.
///
/// Displays a title, subtitle, count badge, and icon for a section.
/// Used to introduce "New Requests" and "Ready to Assign" sections.
class _SectionHeader extends StatelessWidget {
  /// Creates a new [_SectionHeader] instance.
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  /// The main title text (e.g., "New Requests").
  final String title;

  /// Descriptive subtitle (e.g., "Awaiting your quote").
  final String subtitle;

  /// Number to display in the count badge.
  final int count;

  /// Icon to display next to the title.
  final IconData icon;

  /// Color for the icon and count badge.
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
///
/// Displayed when a section has no items to show.
/// Shows an icon and message indicating the empty state.
class _EmptySection extends StatelessWidget {
  /// Creates a new [_EmptySection] instance.
  const _EmptySection({
    required this.message,
    required this.icon,
  });

  /// Message to display (e.g., "No new requests").
  final String message;

  /// Icon to display above the message.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
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
///
/// Shows a dismissible error message with an icon.
/// Styled with error colors and a close button.
class _ErrorBanner extends StatelessWidget {
  /// Creates a new [_ErrorBanner] instance.
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  /// The error message to display.
  final String message;

  /// Callback when the dismiss button is tapped.
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
///
/// Displays a list of common quick actions the supervisor can take:
/// - Search Doers
/// - View Analytics
/// - Recent Projects
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
///
/// A single action item in the quick actions sheet.
/// Displays an icon, title, subtitle, and chevron indicator.
class _QuickActionTile extends StatelessWidget {
  /// Creates a new [_QuickActionTile] instance.
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// Icon to display on the left.
  final IconData icon;

  /// Main title text.
  final String title;

  /// Descriptive subtitle text.
  final String subtitle;

  /// Callback when the tile is tapped.
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

/// A row of 4 KPI stat cards displayed at the top of the dashboard.
///
/// Shows quick summary metrics:
/// - **New Requests**: Live count from dashboard state
/// - **Ready to Assign**: Live count of paid requests
/// - **In Progress** / **Pending QC**: Placeholder until real data is available
///
/// Each card shows a colored icon circle, a bold count, and a small label.
class _KpiCardsRow extends StatelessWidget {
  /// Creates a new [_KpiCardsRow] instance.
  const _KpiCardsRow({required this.newRequestsCount, this.paidRequestsCount = 0});

  /// The number of new requests to display in the first card.
  final int newRequestsCount;

  /// The number of paid requests ready to assign.
  final int paidRequestsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.fiber_new,
              iconColor: AppColors.info,
              value: newRequestsCount.toString(),
              label: 'New Requests'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.assignment_ind,
              iconColor: AppColors.accent,
              value: paidRequestsCount.toString(),
              label: 'Ready to Assign'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.rate_review_outlined,
              iconColor: AppColors.warning,
              value: '--',
              label: 'Pending QC'.tr(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
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

/// A single KPI stat card with a colored icon, bold value, and label.
///
/// Used inside [_KpiCardsRow] to present individual metrics.
class _KpiCard extends StatelessWidget {
  /// Creates a new [_KpiCard] instance.
  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  /// The icon displayed in the colored circle.
  final IconData icon;

  /// The background tint color for the icon circle and text.
  final Color iconColor;

  /// The bold metric value (e.g., "8" or "$2,450").
  final String value;

  /// The descriptive label below the value.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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

/// A placeholder for the weekly completion trends chart.
///
/// Shows a message indicating that analytics data will appear
/// once the supervisor has sufficient project history.
class _MiniChart extends StatelessWidget {
  /// Creates a new [_MiniChart] instance.
  const _MiniChart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Completions'.tr(context),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tasks completed this week'.tr(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analytics will appear once you complete projects'.tr(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent activity feed section showing the last few events.
///
/// Displays a list of recent supervisor activities such as project
/// assignments, quotes sent, payments received, and reviews completed.
/// Uses mock data for now with the right structure for future backend integration.
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
          // Activity items
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
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
                  subtitle: 'Project #1842 - ₹3,500'.tr(context),
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
                  subtitle: 'Project #1838 - ₹5,200'.tr(context),
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

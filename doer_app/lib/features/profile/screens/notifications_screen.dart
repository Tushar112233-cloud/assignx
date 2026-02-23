import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../dashboard/widgets/app_header.dart';

/// Notifications screen displaying all user notifications.
///
/// Shows a list of notifications with type-based icons and colors,
/// read/unread status, and time-ago formatting.
///
/// ## Navigation
/// - Entry: From [ProfileScreen] via quick actions or app bar
/// - Back: Returns to previous screen
/// - Tap: Navigates to relevant content (via actionUrl)
///
/// ## Features
/// - Notification list with type-based styling
/// - Read/unread visual distinction (elevation, border, dot indicator)
/// - "Mark all read" action in header
/// - Pull-to-refresh functionality
/// - Empty state for no notifications
/// - Relative time display ("2 hours ago", "Yesterday")
///
/// ## Notification Types
/// - general: Default notifications
/// - project: Project-related updates
/// - payment: Payment confirmations and updates
/// - deadline: Deadline reminders and warnings
/// - review: Review requests and feedback
/// - system: System announcements
///
/// ## State Management
/// Uses [ProfileProvider] for notification data and actions.
///
/// See also:
/// - [ProfileProvider] for notification state
/// - [AppNotification] for notification model
/// - [_NotificationCard] for individual notification display
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final notifications = profileState.notifications;
    final unreadCount = profileState.unreadNotificationCount;
    final isLoading = profileState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Column(
          children: [
            InnerHeader(
              title: 'Notifications',
              onBack: () => Navigator.pop(context),
              actions: [
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).markAllNotificationsRead(),
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
            Expanded(
              child: notifications.isEmpty && !isLoading
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(profileProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: AppSpacing.paddingMd,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () {
                              if (!notification.isRead) {
                                ref
                                    .read(profileProvider.notifier)
                                    .markNotificationRead(notification.id);
                              }
                              _handleNotificationTap(context, notification);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: AppSpacing.paddingLg,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    if (notification.actionUrl != null) {
      // TODO: Navigate to action URL
    }
  }
}

/// Individual notification card with type-based styling.
///
/// Displays notification with appropriate icon, color, and visual
/// emphasis based on read status. Unread notifications have higher
/// elevation and a colored border.
///
/// ## Visual Elements
/// - Type-specific icon (project, payment, deadline, etc.)
/// - Title with bold weight for unread
/// - Message preview (max 2 lines)
/// - Relative timestamp
/// - Type badge
/// - Blue dot indicator for unread
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? AppColors.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  size: 22,
                  color: _getTypeColor(notification.type),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.timeAgo(notification.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.type.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(notification.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return AppColors.textSecondary;
      case NotificationType.project:
        return AppColors.primary;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.deadline:
        return AppColors.warning;
      case NotificationType.review:
        return AppColors.accent;
      case NotificationType.system:
        return AppColors.info;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.project:
        return Icons.assignment;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.deadline:
        return Icons.schedule;
      case NotificationType.review:
        return Icons.rate_review;
      case NotificationType.system:
        return Icons.info;
    }
  }

}

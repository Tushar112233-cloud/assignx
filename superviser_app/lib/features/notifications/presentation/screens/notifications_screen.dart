import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

/// Notifications screen.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => _showMarkAllReadDialog(context, ref),
              child: const Text('Mark all read'),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          NotificationFilterChips(
            selectedFilter: state.selectedFilter,
            onFilterChanged: (filter) {
              ref.read(notificationsProvider.notifier).setFilter(filter);
            },
          ),

          // Notifications list (grouped by date)
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.notifications.isEmpty
                    ? const EmptyNotifications()
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(notificationsProvider.notifier).refresh(),
                        child: _GroupedNotificationList(
                          notifications: state.notifications,
                          onNotificationTap: (notification) =>
                              _handleNotificationTap(context, notification),
                          onDismiss: (notification) {
                            ref
                                .read(notificationsProvider.notifier)
                                .deleteNotification(notification.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    ref.read(notificationsProvider.notifier).undoDelete();
                                  },
                                ),
                              ),
                            );
                          },
                          onMarkAsRead: (notification) {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(notification.id);
                          },
                          onLoadMore: () {
                            ref.read(notificationsProvider.notifier).loadMore();
                          },
                          isLoadingMore: state.isLoadingMore,
                          hasMore: state.hasMore,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.projectAssigned:
      case NotificationType.projectUpdate:
      case NotificationType.quoteAccepted:
      case NotificationType.quoteRejected:
      case NotificationType.deliveryDue:
      case NotificationType.revisionRequested:
        if (notification.projectId != null) {
          context.pushNamed(
            RouteNames.projectDetail,
            pathParameters: {'projectId': notification.projectId!},
          );
        }
        break;
      case NotificationType.chatMessage:
        if (notification.chatRoomId != null) {
          context.pushNamed(
            RouteNames.chat,
            pathParameters: {'roomId': notification.chatRoomId!},
          );
        }
        break;
      case NotificationType.paymentReceived:
        context.pushNamed(RouteNames.earnings);
        break;
      case NotificationType.support:
        if (notification.ticketId != null) {
          context.pushNamed(
            RouteNames.ticketDetail,
            pathParameters: {'ticketId': notification.ticketId!},
          );
        }
        break;
      case NotificationType.review:
        context.pushNamed(RouteNames.reviews);
        break;
      default:
        // Show notification detail dialog
        _showNotificationDetail(context, notification);
    }
  }

  void _showNotificationDetail(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Text(
              notification.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllReadDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark all as read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: const Text('Mark all'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'settings':
        context.pushNamed(RouteNames.notificationSettings);
        break;
      case 'clear_all':
        _showClearAllDialog(context, ref);
        break;
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationsProvider.notifier).deleteAllNotifications();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

/// Groups notifications by date category and renders section headers.
class _GroupedNotificationList extends StatelessWidget {
  const _GroupedNotificationList({
    required this.notifications,
    required this.onNotificationTap,
    this.onDismiss,
    this.onMarkAsRead,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<NotificationModel> notifications;
  final void Function(NotificationModel) onNotificationTap;
  final void Function(NotificationModel)? onDismiss;
  final void Function(NotificationModel)? onMarkAsRead;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  /// Determines the date group label for a given DateTime.
  static String _dateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final notifDate = DateTime(date.year, date.month, date.day);

    if (notifDate == today) return 'Today';
    if (notifDate == yesterday) return 'Yesterday';
    if (notifDate.isAfter(weekStart) || notifDate == weekStart) {
      return 'This Week';
    }
    return 'Older';
  }

  /// Builds grouped entries: a list of (String? header, NotificationModel? notification).
  /// A header entry has header set and notification null. A notification entry is the opposite.
  List<_GroupEntry> _buildGroupEntries() {
    final entries = <_GroupEntry>[];
    String? currentGroup;

    for (final notification in notifications) {
      final group = _dateGroup(notification.createdAt);
      if (group != currentGroup) {
        currentGroup = group;
        entries.add(_GroupEntry(header: group));
      }
      entries.add(_GroupEntry(notification: notification));
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildGroupEntries();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            scrollNotification.metrics.extentAfter < 100 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: entries.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == entries.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final entry = entries[index];

          // Section header
          if (entry.header != null) {
            return _DateSectionHeader(title: entry.header!);
          }

          // Notification card
          final notification = entry.notification!;
          return NotificationCard(
            notification: notification,
            onTap: () => onNotificationTap(notification),
            onDismiss: () => onDismiss?.call(notification),
            onMarkAsRead: () => onMarkAsRead?.call(notification),
          );
        },
      ),
    );
  }
}

/// Internal entry type for grouped list items.
class _GroupEntry {
  const _GroupEntry({this.header, this.notification});
  final String? header;
  final NotificationModel? notification;
}

/// Section header widget for date groups.
class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}

/// Notification settings screen.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // General settings
                _buildSectionHeader(context, 'General'),
                _buildSwitchTile(
                  context,
                  'Push Notifications',
                  'Receive push notifications on your device',
                  Icons.notifications,
                  state.settings.pushEnabled,
                  (value) => _toggleSetting('push_enabled', value),
                ),
                _buildSwitchTile(
                  context,
                  'Email Notifications',
                  'Receive notifications via email',
                  Icons.email,
                  state.settings.emailEnabled,
                  (value) => _toggleSetting('email_enabled', value),
                ),

                // Notification types
                _buildSectionHeader(context, 'Notification Types'),
                _buildSwitchTile(
                  context,
                  'Project Updates',
                  'New projects, quotes, and status changes',
                  Icons.assignment,
                  state.settings.projectUpdates,
                  (value) => _toggleSetting('project_updates', value),
                ),
                _buildSwitchTile(
                  context,
                  'Chat Messages',
                  'New messages from clients and doers',
                  Icons.chat_bubble,
                  state.settings.chatMessages,
                  (value) => _toggleSetting('chat_messages', value),
                ),
                _buildSwitchTile(
                  context,
                  'Payment Alerts',
                  'Payment received and commission updates',
                  Icons.payment,
                  state.settings.paymentAlerts,
                  (value) => _toggleSetting('payment_alerts', value),
                ),
                _buildSwitchTile(
                  context,
                  'System Alerts',
                  'Important system notifications and updates',
                  Icons.warning_amber,
                  state.settings.systemAlerts,
                  (value) => _toggleSetting('system_alerts', value),
                ),

                // Marketing
                _buildSectionHeader(context, 'Marketing'),
                _buildSwitchTile(
                  context,
                  'Marketing Emails',
                  'Promotional emails and newsletters',
                  Icons.campaign,
                  state.settings.marketingEmails,
                  (value) => _toggleSetting('marketing_emails', value),
                ),

                // Quiet hours
                _buildSectionHeader(context, 'Quiet Hours'),
                _buildSwitchTile(
                  context,
                  'Enable Quiet Hours',
                  'Mute notifications during specified hours',
                  Icons.do_not_disturb,
                  state.settings.quietHoursEnabled,
                  (value) => _toggleSetting('quiet_hours_enabled', value),
                ),
                if (state.settings.quietHoursEnabled) ...[
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start Time'),
                    subtitle: Text(state.settings.quietHoursStart ?? '22:00'),
                    onTap: () => _selectTime(context, true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('End Time'),
                    subtitle: Text(state.settings.quietHoursEnd ?? '07:00'),
                    onTap: () => _selectTime(context, false),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  void _toggleSetting(String key, bool value) {
    ref.read(notificationSettingsProvider.notifier).toggleSetting(key, value);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final state = ref.read(notificationSettingsProvider);
    final currentTime = isStart
        ? state.settings.quietHoursStart
        : state.settings.quietHoursEnd;

    TimeOfDay initialTime = const TimeOfDay(hour: 22, minute: 0);
    if (currentTime != null) {
      final parts = currentTime.split(':');
      if (parts.length == 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 22,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      final newSettings = isStart
          ? state.settings.copyWith(quietHoursStart: timeString)
          : state.settings.copyWith(quietHoursEnd: timeString);
      ref.read(notificationSettingsProvider.notifier).updateSettings(newSettings);
    }
  }
}

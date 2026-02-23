import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/widgets/glass_container.dart';

/// Provider for notifications list
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return [];

  final response = await SupabaseConfig.client
      .from('notifications')
      .select()
      .eq('profile_id', userId)
      .order('created_at', ascending: false)
      .limit(50);

  return (response as List)
      .map((json) => AppNotification.fromJson(json))
      .toList();
});

/// Provider for unread count
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return 0;

  final response = await SupabaseConfig.client
      .from('notifications')
      .select('id')
      .eq('profile_id', userId)
      .eq('is_read', false);

  return (response as List).length;
});

/// Notifications screen showing all user notifications.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
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
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(ref),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildFilterTabs(),
              const SizedBox(height: 16),
              Expanded(
                child: notificationsAsync.when(
        data: (notifications) {
          // Filter notifications based on selected tab
          final filteredNotifications = _filterNotifications(notifications, _selectedTabIndex);

          if (filteredNotifications.isEmpty) {
            return _EmptyNotifications(tabIndex: _selectedTabIndex);
          }

          // Group notifications by date
          final grouped = _groupByDate(filteredNotifications);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadNotificationsCountProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final entry = grouped.entries.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        entry.key,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (notification) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationTile(
                          notification: notification,
                          onTap: () => _handleNotificationTap(context, ref, notification),
                          onDismissed: () => _deleteNotification(ref, notification.id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, _) => Center(
          child: GlassCard(
            blur: 12,
            opacity: 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withValues(alpha: 0.2),
                        AppColors.error.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.alertCircle,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load notifications',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(notificationsProvider),
                  icon: Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build filter tabs with glassmorphic design - even width
  Widget _buildFilterTabs() {
    const tabs = [
      (icon: LucideIcons.inbox, label: 'All'),
      (icon: LucideIcons.mailOpen, label: 'Unread'),
      (icon: LucideIcons.briefcase, label: 'Projects'),
      (icon: LucideIcons.users, label: 'Campus'),
      (icon: LucideIcons.settings, label: 'System'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                setState(() => _selectedTabIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.label,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Filter notifications based on selected tab
  List<AppNotification> _filterNotifications(
    List<AppNotification> notifications,
    int tabIndex,
  ) {
    switch (tabIndex) {
      case 0: // All
        return notifications;
      case 1: // Unread
        return notifications.where((n) => !n.isRead).toList();
      case 2: // Projects
        return notifications.where((n) =>
          n.notificationType == NotificationType.projectSubmitted ||
          n.notificationType == NotificationType.projectAssigned ||
          n.notificationType == NotificationType.projectDelivered ||
          n.notificationType == NotificationType.projectCompleted ||
          n.notificationType == NotificationType.taskAvailable ||
          n.notificationType == NotificationType.taskAssigned
        ).toList();
      case 3: // Campus/Marketplace
        return notifications.where((n) =>
          n.referenceType == 'marketplace' ||
          n.notificationType == NotificationType.promotional
        ).toList();
      case 4: // System
        return notifications.where((n) =>
          n.notificationType == NotificationType.systemAlert ||
          n.notificationType == NotificationType.paymentReceived ||
          n.notificationType == NotificationType.payoutProcessed
        ).toList();
      default:
        return notifications;
    }
  }

  Map<String, List<AppNotification>> _groupByDate(List<AppNotification> notifications) {
    final Map<String, List<AppNotification>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
        key = 'This Week';
      } else {
        key = DateFormat('MMMM yyyy').format(date);
      }

      grouped.putIfAbsent(key, () => []).add(notification);
    }

    return grouped;
  }

  Future<void> _markAllAsRead(WidgetRef ref) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    await SupabaseConfig.client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('profile_id', userId)
        .eq('is_read', false);

    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  /// Delete a notification
  Future<void> _deleteNotification(WidgetRef ref, String notificationId) async {
    await SupabaseConfig.client
        .from('notifications')
        .delete()
        .eq('id', notificationId);

    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    // Mark as read
    if (!notification.isRead) {
      await SupabaseConfig.client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notification.id);

      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationsCountProvider);
    }

    // Navigate based on notification type and action URL
    if (!context.mounted) return;

    if (notification.actionUrl != null) {
      context.push(notification.actionUrl!);
      return;
    }

    // Navigate based on reference type
    switch (notification.referenceType) {
      case 'project':
        if (notification.referenceId != null) {
          context.push('/projects/${notification.referenceId}');
        }
        break;
      case 'chat':
        if (notification.referenceId != null) {
          context.push('/projects/${notification.referenceId}/chat');
        }
        break;
      case 'wallet':
        context.push('/wallet');
        break;
      default:
        // Show notification detail or do nothing
        break;
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  final int tabIndex;

  const _EmptyNotifications({this.tabIndex = 0});

  String _getEmptyMessage() {
    switch (tabIndex) {
      case 1:
        return 'No unread notifications';
      case 2:
        return 'No project notifications';
      case 3:
        return 'No campus notifications';
      case 4:
        return 'No system notifications';
      default:
        return 'No notifications yet';
    }
  }

  String _getEmptySubtitle() {
    switch (tabIndex) {
      case 1:
        return 'All caught up!';
      case 2:
        return 'Project updates will appear here';
      case 3:
        return 'Campus Connect updates will appear here';
      case 4:
        return 'System alerts will appear here';
      default:
        return 'You\'ll see updates about your projects here';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          blur: 12,
          opacity: 0.8,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.bellOff,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getEmptyMessage(),
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getEmptySubtitle(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.error.withValues(alpha: 0.5),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          LucideIcons.trash2,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) => onDismissed(),
      child: GlassCard(
        blur: 12,
        opacity: notification.isRead ? 0.7 : 0.85,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with gradient background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getIconColor().withValues(alpha: 0.3),
                    _getIconColor().withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 24,
                color: _getIconColor(),
              ),
            ),
            const SizedBox(width: 12),

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
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: notification.isRead
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(notification.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
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
    );
  }

  IconData _getIcon() {
    switch (notification.notificationType) {
      case NotificationType.projectSubmitted:
        return LucideIcons.send;
      case NotificationType.quoteReady:
        return LucideIcons.fileText;
      case NotificationType.paymentReceived:
        return LucideIcons.creditCard;
      case NotificationType.projectAssigned:
        return LucideIcons.userPlus;
      case NotificationType.taskAvailable:
        return LucideIcons.clipboardList;
      case NotificationType.taskAssigned:
        return LucideIcons.clipboardCheck;
      case NotificationType.workSubmitted:
        return LucideIcons.uploadCloud;
      case NotificationType.qcApproved:
        return LucideIcons.badgeCheck;
      case NotificationType.qcRejected:
        return LucideIcons.xCircle;
      case NotificationType.revisionRequested:
        return LucideIcons.refreshCw;
      case NotificationType.projectDelivered:
        return LucideIcons.truck;
      case NotificationType.projectCompleted:
        return LucideIcons.checkCircle2;
      case NotificationType.newMessage:
        return LucideIcons.messageCircle;
      case NotificationType.payoutProcessed:
        return LucideIcons.wallet;
      case NotificationType.systemAlert:
        return LucideIcons.info;
      case NotificationType.promotional:
        return LucideIcons.megaphone;
    }
  }

  Color _getIconColor() {
    switch (notification.notificationType) {
      case NotificationType.quoteReady:
      case NotificationType.projectSubmitted:
        return AppColors.info;
      case NotificationType.paymentReceived:
      case NotificationType.payoutProcessed:
      case NotificationType.projectCompleted:
      case NotificationType.qcApproved:
        return AppColors.success;
      case NotificationType.projectDelivered:
      case NotificationType.workSubmitted:
        return AppColors.primary;
      case NotificationType.revisionRequested:
      case NotificationType.qcRejected:
        return AppColors.warning;
      case NotificationType.newMessage:
        return AppColors.primary;
      case NotificationType.systemAlert:
        return AppColors.textSecondary;
      case NotificationType.promotional:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
}

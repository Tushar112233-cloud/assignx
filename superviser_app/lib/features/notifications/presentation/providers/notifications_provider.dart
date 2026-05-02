import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// Provider for notification repository.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// State for notifications.
class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.selectedFilter,
  });

  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final NotificationType? selectedFilter;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    NotificationType? selectedFilter,
    bool clearFilter = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }
}

/// Notifier for notifications state.
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;
  StreamSubscription<List<NotificationModel>>? _subscription;
  NotificationModel? _lastDeletedNotification;

  static const _pageSize = 20;

  /// Initialize and load notifications.
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get initial notifications
      final notifications = await _repository.getNotifications(limit: _pageSize);
      final unreadCount = await _repository.getUnreadCount();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        hasMore: notifications.length >= _pageSize,
      );

      // Subscribe to real-time updates
      _subscribeToUpdates();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Subscribe to real-time notification updates.
  void _subscribeToUpdates() {
    _subscription?.cancel();
    _subscription = _repository.watchNotifications().listen((notifications) {
      // Merge with existing notifications, keeping pagination
      final existingIds = state.notifications.map((n) => n.id).toSet();
      final newNotifications = notifications
          .where((n) => !existingIds.contains(n.id))
          .toList();

      if (newNotifications.isNotEmpty) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        state = state.copyWith(
          notifications: [...newNotifications, ...state.notifications],
          unreadCount: unreadCount,
        );
      }
    });
  }

  /// Load more notifications.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final notifications = await _repository.getNotifications(
        limit: _pageSize,
        offset: state.notifications.length,
        type: state.selectedFilter,
      );

      state = state.copyWith(
        notifications: [...state.notifications, ...notifications],
        isLoadingMore: false,
        hasMore: notifications.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh notifications.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _repository.getNotifications(
        limit: _pageSize,
        type: state.selectedFilter,
      );
      final unreadCount = await _repository.getUnreadCount();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        hasMore: notifications.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Filter notifications by type.
  Future<void> setFilter(NotificationType? type) async {
    state = state.copyWith(
      selectedFilter: type,
      isLoading: true,
      clearFilter: type == null,
    );

    try {
      final notifications = await _repository.getNotifications(
        limit: _pageSize,
        type: type,
      );

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: notifications.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mark notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      final wasUnread = state.notifications
          .firstWhere((n) => n.id == notificationId)
          .isRead == false;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: wasUnread ? state.unreadCount - 1 : state.unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      final updatedNotifications = state.notifications
          .map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete notification.
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notification = state.notifications.firstWhere((n) => n.id == notificationId);
      _lastDeletedNotification = notification;

      await _repository.deleteNotification(notificationId);

      final wasUnread = !notification.isRead;

      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != notificationId).toList(),
        unreadCount: wasUnread ? state.unreadCount - 1 : state.unreadCount,
      );
    } catch (e) {
      _lastDeletedNotification = null;
      state = state.copyWith(error: e.toString());
    }
  }

  /// Undo the last delete operation.
  Future<void> undoDelete() async {
    if (_lastDeletedNotification == null) return;

    try {
      // Restore notification locally (server-side would need a restore endpoint)
      final notification = _lastDeletedNotification!;
      final wasUnread = !notification.isRead;

      state = state.copyWith(
        notifications: [notification, ...state.notifications],
        unreadCount: wasUnread ? state.unreadCount + 1 : state.unreadCount,
      );

      _lastDeletedNotification = null;

      // Optionally call server to restore if there's an endpoint
      // await _repository.restoreNotification(notification.id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete all notifications.
  Future<void> deleteAllNotifications() async {
    try {
      await _repository.deleteAllNotifications();
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for notifications state.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository);
});

/// Provider for unread notification count.
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

/// State for notification settings.
class NotificationSettingsState {
  const NotificationSettingsState({
    this.settings = const NotificationSettings(),
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final NotificationSettings settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  NotificationSettingsState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Notifier for notification settings.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier(this._repository) : super(const NotificationSettingsState());

  final NotificationRepository _repository;

  /// Load settings.
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update settings.
  Future<void> updateSettings(NotificationSettings settings) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      await _repository.updateSettings(settings);
      state = state.copyWith(
        settings: settings,
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle a specific setting.
  Future<void> toggleSetting(String settingKey, bool value) async {
    NotificationSettings newSettings;

    switch (settingKey) {
      case 'push_enabled':
        newSettings = state.settings.copyWith(pushEnabled: value);
        break;
      case 'email_enabled':
        newSettings = state.settings.copyWith(emailEnabled: value);
        break;
      case 'project_updates':
        newSettings = state.settings.copyWith(projectUpdates: value);
        break;
      case 'chat_messages':
        newSettings = state.settings.copyWith(chatMessages: value);
        break;
      case 'payment_alerts':
        newSettings = state.settings.copyWith(paymentAlerts: value);
        break;
      case 'system_alerts':
        newSettings = state.settings.copyWith(systemAlerts: value);
        break;
      case 'marketing_emails':
        newSettings = state.settings.copyWith(marketingEmails: value);
        break;
      case 'quiet_hours_enabled':
        newSettings = state.settings.copyWith(quietHoursEnabled: value);
        break;
      default:
        return;
    }

    await updateSettings(newSettings);
  }
}

/// Provider for notification settings.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationSettingsNotifier(repository);
});

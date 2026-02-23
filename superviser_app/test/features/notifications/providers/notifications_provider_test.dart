import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:superviser_app/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationsState', () {
    test('default state has correct initial values', () {
      const state = NotificationsState();
      expect(state.notifications, isEmpty);
      expect(state.unreadCount, 0);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
      expect(state.selectedFilter, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = NotificationsState();
      final notifications = [
        _createNotification('1'),
        _createNotification('2'),
      ];

      final newState = state.copyWith(
        notifications: notifications,
        unreadCount: 5,
        isLoading: true,
        hasMore: false,
      );

      expect(newState.notifications.length, 2);
      expect(newState.unreadCount, 5);
      expect(newState.isLoading, isTrue);
      expect(newState.hasMore, isFalse);
    });

    test('copyWith with clearFilter clears the selected filter', () {
      const state = NotificationsState(
        selectedFilter: NotificationType.chatMessage,
      );
      final newState = state.copyWith(clearFilter: true);
      expect(newState.selectedFilter, isNull);
    });

    test('copyWith preserves filter when not cleared', () {
      const state = NotificationsState(
        selectedFilter: NotificationType.chatMessage,
      );
      final newState = state.copyWith(isLoading: true);
      expect(newState.selectedFilter, NotificationType.chatMessage);
    });

    test('copyWith updates filter when new filter provided', () {
      const state = NotificationsState(
        selectedFilter: NotificationType.chatMessage,
      );
      final newState = state.copyWith(
        selectedFilter: NotificationType.paymentReceived,
      );
      expect(newState.selectedFilter, NotificationType.paymentReceived);
    });

    test('copyWith error is cleared when new error is null', () {
      const state = NotificationsState(error: 'Previous error');
      final newState = state.copyWith();
      // Error should be cleared when not explicitly passed
      expect(newState.error, isNull);
    });
  });

  group('NotificationSettingsState', () {
    test('default state has correct initial values', () {
      const state = NotificationSettingsState();
      expect(state.settings, isA<NotificationSettings>());
      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith creates new state with updated values', () {
      const state = NotificationSettingsState();
      final settings = const NotificationSettings(
        pushEnabled: false,
        emailEnabled: true,
      );

      final newState = state.copyWith(
        settings: settings,
        isLoading: true,
      );

      expect(newState.settings.pushEnabled, isFalse);
      expect(newState.settings.emailEnabled, isTrue);
      expect(newState.isLoading, isTrue);
    });
  });

  group('NotificationSettings', () {
    test('default settings have correct values', () {
      const settings = NotificationSettings();
      expect(settings.pushEnabled, isTrue);
      expect(settings.emailEnabled, isTrue);
      expect(settings.projectUpdates, isTrue);
      expect(settings.chatMessages, isTrue);
      expect(settings.paymentAlerts, isTrue);
      expect(settings.systemAlerts, isTrue);
      expect(settings.marketingEmails, isFalse);
      expect(settings.quietHoursEnabled, isFalse);
      expect(settings.quietHoursStart, isNull);
      expect(settings.quietHoursEnd, isNull);
    });

    test('copyWith creates new settings with updated values', () {
      const settings = NotificationSettings();
      final newSettings = settings.copyWith(
        pushEnabled: false,
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '07:00',
      );

      expect(newSettings.pushEnabled, isFalse);
      expect(newSettings.quietHoursEnabled, isTrue);
      expect(newSettings.quietHoursStart, '22:00');
      expect(newSettings.quietHoursEnd, '07:00');
      // Original values preserved
      expect(newSettings.emailEnabled, isTrue);
    });
  });

  group('NotificationType', () {
    test('has all expected values', () {
      expect(NotificationType.values.length, greaterThan(5));
      expect(NotificationType.values, contains(NotificationType.projectAssigned));
      expect(NotificationType.values, contains(NotificationType.chatMessage));
      expect(NotificationType.values, contains(NotificationType.paymentReceived));
    });
  });
}

// Helper function to create test notification
NotificationModel _createNotification(String id) {
  return NotificationModel(
    id: id,
    userId: 'user_$id',
    type: NotificationType.projectUpdate,
    title: 'Test Notification $id',
    body: 'This is a test notification',
    isRead: false,
    createdAt: DateTime.now(),
  );
}

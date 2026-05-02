import '../../../../core/api/api_client.dart';
import '../models/notification_model.dart';

/// Repository for notification operations.
class NotificationRepository {
  NotificationRepository();

  /// Fetch notifications with pagination.
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    int offset = 0,
    bool? isRead,
    NotificationType? type,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (isRead != null) 'isRead': '$isRead',
      if (type != null) 'type': type.name,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await ApiClient.get('/notifications?$query');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['notifications'] as List? ?? [];

    return list
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    final response = await ApiClient.get('/notifications/unread-count');
    if (response is Map<String, dynamic>) {
      return response['count'] as int? ?? 0;
    }
    return 0;
  }

  /// Mark notification as read.
  Future<void> markAsRead(String notificationId) async {
    await ApiClient.put('/notifications/$notificationId/read', {});
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await ApiClient.put('/notifications/mark-all-read', {});
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    await ApiClient.delete('/notifications/$notificationId');
  }

  /// Delete all notifications.
  Future<void> deleteAllNotifications() async {
    await ApiClient.delete('/notifications/all');
  }

  /// Stream notifications in real-time.
  /// Note: Real-time notifications handled via Socket.IO in the app.
  Stream<List<NotificationModel>> watchNotifications() {
    // Socket.IO based real-time is handled at the provider level
    return Stream.value([]);
  }

  /// Get notification settings from user preferences.
  Future<NotificationSettings> getSettings() async {
    try {
      final response = await ApiClient.get('/supervisors/me/preferences');
      if (response != null && response is Map<String, dynamic>) {
        return NotificationSettings.fromJson(response);
      }
    } catch (_) {}
    return const NotificationSettings();
  }

  /// Update notification settings in user preferences.
  Future<void> updateSettings(NotificationSettings settings) async {
    await ApiClient.put('/supervisors/me/preferences', settings.toJson());
  }

  /// Register device token for push notifications.
  Future<void> registerDeviceToken(String token, {String? platform}) async {
    // Push token management handled externally
  }

  /// Unregister device token.
  Future<void> unregisterDeviceToken(String token) async {
    // Push token management handled externally
  }
}

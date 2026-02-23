import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/notification_model.dart';

/// Repository for notification operations.
class NotificationRepository {
  NotificationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID.
  String? get _currentUserId => getCurrentUserId();

  /// Fetch notifications with pagination.
  Future<List<NotificationModel>> getNotifications({
    int limit = 20,
    int offset = 0,
    bool? isRead,
    NotificationType? type,
  }) async {
    if (_currentUserId == null) return [];

    var query = _client
        .from('notifications')
        .select()
        .eq('profile_id', _currentUserId!);

    if (isRead != null) {
      query = query.eq('is_read', isRead);
    }

    if (type != null) {
      query = query.eq('notification_type', type.name);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// Get unread notification count.
  Future<int> getUnreadCount() async {
    if (_currentUserId == null) return 0;

    final response = await _client
        .from('notifications')
        .select('id')
        .eq('profile_id', _currentUserId!)
        .eq('is_read', false);

    return (response as List).length;
  }

  /// Mark notification as read.
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    await _client
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('profile_id', _currentUserId!)
        .eq('is_read', false);
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    await _client.from('notifications').delete().eq('id', notificationId);
  }

  /// Delete all notifications.
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;

    await _client
        .from('notifications')
        .delete()
        .eq('profile_id', _currentUserId!);
  }

  /// Stream notifications in real-time.
  Stream<List<NotificationModel>> watchNotifications() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', _currentUserId!)
        .order('created_at', ascending: false)
        .map((data) => data.map(NotificationModel.fromJson).toList());
  }

  /// Get notification settings.
  Future<NotificationSettings> getSettings() async {
    if (_currentUserId == null) return const NotificationSettings();

    final response = await _client
        .from('notification_settings')
        .select()
        .eq('profile_id', _currentUserId!)
        .maybeSingle();

    if (response == null) return const NotificationSettings();
    return NotificationSettings.fromJson(response);
  }

  /// Update notification settings.
  Future<void> updateSettings(NotificationSettings settings) async {
    if (_currentUserId == null) return;

    await _client.from('notification_settings').upsert({
      'user_id': _currentUserId!,
      ...settings.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Register device token for push notifications.
  Future<void> registerDeviceToken(String token, {String? platform}) async {
    if (_currentUserId == null) return;

    await _client.from('device_tokens').upsert({
      'user_id': _currentUserId!,
      'token': token,
      'platform': platform ?? 'unknown',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Unregister device token.
  Future<void> unregisterDeviceToken(String token) async {
    await _client.from('device_tokens').delete().eq('token', token);
  }
}

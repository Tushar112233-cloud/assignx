import '../../core/config/supabase_config.dart';
import '../models/banner_model.dart';
import '../models/notification_model.dart';
import '../models/wallet_model.dart';

/// Repository for home screen data operations.
///
/// Handles wallet, banner, and notification data fetching from Supabase.
/// All user-specific queries use profile_id to match the database schema.
class HomeRepository {
  final _client = SupabaseConfig.client;

  /// Get user wallet by profile ID.
  ///
  /// Fetches wallet data including balance, locked_amount, and transaction totals.
  /// Returns null if no wallet exists for the given profile.
  ///
  /// @param profileId The user's profile UUID (FK to profiles table).
  /// @returns The user's [Wallet] or null if not found.
  Future<Wallet?> getWallet(String profileId) async {
    final response = await _client
        .from('wallets')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response == null) return null;
    return Wallet.fromJson(response);
  }

  /// Get promotional banners from 'banners' table.
  ///
  /// Fetches active banners ordered by display_order.
  /// Falls back to mock banners if the table doesn't exist or on error.
  ///
  /// @returns List of active [AppBanner] objects sorted by display_order.
  Future<List<AppBanner>> getBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return (response as List)
          .map((json) => AppBanner.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock banners if table doesn't exist or error
      return AppBanner.mockBanners;
    }
  }

  /// Get user notifications by profile ID.
  ///
  /// Fetches the most recent 20 notifications for the user,
  /// ordered by created_at descending.
  ///
  /// @param profileId The user's profile UUID (FK to profiles table).
  /// @returns List of [AppNotification] objects.
  Future<List<AppNotification>> getNotifications(String profileId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get unread notification count for a user.
  ///
  /// @param profileId The user's profile UUID (FK to profiles table).
  /// @returns The count of unread notifications.
  Future<int> getUnreadCount(String profileId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('profile_id', profileId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Mark a single notification as read.
  ///
  /// Updates the is_read flag and sets read_at timestamp.
  ///
  /// @param notificationId The UUID of the notification to mark as read.
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// Mark all notifications as read for a user.
  ///
  /// Updates all unread notifications for the given profile,
  /// setting is_read to true and read_at to current timestamp.
  ///
  /// @param profileId The user's profile UUID (FK to profiles table).
  Future<void> markAllAsRead(String profileId) async {
    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('profile_id', profileId).eq('is_read', false);
  }
}

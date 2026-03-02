import '../../core/api/api_client.dart';
import '../models/banner_model.dart';
import '../models/notification_model.dart';
import '../models/wallet_model.dart';

/// Repository for home screen data operations.
///
/// Handles wallet, banner, and notification data fetching via the Express API.
class HomeRepository {
  /// Get user wallet by profile ID.
  Future<Wallet?> getWallet(String profileId) async {
    try {
      final response = await ApiClient.get('/wallets/me');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      // API returns { wallet: {...} } wrapped
      final walletData = data['wallet'] as Map<String, dynamic>? ?? data;
      return Wallet.fromJson(walletData);
    } catch (_) {
      return null;
    }
  }

  /// Get promotional banners.
  Future<List<AppBanner>> getBanners() async {
    try {
      final response = await ApiClient.get('/admin/banners');
      final list = response is List ? response : (response as Map<String, dynamic>)['banners'] as List? ?? [];
      return list
          .map((json) => AppBanner.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return AppBanner.mockBanners;
    }
  }

  /// Get user notifications by profile ID.
  Future<List<AppNotification>> getNotifications(String profileId) async {
    try {
      final response = await ApiClient.get('/notifications', queryParams: {
        'limit': '20',
      });
      final list = response is List ? response : (response as Map<String, dynamic>)['notifications'] as List? ?? [];
      return list
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get unread notification count for a user.
  Future<int> getUnreadCount(String profileId) async {
    try {
      final response = await ApiClient.get('/notifications/unread-count');
      return (response as Map<String, dynamic>)['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    await ApiClient.put('/notifications/$notificationId/read', {});
  }

  /// Mark all notifications as read for a user.
  Future<void> markAllAsRead(String profileId) async {
    await ApiClient.put('/notifications/read-all', {});
  }
}

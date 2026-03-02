import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../../core/api/auth_api.dart';
import '../../core/storage/token_storage.dart';
import '../models/faq_model.dart';
import '../models/support_ticket_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

// Re-export user model for backward compatibility
export '../models/user_model.dart' show UserProfile, UserType, ProfessionalType;

/// Repository for profile operations via the Express API.
class ProfileRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProfileRepository();

  /// Get current user's profile.
  Future<UserProfile> getProfile() async {
    try {
      final response = await ApiClient.get('/profiles/me');
      final data = response as Map<String, dynamic>;
      // API may return flat profile or wrapped in { profile: {...} }
      final profileData = data.containsKey('email') ? data : (data['profile'] as Map<String, dynamic>? ?? data);
      return UserProfile.fromJson(profileData);
    } catch (e) {
      _logger.e('Error fetching profile: $e');
      rethrow;
    }
  }

  /// Update user profile.
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? city,
    String? state,
    UserType? userType,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (city != null) updates['city'] = city;
      if (state != null) updates['state'] = state;
      if (userType != null) updates['userType'] = userType.toDbString();

      final response = await ApiClient.put('/profiles/me', updates);
      final data = response as Map<String, dynamic>;
      // PUT returns { profile: {...} } wrapped
      final profileData = data.containsKey('email') ? data : (data['profile'] as Map<String, dynamic>? ?? data);
      return UserProfile.fromJson(profileData);
    } catch (e) {
      _logger.e('Error updating profile: $e');
      rethrow;
    }
  }

  /// Get user's wallet.
  Future<Wallet> getWallet() async {
    try {
      final response = await ApiClient.get('/wallets/me');
      final data = response as Map<String, dynamic>;
      // API returns { wallet: {...} } wrapped
      final walletData = data['wallet'] as Map<String, dynamic>? ?? data;
      return Wallet.fromJson(walletData);
    } catch (e) {
      _logger.e('Error fetching wallet: $e');
      rethrow;
    }
  }

  /// Get wallet transactions.
  Future<List<WalletTransaction>> getTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await ApiClient.get('/wallets/me/transactions', queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      });
      final list = response is List ? response : (response as Map<String, dynamic>)['transactions'] as List? ?? [];
      return list
          .map((json) => WalletTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching transactions: $e');
      return [];
    }
  }

  /// Top up wallet (deprecated - use PaymentService).
  @Deprecated('Use PaymentService.topUpWallet() for secure payment flow')
  Future<Wallet> topUpWallet(double amount) async {
    try {
      return await getWallet();
    } catch (e) {
      _logger.e('Error getting wallet: $e');
      rethrow;
    }
  }

  /// Get payment methods.
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await ApiClient.get('/profiles/me/payment-methods');
      final list = response is List ? response : (response as Map<String, dynamic>)['paymentMethods'] as List? ?? [];
      return list
          .map((json) => PaymentMethod.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching payment methods: $e');
      return [];
    }
  }

  /// Add payment method.
  Future<PaymentMethod> addPaymentMethod({
    required PaymentMethodType type,
    required String displayName,
    String? lastFourDigits,
    String? upiId,
    bool setAsDefault = false,
  }) async {
    try {
      final response = await ApiClient.post('/profiles/me/payment-methods', {
        'methodType': type.toDbString(),
        'displayName': displayName,
        'cardLastFour': lastFourDigits,
        'upiId': upiId,
        'isDefault': setAsDefault,
      });
      return PaymentMethod.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error adding payment method: $e');
      rethrow;
    }
  }

  /// Delete payment method.
  Future<void> deletePaymentMethod(String id) async {
    try {
      await ApiClient.delete('/profiles/me/payment-methods/$id');
    } catch (e) {
      _logger.e('Error deleting payment method: $e');
      rethrow;
    }
  }

  /// Get referral info.
  Future<Referral> getReferral() async {
    try {
      final response = await ApiClient.get('/profiles/me/referral');
      final data = response as Map<String, dynamic>;
      return Referral.fromJson(data);
    } catch (e) {
      _logger.e('Error fetching referral: $e');
      // Return empty referral instead of crashing
      return Referral(
        id: '',
        userId: '',
        code: '',
        totalReferrals: 0,
        totalEarnings: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Get completed projects count.
  Future<int> getCompletedProjectsCount() async {
    try {
      final response = await ApiClient.get('/projects', queryParams: {
        'status': 'completed',
        'countOnly': 'true',
      });
      if (response is Map<String, dynamic>) {
        return response['count'] as int? ?? 0;
      }
      if (response is List) return response.length;
      return 0;
    } catch (e) {
      _logger.e('Error fetching completed projects count: $e');
      return 0;
    }
  }

  /// Log out user.
  Future<void> logout() async {
    await AuthApi.logout();
  }

  /// Get app version.
  Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      _logger.w('Error getting app version: $e');
      return '1.0.0';
    }
  }

  // ============================================================
  // Support Tickets
  // ============================================================

  /// Get user's support tickets.
  Future<List<SupportTicket>> getSupportTickets({
    int limit = 50,
    int offset = 0,
    TicketStatus? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) queryParams['status'] = status.dbValue;

      final response = await ApiClient.get('/support/tickets', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['tickets'] as List? ?? [];
      return list
          .map((json) => SupportTicket.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching support tickets: $e');
      return [];
    }
  }

  /// Get a single support ticket with responses.
  Future<SupportTicket> getSupportTicket(String ticketId) async {
    try {
      final response = await ApiClient.get('/support/tickets/$ticketId');
      return SupportTicket.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching support ticket: $e');
      rethrow;
    }
  }

  /// Create a new support ticket.
  Future<SupportTicket> createSupportTicket({
    required String subject,
    required String description,
    required TicketCategory category,
  }) async {
    try {
      final response = await ApiClient.post('/support/tickets', {
        'subject': subject,
        'description': description,
        'category': category.dbValue,
      });
      return SupportTicket.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error creating support ticket: $e');
      rethrow;
    }
  }

  /// Add a response to a ticket.
  Future<TicketResponse> addTicketResponse({
    required String ticketId,
    required String message,
  }) async {
    try {
      final response = await ApiClient.post('/support/tickets/$ticketId/messages', {
        'message': message,
      });
      return TicketResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error adding ticket response: $e');
      rethrow;
    }
  }

  // ============================================================
  // FAQs
  // ============================================================

  static const String _faqCacheKey = 'cached_faqs';
  static const Duration _faqCacheExpiry = Duration(hours: 24);

  /// Get FAQs with optional category filter.
  Future<List<FAQ>> getFAQs({FAQCategory? category}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category.dbValue;

      final response = await ApiClient.get('/support/faqs', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['faqs'] as List? ?? [];
      final faqs = list
          .map((json) => FAQ.fromJson(json as Map<String, dynamic>))
          .toList();

      await _cacheFAQs(faqs);
      return faqs;
    } catch (e) {
      _logger.e('Error fetching FAQs: $e');

      final cachedFAQs = await _getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        _logger.i('Returning ${cachedFAQs.length} cached FAQs');
        if (category != null) {
          return cachedFAQs.filterByCategory(category);
        }
        return cachedFAQs;
      }

      return [];
    }
  }

  /// Search FAQs by query string.
  Future<List<FAQ>> searchFAQs(String query) async {
    if (query.isEmpty) return getFAQs();

    try {
      final allFAQs = await getFAQs();
      return allFAQs.search(query);
    } catch (e) {
      _logger.e('Error searching FAQs: $e');
      final cachedFAQs = await _getCachedFAQs();
      if (cachedFAQs.isNotEmpty) return cachedFAQs.search(query);
      return [];
    }
  }

  /// Get FAQs grouped by category.
  Future<List<GroupedFAQs>> getGroupedFAQs() async {
    try {
      final faqs = await getFAQs();
      return faqs.groupByCategory();
    } catch (e) {
      _logger.e('Error getting grouped FAQs: $e');
      return [];
    }
  }

  Future<void> _cacheFAQs(List<FAQ> faqs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'faqs': faqs.map((f) => f.toJson()).toList(),
        'cached_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_faqCacheKey, jsonEncode(data));
    } catch (e) {
      _logger.w('Failed to cache FAQs: $e');
    }
  }

  Future<List<FAQ>> _getCachedFAQs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_faqCacheKey);
      if (cached == null) return [];

      final data = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(data['cached_at'] as String);

      if (DateTime.now().difference(cachedAt) > _faqCacheExpiry) {
        await prefs.remove(_faqCacheKey);
        return [];
      }

      return (data['faqs'] as List)
          .map((json) => FAQ.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.w('Failed to get cached FAQs: $e');
      return [];
    }
  }

  Future<void> clearFAQCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_faqCacheKey);
    } catch (e) {
      _logger.w('Failed to clear FAQ cache: $e');
    }
  }
}

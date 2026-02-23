import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

import '../models/faq_model.dart';
import '../models/support_ticket_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

// Re-export user model for backward compatibility
export '../models/user_model.dart' show UserProfile, UserType, ProfessionalType;

/// Repository for profile operations.
class ProfileRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProfileRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current user ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get current user's profile.
  Future<UserProfile> getProfile() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (city != null) updates['city'] = city;
      if (state != null) updates['state'] = state;
      if (userType != null) updates['user_type'] = userType.toDbString();

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      _logger.e('Error updating profile: $e');
      rethrow;
    }
  }

  /// Get user's wallet.
  Future<Wallet> getWallet() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('wallets')
          .select()
          .eq('profile_id', userId)
          .single();

      return Wallet.fromJson(response);
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First get the wallet ID
      final walletResponse = await _supabase
          .from('wallets')
          .select('id')
          .eq('profile_id', userId)
          .single();

      final walletId = walletResponse['id'] as String;

      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', walletId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => WalletTransaction.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Top up wallet.
  ///
  /// Note: This method is deprecated. Wallet top-ups are now handled
  /// entirely through the PaymentService which:
  /// 1. Creates a server-side Razorpay order
  /// 2. Opens Razorpay checkout
  /// 3. Verifies payment signature on server
  /// 4. Updates wallet balance atomically on server
  ///
  /// Use PaymentService.topUpWallet() instead.
  ///
  /// @param amount Amount to top up in INR.
  /// @returns Current wallet (balance will be updated after payment verification).
  @Deprecated('Use PaymentService.topUpWallet() for secure payment flow')
  Future<Wallet> topUpWallet(double amount) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Just return current wallet - actual top-up happens via PaymentService
      // which handles server-side order creation, verification, and atomic update
      return await getWallet();
    } catch (e) {
      _logger.e('Error getting wallet: $e');
      rethrow;
    }
  }

  /// Get payment methods.
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('payment_methods')
          .select()
          .eq('profile_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentMethod.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching payment methods: $e');
      rethrow;
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // If setting as default, unset other defaults first
      if (setAsDefault) {
        await _supabase
            .from('payment_methods')
            .update({'is_default': false})
            .eq('profile_id', userId);
      }

      final response = await _supabase
          .from('payment_methods')
          .insert({
            'profile_id': userId,
            'method_type': type.toDbString(),
            'display_name': displayName,
            'card_last_four': lastFourDigits,
            'upi_id': upiId,
            'is_default': setAsDefault,
          })
          .select()
          .single();

      return PaymentMethod.fromJson(response);
    } catch (e) {
      _logger.e('Error adding payment method: $e');
      rethrow;
    }
  }

  /// Delete payment method.
  Future<void> deletePaymentMethod(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase
          .from('payment_methods')
          .delete()
          .eq('id', id)
          .eq('profile_id', userId);
    } catch (e) {
      _logger.e('Error deleting payment method: $e');
      rethrow;
    }
  }

  /// Get referral info.
  Future<Referral> getReferral() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get profile with referral code
      final profile = await getProfile();

      // Count successful referrals
      final referralsResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('referred_by', userId);

      final totalReferrals = (referralsResponse as List).length;

      // Calculate total earnings (assuming 200 per referral)
      const earningsPerReferral = 200.0;
      final totalEarnings = totalReferrals * earningsPerReferral;

      return Referral(
        id: userId,
        userId: userId,
        code: profile.referralCode ?? 'ASSIGNX${userId.substring(0, 6).toUpperCase()}',
        totalReferrals: totalReferrals,
        totalEarnings: totalEarnings,
        createdAt: profile.createdAt,
      );
    } catch (e) {
      _logger.e('Error fetching referral: $e');
      rethrow;
    }
  }

  /// Get completed projects count.
  Future<int> getCompletedProjectsCount() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('projects')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');

      return (response as List).length;
    } catch (e) {
      _logger.e('Error fetching completed projects count: $e');
      return 0;
    }
  }

  /// Log out user.
  ///
  /// Signs out from both Google and Supabase to ensure a clean logout.
  Future<void> logout() async {
    // Sign out from Google to clear the cached session
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Sign out from Supabase
    await _supabase.auth.signOut();
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      var query = _supabase
          .from('support_tickets')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status.dbValue);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => SupportTicket.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error fetching support tickets: $e');
      rethrow;
    }
  }

  /// Get a single support ticket with responses.
  Future<SupportTicket> getSupportTicket(String ticketId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get the ticket
      final ticketResponse = await _supabase
          .from('support_tickets')
          .select()
          .eq('id', ticketId)
          .eq('user_id', userId)
          .single();

      // Get responses for the ticket
      final responsesResponse = await _supabase
          .from('ticket_responses')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      // Parse ticket with responses
      final ticketJson = Map<String, dynamic>.from(ticketResponse);
      ticketJson['responses'] = responsesResponse;

      return SupportTicket.fromJson(ticketJson);
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('support_tickets')
          .insert({
            'user_id': userId,
            'subject': subject,
            'description': description,
            'category': category.dbValue,
            'status': TicketStatus.open.dbValue,
          })
          .select()
          .single();

      return SupportTicket.fromJson(response);
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('ticket_responses')
          .insert({
            'ticket_id': ticketId,
            'responder_id': userId,
            'message': message,
            'is_staff_response': false,
          })
          .select()
          .single();

      // Update ticket's updated_at timestamp
      await _supabase
          .from('support_tickets')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', ticketId);

      return TicketResponse.fromJson(response);
    } catch (e) {
      _logger.e('Error adding ticket response: $e');
      rethrow;
    }
  }

  // ============================================================
  // FAQs
  // ============================================================

  /// Cache key for FAQs.
  static const String _faqCacheKey = 'cached_faqs';

  /// Cache expiry duration (24 hours).
  static const Duration _faqCacheExpiry = Duration(hours: 24);

  /// Get FAQs from database with optional category filter.
  ///
  /// Fetches active FAQs sorted by order_index.
  /// Caches the result locally for offline access.
  Future<List<FAQ>> getFAQs({FAQCategory? category}) async {
    try {
      var query = _supabase
          .from('faqs')
          .select()
          .eq('is_active', true);

      if (category != null) {
        query = query.eq('category', category.dbValue);
      }

      final response = await query.order('order_index', ascending: true);

      final faqs = (response as List)
          .map((json) => FAQ.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the FAQs for offline access
      await _cacheFAQs(faqs);

      return faqs;
    } catch (e) {
      _logger.e('Error fetching FAQs: $e');

      // Try to return cached FAQs if network fails
      final cachedFAQs = await _getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        _logger.i('Returning ${cachedFAQs.length} cached FAQs');
        if (category != null) {
          return cachedFAQs.filterByCategory(category);
        }
        return cachedFAQs;
      }

      rethrow;
    }
  }

  /// Search FAQs by query string.
  ///
  /// Searches both question and answer fields.
  Future<List<FAQ>> searchFAQs(String query) async {
    if (query.isEmpty) {
      return getFAQs();
    }

    try {
      // Fetch all active FAQs and filter locally for better search
      final allFAQs = await getFAQs();
      return allFAQs.search(query);
    } catch (e) {
      _logger.e('Error searching FAQs: $e');

      // Try to search cached FAQs
      final cachedFAQs = await _getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        return cachedFAQs.search(query);
      }

      rethrow;
    }
  }

  /// Get FAQs grouped by category.
  Future<List<GroupedFAQs>> getGroupedFAQs() async {
    try {
      final faqs = await getFAQs();
      return faqs.groupByCategory();
    } catch (e) {
      _logger.e('Error getting grouped FAQs: $e');
      rethrow;
    }
  }

  /// Cache FAQs to local storage.
  Future<void> _cacheFAQs(List<FAQ> faqs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'faqs': faqs.map((f) => f.toJson()).toList(),
        'cached_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_faqCacheKey, jsonEncode(data));
      _logger.d('Cached ${faqs.length} FAQs');
    } catch (e) {
      _logger.w('Failed to cache FAQs: $e');
    }
  }

  /// Get cached FAQs from local storage.
  Future<List<FAQ>> _getCachedFAQs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_faqCacheKey);

      if (cached == null) {
        return [];
      }

      final data = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(data['cached_at'] as String);

      // Check if cache is expired
      if (DateTime.now().difference(cachedAt) > _faqCacheExpiry) {
        _logger.d('FAQ cache expired');
        await prefs.remove(_faqCacheKey);
        return [];
      }

      final faqs = (data['faqs'] as List)
          .map((json) => FAQ.fromJson(json as Map<String, dynamic>))
          .toList();

      return faqs;
    } catch (e) {
      _logger.w('Failed to get cached FAQs: $e');
      return [];
    }
  }

  /// Clear FAQ cache.
  Future<void> clearFAQCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_faqCacheKey);
      _logger.d('FAQ cache cleared');
    } catch (e) {
      _logger.w('Failed to clear FAQ cache: $e');
    }
  }
}

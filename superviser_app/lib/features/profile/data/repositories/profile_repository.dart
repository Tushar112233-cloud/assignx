import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/profile_model.dart';
import '../models/review_model.dart';

/// Repository for profile and review operations.
class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ==================== PROFILE ====================

  /// Get current user's profile.
  Future<SupervisorProfile?> getProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final response = await _client
          .from('supervisor_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return SupervisorProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.getProfile error: $e');
      }
      rethrow;
    }
  }

  /// Update profile.
  Future<SupervisorProfile?> updateProfile(SupervisorProfile profile) async {
    try {
      final response = await _client
          .from('supervisor_profiles')
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      return SupervisorProfile.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.updateProfile error: $e');
      }
      rethrow;
    }
  }

  /// Upload avatar image.
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return null;

      final fileName = 'avatar_$userId.jpg';
      final path = 'avatars/$fileName';

      await _client.storage.from('profiles').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from('profiles').getPublicUrl(path);
      return url;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.uploadAvatar error: $e');
      }
      rethrow;
    }
  }

  /// Update availability status.
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      await _client
          .from('supervisor_profiles')
          .update({'is_available': isAvailable}).eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.updateAvailability error: $e');
      }
      rethrow;
    }
  }

  // ==================== REVIEWS ====================

  /// Get reviews for the current user.
  Future<List<ReviewModel>> getReviews({
    int limit = 20,
    int offset = 0,
    ReviewFilter? filter,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return [];

      var query = _client
          .from('reviews')
          .select()
          .eq('supervisor_id', userId);

      if (filter?.minRating != null) {
        query = query.gte('rating', filter!.minRating!);
      }
      if (filter?.maxRating != null) {
        query = query.lte('rating', filter!.maxRating!);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.getReviews error: $e');
      }
      rethrow;
    }
  }

  /// Get reviews summary.
  Future<ReviewsSummary> getReviewsSummary() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client.rpc('get_reviews_summary', params: {
        'supervisor_id': userId,
      });

      return ReviewsSummary.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.getReviewsSummary error: $e');
      }
      rethrow;
    }
  }

  /// Respond to a review.
  Future<bool> respondToReview(String reviewId, String response) async {
    try {
      await _client.from('reviews').update({
        'response': response,
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.respondToReview error: $e');
      }
      rethrow;
    }
  }

  // ==================== DOER BLACKLIST ====================

  /// Get blacklisted doers.
  Future<List<DoerInfo>> getBlacklistedDoers() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return [];

      final response = await _client
          .from('doer_blacklist')
          .select('doers(*)')
          .eq('supervisor_id', userId);

      return (response as List).map((json) {
        final doerJson = json['doers'] as Map<String, dynamic>;
        return DoerInfo.fromJson({
          ...doerJson,
          'is_blacklisted': true,
          'blacklist_reason': json['reason'],
          'blacklisted_at': json['created_at'],
        });
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.getBlacklistedDoers error: $e');
      }
      rethrow;
    }
  }

  /// Add doer to blacklist.
  Future<bool> blacklistDoer(String doerId, String reason) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      await _client.from('doer_blacklist').insert({
        'supervisor_id': userId,
        'doer_id': doerId,
        'reason': reason,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.blacklistDoer error: $e');
      }
      rethrow;
    }
  }

  /// Remove doer from blacklist.
  Future<bool> unblacklistDoer(String doerId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return false;

      await _client
          .from('doer_blacklist')
          .delete()
          .eq('supervisor_id', userId)
          .eq('doer_id', doerId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.unblacklistDoer error: $e');
      }
      rethrow;
    }
  }

}

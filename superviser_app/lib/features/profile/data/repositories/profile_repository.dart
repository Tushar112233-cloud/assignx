import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';
import '../models/review_model.dart';

/// Repository for profile and review operations.
class ProfileRepository {
  ProfileRepository();

  // ==================== PROFILE ====================

  /// Get current user's profile.
  Future<SupervisorProfile?> getProfile() async {
    try {
      final response = await ApiClient.get('/supervisors/me');
      if (response == null) return null;
      return SupervisorProfile.fromJson(response as Map<String, dynamic>);
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
      final response = await ApiClient.put(
        '/supervisor/profile',
        profile.toJson(),
      );
      if (response == null) return null;
      return SupervisorProfile.fromJson(response as Map<String, dynamic>);
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
      final response = await ApiClient.uploadFile(
        '/upload',
        imageFile,
        fieldName: 'file',
        folder: 'assignx/avatars',
      );
      if (response == null) return null;
      return (response as Map<String, dynamic>)['url'] as String?;
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
      await ApiClient.put('/supervisor/profile/availability', {
        'is_available': isAvailable,
      });
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
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (filter?.minRating != null) {
        params['minRating'] = '${filter!.minRating}';
      }
      if (filter?.maxRating != null) {
        params['maxRating'] = '${filter!.maxRating}';
      }
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await ApiClient.get('/supervisor/reviews?$query');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['reviews'] as List? ?? [];

      return list
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
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
      final response = await ApiClient.get('/supervisor/reviews/summary');

      if (response == null) {
        return const ReviewsSummary(
          averageRating: 0,
          totalReviews: 0,
          ratingDistribution: {},
        );
      }

      final data = response as Map<String, dynamic>;
      return ReviewsSummary.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.getReviewsSummary error: $e');
      }
      rethrow;
    }
  }

  /// Respond to a review.
  Future<bool> respondToReview(String reviewId, String response) async {
    // Response functionality not yet supported
    return false;
  }

  // ==================== DOER BLACKLIST ====================

  /// Get blacklisted doers.
  Future<List<DoerInfo>> getBlacklistedDoers() async {
    try {
      final response = await ApiClient.get('/supervisors/me/blacklist');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['doers'] as List? ?? [];

      return list
          .map((json) => DoerInfo.fromJson(json as Map<String, dynamic>))
          .toList();
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
      await ApiClient.post('/supervisors/me/blacklist', {
        'doerId': doerId,
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
      await ApiClient.delete('/supervisors/me/blacklist/$doerId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileRepository.unblacklistDoer error: $e');
      }
      rethrow;
    }
  }
}

library;

import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';
import '../models/community_post_model.dart';

/// Repository for community/Business Hub operations.
///
/// Queries the Express API for supervisor business hub content.
class CommunityRepository {
  CommunityRepository();

  /// Get community posts with optional filters.
  Future<List<CommunityPost>> getPosts({
    BusinessCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'offset': '$offset',
      };
      if (category != null && category != BusinessCategory.all) {
        params['category'] = category.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search'] = searchQuery;
      }
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await ApiClient.get('/community/business-hub?$query');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];

      return list
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching community posts: $e');
      rethrow;
    }
  }

  /// Get a single post by ID.
  Future<CommunityPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/business-hub/$id');
      if (response == null) return null;
      return CommunityPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching post: $e');
      rethrow;
    }
  }

  /// Create a new community post.
  Future<CommunityPost> createPost({
    required BusinessCategory category,
    required BusinessPostType type,
    required String title,
    String? description,
    List<String> images = const [],
    String? location,
  }) async {
    try {
      final response = await ApiClient.post('/community/business-hub', {
        'category': category.name,
        'postType': type.name,
        'title': title,
        'content': description,
        'imageUrls': images,
      });

      return CommunityPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post(
        '/community/business-hub/$postId/like',
      );
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post(
        '/community/business-hub/$postId/save',
      );
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error toggling save: $e');
      rethrow;
    }
  }

  /// Report a post.
  Future<void> reportPost(String postId, String reason,
      {String? details}) async {
    try {
      await ApiClient.post('/community/posts/$postId/report', {
        'reason': reason,
        if (details != null) 'details': details,
      });
    } catch (e) {
      debugPrint('Error reporting post: $e');
      rethrow;
    }
  }

  /// Get saved posts for the current user.
  Future<List<CommunityPost>> getSavedPosts() async {
    try {
      final response = await ApiClient.get('/community/business-hub/saved');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];

      return list
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching saved posts: $e');
      rethrow;
    }
  }
}

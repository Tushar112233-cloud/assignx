/// Repository for community (Pro Network) operations.
///
/// Handles all API interactions for community posts,
/// comments, likes, saves, and reports.
library;

import '../../core/api/api_client.dart';
import '../../core/services/logger_service.dart';
import '../models/community_post_model.dart';
import '../models/community_comment_model.dart';

/// Repository for community post operations.
class CommunityRepository {
  CommunityRepository();

  /// Get community posts with optional filters.
  Future<List<CommunityPost>> getPosts({
    ProfessionalCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (category != null && category != ProfessionalCategory.all) {
        queryParams['category'] = category.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiClient.get('/community/pro-network/posts?$queryString');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];

      return list
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching community posts', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get a single post by ID.
  Future<CommunityPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/pro-network/posts/$id');
      if (response == null) return null;
      return CommunityPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error('Error fetching post', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Create a new community post.
  Future<CommunityPost> createPost({
    required ProfessionalCategory category,
    required ProfessionalPostType type,
    required String title,
    String? description,
    List<String> images = const [],
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await ApiClient.post('/community/pro-network/posts', {
        'category': category.name,
        'title': title,
        'content': description,
        'images': images,
      });

      return CommunityPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error('Error creating post', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/posts/$postId/like', {});
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      LoggerService.error('Error toggling like', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/posts/$postId/save', {});
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      LoggerService.error('Error toggling save', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get saved posts.
  Future<List<CommunityPost>> getSavedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await ApiClient.get(
          '/community/pro-network/posts/saved?limit=$limit&offset=$offset');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];

      return list
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .map((post) => post.copyWith(isSaved: true))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching saved posts', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get comments for a post.
  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final response = await ApiClient.get('/community/pro-network/posts/$postId/comments');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['comments'] as List? ?? [];

      return list
          .map((row) => CommunityComment.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching comments', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Add a comment to a post.
  Future<CommunityComment> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await ApiClient.post('/community/pro-network/posts/$postId/comments', {
        'content': content,
        if (parentId != null) 'parentId': parentId,
      });

      return CommunityComment.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      LoggerService.error('Error adding comment', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Report a post.
  Future<void> reportPost(String postId, String reason,
      {String? details}) async {
    try {
      await ApiClient.post('/community/pro-network/posts/$postId/report', {
        'reason': reason,
        if (details != null) 'details': details,
      });
    } catch (e) {
      LoggerService.error('Error reporting post', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get current user's posts.
  Future<List<CommunityPost>> getUserPosts() async {
    try {
      final response = await ApiClient.get('/community/pro-network/posts/mine');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];

      return list
          .map((row) => CommunityPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching user posts', e, tag: 'CommunityRepo');
      rethrow;
    }
  }
}

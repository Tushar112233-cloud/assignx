library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/business_hub_post_model.dart';

/// Repository for Business Hub community operations.
class BusinessHubRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  BusinessHubRepository();

  Future<String?> get _currentUserId async {
    final hasTokens = await TokenStorage.hasTokens();
    if (!hasTokens) return null;
    try {
      final data = await ApiClient.get('/auth/me');
      if (data == null) return null;
      return ((data as Map<String, dynamic>)['_id'] ?? data['id']) as String?;
    } catch (_) {
      return null;
    }
  }

  /// Get business hub posts with optional filters.
  Future<List<BusinessHubPost>> getPosts({
    BusinessCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (category != null && category != BusinessCategory.all) {
        queryParams['category'] = category.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await ApiClient.get('/community/business-hub', queryParams: queryParams);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) =>
              BusinessHubPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching business hub posts: $e');
      return [];
    }
  }

  /// Get a single post by ID.
  Future<BusinessHubPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/business-hub/$id');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final postData = data['post'] as Map<String, dynamic>? ?? data;
      return BusinessHubPost.fromJson(postData);
    } catch (e) {
      _logger.e('Error fetching business hub post: $e');
      return null;
    }
  }

  /// Create a new business hub post.
  Future<BusinessHubPost> createPost({
    required BusinessCategory category,
    required BusinessPostType postType,
    required String title,
    String? description,
    List<String>? images,
    String? companyName,
    String? industry,
    List<String>? tags,
  }) async {
    try {
      final response = await ApiClient.post('/community/business-hub', {
        'category': category.name,
        'title': title,
        'content': description,
        'imageUrls': images ?? [],
        'tags': tags ?? [],
      });

      final data = response as Map<String, dynamic>;
      final postData = data['post'] as Map<String, dynamic>? ?? data;
      return BusinessHubPost.fromJson(postData);
    } catch (e) {
      _logger.e('Error creating business hub post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post('/community/business-hub/$postId/like', {});
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post('/community/business-hub/$postId/save', {});
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Get saved business hub posts.
  Future<List<BusinessHubPost>> getSavedPosts() async {
    try {
      final response = await ApiClient.get('/community/business-hub/saved');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) =>
              BusinessHubPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching saved posts: $e');
      return [];
    }
  }

}

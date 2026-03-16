library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/pro_network_post_model.dart';

/// Repository for Pro Network community operations.
class ProNetworkRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProNetworkRepository();

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

  /// Get pro network posts with optional filters.
  Future<List<ProNetworkPost>> getPosts({
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

      final response = await ApiClient.get('/community/pro-network', queryParams: queryParams);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) => ProNetworkPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching pro network posts: $e');
      return [];
    }
  }

  /// Get a single post by ID.
  Future<ProNetworkPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/pro-network/$id');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final postData = data['post'] as Map<String, dynamic>? ?? data;
      return ProNetworkPost.fromJson(postData);
    } catch (e) {
      _logger.e('Error fetching pro network post: $e');
      return null;
    }
  }

  /// Create a new pro network post.
  Future<ProNetworkPost> createPost({
    required ProfessionalCategory category,
    required ProfessionalPostType postType,
    required String title,
    String? description,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      final response = await ApiClient.post('/community/pro-network', {
        'category': category.name,
        'title': title,
        'content': description,
        'imageUrls': images ?? [],
        'tags': tags ?? [],
      });

      final data = response as Map<String, dynamic>;
      final postData = data['post'] as Map<String, dynamic>? ?? data;
      return ProNetworkPost.fromJson(postData);
    } catch (e) {
      _logger.e('Error creating pro network post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/$postId/like', {});
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/$postId/save', {});
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Get saved pro network posts.
  Future<List<ProNetworkPost>> getSavedPosts() async {
    try {
      final response = await ApiClient.get('/community/pro-network/saved');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) => ProNetworkPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching saved posts: $e');
      return [];
    }
  }

}

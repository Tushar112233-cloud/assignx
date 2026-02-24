library;

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/community_post_model.dart';

/// Repository for community/Business Hub operations.
///
/// All queries filter by `user_type = 'superviser'` to scope
/// posts to the supervisor community.
class CommunityRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  CommunityRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current user ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Map database row to CommunityPost model.
  CommunityPost _fromDbRow(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;

    return CommunityPost(
      id: row['id'] as String,
      userId: row['user_id'] as String? ?? '',
      userName: author?['full_name'] as String? ?? 'Anonymous',
      userAvatar: author?['avatar_url'] as String?,
      userCompany: author?['company_name'] as String?,
      category: _mapCategory(row['category'] as String?),
      type: _mapPostType(row['post_type'] as String?),
      title: row['title'] as String,
      description: row['description'] as String?,
      images: (row['images'] as List<dynamic>?)?.cast<String>(),
      location: row['location'] as String?,
      status: _mapStatus(row['status'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      expiresAt: row['expires_at'] != null
          ? DateTime.parse(row['expires_at'] as String)
          : null,
      viewCount: row['view_count'] as int? ?? 0,
      likeCount: row['likes_count'] as int? ?? 0,
      commentCount: row['comments_count'] as int? ?? 0,
    );
  }

  /// Map database category string to enum.
  static BusinessCategory _mapCategory(String? category) {
    if (category == null) return BusinessCategory.all;
    return BusinessCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => BusinessCategory.all,
    );
  }

  /// Map database post type string to enum.
  static BusinessPostType _mapPostType(String? type) {
    if (type == null) return BusinessPostType.insight;
    return BusinessPostType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => BusinessPostType.insight,
    );
  }

  /// Map database status string to enum.
  static CommunityPostStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return CommunityPostStatus.active;
      case 'hidden':
        return CommunityPostStatus.hidden;
      case 'removed':
        return CommunityPostStatus.removed;
      default:
        return CommunityPostStatus.active;
    }
  }

  /// Get community posts with optional filters.
  ///
  /// Only returns posts where `user_type = 'superviser'`.
  Future<List<CommunityPost>> getPosts({
    BusinessCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url, company_name)
          ''')
          .eq('user_type', 'superviser')
          .eq('status', 'active');

      // Apply category filter
      if (category != null && category != BusinessCategory.all) {
        query = query.eq('category', category.name);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching community posts: $e');
      rethrow;
    }
  }

  /// Get a single post by ID.
  Future<CommunityPost?> getPostById(String id) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url, company_name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      // Increment view count
      await _supabase
          .from('community_posts')
          .update({'view_count': (response['view_count'] as int? ?? 0) + 1})
          .eq('id', id);

      return _fromDbRow(response);
    } catch (e) {
      _logger.e('Error fetching post: $e');
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('community_posts')
          .insert({
            'user_id': userId,
            'user_type': 'superviser',
            'category': category.name,
            'post_type': type.name,
            'title': title,
            'description': description,
            'images': images,
            'location': location,
            'status': 'active',
          })
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url, company_name)
          ''')
          .single();

      return _fromDbRow(response);
    } catch (e) {
      _logger.e('Error creating post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final existing = await _supabase
          .from('community_post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('community_post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase.from('community_post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final existing = await _supabase
          .from('community_saved_posts')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('community_saved_posts')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase.from('community_saved_posts').insert({
          'post_id': postId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Report a post.
  Future<void> reportPost(String postId, String reason,
      {String? details}) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.from('community_reports').insert({
        'post_id': postId,
        'reporter_id': userId,
        'reason': reason,
        'details': details,
        'status': 'pending',
      });
    } catch (e) {
      _logger.e('Error reporting post: $e');
      rethrow;
    }
  }

  /// Get saved posts for the current user.
  Future<List<CommunityPost>> getSavedPosts() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final savedItems = await _supabase
          .from('community_saved_posts')
          .select('post_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (savedItems.isEmpty) return [];

      final postIds =
          (savedItems as List).map((s) => s['post_id']).toList();

      final posts = await _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url, company_name)
          ''')
          .inFilter('id', postIds)
          .eq('status', 'active');

      final listings = (posts as List)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
          .toList();

      // Sort by saved order
      final savedOrder = <String, int>{};
      for (var i = 0; i < savedItems.length; i++) {
        savedOrder[savedItems[i]['post_id']] = i;
      }
      listings.sort((a, b) {
        final orderA = savedOrder[a.id] ?? 999;
        final orderB = savedOrder[b.id] ?? 999;
        return orderA.compareTo(orderB);
      });

      return listings;
    } catch (e) {
      _logger.e('Error fetching saved posts: $e');
      rethrow;
    }
  }
}

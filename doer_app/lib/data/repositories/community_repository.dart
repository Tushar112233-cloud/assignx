/// Repository for community (Pro Network) operations.
///
/// Handles all Supabase interactions for community posts,
/// comments, likes, saves, and reports.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/logger_service.dart';
import '../models/community_post_model.dart';
import '../models/community_comment_model.dart';

/// Repository for community post operations.
class CommunityRepository {
  final SupabaseClient _supabase;

  CommunityRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Map database category to model enum.
  static ProfessionalCategory _mapCategory(String? categoryName) {
    if (categoryName == null) return ProfessionalCategory.all;
    return ProfessionalCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => ProfessionalCategory.all,
    );
  }

  /// Map database post type to model enum.
  static ProfessionalPostType _mapPostType(String? dbType) {
    if (dbType == null) return ProfessionalPostType.discussion;
    return ProfessionalPostType.values.firstWhere(
      (t) => t.name == dbType,
      orElse: () => ProfessionalPostType.discussion,
    );
  }

  /// Map database status to model enum.
  static PostStatus _mapStatus(String? status) {
    if (status == null) return PostStatus.active;
    return PostStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => PostStatus.active,
    );
  }

  /// Convert database row to CommunityPost.
  CommunityPost _fromDbRow(Map<String, dynamic> row) {
    final profile = row['profile'] as Map<String, dynamic>?;

    return CommunityPost(
      id: row['id'] as String,
      userId: row['user_id'] as String? ?? '',
      userName: profile?['full_name'] as String? ??
          row['user_name'] as String? ??
          'Anonymous',
      userAvatar: profile?['avatar_url'] as String? ??
          row['user_avatar'] as String?,
      userTitle: row['user_title'] as String?,
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
      likeCount: row['like_count'] as int? ?? 0,
      commentCount: row['comment_count'] as int? ?? 0,
      isLiked: row['is_liked'] as bool? ?? false,
      isSaved: row['is_saved'] as bool? ?? false,
      metadata: row['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Get community posts with optional filters.
  Future<List<CommunityPost>> getPosts({
    ProfessionalCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('community_posts')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('status', 'active')
          .eq('user_type', 'doer');

      if (category != null && category != ProfessionalCategory.all) {
        query = query.eq('category', category.name);
      }

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
      LoggerService.error('Error fetching community posts', e, tag: 'CommunityRepo');
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
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      // Increment view count
      await _supabase
          .from('community_posts')
          .update(
              {'view_count': (response['view_count'] as int? ?? 0) + 1})
          .eq('id', id);

      return _fromDbRow(response);
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('community_posts')
          .insert({
            'user_id': userId,
            'user_type': 'doer',
            'category': category.name,
            'post_type': type.name,
            'title': title,
            'description': description,
            'images': images,
            'location': location,
            'metadata': metadata,
            'status': 'active',
          })
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .single();

      return _fromDbRow(response);
    } catch (e) {
      LoggerService.error('Error creating post', e, tag: 'CommunityRepo');
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
      LoggerService.error('Error toggling like', e, tag: 'CommunityRepo');
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
      LoggerService.error('Error toggling save', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get saved posts.
  Future<List<CommunityPost>> getSavedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final savedResponse = await _supabase
          .from('community_saved_posts')
          .select('post_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final postIds = (savedResponse as List<dynamic>)
          .map((r) => r['post_id'] as String)
          .toList();

      if (postIds.isEmpty) return [];

      final postsResponse = await _supabase
          .from('community_posts')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .inFilter('id', postIds);

      return (postsResponse as List<dynamic>)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
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
      final response = await _supabase
          .from('community_comments')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('post_id', postId)
          .isFilter('parent_id', null)
          .order('created_at', ascending: true);

      final comments = (response as List<dynamic>)
          .map((row) =>
              CommunityComment.fromJson(row as Map<String, dynamic>))
          .toList();

      // Fetch replies for each comment
      for (var i = 0; i < comments.length; i++) {
        final repliesResponse = await _supabase
            .from('community_comments')
            .select('''
              *,
              profile:profiles!user_id(full_name, avatar_url)
            ''')
            .eq('post_id', postId)
            .eq('parent_id', comments[i].id)
            .order('created_at', ascending: true);

        final replies = (repliesResponse as List<dynamic>)
            .map((row) =>
                CommunityComment.fromJson(row as Map<String, dynamic>))
            .toList();

        if (replies.isNotEmpty) {
          comments[i] = CommunityComment(
            id: comments[i].id,
            postId: comments[i].postId,
            userId: comments[i].userId,
            userName: comments[i].userName,
            userAvatar: comments[i].userAvatar,
            content: comments[i].content,
            createdAt: comments[i].createdAt,
            parentId: comments[i].parentId,
            likeCount: comments[i].likeCount,
            isLiked: comments[i].isLiked,
            replies: replies,
          );
        }
      }

      return comments;
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
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('community_comments')
          .insert({
            'post_id': postId,
            'user_id': userId,
            'content': content,
            'parent_id': parentId,
          })
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .single();

      return CommunityComment.fromJson(response);
    } catch (e) {
      LoggerService.error('Error adding comment', e, tag: 'CommunityRepo');
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
      LoggerService.error('Error reporting post', e, tag: 'CommunityRepo');
      rethrow;
    }
  }

  /// Get current user's posts.
  Future<List<CommunityPost>> getUserPosts() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error fetching user posts', e, tag: 'CommunityRepo');
      rethrow;
    }
  }
}

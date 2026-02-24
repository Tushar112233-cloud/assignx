library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/community_comment_model.dart';
import '../../data/models/community_post_model.dart';
import '../../data/repositories/community_repository.dart';

/// Provider for the community repository.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

/// Provider for community posts list.
final communityPostsProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final repository = ref.read(communityRepositoryProvider);
  return repository.getPosts();
});

/// Provider for a single community post detail.
final communityPostDetailProvider =
    FutureProvider.autoDispose.family<CommunityPost?, String>(
  (ref, postId) async {
    final repository = ref.read(communityRepositoryProvider);
    return repository.getPostById(postId);
  },
);

/// Provider for saved community posts.
final savedCommunityPostsProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final repository = ref.read(communityRepositoryProvider);
  return repository.getSavedPosts();
});

/// Provider for fetching comments for a post.
final communityCommentsProvider =
    FutureProvider.autoDispose.family<List<CommunityComment>, String>(
  (ref, postId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('community_comments')
        .select('''
          *,
          author:profiles (
            id,
            full_name,
            avatar_url,
            is_verified
          )
        ''')
        .eq('post_id', postId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: false);

    // Fetch replies for each comment
    final comments = <CommunityComment>[];
    for (final data in response as List) {
      final replies = await supabase
          .from('community_comments')
          .select('''
            *,
            author:profiles (
              id,
              full_name,
              avatar_url,
              is_verified
            )
          ''')
          .eq('parent_id', data['id'])
          .order('created_at', ascending: true);

      comments.add(CommunityComment(
        id: data['id'],
        content: data['content'] ?? '',
        authorId: data['author_id'] ?? '',
        authorName: data['author']?['full_name'] ?? 'Anonymous',
        authorAvatar: data['author']?['avatar_url'],
        isAuthorVerified: data['author']?['is_verified'] ?? false,
        createdAt: DateTime.parse(data['created_at']),
        likeCount: data['likes_count'] ?? 0,
        isLiked: false,
        replies: (replies as List).map((r) {
          return CommunityComment(
            id: r['id'],
            content: r['content'] ?? '',
            authorId: r['author_id'] ?? '',
            authorName: r['author']?['full_name'] ?? 'Anonymous',
            authorAvatar: r['author']?['avatar_url'],
            isAuthorVerified: r['author']?['is_verified'] ?? false,
            createdAt: DateTime.parse(r['created_at']),
            likeCount: r['likes_count'] ?? 0,
            isLiked: false,
            parentId: data['id'],
          );
        }).toList(),
      ));
    }

    return comments;
  },
);

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
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
    final response = await ApiClient.get(
      '/community/business-hub/$postId/comments',
    );

    final commentsData = response is List
        ? response
        : (response as Map<String, dynamic>)['comments'] as List? ?? [];

    final comments = <CommunityComment>[];
    for (final data in commentsData) {
      final commentMap = data as Map<String, dynamic>;
      final repliesList = commentMap['replies'] as List? ?? [];

      comments.add(CommunityComment(
        id: commentMap['id'] as String? ?? '',
        content: commentMap['content'] as String? ?? '',
        authorId: commentMap['user_id'] as String? ?? '',
        authorName: (commentMap['author'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'Anonymous',
        authorAvatar: (commentMap['author'] as Map<String, dynamic>?)?['avatar_url'] as String?,
        isAuthorVerified: false,
        createdAt: DateTime.parse(commentMap['created_at'] as String),
        likeCount: commentMap['likes_count'] as int? ?? 0,
        isLiked: false,
        replies: repliesList.map((r) {
          final replyMap = r as Map<String, dynamic>;
          return CommunityComment(
            id: replyMap['id'] as String? ?? '',
            content: replyMap['content'] as String? ?? '',
            authorId: replyMap['user_id'] as String? ?? '',
            authorName: (replyMap['author'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'Anonymous',
            authorAvatar: (replyMap['author'] as Map<String, dynamic>?)?['avatar_url'] as String?,
            isAuthorVerified: false,
            createdAt: DateTime.parse(replyMap['created_at'] as String),
            likeCount: replyMap['likes_count'] as int? ?? 0,
            isLiked: false,
            parentId: commentMap['id'] as String?,
          );
        }).toList(),
      ));
    }

    return comments;
  },
);

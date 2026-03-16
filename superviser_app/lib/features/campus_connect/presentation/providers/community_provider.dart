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
/// Comments are embedded in the post document, so we fetch the post detail
/// and extract them from the response.
final communityCommentsProvider =
    FutureProvider.autoDispose.family<List<CommunityComment>, String>(
  (ref, postId) async {
    final response = await ApiClient.get(
      '/community/business-hub/$postId',
    );

    // Comments are embedded in the post object returned by the detail endpoint
    final postData = response is Map<String, dynamic>
        ? (response['post'] as Map<String, dynamic>? ?? response)
        : response as Map<String, dynamic>;
    final commentsData = postData['comments'] as List? ?? [];

    // Separate top-level comments from replies using parentId
    final topLevel = <Map<String, dynamic>>[];
    final repliesMap = <String, List<Map<String, dynamic>>>{};

    for (final data in commentsData) {
      final commentMap = data as Map<String, dynamic>;
      final parentId = commentMap['parentId'] as String?;
      if (parentId != null && parentId.isNotEmpty) {
        repliesMap.putIfAbsent(parentId, () => []).add(commentMap);
      } else {
        topLevel.add(commentMap);
      }
    }

    CommunityComment parseComment(Map<String, dynamic> commentMap, {String? parentId}) {
      // userId is populated by the API with {fullName, avatarUrl}
      final userObj = commentMap['userId'];
      final String authorId;
      final String authorName;
      final String? authorAvatar;
      if (userObj is Map<String, dynamic>) {
        authorId = (userObj['_id'] ?? userObj['id'] ?? '').toString();
        authorName = (userObj['fullName'] as String?) ?? 'Anonymous';
        authorAvatar = userObj['avatarUrl'] as String?;
      } else {
        authorId = (userObj ?? '').toString();
        authorName = 'Anonymous';
        authorAvatar = null;
      }

      final commentId = (commentMap['_id'] ?? commentMap['id'] ?? '').toString();
      final createdAtRaw = commentMap['createdAt'] ?? commentMap['created_at'];
      final createdAt = createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
          : DateTime.now();

      return CommunityComment(
        id: commentId,
        content: commentMap['content'] as String? ?? '',
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        isAuthorVerified: false,
        createdAt: createdAt,
        likeCount: commentMap['likes_count'] as int? ?? commentMap['likeCount'] as int? ?? 0,
        isLiked: false,
        parentId: parentId,
        replies: (repliesMap[commentId] ?? [])
            .map((r) => parseComment(r, parentId: commentId))
            .toList(),
      );
    }

    final comments = topLevel.map((c) => parseComment(c)).toList();

    return comments;
  },
);

/// Community comment model for the Pro Network feature.
///
/// Defines the CommunityComment class for post comments and replies.
library;

/// Community comment model.
class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final String? parentId;
  final int likeCount;
  final bool isLiked;
  final List<CommunityComment>? replies;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies,
  });

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  bool get hasReplies => replies != null && replies!.isNotEmpty;

  /// Create from JSON.
  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final repliesData = json['replies'] as List<dynamic>?;

    // Handle userId which may be a populated Mongoose object.
    String userId = '';
    String userName = 'Anonymous';
    String? userAvatar;
    final rawUserId = json['user_id'] ?? json['userId'];
    if (rawUserId is String) {
      userId = rawUserId;
    } else if (rawUserId is Map<String, dynamic>) {
      userId = (rawUserId['_id'] ?? rawUserId['id'] ?? '').toString();
      userName = (rawUserId['full_name'] ?? rawUserId['fullName'] ?? rawUserId['name'] ?? 'Anonymous').toString();
      userAvatar = rawUserId['avatar_url'] as String? ?? rawUserId['avatarUrl'] as String?;
    }

    // Override with nested profile or flat fields if available.
    userName = profile?['full_name'] as String? ?? profile?['fullName'] as String?
        ?? json['user_name'] as String? ?? json['userName'] as String? ?? userName;
    userAvatar = profile?['avatar_url'] as String? ?? profile?['avatarUrl'] as String?
        ?? json['user_avatar'] as String? ?? json['userAvatar'] as String? ?? userAvatar;

    // Handle postId which may be a populated Mongoose object.
    String postId = '';
    final rawPostId = json['post_id'] ?? json['postId'];
    if (rawPostId is String) {
      postId = rawPostId;
    } else if (rawPostId is Map<String, dynamic>) {
      postId = (rawPostId['_id'] ?? rawPostId['id'] ?? '').toString();
    }

    return CommunityComment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      postId: postId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: (json['content'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      parentId: json['parent_id'] as String? ?? json['parentId'] as String?,
      likeCount: (json['like_count'] ?? json['likeCount']) as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? json['isLiked'] as bool? ?? false,
      replies: repliesData
          ?.map((r) =>
              CommunityComment.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'like_count': likeCount,
      'is_liked': isLiked,
    };
  }
}

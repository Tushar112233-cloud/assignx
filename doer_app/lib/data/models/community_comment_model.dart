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

    return CommunityComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: profile?['full_name'] as String? ??
          json['user_name'] as String? ??
          'Anonymous',
      userAvatar: profile?['avatar_url'] as String? ??
          json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId: json['parent_id'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
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

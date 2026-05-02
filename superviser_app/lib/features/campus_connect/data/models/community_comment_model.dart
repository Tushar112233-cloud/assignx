library;

/// Comment data model for community posts.
class CommunityComment {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final bool isAuthorVerified;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final String? parentId;
  final List<CommunityComment> replies;

  const CommunityComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.isAuthorVerified = false,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    this.parentId,
    this.replies = const [],
  });

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Create from JSON.
  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Anonymous',
      authorAvatar: json['author_avatar'] as String?,
      isAuthorVerified: json['is_author_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) =>
                  CommunityComment.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

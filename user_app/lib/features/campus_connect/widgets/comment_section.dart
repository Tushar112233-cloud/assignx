import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Comment data model.
class CampusComment {
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
  final List<CampusComment> replies;

  const CampusComment({
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
}

/// Comment section widget with nested replies.
///
/// Features:
/// - Comment input with send button
/// - Nested replies support
/// - Like comments
/// - Reply to comments
/// - Loading and empty states
class CommentSection extends StatefulWidget {
  /// List of comments to display.
  final List<CampusComment> comments;

  /// The post ID for this comment section.
  final String postId;

  /// Callback when a new comment is added.
  final Future<void> Function(String content, String? parentId)? onAddComment;

  /// Callback when a comment is liked.
  final void Function(String commentId)? onLikeComment;

  /// Whether the current user is verified (can comment).
  final bool isVerified;

  /// Whether comments are loading.
  final bool isLoading;

  const CommentSection({
    super.key,
    required this.comments,
    required this.postId,
    this.onAddComment,
    this.onLikeComment,
    this.isVerified = true,
    this.isLoading = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  String? _replyingToId;
  String? _replyingToName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onAddComment?.call(content, _replyingToId);
      _commentController.clear();
      _cancelReply();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _startReply(String commentId, String authorName) {
    setState(() {
      _replyingToId = commentId;
      _replyingToName = authorName;
    });
    // Focus the text field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.comments.length} Comments',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Comment input
        if (widget.isVerified)
          _CommentInput(
            controller: _commentController,
            replyingToName: _replyingToName,
            isSubmitting: _isSubmitting,
            onSubmit: _handleSubmit,
            onCancelReply: _cancelReply,
          )
        else
          _VerificationRequired(),

        const SizedBox(height: 12),

        // Comments list
        if (widget.isLoading)
          const _LoadingComments()
        else if (widget.comments.isEmpty)
          const _EmptyComments()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              return _CommentItem(
                comment: comment,
                onLike: () => widget.onLikeComment?.call(comment.id),
                onReply: () => _startReply(comment.id, comment.authorName),
                isVerified: widget.isVerified,
              );
            },
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}

/// Comment input widget.
class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final String? replyingToName;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancelReply;

  const _CommentInput({
    required this.controller,
    this.replyingToName,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator
          if (replyingToName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to $replyingToName',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 1,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: isSubmitting ? null : onSubmit,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Verification required message.
class _VerificationRequired extends StatelessWidget {
  const _VerificationRequired();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Only verified college students can comment.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single comment item with replies.
class _CommentItem extends StatefulWidget {
  final CampusComment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final bool isVerified;
  final bool isReply;

  const _CommentItem({
    required this.comment,
    required this.onLike,
    required this.onReply,
    required this.isVerified,
    this.isReply = false,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _scaleAnimation;
  bool _showReplies = true;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(_likeAnimationController);
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _likeAnimationController.forward(from: 0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: widget.isReply ? 14 : 18,
              backgroundColor: AppColors.avatarWarm,
              backgroundImage: widget.comment.authorAvatar != null
                  ? NetworkImage(widget.comment.authorAvatar!)
                  : null,
              child: widget.comment.authorAvatar == null
                  ? Text(
                      widget.comment.authorName.isNotEmpty
                          ? widget.comment.authorName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: widget.isReply ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      Text(
                        widget.comment.authorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: widget.isReply ? 13 : 14,
                        ),
                      ),
                      if (widget.comment.isAuthorVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.info,
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        widget.comment.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: widget.isReply ? 11 : 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Comment content
                  Text(
                    widget.comment.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary.withAlpha(230),
                      fontSize: widget.isReply ? 13 : 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Actions
                  Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: _handleLike,
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _likeAnimationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Icon(
                                    widget.comment.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 16,
                                    color: widget.comment.isLiked
                                        ? AppColors.error
                                        : AppColors.textTertiary,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.comment.likeCount.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: widget.comment.isLiked
                                    ? AppColors.error
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Reply button (only for top-level comments)
                      if (widget.isVerified && !widget.isReply)
                        GestureDetector(
                          onTap: widget.onReply,
                          child: Row(
                            children: [
                              Icon(
                                Icons.reply_rounded,
                                size: 16,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reply',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // Replies
        if (widget.comment.replies.isNotEmpty) ...[
          const SizedBox(height: 12),

          // Toggle replies
          if (widget.comment.replies.length > 2 && !_showReplies)
            GestureDetector(
              onTap: () => setState(() => _showReplies = true),
              child: Padding(
                padding: const EdgeInsets.only(left: 46),
                child: Text(
                  'View ${widget.comment.replies.length} replies',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_showReplies)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                children: widget.comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _CommentItem(
                      comment: reply,
                      onLike: () {},
                      onReply: () {},
                      isVerified: widget.isVerified,
                      isReply: true,
                    ),
                  );
                }).toList(),
              ),
            ),

          if (_showReplies && widget.comment.replies.length > 2)
            GestureDetector(
              onTap: () => setState(() => _showReplies = false),
              child: Padding(
                padding: const EdgeInsets.only(left: 46, top: 8),
                child: Text(
                  'Hide replies',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Loading state for comments.
class _LoadingComments extends StatelessWidget {
  const _LoadingComments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerBase,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Empty state for comments.
class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.textTertiary.withAlpha(128),
          ),
          const SizedBox(height: 12),
          Text(
            'No comments yet',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to comment!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

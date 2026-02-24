/// Comment section widget for community post detail.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/community_comment_model.dart';

/// Comment section with nested replies.
class CommentSection extends StatefulWidget {
  final List<CommunityComment> comments;
  final bool isLoading;
  final bool isVerified;
  final ValueChanged<String> onSubmitComment;
  final Function(String commentId, String content)? onReply;

  const CommentSection({
    super.key,
    required this.comments,
    this.isLoading = false,
    this.isVerified = true,
    required this.onSubmitComment,
    this.onReply,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  String? _replyingTo;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_replyingTo != null && widget.onReply != null) {
      widget.onReply!(_replyingTo!, text);
    } else {
      widget.onSubmitComment(text);
    }

    _commentController.clear();
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Comments'.tr(context),
            style: AppTextStyles.headingSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Comments list
        if (widget.isLoading)
          const _LoadingComments()
        else if (widget.comments.isEmpty)
          const _EmptyComments()
        else
          ...widget.comments.map((comment) => _CommentItem(
                comment: comment,
                onReply: () {
                  setState(() => _replyingTo = comment.id);
                },
              )),

        const SizedBox(height: AppSpacing.sm),

        // Input
        if (!widget.isVerified)
          const _VerificationRequired()
        else
          _CommentInput(
            controller: _commentController,
            replyingTo: _replyingTo,
            onSubmit: _handleSubmit,
            onCancelReply: () {
              setState(() => _replyingTo = null);
            },
          ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommunityComment comment;
  final VoidCallback? onReply;

  const _CommentItem({
    required this.comment,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withAlpha(26),
                backgroundImage: comment.userAvatar != null
                    ? CachedNetworkImageProvider(comment.userAvatar!)
                    : null,
                child: comment.userAvatar == null
                    ? Text(
                        comment.userName.isNotEmpty
                            ? comment.userName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          comment.timeAgo,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.content,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Replies
          if (comment.hasReplies)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Column(
                children: comment.replies!
                    .map((reply) => _CommentItem(comment: reply))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final String? replyingTo;
  final VoidCallback onSubmit;
  final VoidCallback onCancelReply;

  const _CommentInput({
    required this.controller,
    this.replyingTo,
    required this.onSubmit,
    required this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Replying to comment',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...'.tr(context),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSubmit,
                icon: const Icon(Icons.send_rounded),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationRequired extends StatelessWidget {
  const _VerificationRequired();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingHorizontalMd,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Only verified professionals can comment.'.tr(context),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingComments extends StatelessWidget {
  const _LoadingComments();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: AppSpacing.paddingMd,
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 32, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              'No comments yet'.tr(context),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share your thoughts'.tr(context),
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

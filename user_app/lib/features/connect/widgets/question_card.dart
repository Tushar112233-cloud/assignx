import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/glass_container.dart';

/// Data model representing a Q&A question.
///
/// Holds all metadata for rendering a question card: title, body,
/// author, subject, answer count, and timestamps.
class Question {
  /// Unique identifier.
  final String id;

  /// Question title.
  final String title;

  /// Full body text of the question.
  final String body;

  /// Subject/category the question belongs to.
  final String subject;

  /// User ID of the author.
  final String authorId;

  /// Display name of the author.
  final String authorName;

  /// Author avatar URL (optional).
  final String? authorAvatar;

  /// Number of answers posted to this question.
  final int answerCount;

  /// Number of upvotes.
  final int upvotes;

  /// Created timestamp.
  final DateTime createdAt;

  /// Whether the question has been marked as answered/resolved.
  final bool isAnswered;

  const Question({
    required this.id,
    required this.title,
    required this.body,
    required this.subject,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.answerCount = 0,
    this.upvotes = 0,
    required this.createdAt,
    this.isAnswered = false,
  });

  /// Get the author's initials for avatar fallback.
  String get authorInitials {
    if (authorName.isEmpty) return '?';
    final parts = authorName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return authorName[0].toUpperCase();
  }

  /// Get a human-readable relative time string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  /// Construct from Supabase JSON response.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      subject: json['subject'] as String? ?? 'General',
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String? ?? 'Anonymous',
      authorAvatar: json['author_avatar'] as String?,
      answerCount: json['answer_count'] as int? ?? 0,
      upvotes: json['upvotes'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isAnswered: json['is_answered'] as bool? ?? false,
    );
  }

  /// Serialize to JSON for Supabase insert.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'subject': subject,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'answer_count': answerCount,
      'upvotes': upvotes,
      'created_at': createdAt.toIso8601String(),
      'is_answered': isAnswered,
    };
  }
}

/// Card widget for displaying a single Q&A question.
///
/// Shows the question title, truncated body excerpt, author info,
/// subject category chip, answer count badge, and relative date.
/// Uses [GlassCard] for consistent glassmorphic styling.
class QuestionCard extends StatelessWidget {
  /// The question data to display.
  final Question question;

  /// Callback when the card is tapped (navigate to detail).
  final VoidCallback? onTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.85,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: answered badge + subject chip
          Row(
            children: [
              // Answered/unanswered status indicator
              if (question.isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Answered'.tr(context),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Unanswered'.tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // Subject category chip
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.subject,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Relative date
              Text(
                question.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Question title
          Text(
            question.title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Body excerpt
          Text(
            question.body,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Divider
          Divider(
            color: AppColors.border.withAlpha(77),
            height: 1,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Footer: author info + answer count
          Row(
            children: [
              // Author avatar
              CircleAvatar(
                radius: 12,
                backgroundColor: question.authorName.isEmpty
                    ? AppColors.avatarGray
                    : AppColors.avatarWarm,
                backgroundImage: isValidImageUrl(question.authorAvatar)
                    ? NetworkImage(question.authorAvatar!)
                    : null,
                child: !isValidImageUrl(question.authorAvatar)
                    ? Text(
                        question.authorInitials,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),

              // Author name
              Expanded(
                child: Text(
                  question.authorName.isEmpty
                      ? 'Anonymous'.tr(context)
                      : question.authorName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Upvotes
              if (question.upvotes > 0) ...[
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 2),
                Text(
                  question.upvotes.toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Answer count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: question.answerCount > 0
                      ? AppColors.info.withAlpha(20)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 13,
                      color: question.answerCount > 0
                          ? AppColors.info
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${question.answerCount} ${'answers'.tr(context)}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: question.answerCount > 0
                            ? AppColors.info
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

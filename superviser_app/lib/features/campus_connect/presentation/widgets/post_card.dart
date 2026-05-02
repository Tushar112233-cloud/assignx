library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/community_post_model.dart';
import 'like_button.dart';

/// Base card wrapper with consistent styling.
class _BasePostCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _BasePostCard({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Insight post card - for industry insights and thought leadership.
///
/// Features light gray background area with centered icon,
/// title, subtitle, footer with avatar + category tag, and like/comment buttons.
class InsightPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const InsightPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon area
          Container(
            height: 100,
            width: double.infinity,
            color: AppColors.neutralLight,
            child: Center(
              child: Icon(
                _getIconForTitle(post.title),
                size: 32,
                color: AppColors.neutralGray,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _PostFooter(
                        userName: post.userName,
                        categoryLabel: 'Insight',
                        categoryColor: AppColors.categoryOrange,
                      ),
                    ),
                    if (post.likeCount > 0)
                      CompactLikeButton(
                        isLiked: isLiked,
                        likeCount: post.likeCount,
                        onToggle: onLike,
                      ),
                    if (post.commentCount > 0) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onComment,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.commentCount.toString(),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('market') || lowerTitle.contains('trend')) {
      return Icons.trending_up;
    }
    if (lowerTitle.contains('tech') || lowerTitle.contains('digital')) {
      return Icons.computer_outlined;
    }
    if (lowerTitle.contains('strategy') || lowerTitle.contains('growth')) {
      return Icons.show_chart;
    }
    return Icons.lightbulb_outline;
  }
}

/// Opportunity post card - for business opportunities.
///
/// Features light gray background with opportunity icon,
/// title, description, and footer.
class OpportunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const OpportunityPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: AppColors.neutralLight,
            child: const Center(
              child: Icon(
                Icons.trending_up,
                size: 32,
                color: AppColors.neutralGray,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                _PostFooter(
                  userName: post.userName,
                  categoryLabel: 'Opportunity',
                  categoryColor: AppColors.categoryGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recruitment post card - for job listings and hiring.
///
/// Features red/orange circular alert badge,
/// no icon area background, title, description, and footer.
class RecruitmentPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const RecruitmentPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        post.title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        post.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),

                // Hiring badge (top right)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hiring',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _PostFooter(
              userName: post.userName,
              categoryLabel: 'Recruitment',
              categoryColor: AppColors.categoryIndigo,
            ),
          ],
        ),
      ),
    );
  }
}

/// Service post card - for service showcase.
///
/// Features icon area with like button overlay.
class ServicePostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const ServicePostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: AppColors.neutralLight,
                child: Center(
                  child: Icon(
                    _getIconForService(post.title),
                    size: 32,
                    color: AppColors.neutralGray,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FloatingLikeButton(
                  isLiked: isLiked,
                  onToggle: onLike,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _PostFooter(
                        userName: post.userName,
                        categoryLabel: 'Service',
                        categoryColor: AppColors.categoryTeal,
                      ),
                    ),
                    if (post.likeCount > 0)
                      CompactLikeButton(
                        isLiked: isLiked,
                        likeCount: post.likeCount,
                        onToggle: onLike,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('consult')) return Icons.support_agent_outlined;
    if (lowerTitle.contains('design')) return Icons.brush_outlined;
    if (lowerTitle.contains('tech') || lowerTitle.contains('it')) {
      return Icons.computer_outlined;
    }
    return Icons.storefront_outlined;
  }
}

/// Company update post card - compact, no icon area.
class CompanyUpdatePostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;

  const CompanyUpdatePostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (post.description != null) ...[
              const SizedBox(height: 6),
              Text(
                post.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            _PostFooter(
              userName: post.userName,
              categoryLabel: 'Update',
              categoryColor: AppColors.categoryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Event post card - with icon area.
class EventPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onRsvp;

  const EventPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: AppColors.neutralLight,
            child: Center(
              child: Icon(
                _getIconForEvent(post.title),
                size: 32,
                color: AppColors.neutralGray,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                _PostFooter(
                  userName: post.userName,
                  categoryLabel: 'Event',
                  categoryColor: AppColors.categoryAmber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEvent(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('conference')) return Icons.groups_outlined;
    if (lowerTitle.contains('workshop')) return Icons.build_outlined;
    if (lowerTitle.contains('webinar')) return Icons.videocam_outlined;
    return Icons.event_outlined;
  }
}

/// Question post card - for help and advice.
class QuestionPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onAnswer;

  const QuestionPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        post.title,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        post.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),

                // Question badge (top right)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _PostFooter(
              userName: post.userName,
              categoryLabel: 'Question',
              categoryColor: AppColors.categoryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Resource post card - for shared resources.
class ResourcePostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const ResourcePostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: AppColors.neutralLight,
            child: const Center(
              child: Icon(
                Icons.menu_book_outlined,
                size: 32,
                color: AppColors.neutralGray,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _PostFooter(
                        userName: post.userName,
                        categoryLabel: 'Resource',
                        categoryColor: AppColors.categoryBlue,
                      ),
                    ),
                    if (post.likeCount > 0)
                      CompactLikeButton(
                        isLiked: isLiked,
                        likeCount: post.likeCount,
                        onToggle: onLike,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns the appropriate post card based on post type.
Widget buildPostCard({
  required CommunityPost post,
  VoidCallback? onTap,
  VoidCallback? onLike,
  VoidCallback? onComment,
}) {
  switch (post.type) {
    case BusinessPostType.insight:
      return InsightPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        onComment: onComment,
        isLiked: post.isLiked,
      );
    case BusinessPostType.opportunity:
      return OpportunityPostCard(post: post, onTap: onTap);
    case BusinessPostType.jobListing:
      return RecruitmentPostCard(post: post, onTap: onTap);
    case BusinessPostType.serviceOffer:
      return ServicePostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: post.isLiked,
      );
    case BusinessPostType.companyUpdate:
      return CompanyUpdatePostCard(post: post, onTap: onTap);
    case BusinessPostType.event:
      return EventPostCard(post: post, onTap: onTap);
    case BusinessPostType.question:
      return QuestionPostCard(post: post, onTap: onTap);
    case BusinessPostType.resource:
      return ResourcePostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: post.isLiked,
      );
  }
}

/// Post footer with avatar, username, and category tag.
class _PostFooter extends StatelessWidget {
  final String userName;
  final String categoryLabel;
  final Color categoryColor;

  const _PostFooter({
    required this.userName,
    required this.categoryLabel,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = userName.isEmpty || userName.toLowerCase() == 'unknown';

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isUnknown ? AppColors.avatarGray : AppColors.avatarWarm,
          child: isUnknown
              ? const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.neutralGray,
                )
              : Text(
                  userName[0].toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: 8),

        // Username
        Expanded(
          child: Text(
            isUnknown ? 'Unknown' : userName,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Category tag
        Text(
          categoryLabel,
          style: AppTypography.labelSmall.copyWith(
            color: categoryColor,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

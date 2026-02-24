library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../campus_connect/widgets/like_button.dart';
import '../data/models/pro_network_post_model.dart';

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

/// Discussion post card for professional discussions.
class ProDiscussionPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const ProDiscussionPostCard({
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
          Container(
            height: 100,
            width: double.infinity,
            color: AppColors.neutralLight,
            child: Center(
              child: Icon(
                Icons.chat_bubble_outline_rounded,
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
                  style: AppTextStyles.labelLarge.copyWith(
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
                    style: AppTextStyles.bodySmall.copyWith(
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
                      child: _ProPostFooter(
                        userName: post.userName,
                        categoryLabel: 'Discussion',
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
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 16, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              post.commentCount.toString(),
                              style: AppTextStyles.caption.copyWith(
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
}

/// Portfolio showcase post card.
class PortfolioPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const PortfolioPostCard({
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
                height: 120,
                width: double.infinity,
                color: AppColors.neutralLight,
                child: Center(
                  child: Icon(Icons.photo_library_outlined,
                      size: 36, color: AppColors.neutralGray),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: FloatingLikeButton(isLiked: isLiked, onToggle: onLike),
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
                  style: AppTextStyles.labelLarge.copyWith(
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                _ProPostFooter(
                  userName: post.userName,
                  categoryLabel: 'Portfolio',
                  categoryColor: AppColors.categoryIndigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skill exchange post card.
class SkillExchangePostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;

  const SkillExchangePostCard({
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.categoryTeal.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.swap_horiz,
                      size: 20, color: AppColors.categoryTeal),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (post.description != null) ...[
              const SizedBox(height: 8),
              Text(
                post.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            _ProPostFooter(
              userName: post.userName,
              categoryLabel: 'Skill Exchange',
              categoryColor: AppColors.categoryTeal,
            ),
          ],
        ),
      ),
    );
  }
}

/// Freelance gig post card.
class FreelanceGigPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const FreelanceGigPostCard({
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
            child: Center(
              child: Icon(Icons.rocket_launch_outlined,
                  size: 32, color: AppColors.neutralGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTextStyles.labelLarge.copyWith(
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
                    style: AppTextStyles.bodySmall.copyWith(
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
                      child: _ProPostFooter(
                        userName: post.userName,
                        categoryLabel: 'Freelance',
                        categoryColor: AppColors.categoryGreen,
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

/// Event post card for professional events.
class ProEventPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;

  const ProEventPostCard({
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
            child: Center(
              child: Icon(Icons.event_outlined,
                  size: 32, color: AppColors.neutralGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTextStyles.labelLarge.copyWith(
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                _ProPostFooter(
                  userName: post.userName,
                  categoryLabel: 'Event',
                  categoryColor: AppColors.categoryIndigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// News article post card.
class NewsPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const NewsPostCard({
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.categoryBlue.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.newspaper_outlined,
                      size: 20, color: AppColors.categoryBlue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (post.description != null) ...[
              const SizedBox(height: 8),
              Text(
                post.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProPostFooter(
                    userName: post.userName,
                    categoryLabel: 'News',
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
    );
  }
}

/// Question/Help post card.
class ProQuestionPostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;

  const ProQuestionPostCard({
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
                        style: AppTextStyles.labelLarge.copyWith(
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
                        style: AppTextStyles.bodySmall.copyWith(
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
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: AppTextStyles.labelMedium.copyWith(
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
            _ProPostFooter(
              userName: post.userName,
              categoryLabel: 'Question',
              categoryColor: AppColors.categoryAmber,
            ),
          ],
        ),
      ),
    );
  }
}

/// Resource post card.
class ProResourcePostCard extends StatelessWidget {
  final ProNetworkPost post;
  final VoidCallback? onTap;

  const ProResourcePostCard({
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
            child: Center(
              child: Icon(Icons.build_outlined,
                  size: 32, color: AppColors.neutralGray),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTextStyles.labelLarge.copyWith(
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                _ProPostFooter(
                  userName: post.userName,
                  categoryLabel: 'Resource',
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

/// Post footer with avatar, username, and category tag.
class _ProPostFooter extends StatelessWidget {
  final String userName;
  final String categoryLabel;
  final Color categoryColor;

  const _ProPostFooter({
    required this.userName,
    required this.categoryLabel,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = userName.isEmpty || userName.toLowerCase() == 'unknown';

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isUnknown ? AppColors.avatarGray : AppColors.avatarWarm,
          child: isUnknown
              ? Icon(Icons.person_outline,
                  size: 14, color: AppColors.neutralMuted)
              : Text(
                  userName[0].toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isUnknown ? 'Unknown' : userName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          categoryLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: categoryColor,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Builds the appropriate post card widget based on post type.
Widget buildProPostCard({
  required ProNetworkPost post,
  required VoidCallback onTap,
  VoidCallback? onLike,
  VoidCallback? onComment,
  bool isLiked = false,
}) {
  switch (post.postType) {
    case ProfessionalPostType.discussion:
      return ProDiscussionPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        onComment: onComment,
        isLiked: isLiked,
      );
    case ProfessionalPostType.portfolioItem:
      return PortfolioPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case ProfessionalPostType.skillOffer:
      return SkillExchangePostCard(post: post, onTap: onTap);
    case ProfessionalPostType.newsArticle:
      return NewsPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case ProfessionalPostType.freelanceGig:
      return FreelanceGigPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case ProfessionalPostType.event:
      return ProEventPostCard(post: post, onTap: onTap);
    case ProfessionalPostType.question:
      return ProQuestionPostCard(post: post, onTap: onTap);
    case ProfessionalPostType.resource:
      return ProResourcePostCard(post: post, onTap: onTap);
  }
}

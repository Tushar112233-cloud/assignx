library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../campus_connect/widgets/like_button.dart';
import '../data/models/business_hub_post_model.dart';

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

/// Insight post card for industry insights.
class InsightPostCard extends StatelessWidget {
  final BusinessHubPost post;
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
                  child: Icon(Icons.insights_outlined,
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
                  child: _BusinessPostFooter(
                    userName: post.userName,
                    companyName: post.companyName,
                    categoryLabel: 'Insight',
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

/// Recruitment post card.
class RecruitmentPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const RecruitmentPostCard({
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
              child: Icon(Icons.people_outline,
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
                      child: _BusinessPostFooter(
                        userName: post.userName,
                        companyName: post.companyName,
                        categoryLabel: 'Recruitment',
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

/// Business opportunity post card.
class OpportunityPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const OpportunityPostCard({
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
              child: Icon(Icons.business_center_outlined,
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
                      child: _BusinessPostFooter(
                        userName: post.userName,
                        companyName: post.companyName,
                        categoryLabel: 'Opportunity',
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
}

/// Innovation post card.
class InnovationPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;

  const InnovationPostCard({
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
                    color: AppColors.categoryAmber.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lightbulb_outline,
                      size: 20, color: AppColors.categoryAmber),
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
            _BusinessPostFooter(
              userName: post.userName,
              companyName: post.companyName,
              categoryLabel: 'Innovation',
              categoryColor: AppColors.categoryAmber,
            ),
          ],
        ),
      ),
    );
  }
}

/// Funding post card.
class FundingPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const FundingPostCard({
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
                  child: Icon(Icons.account_balance_outlined,
                      size: 36, color: AppColors.neutralGray),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child:
                    FloatingLikeButton(isLiked: isLiked, onToggle: onLike),
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
                _BusinessPostFooter(
                  userName: post.userName,
                  companyName: post.companyName,
                  categoryLabel: 'Funding',
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

/// Event post card.
class BusinessEventPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;

  const BusinessEventPostCard({
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
                _BusinessPostFooter(
                  userName: post.userName,
                  companyName: post.companyName,
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

/// Partnership post card.
class PartnershipPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;

  const PartnershipPostCard({
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
                  child: Icon(Icons.handshake_outlined,
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
            _BusinessPostFooter(
              userName: post.userName,
              companyName: post.companyName,
              categoryLabel: 'Partnership',
              categoryColor: AppColors.categoryTeal,
            ),
          ],
        ),
      ),
    );
  }
}

/// Market analysis post card.
class MarketAnalysisPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const MarketAnalysisPostCard({
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
                    color: AppColors.categoryGreen.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.trending_up,
                      size: 20, color: AppColors.categoryGreen),
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
                  child: _BusinessPostFooter(
                    userName: post.userName,
                    companyName: post.companyName,
                    categoryLabel: 'Market Trends',
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
    );
  }
}

/// Post footer with avatar, username, company, and category tag.
class _BusinessPostFooter extends StatelessWidget {
  final String userName;
  final String? companyName;
  final String categoryLabel;
  final Color categoryColor;

  const _BusinessPostFooter({
    required this.userName,
    this.companyName,
    required this.categoryLabel,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = userName.isEmpty || userName.toLowerCase() == 'unknown';
    final displayName = companyName != null
        ? '$userName - $companyName'
        : userName;

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
            isUnknown ? 'Unknown' : displayName,
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
Widget buildBusinessPostCard({
  required BusinessHubPost post,
  required VoidCallback onTap,
  VoidCallback? onLike,
  VoidCallback? onComment,
  bool isLiked = false,
}) {
  switch (post.postType) {
    case BusinessPostType.insight:
      return InsightPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        onComment: onComment,
        isLiked: isLiked,
      );
    case BusinessPostType.recruitment:
      return RecruitmentPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        onComment: onComment,
        isLiked: isLiked,
      );
    case BusinessPostType.opportunity:
      return OpportunityPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case BusinessPostType.marketAnalysis:
      return MarketAnalysisPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case BusinessPostType.leadership:
      return InsightPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
    case BusinessPostType.innovation:
      return InnovationPostCard(post: post, onTap: onTap);
    case BusinessPostType.partnership:
      return PartnershipPostCard(post: post, onTap: onTap);
    case BusinessPostType.event:
      return BusinessEventPostCard(post: post, onTap: onTap);
    case BusinessPostType.funding:
      return FundingPostCard(
        post: post,
        onTap: onTap,
        onLike: onLike,
        isLiked: isLiked,
      );
  }
}

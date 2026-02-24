/// Post card widgets for community feed.
///
/// Provides different card layouts for various post types
/// (discussion, portfolio, skill exchange, freelance gig, event, etc).
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/community_post_model.dart';
import 'like_button.dart';
import 'save_button.dart';

/// Base post card with shared layout.
class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeTap,
    this.onSaveTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and category
            _PostHeader(post: post),

            // Title and description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: AppTextStyles.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (post.description != null &&
                      post.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      post.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Image gallery
            if (post.hasImages) ...[
              const SizedBox(height: AppSpacing.sm),
              _PostImageGallery(images: post.images!),
            ],

            // Footer with actions
            _PostFooter(
              post: post,
              onLikeTap: onLikeTap,
              onSaveTap: onSaveTap,
              onShareTap: onShareTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Post header with user info and category badge.
class _PostHeader extends StatelessWidget {
  final CommunityPost post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withAlpha(26),
            backgroundImage: post.userAvatar != null
                ? CachedNetworkImageProvider(post.userAvatar!)
                : null,
            child: post.userAvatar == null
                ? Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 14,
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
                Text(
                  post.userName,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.userTitle != null) ...[
                  Text(
                    post.userTitle!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Category badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: post.category.color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.category.icon,
                  size: 12,
                  color: post.category.color,
                ),
                const SizedBox(width: 4),
                Text(
                  post.category.displayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: post.category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            post.timeAgo,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Post image gallery.
class _PostImageGallery extends StatelessWidget {
  final List<String> images;

  const _PostImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ClipRRect(
          borderRadius: AppSpacing.borderRadiusSm,
          child: CachedNetworkImage(
            imageUrl: images.first,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: AppColors.surfaceVariant,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined,
                  color: AppColors.textTertiary),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: AppSpacing.borderRadiusSm,
            child: CachedNetworkImage(
              imageUrl: images[index],
              width: 160,
              height: 160,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 160,
                color: AppColors.surfaceVariant,
              ),
              errorWidget: (context, url, error) => Container(
                width: 160,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Post footer with like, comment, save, share actions.
class _PostFooter extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onSaveTap;
  final VoidCallback? onShareTap;

  const _PostFooter({
    required this.post,
    this.onLikeTap,
    this.onSaveTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          CompactLikeButton(
            isLiked: post.isLiked,
            likeCount: post.likeCount,
            onToggle: onLikeTap,
          ),
          const SizedBox(width: AppSpacing.md),
          // Comment count
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: AppColors.textTertiary,
              ),
              if (post.commentCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  post.commentCount.toString(),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          SaveButton(
            isSaved: post.isSaved,
            size: SaveButtonSize.small,
            onToggle: onSaveTap,
          ),
          if (onShareTap != null)
            IconButton(
              onPressed: onShareTap,
              icon: const Icon(Icons.share_outlined),
              iconSize: 18,
              color: AppColors.textTertiary,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

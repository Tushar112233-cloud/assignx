/// Post detail screen for the Pro Network feature.
///
/// Displays full post content with comments section.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/community_provider.dart';
import '../widgets/comment_section.dart';
import '../widgets/like_button.dart';
import '../widgets/save_button.dart';
import '../widgets/report_dialog.dart';

/// Post detail screen.
class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(communityPostDetailProvider(postId));
    final commentsAsync = ref.watch(postCommentsProvider(postId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Post'.tr(context)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () {
              showReportBottomSheet(
                context: context,
                postId: postId,
              );
            },
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return Center(
              child: Text('Post not found'.tr(context)),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author card
                Container(
                  padding: AppSpacing.paddingMd,
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppColors.primary.withAlpha(26),
                        backgroundImage: post.userAvatar != null
                            ? CachedNetworkImageProvider(
                                post.userAvatar!)
                            : null,
                        child: post.userAvatar == null
                            ? Text(
                                post.userName.isNotEmpty
                                    ? post.userName[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style:
                                  AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                if (post.userTitle != null) ...[
                                  Text(
                                    post.userTitle!,
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  post.timeAgo,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              post.category.color.withAlpha(26),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.category.displayName,
                          style:
                              AppTextStyles.labelSmall.copyWith(
                            color: post.category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Post content
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: AppTextStyles.headingMedium,
                      ),
                      if (post.description != null &&
                          post.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          post.description!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Images
                if (post.hasImages) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ...post.images!.map((imageUrl) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: ClipRRect(
                          borderRadius: AppSpacing.borderRadiusMd,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(
                              height: 200,
                              color: AppColors.surfaceVariant,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget:
                                (context, url, error) =>
                                    Container(
                              height: 200,
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      )),
                ],

                // Actions bar
                Padding(
                  padding: AppSpacing.paddingMd,
                  child: Row(
                    children: [
                      LikeButton(
                        isLiked: post.isLiked,
                        likeCount: post.likeCount,
                        onToggle: () {
                          ref
                              .read(communityRepositoryProvider)
                              .toggleLike(post.id);
                          ref.invalidate(
                              communityPostDetailProvider);
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${post.viewCount}',
                            style: AppTextStyles.caption
                                .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SaveButton(
                        isSaved: post.isSaved,
                        showLabel: true,
                        onToggle: () {
                          ref
                              .read(communityRepositoryProvider)
                              .toggleSave(post.id);
                          ref.invalidate(
                              communityPostDetailProvider);
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text:
                                '${post.title}\n\nCheck out this post on Pro Network!',
                          ));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied to clipboard'.tr(context)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                            Icons.share_outlined),
                        iconSize: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Comments section
                commentsAsync.when(
                  data: (comments) => CommentSection(
                    comments: comments,
                    onSubmitComment: (content) async {
                      await ref
                          .read(communityRepositoryProvider)
                          .addComment(
                            postId: postId,
                            content: content,
                          );
                      ref.invalidate(postCommentsProvider);
                    },
                    onReply: (commentId, content) async {
                      await ref
                          .read(communityRepositoryProvider)
                          .addComment(
                            postId: postId,
                            content: content,
                            parentId: commentId,
                          );
                      ref.invalidate(postCommentsProvider);
                    },
                  ),
                  loading: () => CommentSection(
                    comments: const [],
                    isLoading: true,
                    onSubmitComment: (_) {},
                  ),
                  error: (_, __) => CommentSection(
                    comments: const [],
                    onSubmitComment: (_) {},
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load post'.tr(context),
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.invalidate(communityPostDetailProvider);
                },
                child: Text('Retry'.tr(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

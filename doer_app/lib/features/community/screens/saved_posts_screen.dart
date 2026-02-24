/// Saved posts screen for the Pro Network feature.
///
/// Displays all posts the user has saved/bookmarked.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/community_provider.dart';
import '../widgets/post_card.dart';

/// Saved posts screen.
class SavedPostsScreen extends ConsumerWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPostsAsync = ref.watch(savedCommunityPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Saved Posts'.tr(context)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savedCommunityPostsProvider);
        },
        child: savedPostsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No saved posts'.tr(context),
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Posts you save will appear here'.tr(context),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xxl,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  onTap: () {
                    context.push(
                      RouteNames.communityPost
                          .replaceFirst(':id', post.id),
                    );
                  },
                  onLikeTap: () {
                    ref
                        .read(communityRepositoryProvider)
                        .toggleLike(post.id);
                    ref.invalidate(savedCommunityPostsProvider);
                  },
                  onSaveTap: () {
                    ref
                        .read(communityRepositoryProvider)
                        .toggleSave(post.id);
                    ref.invalidate(savedCommunityPostsProvider);
                  },
                );
              },
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
                  'Failed to load saved posts'.tr(context),
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(savedCommunityPostsProvider);
                  },
                  child: Text('Retry'.tr(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

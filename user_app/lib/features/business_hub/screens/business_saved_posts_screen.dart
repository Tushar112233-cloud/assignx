library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';
import '../providers/business_hub_provider.dart';

/// Screen displaying user's saved Business Hub posts.
class BusinessSavedPostsScreen extends ConsumerStatefulWidget {
  const BusinessSavedPostsScreen({super.key});

  @override
  ConsumerState<BusinessSavedPostsScreen> createState() =>
      _BusinessSavedPostsScreenState();
}

class _BusinessSavedPostsScreenState
    extends ConsumerState<BusinessSavedPostsScreen> {
  final Set<String> _removingIds = {};

  Future<void> _removeSavedPost(String postId) async {
    setState(() => _removingIds.add(postId));

    try {
      await ApiClient.delete('/community/business-hub/$postId/save');

      ref.invalidate(savedBusinessHubPostsProvider);
    } catch (e) {
      setState(() => _removingIds.remove(postId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove saved post'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedPostsAsync = ref.watch(savedBusinessHubPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Back button
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => context.pop(),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Posts',
                          style: AppTextStyles.headingSmall
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        savedPostsAsync.when(
                          data: (posts) {
                            final count =
                                posts.length - _removingIds.length;
                            return Text(
                              count == 0
                                  ? 'No saved posts yet'
                                  : '$count saved ${count == 1 ? 'post' : 'posts'}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                          loading: () => Text(
                            'Loading...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          error: (_, __) => Text(
                            'Failed to load',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.invalidate(savedBusinessHubPostsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          savedPostsAsync.when(
            data: (posts) {
              final visiblePosts = posts
                  .where((p) => !_removingIds.contains(p.id))
                  .toList();

              if (visiblePosts.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.neutralLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_outline_rounded,
                              size: 40,
                              color: AppColors.neutralGray,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No Saved Posts',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Save posts by tapping the bookmark icon.\nThey'll appear here for easy access.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => context.pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.explore_outlined,
                                size: 18),
                            label: Text(
                              'Browse Posts',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = visiblePosts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SavedPostCard(
                          post: post,
                          isRemoving: _removingIds.contains(post.id),
                          onRemove: () => _removeSavedPost(post.id),
                          onTap: () => context
                              .push('/business-hub/post/${post.id}'),
                        ),
                      );
                    },
                    childCount: visiblePosts.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.neutralLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutralLight,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 12,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutralLight,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Something went wrong',
                        style: AppTextStyles.headingSmall),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(savedBusinessHubPostsProvider),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  final BusinessHubPost post;
  final bool isRemoving;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedPostCard({
    required this.post,
    required this.isRemoving,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRemoving ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isRemoving ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(post.postType),
                    size: 28,
                    color: AppColors.neutralGray,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.avatarWarm,
                            child: Text(
                              post.userName.isNotEmpty
                                  ? post.userName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.userName,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            post.postType.label,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isRemoving ? null : onRemove,
                  icon: isRemoving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : const Icon(Icons.bookmark_remove_outlined,
                          color: AppColors.error),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(BusinessPostType type) {
    switch (type) {
      case BusinessPostType.insight:
        return Icons.insights_outlined;
      case BusinessPostType.recruitment:
        return Icons.people_outline;
      case BusinessPostType.opportunity:
        return Icons.business_center_outlined;
      case BusinessPostType.marketAnalysis:
        return Icons.trending_up;
      case BusinessPostType.leadership:
        return Icons.emoji_events_outlined;
      case BusinessPostType.innovation:
        return Icons.lightbulb_outline;
      case BusinessPostType.partnership:
        return Icons.handshake_outlined;
      case BusinessPostType.event:
        return Icons.event_outlined;
      case BusinessPostType.funding:
        return Icons.account_balance_outlined;
    }
  }
}

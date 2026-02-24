/// Main community feed screen for the Pro Network feature.
///
/// Displays a filterable feed of community posts with search,
/// category filtering, and pull-to-refresh functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/community_post_model.dart';
import '../../../providers/community_provider.dart';
import '../widgets/community_hero.dart';
import '../widgets/filter_tabs_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar_widget.dart';

/// Main community feed screen.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCommunityCategory);
    final postsAsync = ref.watch(communityPostsProvider(
      selectedCategory == ProfessionalCategory.all
          ? null
          : selectedCategory,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(communityPostsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Hero section
            SliverToBoxAdapter(
              child: CommunityHero(
                onCreatePost: () {
                  context.push(RouteNames.communityCreate);
                },
                onViewSaved: () {
                  context.push(RouteNames.communitySaved);
                },
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: SearchBarWidget(
                  controller: _searchController,
                  onChanged: (query) {
                    ref.read(communitySearchQuery.notifier).update(query);
                  },
                ),
              ),
            ),

            // Filter tabs
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: FilterTabsBar(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: (category) {
                    ref
                        .read(selectedCommunityCategory.notifier)
                        .select(category);
                  },
                ),
              ),
            ),

            // Posts list
            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      category: selectedCategory,
                      onCreatePost: () {
                        context.push(RouteNames.communityCreate);
                      },
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                          ref.invalidate(communityPostsProvider);
                        },
                        onSaveTap: () {
                          ref
                              .read(communityRepositoryProvider)
                              .toggleSave(post.id);
                          ref.invalidate(communityPostsProvider);
                        },
                      );
                    },
                    childCount: posts.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _ErrorState(
                  onRetry: () {
                    ref.invalidate(communityPostsProvider);
                  },
                ),
              ),
            ),

            // Bottom padding
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ProfessionalCategory category;
  final VoidCallback? onCreatePost;

  const _EmptyState({
    required this.category,
    this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              category == ProfessionalCategory.all
                  ? 'No posts yet'.tr(context)
                  : 'No ${category.displayName} posts yet'.tr(context),
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Be the first to share something with the community'
                  .tr(context),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onCreatePost,
              icon: const Icon(Icons.add),
              label: Text('Create Post'.tr(context)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const _ErrorState({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong'.tr(context),
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: Text('Try again'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}

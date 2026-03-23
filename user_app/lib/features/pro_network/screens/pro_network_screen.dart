library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/pro_network_post_model.dart';
import '../providers/pro_network_provider.dart';
import '../widgets/pro_filter_tabs_bar.dart';
import '../widgets/pro_network_hero.dart';
import '../widgets/pro_post_card.dart';
import '../widgets/pro_search_bar.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Pro Network screen with staggered feed of professional content.
class ProNetworkScreen extends ConsumerStatefulWidget {
  const ProNetworkScreen({super.key});

  @override
  ConsumerState<ProNetworkScreen> createState() => _ProNetworkScreenState();
}

class _ProNetworkScreenState extends ConsumerState<ProNetworkScreen> {
  ProfessionalCategory? _selectedCategory;
  String _searchQuery = '';

  List<ProNetworkPost> _filterPosts(List<ProNetworkPost> posts) {
    var filtered = posts;

    if (_selectedCategory != null &&
        _selectedCategory != ProfessionalCategory.all) {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false) ||
            p.userName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(proNetworkPostsProvider);

    final canPop = Navigator.of(context).canPop();

    return SubtleGradientScaffold.standard(
      body: Stack(
        children: [
          CustomScrollView(
        slivers: [
          // Back button (only shown when navigated to directly via route)
          if (canPop)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          // Hero section
          const SliverToBoxAdapter(child: ProNetworkHero()),

          // Search bar
          SliverToBoxAdapter(
            child: ProSearchBar(
              onChanged: (query) => setState(() => _searchQuery = query),
            ),
          ),

          // Filter tabs
          SliverToBoxAdapter(
            child: ProFilterTabsBar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),

          // Posts count
          SliverToBoxAdapter(
            child: postsAsync.when(
              data: (posts) {
                final filtered = _filterPosts(posts);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${filtered.length} posts',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Posts grid
          postsAsync.when(
            data: (posts) {
              final filtered = _filterPosts(posts);

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasFilters: _selectedCategory != null ||
                        _searchQuery.isNotEmpty,
                    onClearFilters: () {
                      setState(() {
                        _selectedCategory = null;
                        _searchQuery = '';
                      });
                    },
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: filtered.length,
                  itemBuilder: (context, index) {
                    final post = filtered[index];
                    return buildProPostCard(
                      post: post,
                      onTap: () {
                        context.push('/pro-network/post/${post.id}');
                      },
                      onLike: () {},
                      onComment: () {
                        context.push('/pro-network/post/${post.id}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load posts',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(proNetworkPostsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
          // Pro Network posts are admin-managed — no create FAB for users
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.hub_outlined,
              size: 64,
              color: AppColors.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching posts' : 'No posts yet',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Be the first to share with the community!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

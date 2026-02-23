import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/save_button.dart';

/// Provider for saved listings data.
final savedListingsProvider = FutureProvider.autoDispose<List<MarketplaceListing>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  // Get saved listing IDs
  final savedItems = await supabase
      .from('saved_listings')
      .select('listing_id, created_at')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  if (savedItems.isEmpty) {
    return [];
  }

  final listingIds = (savedItems as List).map((s) => s['listing_id']).toList();

  // Fetch the full post data
  final posts = await supabase
      .from('campus_posts')
      .select('''
        *,
        author:profiles (
          id,
          full_name,
          avatar_url,
          is_college_verified
        ),
        college:colleges (
          id,
          name,
          short_name,
          city
        )
      ''')
      .inFilter('id', listingIds)
      .or('status.eq.active,status.eq.published,status.is.null');

  // Transform to MarketplaceListing model
  final listings = (posts as List).map((post) {
    return MarketplaceListing(
      id: post['id'],
      title: post['title'] ?? '',
      description: post['content'],
      type: _getListingType(post['category']),
      userName: post['author']?['full_name'] ?? 'Anonymous',
      userAvatar: post['author']?['avatar_url'],
      likeCount: post['likes_count'] ?? 0,
      commentCount: post['comments_count'] ?? 0,
      createdAt: DateTime.parse(post['created_at']),
      images: post['images'] != null ? List<String>.from(post['images']) : null,
      collegeName: post['college']?['name'],
    );
  }).toList();

  // Sort by saved order
  final savedOrder = <String, int>{};
  for (var i = 0; i < savedItems.length; i++) {
    savedOrder[savedItems[i]['listing_id']] = i;
  }
  listings.sort((a, b) {
    final orderA = savedOrder[a.id] ?? 999;
    final orderB = savedOrder[b.id] ?? 999;
    return orderA.compareTo(orderB);
  });

  return listings;
});

ListingType _getListingType(String? category) {
  switch (category) {
    case 'housing':
      return ListingType.housing;
    case 'marketplace':
    case 'products':
      return ListingType.product;
    case 'events':
      return ListingType.event;
    case 'opportunities':
      return ListingType.opportunity;
    default:
      return ListingType.communityPost;
  }
}

/// Screen displaying user's saved campus connect listings.
///
/// Features:
/// - Pull to refresh
/// - Empty state when no saved items
/// - Remove from saved functionality
class SavedListingsScreen extends ConsumerStatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  ConsumerState<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends ConsumerState<SavedListingsScreen> {
  final Set<String> _removingIds = {};

  Future<void> _removeSavedListing(String listingId) async {
    // Optimistic update
    setState(() {
      _removingIds.add(listingId);
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      await supabase
          .from('saved_listings')
          .delete()
          .eq('listing_id', listingId)
          .eq('user_id', user.id);

      // Refresh the list
      ref.invalidate(savedListingsProvider);
    } catch (e) {
      // Revert on error
      setState(() {
        _removingIds.remove(listingId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove saved listing'),
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
    final savedListingsAsync = ref.watch(savedListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          const SliverToBoxAdapter(
            child: DashboardAppBar(),
          ),

          // Header
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
                          'Saved Listings',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        savedListingsAsync.when(
                          data: (listings) {
                            final count = listings.length - _removingIds.length;
                            return Text(
                              count == 0
                                  ? 'No saved listings yet'
                                  : '$count saved ${count == 1 ? "listing" : "listings"}',
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
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.invalidate(savedListingsProvider);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Content
          savedListingsAsync.when(
            data: (listings) {
              // Filter out removing items
              final visibleListings = listings
                  .where((l) => !_removingIds.contains(l.id))
                  .toList();

              if (visibleListings.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onBrowse: () => context.go('/campus-connect'),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = visibleListings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SavedListingCard(
                          listing: listing,
                          isRemoving: _removingIds.contains(listing.id),
                          onRemove: () => _removeSavedListing(listing.id),
                          onTap: () => context.push('/marketplace/${listing.id}'),
                        ),
                      );
                    },
                    childCount: visibleListings.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _LoadingCard(),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: _ErrorState(
                error: error.toString(),
                onRetry: () => ref.invalidate(savedListingsProvider),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Card for displaying a saved listing with remove option.
class _SavedListingCard extends StatelessWidget {
  final MarketplaceListing listing;
  final bool isRemoving;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedListingCard({
    required this.listing,
    required this.isRemoving,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRemoving ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: isRemoving ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
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
              onTap: isRemoving ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.neutralLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: listing.images != null && listing.images!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                listing.images!.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  _getIconForType(listing.type),
                                  size: 28,
                                  color: AppColors.neutralGray,
                                ),
                              ),
                            )
                          : Icon(
                              _getIconForType(listing.type),
                              size: 28,
                              color: AppColors.neutralGray,
                            ),
                    ),

                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (listing.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              listing.description!,
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
                                  listing.userName[0].toUpperCase(),
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
                                  listing.userName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _CategoryTag(type: listing.type),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Remove button
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
                          : const Icon(
                              Icons.bookmark_remove_outlined,
                              color: AppColors.error,
                            ),
                      tooltip: 'Remove from saved',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(ListingType type) {
    switch (type) {
      case ListingType.communityPost:
        return Icons.chat_bubble_outline_rounded;
      case ListingType.poll:
        return Icons.poll_outlined;
      case ListingType.event:
        return Icons.event_outlined;
      case ListingType.opportunity:
        return Icons.work_outline_rounded;
      case ListingType.product:
        return Icons.shopping_bag_outlined;
      case ListingType.housing:
        return Icons.home_outlined;
    }
  }
}

/// Category tag widget.
class _CategoryTag extends StatelessWidget {
  final ListingType type;

  const _CategoryTag({required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (type) {
      case ListingType.communityPost:
        label = 'Community';
        color = AppColors.categoryOrange;
        break;
      case ListingType.poll:
        label = 'Poll';
        color = AppColors.categoryIndigo;
        break;
      case ListingType.event:
        label = 'Event';
        color = AppColors.categoryIndigo;
        break;
      case ListingType.opportunity:
        label = 'Opportunity';
        color = AppColors.categoryTeal;
        break;
      case ListingType.product:
        label = 'Product';
        color = AppColors.categoryGreen;
        break;
      case ListingType.housing:
        label = 'Housing';
        color = AppColors.categoryAmber;
        break;
    }

    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              'No Saved Listings',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save listings by tapping the bookmark icon.\nThey\'ll appear here for easy access.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onBrowse,
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
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: Text(
                'Browse Listings',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
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
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading card skeleton.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail skeleton
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutralLight,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(width: 14),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.neutralLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.neutralLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 10,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.neutralLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
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

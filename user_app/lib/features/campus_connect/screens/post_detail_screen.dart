import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../providers/marketplace_provider.dart';
import '../widgets/comment_section.dart';
import '../widgets/like_button.dart';
import '../widgets/save_button.dart';
import '../widgets/report_button.dart';

/// Provider for fetching comments for a post.
final postCommentsProvider =
    FutureProvider.autoDispose.family<List<CampusComment>, String>(
  (ref, postId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('campus_comments')
        .select('''
          *,
          author:profiles (
            id,
            full_name,
            avatar_url,
            is_college_verified
          )
        ''')
        .eq('post_id', postId)
        .isFilter('parent_id', null)
        .order('created_at', ascending: false);

    // Fetch replies for each comment
    final comments = <CampusComment>[];
    for (final data in response as List) {
      final replies = await supabase
          .from('campus_comments')
          .select('''
            *,
            author:profiles (
              id,
              full_name,
              avatar_url,
              is_college_verified
            )
          ''')
          .eq('parent_id', data['id'])
          .order('created_at', ascending: true);

      comments.add(CampusComment(
        id: data['id'],
        content: data['content'] ?? '',
        authorId: data['author_id'] ?? '',
        authorName: data['author']?['full_name'] ?? 'Anonymous',
        authorAvatar: data['author']?['avatar_url'],
        isAuthorVerified: data['author']?['is_college_verified'] ?? false,
        createdAt: DateTime.parse(data['created_at']),
        likeCount: data['likes_count'] ?? 0,
        isLiked: false, // TODO: Check if user liked
        replies: (replies as List).map((r) {
          return CampusComment(
            id: r['id'],
            content: r['content'] ?? '',
            authorId: r['author_id'] ?? '',
            authorName: r['author']?['full_name'] ?? 'Anonymous',
            authorAvatar: r['author']?['avatar_url'],
            isAuthorVerified: r['author']?['is_college_verified'] ?? false,
            createdAt: DateTime.parse(r['created_at']),
            likeCount: r['likes_count'] ?? 0,
            isLiked: false,
            parentId: data['id'],
          );
        }).toList(),
      ));
    }

    return comments;
  },
);

/// Detailed view for a Campus Connect post.
///
/// Features:
/// - Full post content with images
/// - Author info with verification badge
/// - Like, save, share, report actions
/// - Comments section with nested replies
/// - Contact/RSVP button for events/housing
class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserInteractions();
  }

  Future<void> _checkUserInteractions() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Check if liked
      final likeResponse = await supabase
          .from('campus_post_likes')
          .select('id')
          .eq('post_id', widget.postId)
          .eq('user_id', user.id)
          .maybeSingle();

      // Check if saved
      final savedResponse = await supabase
          .from('saved_listings')
          .select('id')
          .eq('listing_id', widget.postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isLiked = likeResponse != null;
          _isSaved = savedResponse != null;
        });
      }
    } catch (e) {
      debugPrint('Error checking interactions: $e');
    }
  }

  Future<void> _toggleLike(MarketplaceListing listing) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts')),
      );
      return;
    }

    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await supabase.from('campus_post_likes').insert({
          'post_id': widget.postId,
          'user_id': user.id,
        });
      } else {
        await supabase
            .from('campus_post_likes')
            .delete()
            .eq('post_id', widget.postId)
            .eq('user_id', user.id);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save posts')),
      );
      return;
    }

    final wasSaved = _isSaved;
    setState(() {
      _isSaved = !_isSaved;
    });

    try {
      if (_isSaved) {
        await supabase.from('saved_listings').insert({
          'listing_id': widget.postId,
          'user_id': user.id,
        });
      } else {
        await supabase
            .from('saved_listings')
            .delete()
            .eq('listing_id', widget.postId)
            .eq('user_id', user.id);
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isSaved = wasSaved;
        });
      }
    }
  }

  Future<void> _addComment(String content, String? parentId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('campus_comments').insert({
      'post_id': widget.postId,
      'author_id': user.id,
      'content': content,
      'parent_id': parentId,
    });

    // Refresh comments
    ref.invalidate(postCommentsProvider(widget.postId));
  }

  void _likeComment(String commentId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Toggle comment like
      final existing = await supabase
          .from('campus_comment_likes')
          .select('id')
          .eq('comment_id', commentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('campus_comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', user.id);
      } else {
        await supabase.from('campus_comment_likes').insert({
          'comment_id': commentId,
          'user_id': user.id,
        });
      }

      // Refresh comments
      ref.invalidate(postCommentsProvider(widget.postId));
    } catch (e) {
      debugPrint('Error toggling comment like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.postId));
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return _buildNotFound(context);
          }

          // Initialize like count if not set
          if (_likeCount == 0) {
            _likeCount = listing.likeCount;
          }

          return CustomScrollView(
            slivers: [
              // App bar with image
              _buildAppBar(context, listing),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post content
                    _PostContent(
                      listing: listing,
                      isLiked: _isLiked,
                      isSaved: _isSaved,
                      likeCount: _likeCount,
                      onLike: () => _toggleLike(listing),
                      onSave: _toggleSave,
                    ),

                    const Divider(height: 32),

                    // Comments section
                    commentsAsync.when(
                      data: (comments) => CommentSection(
                        comments: comments,
                        postId: widget.postId,
                        onAddComment: _addComment,
                        onLikeComment: _likeComment,
                        isVerified: true,
                        isLoading: false,
                      ),
                      loading: () => CommentSection(
                        comments: const [],
                        postId: widget.postId,
                        isLoading: true,
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Failed to load comments',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),

                    // Bottom padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, e.toString()),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MarketplaceListing listing) {
    final hasImages = listing.hasImages;

    return SliverAppBar(
      expandedHeight: hasImages ? 280 : 56,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasImages
                ? Colors.black.withAlpha(100)
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: hasImages ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Share.share(
              'Check out this post on AssignX: ${listing.title}',
              subject: listing.title,
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasImages
                  ? Colors.black.withAlpha(100)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_outlined,
              color: hasImages ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showMoreOptions(context, listing),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasImages
                  ? Colors.black.withAlpha(100)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_vert,
              color: hasImages ? Colors.white : AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: hasImages
          ? FlexibleSpaceBar(
              background: _ImageGallery(images: listing.images),
            )
          : null,
    );
  }

  void _showMoreOptions(BuildContext context, MarketplaceListing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved ? AppColors.primary : null,
              ),
              title: Text(_isSaved ? 'Remove from saved' : 'Save post'),
              onTap: () {
                Navigator.pop(context);
                _toggleSave();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(context);
                // Show report dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.error),
              title: Text(
                'Block user',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Post not found',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This post may have been removed',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.invalidate(listingDetailProvider(widget.postId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Post content section.
class _PostContent extends StatelessWidget {
  final MarketplaceListing listing;
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const _PostContent({
    required this.listing,
    required this.isLiked,
    required this.isSaved,
    required this.likeCount,
    required this.onLike,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge and time
          Row(
            children: [
              _CategoryBadge(type: listing.type),
              const Spacer(),
              Text(
                listing.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            listing.title,
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Author info
          _AuthorCard(listing: listing),

          const SizedBox(height: 16),

          // Description
          if (listing.description != null) ...[
            Text(
              listing.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Price (if applicable)
          if (listing.price != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    listing.priceString,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (listing.isNegotiable) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Negotiable',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Location
          if (listing.location != null) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  listing.location!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Actions row
          const SizedBox(height: 8),
          Row(
            children: [
              // Like button
              LikeButton(
                isLiked: isLiked,
                likeCount: likeCount,
                onToggle: onLike,
              ),

              const SizedBox(width: 8),

              // Save button
              SaveButton(
                isSaved: isSaved,
                onToggle: onSave,
                showLabel: true,
              ),

              const Spacer(),

              // Report button
              ReportButton(
                listingId: listing.id,
                size: ReportButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Category badge widget.
class _CategoryBadge extends StatelessWidget {
  final ListingType type;

  const _CategoryBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getConfig() {
    switch (type) {
      case ListingType.communityPost:
        return ('Discussion', AppColors.categoryOrange, Icons.chat_bubble_outline);
      case ListingType.poll:
        return ('Poll', AppColors.categoryIndigo, Icons.poll_outlined);
      case ListingType.event:
        return ('Event', AppColors.categoryIndigo, Icons.event_outlined);
      case ListingType.opportunity:
        return ('Opportunity', AppColors.categoryTeal, Icons.work_outline);
      case ListingType.product:
        return ('Product', AppColors.categoryGreen, Icons.shopping_bag_outlined);
      case ListingType.housing:
        return ('Housing', AppColors.categoryAmber, Icons.home_outlined);
    }
  }
}

/// Author info card.
class _AuthorCard extends StatelessWidget {
  final MarketplaceListing listing;

  const _AuthorCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.avatarWarm,
            backgroundImage: listing.userAvatar != null
                ? NetworkImage(listing.userAvatar!)
                : null,
            child: listing.userAvatar == null
                ? Text(
                    listing.userName.isNotEmpty
                        ? listing.userName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      listing.userName,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Verification badge would show here if user is verified
                  ],
                ),
                if (listing.userUniversity != null)
                  Text(
                    listing.userUniversity!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // Open chat or contact
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening chat...')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}

/// Image gallery widget.
class _ImageGallery extends StatefulWidget {
  final List<String>? images;

  const _ImageGallery({this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images == null || widget.images!.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images!.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.images![index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              ),
            );
          },
        ),

        // Page indicator
        if (widget.images!.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images!.length,
                (index) => Container(
                  width: _currentIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

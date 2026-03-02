library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/community_post_model.dart';
import '../providers/community_provider.dart';
import '../widgets/comment_section.dart';
import '../widgets/like_button.dart';
import '../widgets/save_button.dart';
import '../widgets/report_button.dart';

/// Detailed view for a Business Hub post.
///
/// Features:
/// - Full post content with images
/// - Author info with verification badge
/// - Like, save, share, report actions
/// - Comments section with nested replies
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
    try {
      final response = await ApiClient.get(
        '/community/business-hub/${widget.postId}/interactions',
      );

      if (mounted && response is Map<String, dynamic>) {
        setState(() {
          _isLiked = response['is_liked'] as bool? ?? false;
          _isSaved = response['is_saved'] as bool? ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error checking interactions: $e');
    }
  }

  Future<void> _toggleLike() async {
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await ApiClient.post(
        '/community/business-hub/${widget.postId}/like',
        {'liked': _isLiked},
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    }
  }

  Future<void> _toggleSave() async {
    final wasSaved = _isSaved;
    setState(() {
      _isSaved = !_isSaved;
    });

    try {
      await ApiClient.post(
        '/community/business-hub/${widget.postId}/save',
        {'saved': _isSaved},
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaved = wasSaved;
        });
      }
    }
  }

  Future<void> _addComment(String content, String? parentId) async {
    try {
      await ApiClient.post(
        '/community/business-hub/${widget.postId}/comments',
        {
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );

      ref.invalidate(communityCommentsProvider(widget.postId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    }
  }

  void _likeComment(String commentId) async {
    // Note: No separate comment likes table exists in the database.
    // Comment like counts are stored directly on business_hub_post_comments.
    debugPrint('Comment like toggling not yet supported (no comment likes table)');
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(communityPostDetailProvider(widget.postId));
    final commentsAsync =
        ref.watch(communityCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return _buildNotFound(context);
          }

          if (_likeCount == 0) {
            _likeCount = post.likeCount;
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, post),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PostContent(
                      post: post,
                      isLiked: _isLiked,
                      isSaved: _isSaved,
                      likeCount: _likeCount,
                      onLike: _toggleLike,
                      onSave: _toggleSave,
                    ),
                    const Divider(height: 32),
                    commentsAsync.when(
                      data: (comments) {
                        final campusComments = comments
                            .map((c) => CampusComment(
                                  id: c.id,
                                  content: c.content,
                                  authorId: c.authorId,
                                  authorName: c.authorName,
                                  authorAvatar: c.authorAvatar,
                                  isAuthorVerified: c.isAuthorVerified,
                                  createdAt: c.createdAt,
                                  likeCount: c.likeCount,
                                  isLiked: c.isLiked,
                                  parentId: c.parentId,
                                  replies: c.replies
                                      .map((r) => CampusComment(
                                            id: r.id,
                                            content: r.content,
                                            authorId: r.authorId,
                                            authorName: r.authorName,
                                            authorAvatar: r.authorAvatar,
                                            isAuthorVerified:
                                                r.isAuthorVerified,
                                            createdAt: r.createdAt,
                                            likeCount: r.likeCount,
                                            isLiked: r.isLiked,
                                            parentId: r.parentId,
                                          ))
                                      .toList(),
                                ))
                            .toList();

                        return CommentSection(
                          comments: campusComments,
                          postId: widget.postId,
                          onAddComment: _addComment,
                          onLikeComment: _likeComment,
                          isVerified: true,
                          isLoading: false,
                        );
                      },
                      loading: () => CommentSection(
                        comments: const [],
                        postId: widget.postId,
                        isLoading: true,
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Failed to load comments',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildAppBar(BuildContext context, CommunityPost post) {
    final hasImages = post.hasImages;

    return SliverAppBar(
      expandedHeight: hasImages ? 280 : 56,
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasImages
                ? Colors.black.withAlpha(100)
                : AppColors.surfaceVariantLight,
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
              'Check out this post on Business Hub: ${post.title}',
              subject: post.title,
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasImages
                  ? Colors.black.withAlpha(100)
                  : AppColors.surfaceVariantLight,
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
          onPressed: () => _showMoreOptions(context, post),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasImages
                  ? Colors.black.withAlpha(100)
                  : AppColors.surfaceVariantLight,
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
              background: _ImageGallery(images: post.images),
            )
          : null,
    );
  }

  void _showMoreOptions(BuildContext context, CommunityPost post) {
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
              title:
                  Text(_isSaved ? 'Remove from saved' : 'Save post'),
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
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.block, color: AppColors.error),
              title: Text(
                'Block user',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.error),
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
              const Icon(Icons.search_off,
                  size: 80, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text('Post not found',
                  style: AppTypography.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'This post may have been removed',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
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
              const Icon(Icons.error_outline,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.invalidate(
                      communityPostDetailProvider(widget.postId));
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
  final CommunityPost post;
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const _PostContent({
    required this.post,
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
              _CategoryBadge(type: post.type),
              const Spacer(),
              Text(
                post.timeAgo,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            post.title,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Author info
          _AuthorCard(post: post),

          const SizedBox(height: 16),

          // Description
          if (post.description != null) ...[
            Text(
              post.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Location
          if (post.location != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  post.location!,
                  style: AppTypography.bodyMedium.copyWith(
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
              LikeButton(
                isLiked: isLiked,
                likeCount: likeCount,
                onToggle: onLike,
              ),
              const SizedBox(width: 8),
              SaveButton(
                isSaved: isSaved,
                onToggle: onSave,
                showLabel: true,
              ),
              const Spacer(),
              ReportButton(
                postId: post.id,
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
  final BusinessPostType type;

  const _CategoryBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getConfig() {
    switch (type) {
      case BusinessPostType.insight:
        return ('Insight', AppColors.categoryOrange);
      case BusinessPostType.opportunity:
        return ('Opportunity', AppColors.categoryGreen);
      case BusinessPostType.jobListing:
        return ('Recruitment', AppColors.categoryIndigo);
      case BusinessPostType.serviceOffer:
        return ('Service', AppColors.categoryTeal);
      case BusinessPostType.companyUpdate:
        return ('Update', AppColors.categoryBlue);
      case BusinessPostType.event:
        return ('Event', AppColors.categoryAmber);
      case BusinessPostType.question:
        return ('Question', AppColors.categoryBlue);
      case BusinessPostType.resource:
        return ('Resource', AppColors.categoryBlue);
    }
  }
}

/// Author info card.
class _AuthorCard extends StatelessWidget {
  final CommunityPost post;

  const _AuthorCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.avatarWarm,
            backgroundImage: post.userAvatar != null
                ? NetworkImage(post.userAvatar!)
                : null,
            child: post.userAvatar == null
                ? Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : '?',
                    style: AppTypography.labelLarge.copyWith(
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
                Text(
                  post.userName,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (post.userCompany != null)
                  Text(
                    post.userCompany!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening chat...')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
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
        color: AppColors.surfaceVariantLight,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 48, color: AppColors.textTertiary),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images!.length,
          onPageChanged: (index) =>
              setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.images![index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariantLight,
                child: const Icon(Icons.broken_image_outlined,
                    size: 48, color: AppColors.textTertiary),
              ),
            );
          },
        ),
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

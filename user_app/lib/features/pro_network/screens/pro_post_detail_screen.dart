library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../campus_connect/widgets/comment_section.dart';
import '../../campus_connect/widgets/like_button.dart';
import '../../campus_connect/widgets/save_button.dart';
import '../../campus_connect/widgets/report_button.dart';
import '../data/models/pro_network_post_model.dart';
import '../providers/pro_network_provider.dart';

/// Provider for fetching comments for a pro network post.
final proPostCommentsProvider =
    FutureProvider.autoDispose.family<List<CampusComment>, String>(
  (ref, postId) async {
    final response = await ApiClient.get('/community/pro-network/$postId/comments');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['comments'] as List? ?? [];

    final comments = <CampusComment>[];
    for (final data in list) {
      final d = data as Map<String, dynamic>;
      final repliesList = d['replies'] as List? ?? [];

      comments.add(CampusComment(
        id: (d['_id'] ?? d['id'] ?? '') as String,
        content: (d['content'] ?? '') as String,
        authorId: (d['user_id'] ?? '') as String,
        authorName: (d['author']?['full_name'] ?? 'Anonymous') as String,
        authorAvatar: d['author']?['avatar_url'] as String?,
        isAuthorVerified: (d['author']?['is_college_verified'] ?? false) as bool,
        createdAt: DateTime.parse((d['created_at'] ?? d['createdAt'] ?? DateTime.now().toIso8601String()) as String),
        likeCount: (d['likes_count'] ?? d['likeCount'] ?? 0) as int,
        isLiked: (d['is_liked'] ?? false) as bool,
        replies: repliesList.map((r) {
          final reply = r as Map<String, dynamic>;
          return CampusComment(
            id: (reply['_id'] ?? reply['id'] ?? '') as String,
            content: (reply['content'] ?? '') as String,
            authorId: (reply['user_id'] ?? '') as String,
            authorName: (reply['author']?['full_name'] ?? 'Anonymous') as String,
            authorAvatar: reply['author']?['avatar_url'] as String?,
            isAuthorVerified: (reply['author']?['is_college_verified'] ?? false) as bool,
            createdAt: DateTime.parse((reply['created_at'] ?? reply['createdAt'] ?? DateTime.now().toIso8601String()) as String),
            likeCount: (reply['likes_count'] ?? reply['likeCount'] ?? 0) as int,
            isLiked: (reply['is_liked'] ?? false) as bool,
            parentId: (d['_id'] ?? d['id'] ?? '') as String,
          );
        }).toList(),
      ));
    }

    return comments;
  },
);

/// Detailed view for a Pro Network post.
class ProPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const ProPostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ProPostDetailScreen> createState() =>
      _ProPostDetailScreenState();
}

class _ProPostDetailScreenState extends ConsumerState<ProPostDetailScreen> {
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
      final response = await ApiClient.get('/community/pro-network/${widget.postId}/interactions');
      if (response == null) return;
      final data = response as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _isLiked = data['liked'] as bool? ?? false;
          _isSaved = data['saved'] as bool? ?? false;
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
      await ApiClient.post('/community/pro-network/${widget.postId}/like', {});
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
      await ApiClient.post('/community/pro-network/${widget.postId}/save', {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaved = wasSaved;
        });
      }
    }
  }

  Future<void> _addComment(String content, String? parentId) async {
    await ApiClient.post('/community/pro-network/${widget.postId}/comments', {
      'content': content,
      'parent_id': parentId,
    });

    ref.invalidate(proPostCommentsProvider(widget.postId));
  }

  void _likeComment(String commentId) async {
    // Comment liking not yet supported - no campus_comment_likes table exists
    debugPrint('Comment liking not yet supported for pro network posts');
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(proNetworkPostDetailProvider(widget.postId));
    final commentsAsync = ref.watch(proPostCommentsProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.background,
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

  Widget _buildAppBar(BuildContext context, ProNetworkPost post) {
    final hasImages = post.hasImages;

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
              'Check out this post on AssignX: ${post.title}',
              subject: post.title,
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
          onPressed: () => _showMoreOptions(context, post),
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
              background: _ImageGallery(images: post.images),
            )
          : null,
    );
  }

  void _showMoreOptions(BuildContext context, ProNetworkPost post) {
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
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.error),
              title: Text(
                'Block user',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
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
                  ref.invalidate(
                      proNetworkPostDetailProvider(widget.postId));
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
  final ProNetworkPost post;
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
              _CategoryBadge(postType: post.postType),
              const Spacer(),
              Text(
                post.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            post.title,
            style: AppTextStyles.headingMedium.copyWith(
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
              style: AppTextStyles.bodyMedium.copyWith(
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
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  post.location!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Tags
          if (post.tags != null && post.tags!.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags!.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
                listingId: post.id,
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
  final ProfessionalPostType postType;

  const _CategoryBadge({required this.postType});

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
    switch (postType) {
      case ProfessionalPostType.discussion:
        return (
          'Discussion',
          AppColors.categoryOrange,
          Icons.chat_bubble_outline
        );
      case ProfessionalPostType.portfolioItem:
        return (
          'Portfolio',
          AppColors.categoryIndigo,
          Icons.photo_library_outlined
        );
      case ProfessionalPostType.skillOffer:
        return ('Skill Exchange', AppColors.categoryTeal, Icons.swap_horiz);
      case ProfessionalPostType.newsArticle:
        return ('News', AppColors.categoryBlue, Icons.newspaper_outlined);
      case ProfessionalPostType.freelanceGig:
        return (
          'Freelance',
          AppColors.categoryGreen,
          Icons.rocket_launch_outlined
        );
      case ProfessionalPostType.event:
        return ('Event', AppColors.categoryIndigo, Icons.event_outlined);
      case ProfessionalPostType.question:
        return ('Question', AppColors.categoryAmber, Icons.help_outline);
      case ProfessionalPostType.resource:
        return ('Resource', AppColors.categoryGreen, Icons.build_outlined);
    }
  }
}

/// Author info card.
class _AuthorCard extends StatelessWidget {
  final ProNetworkPost post;

  const _AuthorCard({required this.post});

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
            backgroundImage: isValidImageUrl(post.userAvatar)
                ? NetworkImage(post.userAvatar!)
                : null,
            child: !isValidImageUrl(post.userAvatar)
                ? Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
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
                Text(
                  post.userName,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (post.userTitle != null)
                  Text(
                    post.userTitle!,
                    style: AppTextStyles.caption.copyWith(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../providers/marketplace_provider.dart';

/// Detail screen for marketplace listings.
class ItemDetailScreen extends ConsumerWidget {
  final String listingId;

  const ItemDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return _buildNotFound(context);
          }
          return _ListingDetailContent(listing: listing);
        },
        loading: () => const _LoadingState(),
        error: (error, stack) => _ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(listingDetailProvider(listingId)),
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
                'Listing not found',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This listing may have been removed',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main content for listing detail using NestedScrollView.
class _ListingDetailContent extends StatelessWidget {
  final MarketplaceListing listing;

  const _ListingDetailContent({required this.listing});

  @override
  Widget build(BuildContext context) {
    final hasImages = listing.hasImages;
    final screenWidth = MediaQuery.of(context).size.width;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: hasImages ? 300 : 100,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: _buildBackButton(context),
            actions: [
              _buildShareButton(context),
              _buildMoreButton(context),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImages
                  ? _ImageGallery(listing: listing)
                  : _PlaceholderImage(type: listing.type),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: screenWidth - 32, // Account for padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge and time
              Row(
                children: [
                  _TypeBadge(listing: listing),
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
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),

              // Price (if applicable)
              if (listing.price != null) ...[
                Row(
                  children: [
                    Text(
                      listing.priceString,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: AppColors.primary,
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
                const SizedBox(height: 16),
              ],

              // Seller info
              _SellerInfoCard(listing: listing),
              const SizedBox(height: 20),

              // Description
              if (listing.description != null) ...[
                Text(
                  'Description',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Location
              if (listing.location != null)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: listing.location!,
                ),

              // Distance
              if (listing.distanceKm != null)
                _InfoRow(
                  icon: Icons.near_me_outlined,
                  label: 'Distance',
                  value: listing.distanceString ?? '',
                ),

              // Event date
              if (listing.metadata?['eventDate'] != null)
                _InfoRow(
                  icon: Icons.event_outlined,
                  label: 'Event Date',
                  value: _formatDate(listing.metadata!['eventDate']),
                ),

              // Salary
              if (listing.metadata?['salary'] != null)
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Compensation',
                  value: listing.metadata!['salary'],
                ),

              // Stats
              const SizedBox(height: 16),
              _StatsRow(listing: listing),

              // Poll options (if poll)
              if (listing.type == ListingType.poll &&
                  listing.metadata?['pollOptions'] != null) ...[
                const SizedBox(height: 24),
                _PollSection(listing: listing),
              ],

              // Expiry warning
              if (listing.expiresAt != null) ...[
                const SizedBox(height: 20),
                _ExpiryWarning(expiresAt: listing.expiresAt!),
              ],

              // Bottom padding
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => context.pop(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.39),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Share.share(
          'Check out this on AssignX: ${listing.title}',
          subject: listing.title,
        );
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.39),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.share_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showMoreOptions(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.39),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Save listing'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report listing'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
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

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Spam or misleading',
            'Inappropriate content',
            'Scam or fraud',
            'Other',
          ]
              .map(
                (reason) => ListTile(
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted. Thank you!'),
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return DateFormat('EEEE, MMM d, yyyy • h:mm a').format(date);
  }
}

/// Image gallery widget.
class _ImageGallery extends StatefulWidget {
  final MarketplaceListing listing;

  const _ImageGallery({required this.listing});

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
    final images = widget.listing.images ?? [];
    if (images.isEmpty) {
      return _PlaceholderImage(type: widget.listing.type);
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.shimmerBase,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              ),
            );
          },
        ),

        // Page indicator
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: _currentIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.39),
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

/// Placeholder image when no images available.
class _PlaceholderImage extends StatelessWidget {
  final ListingType type;

  const _PlaceholderImage({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          _getTypeIcon(type),
          size: 48,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  IconData _getTypeIcon(ListingType type) {
    switch (type) {
      case ListingType.product:
        return Icons.shopping_bag_outlined;
      case ListingType.housing:
        return Icons.home_outlined;
      case ListingType.event:
        return Icons.event_outlined;
      case ListingType.opportunity:
        return Icons.work_outline;
      case ListingType.communityPost:
        return Icons.chat_bubble_outline;
      case ListingType.poll:
        return Icons.poll_outlined;
    }
  }
}

/// Type badge widget.
class _TypeBadge extends StatelessWidget {
  final MarketplaceListing listing;

  const _TypeBadge({required this.listing});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            listing.category.icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            listing.category.label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (listing.category) {
      case MarketplaceCategory.hardGoods:
        return AppColors.primary;
      case MarketplaceCategory.housing:
        return AppColors.info;
      case MarketplaceCategory.opportunities:
        return AppColors.success;
      case MarketplaceCategory.community:
        return AppColors.warning;
    }
  }
}

/// Seller information card.
class _SellerInfoCard extends StatelessWidget {
  final MarketplaceListing listing;

  const _SellerInfoCard({required this.listing});

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
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              listing.userName.isNotEmpty
                  ? listing.userName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.userName,
                  style: AppTextStyles.labelLarge,
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
          SizedBox(
            width: 100,
            child: OutlinedButton(
              onPressed: () {
                // Contact seller
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Contact'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Information row widget.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats row (views, likes, comments).
class _StatsRow extends StatelessWidget {
  final MarketplaceListing listing;

  const _StatsRow({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: [
        _StatItem(
          icon: Icons.remove_red_eye_outlined,
          value: listing.viewCount,
          label: 'views',
        ),
        _StatItem(
          icon: Icons.favorite_border,
          value: listing.likeCount,
          label: 'likes',
        ),
        if (listing.commentCount > 0)
          _StatItem(
            icon: Icons.chat_bubble_outline,
            value: listing.commentCount,
            label: 'comments',
          ),
      ],
    );
  }
}

/// Individual stat item.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Poll section for poll listings.
class _PollSection extends StatelessWidget {
  final MarketplaceListing listing;

  const _PollSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final options = listing.metadata!['pollOptions'] as List<dynamic>;
    final totalVotes = listing.metadata?['totalVotes'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poll Results',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        ...options.map((option) => _PollOptionTile(
              text: option['text'] ?? '',
              percentage: option['percentage'] ?? 0,
              votes: option['votes'] ?? 0,
            )),
        const SizedBox(height: 12),
        Text(
          '$totalVotes total votes',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Poll option tile.
class _PollOptionTile extends StatelessWidget {
  final String text;
  final int percentage;
  final int votes;

  const _PollOptionTile({
    required this.text,
    required this.percentage,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$votes votes',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Expiry warning widget.
class _ExpiryWarning extends StatelessWidget {
  final DateTime expiresAt;

  const _ExpiryWarning({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    final isExpired = diff.isNegative;
    final isExpiringSoon = !isExpired && diff.inDays < 3;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.errorLight
            : isExpiringSoon
                ? AppColors.warningLight
                : AppColors.infoLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isExpired
                ? Icons.error_outline
                : isExpiringSoon
                    ? Icons.warning_amber_outlined
                    : Icons.schedule,
            color: isExpired
                ? AppColors.error
                : isExpiringSoon
                    ? AppColors.warning
                    : AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isExpired
                  ? 'This listing has expired'
                  : isExpiringSoon
                      ? 'Expires in ${diff.inDays > 0 ? '${diff.inDays} days' : '${diff.inHours} hours'}'
                      : 'Closes on ${DateFormat('MMM d, yyyy').format(expiresAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isExpired
                    ? AppColors.error
                    : isExpiringSoon
                        ? AppColors.warning
                        : AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state widget.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
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
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

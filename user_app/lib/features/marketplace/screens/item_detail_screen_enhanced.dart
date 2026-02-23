import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';

/// Enhanced detail screen for marketplace listings with modern glass morphism design.
///
/// Features:
/// - Gradient background matching marketplace theme
/// - Glass morphism for action cards
/// - Image gallery with swipe and indicators
/// - Seller info card with glass effect
/// - Related items section
/// - Like/save/share buttons with animations
/// - Contact seller button with glass design
class ItemDetailScreenEnhanced extends ConsumerStatefulWidget {
  final String listingId;

  const ItemDetailScreenEnhanced({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ItemDetailScreenEnhanced> createState() => _ItemDetailScreenEnhancedState();
}

class _ItemDetailScreenEnhancedState extends ConsumerState<ItemDetailScreenEnhanced> {
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        opacity: 0.4,
        colors: const [
          Color(0xFFFBE8E8), // Soft pink
          Color(0xFFFCEDE8), // Soft peach
          Color(0xFFF0E8F8), // Soft purple
        ],
        child: listingAsync.when(
          data: (listing) {
            if (listing == null) {
              return _buildNotFound(context);
            }
            return _buildContent(context, listing);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MarketplaceListing listing) {
    final hasImages = listing.hasImages;

    return CustomScrollView(
      slivers: [
        // Image gallery with glass back button
        SliverAppBar(
          expandedHeight: hasImages ? 350 : 120,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            _buildActionButton(
              icon: _isLiked ? Icons.favorite : Icons.favorite_border,
              onTap: () {
                setState(() => _isLiked = !_isLiked);
              },
              color: _isLiked ? AppColors.error : Colors.white,
            ),
            _buildActionButton(
              icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
              onTap: () {
                setState(() => _isSaved = !_isSaved);
              },
              color: _isSaved ? AppColors.warning : Colors.white,
            ),
            _buildActionButton(
              icon: Icons.share_outlined,
              onTap: () {
                Share.share(
                  'Check out this on AssignX: ${listing.title}',
                  subject: listing.title,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: hasImages
                ? _ImageGallery(listing: listing)
                : _PlaceholderImage(type: listing.type),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Type badge and time
              Row(
                children: [
                  _TypeBadge(listing: listing),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                listing.title,
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 12),

              // Price with glass container
              if (listing.price != null) ...[
                GlassCard(
                  blur: 12,
                  opacity: 0.8,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        listing.priceString,
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (listing.isNegotiable) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Negotiable',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Seller info card with glass effect
              _SellerInfoCard(listing: listing),
              const SizedBox(height: 20),

              // Description
              if (listing.description != null) ...[
                GlassCard(
                  blur: 12,
                  opacity: 0.8,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Description',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Location & Stats
              GlassCard(
                blur: 12,
                opacity: 0.8,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (listing.location != null)
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: listing.location!,
                      ),
                    if (listing.distanceKm != null) ...[
                      if (listing.location != null) const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.near_me_outlined,
                        label: 'Distance',
                        value: listing.distanceString ?? '',
                      ),
                    ],
                    if (listing.location != null || listing.distanceKm != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                    _StatsRow(listing: listing),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onTap,
              icon: Icon(icon, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: GlassCard(
        blur: 15,
        opacity: 0.8,
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
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
            GlassButton(
              label: 'Go Back',
              icon: Icons.arrow_back,
              onPressed: () => context.pop(),
              blur: 12,
              opacity: 0.9,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fullWidth: false,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image gallery widget with page indicators.
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
        // Images
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
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withAlpha(128),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(77),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final ListingType type;

  const _PlaceholderImage({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant,
            AppColors.surface,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(type),
          size: 64,
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

class _TypeBadge extends StatelessWidget {
  final MarketplaceListing listing;

  const _TypeBadge({required this.listing});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            listing.category.icon,
            size: 16,
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

class _SellerInfoCard extends StatelessWidget {
  final MarketplaceListing listing;

  const _SellerInfoCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.85,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                listing.userName.isNotEmpty
                    ? listing.userName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.userName,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (listing.userUniversity != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    listing.userUniversity!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GlassButton(
            label: 'Contact',
            icon: Icons.chat_bubble_outline,
            onPressed: () {
              // Handle contact seller
            },
            blur: 10,
            opacity: 0.9,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            fullWidth: false,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}

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
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
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
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final MarketplaceListing listing;

  const _StatsRow({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          icon: Icons.visibility_outlined,
          value: listing.viewCount,
          label: 'Views',
        ),
        Container(width: 1, height: 32, color: AppColors.border),
        _StatItem(
          icon: Icons.favorite_border,
          value: listing.likeCount,
          label: 'Likes',
        ),
        if (listing.commentCount > 0) ...[
          Container(width: 1, height: 32, color: AppColors.border),
          _StatItem(
            icon: Icons.chat_bubble_outline,
            value: listing.commentCount,
            label: 'Comments',
          ),
        ],
      ],
    );
  }
}

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
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

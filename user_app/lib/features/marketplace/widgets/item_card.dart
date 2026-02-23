import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Pinterest-style item card for marketplace listings.
///
/// Uses the new glass morphism design system with:
/// - GlassCard for container styling
/// - AppShadows for elevation
/// - TapScaleContainer for press animations
/// - SkeletonLoader for loading placeholders
/// - AppColors for consistent theming
class ItemCard extends StatefulWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const ItemCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLike,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleContainer(
      onTap: widget.onTap,
      pressedScale: 0.97,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GlassCard(
          blur: 10,
          opacity: _isHovered ? 0.85 : 0.75,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          padding: EdgeInsets.zero,
          elevation: _isHovered ? 3 : 2,
          enableHoverEffect: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              if (widget.listing.hasImages)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMd),
                  ),
                  child: Stack(
                    children: [
                      // Product image with skeleton loading
                      CachedNetworkImage(
                        imageUrl: widget.listing.primaryImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const SkeletonLoader(
                          height: 120,
                          borderRadius: 0,
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 120,
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),

                      // Price tag with glass effect
                      if (widget.listing.price != null)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: AppShadows.sm,
                            ),
                            child: Text(
                              widget.listing.priceString,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // Animated like button
                      Positioned(
                        right: 8,
                        top: 8,
                        child: _GlassLikeButton(
                          isLiked: widget.listing.isLiked,
                          onTap: widget.onLike,
                        ),
                      ),

                      // Negotiable badge
                      if (widget.listing.isNegotiable)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: AppShadows.xs,
                            ),
                            child: Text(
                              'Negotiable',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.listing.title,
                      style: AppTextStyles.labelMedium.copyWith(
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Location and distance
                    if (widget.listing.location != null ||
                        widget.listing.distanceKm != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.listing.distanceString ??
                                  widget.listing.location ??
                                  '',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                    // Time and likes row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Time ago
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.listing.timeAgo,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        // Like count
                        if (widget.listing.likeCount > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${widget.listing.likeCount}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated glass-style like button with press feedback.
class _GlassLikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback? onTap;

  const _GlassLikeButton({
    required this.isLiked,
    this.onTap,
  });

  @override
  State<_GlassLikeButton> createState() => _GlassLikeButtonState();
}

class _GlassLikeButtonState extends State<_GlassLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_GlassLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        if (!widget.isLiked) {
          _controller.forward().then((_) => _controller.reverse());
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              blur: 12,
              opacity: 0.9,
              padding: const EdgeInsets.all(8),
              borderRadius: BorderRadius.circular(20),
              borderColor: Colors.white.withAlpha(77),
              backgroundColor: Colors.white,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(widget.isLiked),
                  size: 16,
                  color: widget.isLiked ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact version for smaller grids with tap animation.
class CompactItemCard extends StatefulWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;

  const CompactItemCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  State<CompactItemCard> createState() => _CompactItemCardState();
}

class _CompactItemCardState extends State<CompactItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TapScaleContainer(
      onTap: widget.onTap,
      pressedScale: 0.98,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GlassCard(
          blur: 8,
          opacity: _isHovered ? 0.85 : 0.7,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          padding: EdgeInsets.zero,
          elevation: _isHovered ? 2 : 1,
          enableHoverEffect: false,
          child: Row(
            children: [
              // Image with skeleton loader
              if (widget.listing.hasImages)
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppSpacing.radiusSm),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.listing.primaryImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SkeletonLoader(
                      width: 80,
                      height: 80,
                      borderRadius: 0,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.listing.title,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(20),
                              AppColors.primaryLight.withAlpha(20),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.listing.priceString,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for marketplace item cards with glass effect.
class ItemCardSkeleton extends StatelessWidget {
  const ItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 8,
      opacity: 0.6,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      padding: EdgeInsets.zero,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const SkeletonLoader(
            height: 120,
            borderRadius: 0,
          ),
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(height: 14, width: 120),
                SizedBox(height: 8),
                SkeletonLoader(height: 12, width: 80),
                SizedBox(height: 6),
                SkeletonLoader(height: 10, width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

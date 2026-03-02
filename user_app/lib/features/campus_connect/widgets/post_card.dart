import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/marketplace_model.dart';
import 'like_button.dart';

/// Base card wrapper with consistent elevated styling, clean shadows,
/// and rounded corners for a premium feel.
class _BasePostCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _BasePostCard({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Discussion/Community post card (Type 1: Simple with icon area).
///
/// Features a colorful gradient icon area, title, subtitle, footer with
/// avatar + category tag, and like/comment buttons.
class DiscussionPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const DiscussionPostCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLike,
    this.onComment,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForTitle(listing.title);
    final gradientColors = _getGradientForTitle(listing.title);

    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon area
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              children: [
                // Subtle pattern overlay
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      iconData,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
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
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer row with like and comment
                Row(
                  children: [
                    Expanded(
                      child: _PostFooter(
                        userName: listing.userName,
                        categoryLabel: 'Discussion'.tr(context),
                        categoryColor: AppColors.categoryOrange,
                      ),
                    ),
                    // Like count
                    if (listing.likeCount > 0)
                      CompactLikeButton(
                        isLiked: isLiked,
                        likeCount: listing.likeCount,
                        onToggle: onLike,
                      ),
                    // Comment count
                    if (listing.commentCount > 0) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onComment,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.commentCount.toString(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('food') || lowerTitle.contains('cafe')) {
      return Icons.restaurant_outlined;
    }
    if (lowerTitle.contains('book') || lowerTitle.contains('academic')) {
      return Icons.menu_book_outlined;
    }
    if (lowerTitle.contains('manage') || lowerTitle.contains('coding')) {
      return Icons.code_rounded;
    }
    return Icons.chat_bubble_outline_rounded;
  }

  List<Color> _getGradientForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('food') || lowerTitle.contains('cafe')) {
      return [const Color(0xFFFF6B35), const Color(0xFFFF8C42)];
    }
    if (lowerTitle.contains('book') || lowerTitle.contains('academic')) {
      return [const Color(0xFF6366F1), const Color(0xFF818CF8)];
    }
    if (lowerTitle.contains('manage') || lowerTitle.contains('coding')) {
      return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
    return [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)];
  }
}

/// Help post card (Type 2: With alert icon).
///
/// Features a warm gradient alert badge, title, description, and footer.
class HelpPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onAnswer;

  const HelpPostCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack for alert badge positioning
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
                        child: Text(
                          listing.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (listing.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          listing.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),

                  // Alert badge (top right) with gradient
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B35),
                            Color(0xFFFF4444),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4444)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '!',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer row
              _PostFooter(
                userName: listing.userName,
                categoryLabel: 'Help'.tr(context),
                categoryColor: AppColors.categoryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Event post card (Type 3: With gradient icon area).
///
/// Features a colorful gradient background with event icon,
/// title, description (truncated), and footer.
class EventPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onRsvp;

  const EventPostCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon area
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -15,
                  bottom: -15,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getIconForEvent(listing.title),
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer row
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Event'.tr(context),
                  categoryColor: AppColors.categoryIndigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEvent(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('aws') || lowerTitle.contains('cloud')) {
      return Icons.cloud_outlined;
    }
    if (lowerTitle.contains('workshop')) {
      return Icons.build_outlined;
    }
    return Icons.celebration_rounded;
  }
}

/// Product listing card (Type 4: With gradient icon area and like overlay).
///
/// Features a colorful gradient background with product icon,
/// title, description (truncated), footer, and like button.
class ProductPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const ProductPostCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon area with like button overlay
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _getIconForProduct(listing.title),
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Like button in top right corner
              Positioned(
                top: 8,
                right: 8,
                child: FloatingLikeButton(
                  isLiked: isLiked,
                  onToggle: onLike,
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer row with likes
                Row(
                  children: [
                    Expanded(
                      child: _PostFooter(
                        userName: listing.userName,
                        categoryLabel: 'Product'.tr(context),
                        categoryColor: AppColors.categoryGreen,
                      ),
                    ),
                    if (listing.likeCount > 0)
                      CompactLikeButton(
                        isLiked: isLiked,
                        likeCount: listing.likeCount,
                        onToggle: onLike,
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

  IconData _getIconForProduct(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('cycle') || lowerTitle.contains('bike')) {
      return Icons.pedal_bike_outlined;
    }
    if (lowerTitle.contains('laptop') || lowerTitle.contains('computer')) {
      return Icons.laptop_outlined;
    }
    if (lowerTitle.contains('phone') || lowerTitle.contains('mobile')) {
      return Icons.smartphone_outlined;
    }
    return Icons.shopping_bag_rounded;
  }
}

/// Housing listing card (Type 5: Compact with subtle gradient).
///
/// Features content-only card layout with a warm subtle gradient,
/// title, description, and footer.
class HousingPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onContact;

  const HousingPostCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFEF3C7).withValues(alpha: 0.4),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Housing icon badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      listing.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (listing.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  listing.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer row
              _PostFooter(
                userName: listing.userName,
                categoryLabel: 'Housing'.tr(context),
                categoryColor: AppColors.categoryAmber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opportunity post card.
///
/// Features a vibrant green gradient icon area with Opportunities category.
class OpportunityPostCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;

  const OpportunityPostCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon area
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Footer row
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Opportunities'.tr(context),
                  categoryColor: AppColors.categoryTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Post footer with styled avatar, username, and colored category pill.
class _PostFooter extends StatelessWidget {
  final String userName;
  final String categoryLabel;
  final Color categoryColor;

  const _PostFooter({
    required this.userName,
    required this.categoryLabel,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = userName.isEmpty || userName.toLowerCase() == 'unknown';

    return Row(
      children: [
        // Styled avatar with gradient ring
        Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUnknown
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withValues(alpha: 0.6),
                      categoryColor,
                    ],
                  ),
            border: isUnknown
                ? Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: isUnknown
                ? AppColors.avatarGray
                : categoryColor.withValues(alpha: 0.12),
            child: isUnknown
                ? Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.neutralMuted,
                  )
                : Text(
                    userName[0].toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: categoryColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),

        // Username
        Expanded(
          child: Text(
            isUnknown ? 'Unknown'.tr(context) : userName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Category pill tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            categoryLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

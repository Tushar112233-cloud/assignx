import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/marketplace_model.dart';
import 'like_button.dart';

// ─────────────────────────────────────────────────────────────
// Base card — clean, minimal, coffee brown accent
// ─────────────────────────────────────────────────────────────

class _BasePostCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? leftAccent;

  const _BasePostCard({
    required this.child,
    this.onTap,
    this.leftAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: leftAccent != null
                ? IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(width: 3, color: leftAccent),
                        Expanded(child: child),
                      ],
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Discussion / Community Post Card
// ─────────────────────────────────────────────────────────────

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
    final gradientColors = _getGradientForTitle(listing.title);
    final iconData = _getIconForTitle(listing.title);

    return _BasePostCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact gradient header with icon
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, size: 24, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Discussion'.tr(context),
                  categoryIconColor: const Color(0xFFF97316),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (listing.likeCount > 0)
                        CompactLikeButton(
                          isLiked: isLiked,
                          likeCount: listing.likeCount,
                          onToggle: onLike,
                        ),
                      if (listing.commentCount > 0) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onComment,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 3),
                              Text(
                                listing.commentCount.toString(),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('food') || t.contains('cafe')) {
      return Icons.restaurant_outlined;
    }
    if (t.contains('book') || t.contains('academic')) {
      return Icons.menu_book_outlined;
    }
    if (t.contains('manage') || t.contains('coding')) {
      return Icons.code_rounded;
    }
    return Icons.chat_bubble_outline_rounded;
  }

  List<Color> _getGradientForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('food') || t.contains('cafe')) {
      return [const Color(0xFFEA580C), const Color(0xFFFB923C)];
    }
    if (t.contains('book') || t.contains('academic')) {
      return [const Color(0xFF4F46E5), const Color(0xFF818CF8)];
    }
    if (t.contains('manage') || t.contains('coding')) {
      return [const Color(0xFF059669), const Color(0xFF34D399)];
    }
    return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
  }
}

// ─────────────────────────────────────────────────────────────
// Help / Question Post Card
// ─────────────────────────────────────────────────────────────

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
      leftAccent: AppColors.primary,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primary.withValues(alpha: 0.04),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge with colorful icon pop
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Needs Help',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                listing.title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (listing.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  listing.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              _PostFooter(
                userName: listing.userName,
                categoryLabel: 'Help'.tr(context),
                categoryIconColor: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Event Post Card
// ─────────────────────────────────────────────────────────────

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
          Container(
            height: 80,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDB2777), Color(0xFFF472B6)],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForEvent(listing.title),
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Event'.tr(context),
                  categoryIconColor: const Color(0xFFEC4899),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForEvent(String title) {
    final t = title.toLowerCase();
    if (t.contains('aws') || t.contains('cloud')) return Icons.cloud_outlined;
    if (t.contains('workshop')) return Icons.build_outlined;
    return Icons.celebration_rounded;
  }
}

// ─────────────────────────────────────────────────────────────
// Product / Marketplace Post Card
// ─────────────────────────────────────────────────────────────

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
          Stack(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForProduct(listing.title),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: FloatingLikeButton(
                  isLiked: isLiked,
                  onToggle: onLike,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Product'.tr(context),
                  categoryIconColor: const Color(0xFF3B82F6),
                  trailing: listing.likeCount > 0
                      ? CompactLikeButton(
                          isLiked: isLiked,
                          likeCount: listing.likeCount,
                          onToggle: onLike,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForProduct(String title) {
    final t = title.toLowerCase();
    if (t.contains('cycle') || t.contains('bike')) {
      return Icons.pedal_bike_outlined;
    }
    if (t.contains('laptop') || t.contains('computer')) {
      return Icons.laptop_outlined;
    }
    if (t.contains('phone') || t.contains('mobile')) {
      return Icons.smartphone_outlined;
    }
    return Icons.shopping_bag_rounded;
  }
}

// ─────────────────────────────────────────────────────────────
// Housing Post Card
// ─────────────────────────────────────────────────────────────

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
      leftAccent: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colorful icon container — wallet-page style
                Container(
                  padding: const EdgeInsets.all(7),
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
                  child: const Icon(Icons.home_rounded,
                      size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    listing.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (listing.description != null) ...[
              const SizedBox(height: 6),
              Text(
                listing.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            _PostFooter(
              userName: listing.userName,
              categoryLabel: 'Housing'.tr(context),
              categoryIconColor: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Opportunity Post Card
// ─────────────────────────────────────────────────────────────

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
          Container(
            height: 80,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF059669), Color(0xFF34D399)],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    size: 24, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (listing.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    listing.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                _PostFooter(
                  userName: listing.userName,
                  categoryLabel: 'Opportunity'.tr(context),
                  categoryIconColor: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Footer — coffee brown text, colorful category dot only
// ─────────────────────────────────────────────────────────────

class _PostFooter extends StatelessWidget {
  final String userName;
  final String categoryLabel;
  final Color categoryIconColor;
  final Widget? trailing;

  const _PostFooter({
    required this.userName,
    required this.categoryLabel,
    required this.categoryIconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknown = userName.isEmpty || userName.toLowerCase() == 'unknown';

    return Row(
      children: [
        // Avatar — coffee brown tones
        CircleAvatar(
          radius: 11,
          backgroundColor: isUnknown
              ? AppColors.surfaceVariant
              : AppColors.primary.withValues(alpha: 0.08),
          child: isUnknown
              ? Icon(Icons.person_outline,
                  size: 13, color: AppColors.neutralMuted)
              : Text(
                  userName[0].toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
        ),
        const SizedBox(width: 6),

        // Username — coffee brown secondary text
        Expanded(
          child: Text(
            isUnknown ? 'Unknown'.tr(context) : userName,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (trailing != null) ...[
          trailing!,
          const SizedBox(width: 8),
        ],

        // Category pill — coffee brown bg with colorful dot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small colorful dot — the pop of color
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: categoryIconColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  categoryLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

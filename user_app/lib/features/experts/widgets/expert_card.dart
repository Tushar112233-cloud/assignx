import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';

/// Expert card widget with glassmorphic styling.
///
/// Displays expert information in a card format with avatar, credentials,
/// rating, price, and book button. Supports default, compact, and featured variants.
class ExpertCard extends StatelessWidget {
  /// The expert to display.
  final Expert expert;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the book button is pressed.
  final VoidCallback? onBook;

  /// Card variant style.
  final ExpertCardVariant variant;

  const ExpertCard({
    super.key,
    required this.expert,
    this.onTap,
    this.onBook,
    this.variant = ExpertCardVariant.defaultCard,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ExpertCardVariant.compact:
        return _buildCompactCard(context);
      case ExpertCardVariant.featured:
        return _buildFeaturedCard(context);
      case ExpertCardVariant.defaultCard:
        return _buildDefaultCard(context);
    }
  }

  /// Build compact variant - minimal card for horizontal lists.
  Widget _buildCompactCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar and info row - doctor prominent
            Row(
              children: [
                _buildAvatar(size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expert.name,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (expert.verified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: 14,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expert.designation,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating row
            Row(
              children: [
                _buildRatingBadge(small: true),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.users,
                  size: 11,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 3),
                Text(
                  '${expert.totalSessions}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price and book row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.priceString,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '/session',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                _buildBookButton(small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build featured variant - prominent card with golden accent.
  Widget _buildFeaturedCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFEF7E0), // Warm golden tint
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5D9B6).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured badge at top
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.award,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Featured',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Avatar and info row - doctor as main focus
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(size: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expert.name,
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (expert.verified) ...[
                            const SizedBox(width: 6),
                            Icon(
                              LucideIcons.badgeCheck,
                              size: 20,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.designation,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Rating and sessions
                      Row(
                        children: [
                          _buildRatingBadge(),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.users,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${expert.totalSessions} sessions',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Specializations
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: expert.specializations.take(3).map((spec) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    spec.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Price and book row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.priceString,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '/session',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                _buildBookButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build default variant - horizontal card with doctor as main focus.
  Widget _buildDefaultCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Large prominent avatar - doctor as main focus
            _buildAvatar(size: 72),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with verification
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          expert.name,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (expert.verified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Designation
                  Text(
                    expert.designation,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Stats row
                  Row(
                    children: [
                      _buildRatingBadge(small: true),
                      const SizedBox(width: 10),
                      Icon(
                        LucideIcons.users,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${expert.totalSessions}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          expert.responseTime.replaceAll('Within ', ''),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Price and book button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expert.priceString,
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '/session',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      _buildBookButton(small: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build avatar with availability indicator.
  Widget _buildAvatar({required double size}) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.primaryLight.withAlpha(50),
            backgroundImage:
                expert.avatar != null ? NetworkImage(expert.avatar!) : null,
            child: expert.avatar == null
                ? Text(
                    expert.initials,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.35,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.25,
            height: size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getAvailabilityColor(),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get color for availability indicator.
  Color _getAvailabilityColor() {
    switch (expert.availability) {
      case ExpertAvailability.available:
        return AppColors.success;
      case ExpertAvailability.busy:
        return AppColors.warning;
      case ExpertAvailability.offline:
        return AppColors.neutralGray;
    }
  }

  /// Build rating badge.
  Widget _buildRatingBadge({bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(30),
        borderRadius: BorderRadius.circular(small ? 10 : 12),
        border: Border.all(
          color: AppColors.warning.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.star,
            size: small ? 12 : 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            expert.ratingString,
            style: (small ? AppTextStyles.caption : AppTextStyles.labelSmall)
                .copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: small ? 11 : 12,
            ),
          ),
          if (expert.reviewCount > 0) ...[
            Text(
              ' (${expert.reviewCount})',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: small ? 9 : 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build book button.
  Widget _buildBookButton({bool small = false}) {
    return Material(
      color: AppColors.darkBrown,
      borderRadius: BorderRadius.circular(small ? 8 : 10),
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(small ? 8 : 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: small ? 14 : 20,
            vertical: small ? 8 : 10,
          ),
          child: Text(
            small ? 'Book' : 'Book Now',
            style: (small ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Expert card variant.
enum ExpertCardVariant {
  defaultCard,
  compact,
  featured,
}

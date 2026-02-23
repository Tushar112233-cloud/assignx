import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/user_type.dart';
import '../../features/profile/widgets/account_badge.dart';

/// Size variants for UserBadgeCard.
enum UserBadgeSize {
  /// Small size for compact lists
  sm,

  /// Medium size for standard use
  md,

  /// Large size for headers
  lg,
}

/// A card displaying user information with their account type badge.
///
/// Use this in chat headers, project cards, and user lists to show
/// consistent user information with their account type badge.
///
/// Example usage:
/// ```dart
/// UserBadgeCard(
///   name: 'John Doe',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   accountType: 'professional',
///   isVerified: true,
///   subtitle: 'Last seen 2m ago',
/// )
/// ```
class UserBadgeCard extends StatelessWidget {
  /// User's display name.
  final String name;

  /// User's avatar URL (optional).
  final String? avatarUrl;

  /// User's account type ('student', 'professional', 'business_owner').
  final String? accountType;

  /// Whether the account is verified.
  final bool isVerified;

  /// Size variant.
  final UserBadgeSize size;

  /// Optional subtitle text (e.g., email, role, status).
  final String? subtitle;

  /// Whether to show compact badge (icon only) or full badge.
  final bool compact;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Optional trailing widget.
  final Widget? trailing;

  const UserBadgeCard({
    super.key,
    required this.name,
    this.avatarUrl,
    this.accountType,
    this.isVerified = false,
    this.size = UserBadgeSize.md,
    this.subtitle,
    this.compact = false,
    this.onTap,
    this.trailing,
  });

  /// Creates a UserBadgeCard from a UserType enum.
  factory UserBadgeCard.fromUserType({
    Key? key,
    required String name,
    String? avatarUrl,
    required UserType? userType,
    bool isVerified = false,
    UserBadgeSize size = UserBadgeSize.md,
    String? subtitle,
    bool compact = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return UserBadgeCard(
      key: key,
      name: name,
      avatarUrl: avatarUrl,
      accountType: userType?.toDbString(),
      isVerified: isVerified,
      size: size,
      subtitle: subtitle,
      compact: compact,
      onTap: onTap,
      trailing: trailing,
    );
  }

  /// Size configuration mapping.
  static const Map<UserBadgeSize, _SizeConfig> _sizeConfigs = {
    UserBadgeSize.sm: _SizeConfig(
      avatarRadius: 16,
      nameStyle: AppTextStyles.labelMedium,
      subtitleStyle: AppTextStyles.caption,
      spacing: 8,
      badgeSize: BadgeSize.sm,
    ),
    UserBadgeSize.md: _SizeConfig(
      avatarRadius: 20,
      nameStyle: AppTextStyles.labelLarge,
      subtitleStyle: AppTextStyles.bodySmall,
      spacing: 12,
      badgeSize: BadgeSize.sm,
    ),
    UserBadgeSize.lg: _SizeConfig(
      avatarRadius: 24,
      nameStyle: AppTextStyles.headingSmall,
      subtitleStyle: AppTextStyles.bodyMedium,
      spacing: 16,
      badgeSize: BadgeSize.md,
    ),
  };

  _SizeConfig get _config => _sizeConfigs[size]!;

  String get _initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        // Avatar with optional badge overlay
        _buildAvatar(),
        SizedBox(width: _config.spacing),

        // Name and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: _config.nameStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // Full badge next to name (non-compact mode)
                  if (!compact && accountType != null) ...[
                    const SizedBox(width: 8),
                    AccountBadge(
                      accountType: accountType!,
                      isVerified: isVerified,
                      size: _config.badgeSize,
                      animate: false,
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: _config.subtitleStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),

        // Trailing widget
        if (trailing != null) ...[
          SizedBox(width: _config.spacing),
          trailing!,
        ],
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildAvatar() {
    final avatar = CircleAvatar(
      radius: _config.avatarRadius,
      backgroundColor: AppColors.primaryLight,
      child: avatarUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                width: _config.avatarRadius * 2,
                height: _config.avatarRadius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitialsAvatar(),
                errorWidget: (context, url, error) => _buildInitialsAvatar(),
              ),
            )
          : _buildInitialsAvatar(),
    );

    // In compact mode, overlay the badge on the avatar
    if (compact && accountType != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: -2,
            right: -2,
            child: CompactAccountBadge(
              accountType: accountType!,
              isVerified: isVerified,
              size: _config.avatarRadius * 0.8,
            ),
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: _config.avatarRadius * 0.7,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Size configuration helper class.
class _SizeConfig {
  final double avatarRadius;
  final TextStyle nameStyle;
  final TextStyle subtitleStyle;
  final double spacing;
  final BadgeSize badgeSize;

  const _SizeConfig({
    required this.avatarRadius,
    required this.nameStyle,
    required this.subtitleStyle,
    required this.spacing,
    required this.badgeSize,
  });
}

/// A standalone avatar with account badge overlay.
///
/// Use this when you only need the avatar without the full user info.
///
/// Example usage:
/// ```dart
/// UserAvatarWithBadge(
///   name: 'John Doe',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   accountType: 'student',
///   isVerified: true,
///   radius: 24,
/// )
/// ```
class UserAvatarWithBadge extends StatelessWidget {
  /// User's display name (for initials fallback).
  final String name;

  /// User's avatar URL (optional).
  final String? avatarUrl;

  /// User's account type.
  final String? accountType;

  /// Whether the account is verified.
  final bool isVerified;

  /// Avatar radius.
  final double radius;

  /// Callback when tapped.
  final VoidCallback? onTap;

  const UserAvatarWithBadge({
    super.key,
    required this.name,
    this.avatarUrl,
    this.accountType,
    this.isVerified = false,
    this.radius = 24,
    this.onTap,
  });

  /// Creates from UserType enum.
  factory UserAvatarWithBadge.fromUserType({
    Key? key,
    required String name,
    String? avatarUrl,
    required UserType? userType,
    bool isVerified = false,
    double radius = 24,
    VoidCallback? onTap,
  }) {
    return UserAvatarWithBadge(
      key: key,
      name: name,
      avatarUrl: avatarUrl,
      accountType: userType?.toDbString(),
      isVerified: isVerified,
      radius: radius,
      onTap: onTap,
    );
  }

  String get _initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: avatarUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitialsAvatar(),
                errorWidget: (context, url, error) => _buildInitialsAvatar(),
              ),
            )
          : _buildInitialsAvatar(),
    );

    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        if (accountType != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: CompactAccountBadge(
              accountType: accountType!,
              isVerified: isVerified,
              size: radius * 0.7,
            ),
          ),
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

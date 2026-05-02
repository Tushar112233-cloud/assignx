/// A customizable avatar widget for displaying user profile images.
///
/// This file provides a reusable avatar component with support for
/// network images, initials fallback, and status badges.
///
/// ## Features
/// - Multiple size options (small, medium, large, xlarge)
/// - Network image loading with caching
/// - Initials fallback when no image is available
/// - Optional status badge indicator
/// - Custom badge widget support
/// - Tap interaction support
///
/// ## Example
/// ```dart
/// AppAvatar(
///   imageUrl: user.avatarUrl,
///   name: user.fullName,
///   size: AvatarSize.large,
///   showBadge: user.isOnline,
///   badgeColor: AppColors.success,
/// )
/// ```
///
/// See also:
/// - [CachedNetworkImage] for image caching
/// - [AppColors] for the color scheme
/// - [AppSpacing] for avatar size constants
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/helpers.dart';

/// Available avatar size options.
///
/// Each size provides consistent dimensions for avatars:
/// - [small]: 32px diameter
/// - [medium]: 48px diameter (default)
/// - [large]: 64px diameter
/// - [xlarge]: 96px diameter
enum AvatarSize { small, medium, large, xlarge }

/// A customizable avatar widget for displaying user profile images.
///
/// Supports network images with caching, initials fallback, and status badges.
/// Automatically displays the user's initials when no image is available.
///
/// ## Usage
/// ```dart
/// AppAvatar(
///   imageUrl: user.avatarUrl,
///   name: user.fullName,
///   size: AvatarSize.large,
///   showBadge: user.isOnline,
///   badgeColor: AppColors.success,
/// )
/// ```
///
/// ## Badge Display
/// Set [showBadge] to true to show a simple colored dot badge.
/// Use [badge] for a custom badge widget.
///
/// See also:
/// - [AvatarSize] for available sizes
class AppAvatar extends StatelessWidget {
  /// Creates an avatar with the specified properties.
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AvatarSize.medium,
    this.onTap,
    this.showBadge = false,
    this.badgeColor,
    this.badge,
  });

  /// The URL of the profile image to display.
  ///
  /// If null or empty, displays initials from [name] or a default icon.
  final String? imageUrl;

  /// The user's full name for generating initials.
  ///
  /// Used as fallback when [imageUrl] is not available.
  final String? name;

  /// The size of the avatar.
  ///
  /// Defaults to [AvatarSize.medium].
  final AvatarSize size;

  /// Callback invoked when the avatar is tapped.
  final VoidCallback? onTap;

  /// Whether to show a status badge indicator.
  ///
  /// When true, displays a small colored dot in the bottom-right corner.
  final bool showBadge;

  /// The color of the status badge.
  ///
  /// Only applies when [showBadge] is true.
  /// Defaults to [AppColors.success].
  final Color? badgeColor;

  /// Custom widget to display as a badge.
  ///
  /// When provided, overrides the default dot badge.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: _getSize(),
            height: _getSize(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: _buildContent(),
            ),
          ),
          if (showBadge || badge != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: badge ??
                  Container(
                    width: _getBadgeSize(),
                    height: _getBadgeSize(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor ?? AppColors.success,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  /// Builds the avatar content (image, initials, or default icon).
  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  /// Builds the placeholder content (initials or default icon).
  Widget _buildPlaceholder() {
    if (name != null && name!.isNotEmpty) {
      return Container(
        color: AppColors.primary.withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: Text(
          Helpers.getInitials(name!),
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: _getIconSize(),
        color: AppColors.textTertiary,
      ),
    );
  }

  /// Returns the avatar size in pixels based on [size].
  double _getSize() {
    switch (size) {
      case AvatarSize.small:
        return AppSpacing.avatarSm;
      case AvatarSize.medium:
        return AppSpacing.avatarMd;
      case AvatarSize.large:
        return AppSpacing.avatarLg;
      case AvatarSize.xlarge:
        return AppSpacing.avatarXl;
    }
  }

  /// Returns the font size for initials based on avatar [size].
  double _getFontSize() {
    switch (size) {
      case AvatarSize.small:
        return 12;
      case AvatarSize.medium:
        return 16;
      case AvatarSize.large:
        return 20;
      case AvatarSize.xlarge:
        return 28;
    }
  }

  /// Returns the icon size for the default placeholder based on avatar [size].
  double _getIconSize() {
    switch (size) {
      case AvatarSize.small:
        return 16;
      case AvatarSize.medium:
        return 24;
      case AvatarSize.large:
        return 32;
      case AvatarSize.xlarge:
        return 48;
    }
  }

  /// Returns the badge size based on avatar [size].
  double _getBadgeSize() {
    switch (size) {
      case AvatarSize.small:
        return 8;
      case AvatarSize.medium:
        return 12;
      case AvatarSize.large:
        return 16;
      case AvatarSize.xlarge:
        return 20;
    }
  }
}

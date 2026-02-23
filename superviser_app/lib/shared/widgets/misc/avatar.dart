import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// {@template avatar}
/// A user avatar widget with image support and fallback to initials.
///
/// Displays a profile image from a URL if available. When no image is
/// provided or loading fails, displays the user's initials on a
/// colored background.
///
/// ## Appearance
/// - Circular by default (or rounded rectangle with custom [borderRadius])
/// - Displays network image if [imageUrl] is provided
/// - Falls back to initials from [name] if image is unavailable
/// - Initials are automatically extracted from first and last name
/// - Text size scales based on avatar [size]
///
/// ## Features
/// - Network image caching via [CachedNetworkImage]
/// - Graceful fallback for failed image loads
/// - Tap interaction support via [onTap]
/// - Customizable colors for background and text
///
/// ## Usage
///
/// With image:
/// ```dart
/// Avatar(
///   imageUrl: user.profilePicture,
///   name: user.fullName,
///   size: 48,
/// )
/// ```
///
/// Initials only:
/// ```dart
/// Avatar(
///   name: 'John Doe',
///   size: 40,
///   backgroundColor: Colors.blue,
/// )
/// ```
///
/// With rounded corners:
/// ```dart
/// Avatar(
///   imageUrl: user.avatar,
///   name: user.name,
///   size: 56,
///   borderRadius: 12,
/// )
/// ```
///
/// Tappable avatar:
/// ```dart
/// Avatar(
///   imageUrl: user.avatar,
///   name: user.name,
///   onTap: () => navigateToProfile(),
/// )
/// ```
///
/// See also:
/// - [AvatarWithStatus] for avatars with online/offline indicator
/// {@endtemplate}
class Avatar extends StatelessWidget {
  /// Creates an avatar widget.
  const Avatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  /// URL of the profile image.
  ///
  /// If null or empty, initials from [name] are displayed instead.
  final String? imageUrl;

  /// The user's name for generating initials.
  ///
  /// Initials are extracted from the first letter of the first and
  /// last words. For example:
  /// - "John Doe" -> "JD"
  /// - "Alice" -> "A"
  /// - null or empty -> "?"
  final String? name;

  /// The diameter of the avatar.
  ///
  /// Defaults to 40 pixels.
  final double size;

  /// Corner radius for rounded rectangle shape.
  ///
  /// If null, the avatar is circular.
  final double? borderRadius;

  /// Background color for the initials fallback.
  ///
  /// Defaults to [AppColors.primaryLight].
  final Color? backgroundColor;

  /// Text color for the initials.
  ///
  /// Defaults to white.
  final Color? textColor;

  /// Callback when the avatar is tapped.
  ///
  /// If null, the avatar is not interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryLight;
    final txtColor = textColor ?? Colors.white;

    final shape = borderRadius != null
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          )
        : const CircleBorder();

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipPath(
        clipper: borderRadius != null
            ? null
            : const ShapeBorderClipper(shape: CircleBorder()),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(bgColor, txtColor),
          errorWidget: (context, url, error) =>
              _buildPlaceholder(bgColor, txtColor),
        ),
      );

      if (borderRadius != null) {
        avatar = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius!),
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(bgColor, txtColor),
            errorWidget: (context, url, error) =>
                _buildPlaceholder(bgColor, txtColor),
          ),
        );
      }
    } else {
      avatar = Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: bgColor,
          shape: shape,
        ),
        child: Center(
          child: Text(
            _getInitials(),
            style: _getTextStyle(txtColor),
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Builds the placeholder widget shown while loading or on error.
  Widget _buildPlaceholder(Color bgColor, Color txtColor) {
    final shape = borderRadius != null
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          )
        : const CircleBorder();

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: bgColor,
        shape: shape,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: _getTextStyle(txtColor),
        ),
      ),
    );
  }

  /// Extracts initials from the [name].
  ///
  /// Returns up to 2 characters from the first letter of the first
  /// and last words in the name.
  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Gets the appropriate text style based on avatar [size].
  TextStyle _getTextStyle(Color color) {
    if (size < 32) {
      return AppTypography.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      );
    }
    if (size < 48) {
      return AppTypography.labelMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      );
    }
    if (size < 64) {
      return AppTypography.titleSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      );
    }
    return AppTypography.titleMedium.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );
  }
}

/// {@template avatar_with_status}
/// An avatar with an online/offline status indicator.
///
/// Displays a small colored dot in the bottom-right corner to
/// indicate the user's online status.
///
/// ## Appearance
/// - Standard [Avatar] as the base
/// - Small circular indicator positioned at bottom-right
/// - Green dot for online, muted color for offline
/// - Indicator is 30% of avatar size with a white border
///
/// ## Usage
/// ```dart
/// AvatarWithStatus(
///   imageUrl: user.avatar,
///   name: user.name,
///   size: 48,
///   isOnline: user.isOnline,
///   onTap: () => showUserProfile(user),
/// )
/// ```
///
/// See also:
/// - [Avatar] for basic avatar without status
/// {@endtemplate}
class AvatarWithStatus extends StatelessWidget {
  /// Creates an avatar with status indicator.
  const AvatarWithStatus({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.isOnline = false,
    this.onTap,
  });

  /// URL of the profile image.
  final String? imageUrl;

  /// The user's name for generating initials.
  final String? name;

  /// The diameter of the avatar.
  ///
  /// Defaults to 40 pixels.
  final double size;

  /// Whether the user is currently online.
  ///
  /// When true, displays a green indicator.
  /// When false, displays a muted gray indicator.
  final bool isOnline;

  /// Callback when the avatar is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Avatar(
          imageUrl: imageUrl,
          name: name,
          size: size,
          onTap: onTap,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).scaffoldBackgroundColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

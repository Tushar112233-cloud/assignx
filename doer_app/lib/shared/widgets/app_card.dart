/// A collection of reusable card widgets following the app design system.
///
/// This file provides card components with different variants for
/// displaying content, status information, and interactive elements.
///
/// ## Features
/// - Customizable padding, margin, and colors
/// - Optional shadow and border
/// - Tap interaction support
/// - Status card variant with icon
/// - Info card variant with title/description
///
/// ## Example
/// ```dart
/// AppCard(
///   padding: AppSpacing.paddingMd,
///   onTap: () => handleTap(),
///   child: Text('Card content'),
/// )
/// ```
///
/// See also:
/// - [AppStatusCard] for status display cards
/// - [AppInfoCard] for title/description cards
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A reusable card widget with customizable styling.
///
/// Provides a consistent card appearance with optional shadow, border,
/// and tap interaction. Use as a container for any content.
///
/// ## Usage
/// ```dart
/// AppCard(
///   padding: AppSpacing.paddingMd,
///   onTap: () => handleTap(),
///   child: Text('Card content'),
/// )
/// ```
///
/// ## Customization
/// - [padding]: Inner padding around the child
/// - [margin]: Outer margin around the card
/// - [color]: Background color (defaults to [AppColors.surface])
/// - [elevation]: Shadow blur radius
/// - [borderRadius]: Corner radius
/// - [border]: Custom border
/// - [hasShadow]: Whether to show drop shadow
class AppCard extends StatelessWidget {
  /// Creates a card with the specified properties.
  ///
  /// The [child] parameter is required.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.hasShadow = true,
  });

  /// The content to display inside the card.
  final Widget child;

  /// Inner padding around the child.
  ///
  /// Defaults to [AppSpacing.paddingMd].
  final EdgeInsetsGeometry? padding;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Background color of the card.
  ///
  /// Defaults to [AppColors.surface].
  final Color? color;

  /// Shadow blur radius (elevation effect).
  ///
  /// Only applies when [hasShadow] is true.
  /// Defaults to 4.
  final double? elevation;

  /// Corner radius for the card.
  ///
  /// Defaults to [AppSpacing.borderRadiusMd].
  final BorderRadius? borderRadius;

  /// Custom border for the card.
  ///
  /// Defaults to a light border using [AppColors.borderLight].
  final Border? border;

  /// Callback invoked when the card is tapped.
  ///
  /// Adds an ink well effect for visual feedback.
  final VoidCallback? onTap;

  /// Whether to display a drop shadow.
  ///
  /// Defaults to true.
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        border: border ?? Border.all(color: AppColors.borderLight),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation ?? 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius ?? AppSpacing.borderRadiusMd,
            child: Padding(
              padding: padding ?? AppSpacing.paddingMd,
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

/// A status card widget with icon, title, and value display.
///
/// Useful for displaying metrics, counts, or status information
/// with a colored icon indicator.
///
/// ## Usage
/// ```dart
/// AppStatusCard(
///   icon: Icons.assignment,
///   title: 'Active Projects',
///   value: '5',
///   color: AppColors.primary,
///   onTap: () => navigateToProjects(),
/// )
/// ```
///
/// See also:
/// - [AppCard] for general purpose cards
class AppStatusCard extends StatelessWidget {
  /// Creates a status card with the specified properties.
  ///
  /// [icon], [title], [value], and [color] are required.
  const AppStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  /// The icon to display in the colored container.
  final IconData icon;

  /// The title label describing the value.
  final String title;

  /// The main value to display prominently.
  final String value;

  /// The theme color for the icon background and text.
  final Color color;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An info card widget with title, description, and optional icons.
///
/// Useful for displaying list items, settings, or information
/// with a consistent title/description layout.
///
/// ## Usage
/// ```dart
/// AppInfoCard(
///   title: 'Account Settings',
///   description: 'Manage your account preferences',
///   leading: Icon(Icons.settings),
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => navigateToSettings(),
/// )
/// ```
///
/// See also:
/// - [AppCard] for general purpose cards
/// - [AppStatusCard] for metric display
class AppInfoCard extends StatelessWidget {
  /// Creates an info card with the specified properties.
  ///
  /// [title] and [description] are required.
  const AppInfoCard({
    super.key,
    required this.title,
    required this.description,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  /// The main title text.
  final String title;

  /// The description text below the title.
  final String description;

  /// Optional widget displayed before the title/description.
  ///
  /// Typically an icon or avatar.
  final Widget? leading;

  /// Optional widget displayed after the title/description.
  ///
  /// Typically a chevron or action icon.
  final Widget? trailing;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// Background color override.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: backgroundColor,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

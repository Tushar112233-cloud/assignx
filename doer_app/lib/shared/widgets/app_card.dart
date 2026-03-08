/// A collection of reusable card widgets following the app design system.
///
/// This file provides glassmorphism-style card components with different
/// variants for displaying content, status information, and interactive
/// elements. Cards use backdrop blur and translucent backgrounds for a
/// frosted glass appearance.
///
/// ## Features
/// - Glassmorphism: backdrop blur, translucent backgrounds, subtle borders
/// - Default, elevated, and stat card variants
/// - Scale-on-tap animation for elevated cards
/// - Teal gradient accent strip on stat cards
/// - Backward-compatible API with the original elevation-based cards
///
/// ## Example
/// ```dart
/// AppCard(
///   padding: AppSpacing.paddingLg,
///   onTap: () => handleTap(),
///   child: Text('Card content'.tr(context)),
/// )
/// ```
///
/// See also:
/// - [GlassContainer] for the base glass morphism effect
/// - [AppStatusCard] for status display cards
/// - [AppInfoCard] for title/description cards
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A reusable glassmorphism card widget with customizable styling.
///
/// Provides a frosted glass appearance with backdrop blur, translucent
/// background, and a subtle white border. Supports optional tap interaction
/// with ink well feedback.
///
/// ## Usage
/// ```dart
/// AppCard(
///   padding: AppSpacing.paddingLg,
///   onTap: () => handleTap(),
///   child: Text('Card content'.tr(context)),
/// )
/// ```
///
/// ## Customization
/// - [padding]: Inner padding around the child (default 20)
/// - [margin]: Outer margin around the card
/// - [color]: Background color before opacity is applied
/// - [elevation]: Controls blur intensity and shadow (legacy compat)
/// - [borderRadius]: Corner radius (default 20)
/// - [border]: Custom border (default: 1px white at 0.2 opacity)
/// - [hasShadow]: Whether to show drop shadow
/// - [blur]: Backdrop blur sigma (default 15)
/// - [opacity]: Background opacity 0.0-1.0 (default 0.9)
class AppCard extends StatelessWidget {
  /// Creates a glass card with the specified properties.
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
    this.blur = 15.0,
    this.opacity = 0.9,
  });

  /// The content to display inside the card.
  final Widget child;

  /// Inner padding around the child.
  ///
  /// Defaults to 20px on all sides.
  final EdgeInsetsGeometry? padding;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Background color of the card before opacity is applied.
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
  /// Defaults to 20.
  final BorderRadius? borderRadius;

  /// Custom border for the card.
  ///
  /// Defaults to 1px white at 0.2 opacity for the glass edge.
  final Border? border;

  /// Callback invoked when the card is tapped.
  ///
  /// Adds an ink well effect for visual feedback.
  final VoidCallback? onTap;

  /// Whether to display a drop shadow.
  ///
  /// Defaults to true.
  final bool hasShadow;

  /// Backdrop blur sigma value.
  ///
  /// Higher values produce a stronger frosted glass effect.
  /// Defaults to 15.
  final double blur;

  /// Background opacity (0.0 to 1.0).
  ///
  /// Controls how translucent the card background is.
  /// Defaults to 0.9.
  final double opacity;

  static const BorderRadius _defaultRadius =
      BorderRadius.all(Radius.circular(20.0));

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.surface;
    final radius = borderRadius ?? _defaultRadius;
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withAlpha(51), // 0.2 opacity
          width: 1.0,
        );

    final card = Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor.withAlpha((opacity * 255).round()),
              borderRadius: radius,
              border: effectiveBorder,
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20.0),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

/// An elevated glass card with stronger blur, subtle shadow, and
/// scale-on-tap animation.
///
/// Use for interactive cards that need visual prominence, such as
/// project cards or primary action cards.
///
/// ## Usage
/// ```dart
/// AppElevatedCard(
///   onTap: () => openProject(),
///   child: ProjectContent(),
/// )
/// ```
class AppElevatedCard extends StatefulWidget {
  /// Creates an elevated glass card.
  ///
  /// The [child] parameter is required.
  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
    this.blur = 20.0,
    this.opacity = 0.9,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  /// The content to display inside the card.
  final Widget child;

  /// Inner padding around the child.
  final EdgeInsetsGeometry? padding;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Background color before opacity is applied.
  final Color? color;

  /// Corner radius for the card.
  final BorderRadius? borderRadius;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// Backdrop blur sigma value. Defaults to 20 for elevated variant.
  final double blur;

  /// Background opacity (0.0 to 1.0). Defaults to 0.9.
  final double opacity;

  /// Duration of the scale animation on tap.
  final Duration animationDuration;

  @override
  State<AppElevatedCard> createState() => _AppElevatedCardState();
}

class _AppElevatedCardState extends State<AppElevatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const BorderRadius _defaultRadius =
      BorderRadius.all(Radius.circular(20.0));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? AppColors.surface;
    final radius = widget.borderRadius ?? _defaultRadius;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          margin: widget.margin,
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor.withAlpha((widget.opacity * 255).round()),
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(20.0),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A stat card with a teal gradient accent strip at the top.
///
/// Displays a metric with icon, title, and value inside a glass card
/// that has a gradient accent bar along its top edge.
///
/// ## Usage
/// ```dart
/// AppStatCard(
///   icon: Icons.assignment,
///   title: 'Active Projects',
///   value: '5',
///   color: AppColors.primary,
///   onTap: () => navigateToProjects(),
/// )
/// ```
class AppStatCard extends StatelessWidget {
  /// Creates a stat card with gradient accent strip.
  ///
  /// [icon], [title], [value], and [color] are required.
  const AppStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
    this.blur = 15.0,
    this.opacity = 0.9,
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

  /// Backdrop blur sigma value.
  final double blur;

  /// Background opacity.
  final double opacity;

  static const BorderRadius _defaultRadius =
      BorderRadius.all(Radius.circular(20.0));

  /// Teal gradient used for the accent strip.
  static const LinearGradient _accentGradient = LinearGradient(
    colors: <Color>[AppColors.primary, AppColors.accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    const bgColor = AppColors.surface;

    return ClipRRect(
        borderRadius: _defaultRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor.withAlpha((opacity * 255).round()),
              borderRadius: _defaultRadius,
              border: Border.all(
                color: Colors.white.withAlpha(51),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Teal gradient accent strip
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: _accentGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                ),
                // Card content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: _defaultRadius,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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

/// A status card widget with icon, title, and value display.
///
/// Uses glassmorphism styling via [AppCard]. Useful for displaying
/// metrics, counts, or status information with a colored icon indicator.
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
/// - [AppStatCard] for stat cards with gradient accent strip
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
/// Uses glassmorphism styling via [AppCard]. Useful for displaying
/// list items, settings, or information with a consistent layout.
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

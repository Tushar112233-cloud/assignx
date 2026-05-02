import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/widgets/glass_container.dart';

/// Dashboard action card widget for quick action items.
///
/// Displays an icon, title, and optional subtitle with glass morphism effect.
/// Supports gradient backgrounds and interactive tap effects.
///
/// Example:
/// ```dart
/// DashboardActionCard(
///   icon: Icons.add_circle_outline,
///   title: 'New Project',
///   subtitle: 'Create assignment',
///   gradient: LinearGradient(colors: [primary, primaryLight]),
///   onTap: () => context.push('/new-project'),
/// )
/// ```
class DashboardActionCard extends StatelessWidget {
  /// Icon to display in the card.
  final IconData icon;

  /// Primary title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional gradient background.
  final Gradient? gradient;

  /// Background color when gradient is not provided.
  final Color? backgroundColor;

  /// Icon color. Defaults to white if gradient is provided, otherwise primary.
  final Color? iconColor;

  /// Title text color. Defaults to white if gradient is provided.
  final Color? titleColor;

  /// Subtitle text color. Defaults to semi-transparent white if gradient is provided.
  final Color? subtitleColor;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Card width. Defaults to flexible sizing.
  final double? width;

  /// Card height. Defaults to 140.
  final double height;

  /// Animation delay for staggered entrance.
  final Duration? animationDelay;

  /// Enable hover/press lift effect. Default is true.
  final bool enableHoverEffect;

  const DashboardActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.gradient,
    this.backgroundColor,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.onTap,
    this.width,
    this.height = 140,
    this.animationDelay,
    this.enableHoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasGradient = gradient != null;
    final effectiveIconColor = iconColor ??
        (hasGradient ? Colors.white : AppColors.primary);
    final effectiveTitleColor = titleColor ??
        (hasGradient ? Colors.white : AppColors.textPrimary);
    final effectiveSubtitleColor = subtitleColor ??
        (hasGradient
            ? Colors.white.withValues(alpha: 0.8)
            : AppColors.textSecondary);
    final effectiveBgColor = backgroundColor ?? AppColors.surface;

    Widget card = GlassCard(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      gradient: gradient,
      backgroundColor: hasGradient ? null : effectiveBgColor,
      borderColor: hasGradient
          ? Colors.white.withValues(alpha: 0.2)
          : AppColors.border.withValues(alpha: 0.3),
      onTap: onTap,
      enableHoverEffect: enableHoverEffect,
      child: Stack(
        children: [
          // Background decorative icon (if gradient is applied)
          if (hasGradient)
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasGradient
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 22,
                ),
              ),
              const Spacer(),
              // Title
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: effectiveTitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                // Subtitle
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: effectiveSubtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    // Apply animation if delay is provided
    if (animationDelay != null) {
      card = card.fadeInSlideUp(
        delay: animationDelay!,
        duration: const Duration(milliseconds: 400),
      );
    }

    return card;
  }
}

/// Preset action card variants for common dashboard actions.
class DashboardActionCardVariants {
  DashboardActionCardVariants._();

  /// Primary action card with gradient background.
  static DashboardActionCard primary({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback? onTap,
    double? width,
    double height = 140,
    Duration? animationDelay,
  }) {
    return DashboardActionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryLight],
      ),
      onTap: onTap,
      width: width,
      height: height,
      animationDelay: animationDelay,
    );
  }

  /// Stats card with icon and large number display.
  static Widget stats({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
    Color? iconBackgroundColor,
    VoidCallback? onTap,
    double? width,
    double height = 140,
    Duration? animationDelay,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.info;
    final effectiveIconBgColor = iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: 0.12);

    Widget card = GlassCard(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveIconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: 22,
            ),
          ),
          const Spacer(),
          // Value
          Text(
            value,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    // Apply animation if delay is provided
    if (animationDelay != null) {
      card = card.fadeInSlideUp(
        delay: animationDelay,
        duration: const Duration(milliseconds: 400),
      );
    }

    return card;
  }
}

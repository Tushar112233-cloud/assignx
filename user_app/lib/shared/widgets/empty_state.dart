import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'app_button.dart';

/// Illustrated empty state widget for when content is unavailable.
///
/// Displays an icon, title, subtitle, and optional action button
/// with smooth fade-in animation on display.
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No Messages',
///   subtitle: 'Your inbox is empty. Start a conversation!',
///   actionLabel: 'Compose',
///   onAction: () => Navigator.push(...),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Icon to display. Can be an IconData or a custom widget.
  final IconData? icon;

  /// Custom icon widget (takes precedence over icon).
  final Widget? iconWidget;

  /// Main title text.
  final String title;

  /// Subtitle/description text.
  final String? subtitle;

  /// Optional action button label.
  final String? actionLabel;

  /// Callback when action button is pressed.
  final VoidCallback? onAction;

  /// Icon size. Default is 80.
  final double iconSize;

  /// Icon color. Default is textTertiary.
  final Color? iconColor;

  /// Background color for icon circle. Default is surfaceVariant.
  final Color? iconBackgroundColor;

  /// Whether to show icon in a circle background. Default is true.
  final bool showIconBackground;

  /// Padding around the empty state.
  final EdgeInsetsGeometry padding;

  /// Whether to animate on display. Default is true.
  final bool animate;

  /// Animation duration. Default is 600ms.
  final Duration animationDuration;

  /// Secondary action label (text button).
  final String? secondaryActionLabel;

  /// Secondary action callback.
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
    this.iconBackgroundColor,
    this.showIconBackground = true,
    this.padding = const EdgeInsets.all(32),
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(context),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              _buildSubtitle(context),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              _buildSecondaryAction(),
            ],
          ],
        ),
      ),
    );

    if (animate) {
      content = content
          .animate()
          .fadeIn(duration: animationDuration)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: animationDuration,
            curve: Curves.easeOut,
          );
    }

    return content;
  }

  Widget _buildIcon() {
    final iconWidget = this.iconWidget ??
        Icon(
          icon ?? Icons.inbox_outlined,
          size: iconSize * 0.5,
          color: iconColor ?? AppColors.textTertiary,
        );

    if (!showIconBackground) {
      return iconWidget;
    }

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Center(child: iconWidget),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      subtitle!,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return AppButton(
      label: actionLabel!,
      onPressed: onAction,
      fullWidth: false,
      size: AppButtonSize.medium,
    );
  }

  Widget _buildSecondaryAction() {
    return TextButton(
      onPressed: onSecondaryAction,
      child: Text(
        secondaryActionLabel!,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Preset empty state variants for common use cases.
class EmptyStateVariants {
  EmptyStateVariants._();

  /// No projects empty state.
  static EmptyState noProjects({
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.folder_outlined,
      title: 'No Projects Yet',
      subtitle: 'Create your first project to get started with AssignX.',
      actionLabel: 'Create Project',
      onAction: onAction,
    );
  }

  /// No messages empty state.
  static EmptyState noMessages({
    VoidCallback? onAction,
  }) {
    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'No Messages',
      subtitle: 'Your conversation inbox is empty. Messages will appear here.',
      actionLabel: onAction != null ? 'Start Chat' : null,
      onAction: onAction,
    );
  }

  /// No notifications empty state.
  static EmptyState noNotifications() {
    return const EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'All Caught Up!',
      subtitle: 'You have no new notifications at this time.',
    );
  }

  /// No search results empty state.
  static EmptyState noSearchResults({
    String? searchQuery,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No Results Found',
      subtitle: searchQuery != null
          ? 'No results found for "$searchQuery". Try a different search term.'
          : 'No results match your search criteria.',
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }

  /// Network error empty state.
  static EmptyState networkError({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.wifi_off_outlined,
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.errorLight,
      title: 'Connection Error',
      subtitle: 'Unable to connect to the server. Please check your internet connection.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Generic error empty state.
  static EmptyState error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.errorLight,
      title: 'Something Went Wrong',
      subtitle: message ?? 'An unexpected error occurred. Please try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// No files/attachments empty state.
  static EmptyState noFiles({
    VoidCallback? onUpload,
  }) {
    return EmptyState(
      icon: Icons.attach_file_outlined,
      title: 'No Files',
      subtitle: 'No files have been attached yet.',
      actionLabel: onUpload != null ? 'Upload File' : null,
      onAction: onUpload,
    );
  }

  /// Empty wallet state.
  static EmptyState emptyWallet({
    VoidCallback? onTopUp,
  }) {
    return EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Wallet Empty',
      subtitle: 'Add funds to your wallet to make purchases.',
      actionLabel: 'Top Up',
      onAction: onTopUp,
    );
  }

  /// No favorites/bookmarks.
  static EmptyState noFavorites({
    VoidCallback? onBrowse,
  }) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'No Favorites',
      subtitle: 'Items you favorite will appear here.',
      actionLabel: onBrowse != null ? 'Browse Items' : null,
      onAction: onBrowse,
    );
  }

  /// Maintenance/coming soon.
  static EmptyState comingSoon({
    String? feature,
  }) {
    return EmptyState(
      icon: Icons.construction_outlined,
      iconColor: AppColors.warning,
      iconBackgroundColor: AppColors.warningLight,
      title: 'Coming Soon',
      subtitle: feature != null
          ? '$feature is under development. Check back soon!'
          : 'This feature is under development. Check back soon!',
    );
  }
}

/// Animated illustration empty state with Lottie support.
class IllustratedEmptyState extends StatelessWidget {
  /// Lottie or image asset path.
  final String? assetPath;

  /// Fallback icon if asset fails.
  final IconData fallbackIcon;

  /// Main title text.
  final String title;

  /// Subtitle/description.
  final String? subtitle;

  /// Optional action button label.
  final String? actionLabel;

  /// Action button callback.
  final VoidCallback? onAction;

  /// Illustration size. Default is 200.
  final double illustrationSize;

  /// Padding around the widget.
  final EdgeInsetsGeometry padding;

  const IllustratedEmptyState({
    super.key,
    this.assetPath,
    this.fallbackIcon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.illustrationSize = 200,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: _buildIllustration(),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildIllustration() {
    // If no asset provided, use icon
    if (assetPath == null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          fallbackIcon,
          size: illustrationSize * 0.4,
          color: AppColors.textTertiary,
        ),
      );
    }

    // Try to load the asset
    if (assetPath!.endsWith('.json')) {
      // Lottie animation - return placeholder for now
      // Can be replaced with Lottie.asset when needed
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          fallbackIcon,
          size: illustrationSize * 0.4,
          color: AppColors.textTertiary,
        ),
      );
    }

    // Image asset
    return Image.asset(
      assetPath!,
      width: illustrationSize,
      height: illustrationSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            fallbackIcon,
            size: illustrationSize * 0.4,
            color: AppColors.textTertiary,
          ),
        );
      },
    );
  }
}

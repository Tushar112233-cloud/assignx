/// Application header widgets for navigation and branding.
///
/// This file provides header components used across the dashboard
/// including the main app header, logo, notification bell, and inner screen headers.
///
/// ## Features
/// - Main app header with menu, logo, and notifications
/// - App logo with gradient styling
/// - Notification bell with badge count
/// - Inner screen header with back navigation
///
/// ## Example
/// ```dart
/// AppHeader(
///   onMenuTap: () => Scaffold.of(context).openDrawer(),
///   onNotificationTap: () => navigateToNotifications(),
///   notificationCount: 5,
/// )
/// ```
///
/// See also:
/// - [AppDrawer] for the navigation drawer
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Main application header widget with navigation controls.
///
/// Displays the app logo, menu button, and notification bell in a
/// consistent header bar with shadow styling.
///
/// ## Usage
/// ```dart
/// AppHeader(
///   onMenuTap: () => Scaffold.of(context).openDrawer(),
///   onNotificationTap: () => navigateToNotifications(),
///   notificationCount: 5,
/// )
/// ```
///
/// ## Layout
/// - Left: Menu hamburger button
/// - Center: App logo
/// - Right: Notification bell with badge
///
/// See also:
/// - [AppLogo] for the logo component
/// - [NotificationBell] for the notification indicator
class AppHeader extends ConsumerWidget {
  /// Creates an app header with the specified properties.
  const AppHeader({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  /// Callback invoked when the menu button is tapped.
  ///
  /// Typically opens the navigation drawer.
  final VoidCallback? onMenuTap;

  /// Callback invoked when the notification bell is tapped.
  ///
  /// Typically navigates to the notifications screen.
  final VoidCallback? onNotificationTap;

  /// The number of unread notifications to display.
  ///
  /// When > 0, shows a badge on the notification bell.
  /// Displays "99+" for counts over 99.
  final int notificationCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Menu button
            IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu),
              color: AppColors.textPrimary,
              tooltip: 'Menu',
            ),

            const SizedBox(width: AppSpacing.sm),

            // Logo
            const AppLogo(),

            const Spacer(),

            // Notification bell with badge
            NotificationBell(
              count: notificationCount,
              onTap: onNotificationTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// App logo widget with gradient styling.
///
/// Displays the DOER logo with a gradient background and optional
/// text label. Used in headers, drawers, and splash screens.
///
/// ## Usage
/// ```dart
/// AppLogo(size: 32, showText: true)
/// AppLogo(size: 24, showText: false) // Icon only
/// ```
///
/// ## Customization
/// - [size]: Controls the logo icon dimensions
/// - [showText]: Whether to show the "DOER" text label
class AppLogo extends StatelessWidget {
  /// Creates an app logo with the specified properties.
  const AppLogo({
    super.key,
    this.size = 32,
    this.showText = true,
  });

  /// The size of the logo icon in logical pixels.
  ///
  /// The text size scales proportionally.
  /// Defaults to 32.
  final double size;

  /// Whether to display the "DOER" text next to the icon.
  ///
  /// Defaults to true.
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Center(
            child: Text(
              'D',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          const Text(
            'DOER',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}

/// Notification bell widget with badge indicator.
///
/// Displays a notification icon that shows a badge when there are
/// unread notifications. The icon style changes based on count.
///
/// ## Usage
/// ```dart
/// NotificationBell(
///   count: 5,
///   onTap: () => navigateToNotifications(),
/// )
/// ```
///
/// ## Badge Display
/// - 0: Outlined bell icon, no badge
/// - 1-99: Filled bell icon, badge with count
/// - 100+: Filled bell icon, badge shows "99+"
class NotificationBell extends StatelessWidget {
  /// Creates a notification bell with the specified properties.
  const NotificationBell({
    super.key,
    this.count = 0,
    this.onTap,
  });

  /// The number of unread notifications.
  ///
  /// Displayed as a badge when > 0.
  final int count;

  /// Callback invoked when the bell is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(
            count > 0 ? Icons.notifications : Icons.notifications_outlined,
            color: count > 0 ? AppColors.primary : AppColors.textSecondary,
          ),
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Header for inner screens with back navigation.
///
/// Provides a consistent header for sub-pages with a back button,
/// title, and optional action buttons.
///
/// ## Usage
/// ```dart
/// InnerHeader(
///   title: 'Project Details',
///   onBack: () => Navigator.pop(context),
///   actions: [
///     IconButton(icon: Icon(Icons.edit), onPressed: editProject),
///   ],
/// )
/// ```
///
/// See also:
/// - [AppHeader] for the main dashboard header
class InnerHeader extends StatelessWidget {
  /// Creates an inner header with the specified properties.
  ///
  /// [title] is required.
  const InnerHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  /// The title text displayed in the header.
  final String title;

  /// Callback invoked when the back button is tapped.
  ///
  /// If null, uses [Navigator.pop].
  final VoidCallback? onBack;

  /// Optional action widgets displayed on the right side.
  ///
  /// Typically icon buttons for edit, share, etc.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

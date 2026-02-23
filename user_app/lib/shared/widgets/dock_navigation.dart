import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

/// A dock navigation item representing a single navigation destination.
///
/// Each item has an icon, label, and route for navigation.
/// Items can be marked as FAB (Floating Action Button) for special actions.
///
/// Example:
/// ```dart
/// DockItem(
///   icon: Icons.home,
///   label: 'Home',
///   route: '/home',
/// )
/// ```
class DockItem {
  /// The icon to display in the dock.
  final IconData icon;

  /// The active icon to display when selected (optional).
  final IconData? activeIcon;

  /// The label for the item (shown in tooltip).
  final String label;

  /// The navigation route for this item.
  final String? route;

  /// Callback when item is tapped (for FAB items).
  final VoidCallback? onTap;

  /// Whether this item is a FAB (Floating Action Button).
  final bool isFab;

  /// Optional custom color for the active state.
  final Color? activeColor;

  /// Optional badge count to display.
  final int? badgeCount;

  /// Creates a standard dock item.
  const DockItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.route,
    this.onTap,
    this.activeColor,
    this.badgeCount,
  }) : isFab = false;

  /// Creates a FAB (center action button) dock item.
  const DockItem.fab({
    required this.icon,
    this.label = 'Add',
    required this.onTap,
    this.activeColor,
  })  : activeIcon = null,
        route = null,
        isFab = true,
        badgeCount = null;
}

/// A visual separator between dock items.
///
/// Use this to group related items visually.
class DockSeparator extends StatelessWidget {
  /// Height of the separator line.
  final double height;

  /// Width of the separator line.
  final double width;

  /// Color of the separator.
  final Color? color;

  const DockSeparator({
    super.key,
    this.height = 24,
    this.width = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color ??
            (isDark
                ? Colors.white.withAlpha(30)
                : Colors.black.withAlpha(20)),
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}

/// A tooltip that appears above dock items on long press.
///
/// Displays the item label with a subtle animation.
class DockTooltip extends StatelessWidget {
  /// The label text to display.
  final String label;

  /// Whether the tooltip is visible.
  final bool visible;

  const DockTooltip({
    super.key,
    required this.label,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.5),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : AppColors.textPrimary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A macOS-style dock navigation bar with glass morphism effect.
///
/// Features:
/// - Glass morphism background with blur and saturation
/// - Icon magnification on hover/press
/// - Spring animations for tap feedback
/// - Active indicator with smooth transitions
/// - Tooltips on long press
/// - Support for FAB (center action button)
/// - Separators for grouping items
///
/// Example:
/// ```dart
/// DockNavigation(
///   items: [
///     DockItem(icon: Icons.home, label: 'Home', route: '/home'),
///     DockItem(icon: Icons.folder, label: 'Projects', route: '/projects'),
///     DockItem.fab(icon: Icons.add, onTap: () {}),
///     DockItem(icon: Icons.store, label: 'Connect', route: '/marketplace'),
///     DockItem(icon: Icons.person, label: 'Profile', route: '/profile'),
///   ],
///   currentRoute: '/home',
///   onItemTap: (route) => context.go(route),
/// )
/// ```
class DockNavigation extends StatefulWidget {
  /// The list of dock items to display.
  final List<DockItem> items;

  /// The current active route for highlighting.
  final String currentRoute;

  /// Callback when a navigation item is tapped.
  final void Function(String route) onItemTap;

  /// Bottom margin from screen edge.
  final double bottomMargin;

  /// Whether to show labels below icons.
  final bool showLabels;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  const DockNavigation({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onItemTap,
    this.bottomMargin = 16,
    this.showLabels = false,
    this.enableHaptics = true,
  });

  @override
  State<DockNavigation> createState() => _DockNavigationState();
}

class _DockNavigationState extends State<DockNavigation> {
  /// Track which item is being pressed for magnification.
  int? _pressedIndex;

  /// Track which item is showing tooltip.
  int? _tooltipIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottomMargin + bottomPadding,
      child: Center(
        child: _buildDockContainer(isDark),
      ),
    );
  }

  Widget _buildDockContainer(bool isDark) {
    // Always use dark/black navbar regardless of theme
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withAlpha(240), // Dark/black navbar
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(15),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildDockItems(true), // Always use dark mode styling for icons
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDockItems(bool isDark) {
    final items = <Widget>[];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      if (item.isFab) {
        items.add(_buildFabItem(item, i, isDark));
      } else {
        items.add(_buildNavItem(item, i, isDark));
      }
    }

    return items;
  }

  Widget _buildNavItem(DockItem item, int index, bool isDark) {
    final isActive = item.route == widget.currentRoute;
    final isPressed = _pressedIndex == index;
    final showTooltip = _tooltipIndex == index;

    // Calculate scale based on press state
    final scale = isPressed ? 1.15 : 1.0;

    return GestureDetector(
      onTapDown: (_) => _onItemPressStart(index),
      onTapUp: (_) => _onItemPressEnd(index, item),
      onTapCancel: () => _onItemPressCancel(),
      onLongPress: () => _onItemLongPress(index),
      onLongPressEnd: (_) => _onItemLongPressEnd(),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: item.label,
        selected: isActive,
        hint: isActive
            ? 'Currently selected'
            : 'Double tap to navigate to ${item.label}',
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Tooltip positioned above
            Positioned(
              bottom: 56,
              child: DockTooltip(
                label: item.label,
                visible: showTooltip,
              ),
            ),
            // Item container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: const _SpringCurve(),
              transform: Matrix4.diagonal3Values(scale, scale, 1.0),
              transformAlignment: Alignment.center,
              child: Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Active indicator background - subtle white glow on dark navbar
                    AnimatedScale(
                      scale: isActive ? 1.0 : 0.85,
                      duration: const Duration(milliseconds: 250),
                      curve: const _SpringCurve(),
                      child: AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30), // Subtle white glow
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Icon - white/light for dark navbar
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isActive
                            ? (item.activeIcon ?? item.icon)
                            : item.icon,
                        key: ValueKey(isActive),
                        size: 24,
                        color: isActive
                            ? (item.activeColor ?? Colors.white)
                            : Colors.white.withAlpha(150), // Light gray/white for inactive
                      ),
                    ),
                    // Badge
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: _buildBadge(item.badgeCount!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabItem(DockItem item, int index, bool isDark) {
    final isPressed = _pressedIndex == index;
    final scale = isPressed ? 1.1 : 1.0;

    return GestureDetector(
      onTapDown: (_) => _onItemPressStart(index),
      onTapUp: (_) {
        _onItemPressCancel();
        item.onTap?.call();
        if (widget.enableHaptics) {
          HapticFeedback.mediumImpact();
        }
      },
      onTapCancel: () => _onItemPressCancel(),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: item.label,
        hint: 'Double tap to ${item.label.toLowerCase()}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const _SpringCurve(),
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          transformAlignment: Alignment.center,
          child: Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.activeColor ?? AppColors.primary,
                  (item.activeColor ?? AppColors.primary).withAlpha(200),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (item.activeColor ?? AppColors.primary).withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onItemPressStart(int index) {
    setState(() => _pressedIndex = index);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _onItemPressEnd(int index, DockItem item) {
    setState(() => _pressedIndex = null);

    if (item.route != null && item.route != widget.currentRoute) {
      widget.onItemTap(item.route!);
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _onItemPressCancel() {
    setState(() => _pressedIndex = null);
  }

  void _onItemLongPress(int index) {
    setState(() => _tooltipIndex = index);
    if (widget.enableHaptics) {
      HapticFeedback.heavyImpact();
    }
  }

  void _onItemLongPressEnd() {
    setState(() => _tooltipIndex = null);
  }
}

/// A custom spring curve for smooth, bouncy animations.
///
/// Uses a critically damped spring simulation for natural feel.
class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Custom cubic bezier approximation of spring: cubic-bezier(0.34, 1.56, 0.64, 1)
    final double p1 = 0.34;
    final double p2 = 1.56;
    final double p3 = 0.64;
    final double p4 = 1.0;

    // De Casteljau's algorithm for cubic Bezier
    double bezier(double p0, double p1, double p2, double p3, double t) {
      final double u = 1 - t;
      final double tt = t * t;
      final double uu = u * u;
      final double uuu = uu * u;
      final double ttt = tt * t;

      double p = uuu * p0;
      p += 3 * uu * t * p1;
      p += 3 * u * tt * p2;
      p += ttt * p3;

      return p;
    }

    // Find the x value for the given t using Newton-Raphson method
    double sampleCurveX(double t) {
      return bezier(0, p1, p3, 1, t);
    }

    double sampleCurveY(double t) {
      return bezier(0, p2, p4, 1, t);
    }

    // Binary search to find t for given x
    double solveCurveX(double x, double epsilon) {
      double t2 = x;
      for (int i = 0; i < 8; i++) {
        final double x2 = sampleCurveX(t2) - x;
        if (x2.abs() < epsilon) return t2;
        final double d2 = (sampleCurveX(t2 + 0.001) - sampleCurveX(t2 - 0.001)) / 0.002;
        if (d2.abs() < 1e-6) break;
        t2 = t2 - x2 / d2;
      }

      // Fallback to binary search
      double t0 = 0.0;
      double t1 = 1.0;
      t2 = x;

      while (t0 < t1) {
        final double x2 = sampleCurveX(t2);
        if ((x2 - x).abs() < epsilon) return t2;
        if (x > x2) {
          t0 = t2;
        } else {
          t1 = t2;
        }
        t2 = (t1 - t0) * 0.5 + t0;
      }

      return t2;
    }

    final double solvedT = solveCurveX(t, 1e-6);
    return sampleCurveY(solvedT).clamp(0.0, 1.0);
  }
}

/// A wrapper widget that positions the dock at the bottom of the screen.
///
/// Use this as a layer in your Stack or with a Scaffold's body.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     // Your main content
///     Scaffold(body: ...),
///     // Dock navigation overlay
///     DockNavigationOverlay(
///       items: [...],
///       currentRoute: '/home',
///       onItemTap: (route) => context.go(route),
///     ),
///   ],
/// )
/// ```
class DockNavigationOverlay extends StatelessWidget {
  /// The list of dock items to display.
  final List<DockItem> items;

  /// The current active route for highlighting.
  final String currentRoute;

  /// Callback when a navigation item is tapped.
  final void Function(String route) onItemTap;

  /// Bottom margin from screen edge.
  final double bottomMargin;

  /// Whether to show labels below icons.
  final bool showLabels;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  const DockNavigationOverlay({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onItemTap,
    this.bottomMargin = 16,
    this.showLabels = false,
    this.enableHaptics = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DockNavigation(
          items: items,
          currentRoute: currentRoute,
          onItemTap: onItemTap,
          bottomMargin: bottomMargin,
          showLabels: showLabels,
          enableHaptics: enableHaptics,
        ),
      ],
    );
  }
}

/// A helper widget for creating a scaffold with dock navigation.
///
/// Provides a convenient way to add dock navigation to any page.
///
/// Example:
/// ```dart
/// DockScaffold(
///   items: [...],
///   currentRoute: '/home',
///   onItemTap: (route) => context.go(route),
///   body: YourPageContent(),
/// )
/// ```
class DockScaffold extends StatelessWidget {
  /// The main content of the scaffold.
  final Widget body;

  /// The list of dock items to display.
  final List<DockItem> items;

  /// The current active route for highlighting.
  final String currentRoute;

  /// Callback when a navigation item is tapped.
  final void Function(String route) onItemTap;

  /// Bottom margin from screen edge.
  final double bottomMargin;

  /// Whether to show labels below icons.
  final bool showLabels;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;

  /// Optional app bar.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Background color of the scaffold.
  final Color? backgroundColor;

  /// Whether to extend body behind the app bar.
  final bool extendBodyBehindAppBar;

  /// Whether to resize to avoid bottom inset.
  final bool resizeToAvoidBottomInset;

  const DockScaffold({
    super.key,
    required this.body,
    required this.items,
    required this.currentRoute,
    required this.onItemTap,
    this.bottomMargin = 16,
    this.showLabels = false,
    this.enableHaptics = true,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to account for dock height
    final dockHeight = 60.0 + bottomMargin + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Main content with bottom padding for dock
          Padding(
            padding: EdgeInsets.only(bottom: dockHeight),
            child: body,
          ),
          // Dock navigation
          DockNavigation(
            items: items,
            currentRoute: currentRoute,
            onItemTap: onItemTap,
            bottomMargin: bottomMargin,
            showLabels: showLabels,
            enableHaptics: enableHaptics,
          ),
        ],
      ),
    );
  }
}

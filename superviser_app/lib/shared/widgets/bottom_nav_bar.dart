/// Floating pill-shaped bottom navigation bar for the supervisor app.
///
/// Features:
/// - Floating pill shape (height 60, borderRadius 30)
/// - Solid dark background (#1A1A1A)
/// - 4 navigation items: Dashboard, Projects, Chat, Profile
/// - Active icon: white, Inactive: #8A8A8A
/// - Profile item shows avatar circle with border
/// - Optional notification badge on Dashboard tab
/// - Designed to be placed inside a Stack via Positioned
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     child,
///     BottomNavBar(
///       currentIndex: 0,
///       onTap: (index) => handleNavigation(index),
///       dashboardBadgeCount: 3,
///     ),
///   ],
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// Floating pill-shaped bottom navigation bar.
class BottomNavBar extends StatelessWidget {
  /// Currently selected index.
  final int currentIndex;

  /// Callback when navigation item is tapped.
  final ValueChanged<int> onTap;

  /// Profile avatar URL (optional).
  final String? profileImageUrl;

  /// Bottom offset from screen edge. Defaults to 20px.
  final double bottomOffset;

  /// Horizontal padding. Defaults to 16px.
  final double horizontalPadding;

  /// Unread notification badge count for the Dashboard tab.
  final int dashboardBadgeCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.bottomOffset = 20,
    this.horizontalPadding = 16,
    this.dashboardBadgeCount = 0,
  });

  // Solid dark navbar colors
  static const Color _navBackground = Color(0xFF1A1A1A);
  static const Color _activeIconColor = Colors.white;
  static const Color _inactiveIconColor = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: bottomOffset,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _navBackground,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 0: Dashboard
            _buildNavItem(
              activeIcon: Icons.dashboard_rounded,
              inactiveIcon: Icons.dashboard_outlined,
              index: 0,
              badgeCount: dashboardBadgeCount,
            ),
            // 1: Projects
            _buildNavItem(
              activeIcon: Icons.folder_rounded,
              inactiveIcon: Icons.folder_outlined,
              index: 1,
            ),
            // 2: Chat
            _buildNavItem(
              activeIcon: Icons.chat_bubble_rounded,
              inactiveIcon: Icons.chat_bubble_outline,
              index: 2,
            ),
            // 3: Profile (avatar)
            _buildProfileItem(index: 3),
          ],
        ),
      ),
    );
  }

  /// Builds a single navigation item with icon only.
  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required int index,
    int badgeCount = 0,
  }) {
    final isActive = currentIndex == index;

    Widget iconWidget = Icon(
      isActive ? activeIcon : inactiveIcon,
      size: 24,
      color: isActive ? _activeIconColor : _inactiveIconColor,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : badgeCount.toString(),
          style: const TextStyle(fontSize: 10),
        ),
        child: iconWidget,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: iconWidget,
        ),
      ),
    );
  }

  /// Builds the profile avatar item.
  Widget _buildProfileItem({required int index}) {
    final isActive = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? _activeIconColor : _inactiveIconColor,
                width: isActive ? 2 : 1.5,
              ),
              image: profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: profileImageUrl == null ? const Color(0xFF3A3A3A) : null,
            ),
            child: profileImageUrl == null
                ? const Icon(
                    Icons.person,
                    size: 16,
                    color: _inactiveIconColor,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

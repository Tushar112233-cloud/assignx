import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Floating pill-shaped bottom navigation bar for the doer app.
///
/// Features:
/// - Floating pill shape (height 60, borderRadius 30)
/// - Solid dark background (#1A1A1A)
/// - 5 navigation items: Dashboard, Projects, Resources, Earnings, Profile
/// - Active icon: white, Inactive: #8A8A8A
/// - Profile item shows avatar circle with border
/// - Designed to be placed inside a Stack via Positioned
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     IndexedStack(...),
///     BottomNavBar(
///       currentIndex: 0,
///       onTap: (index) => handleNavigation(index),
///     ),
///   ],
/// )
/// ```
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

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.bottomOffset = 20,
    this.horizontalPadding = 16,
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
              activeIcon: LucideIcons.layoutDashboard,
              inactiveIcon: LucideIcons.layoutDashboard,
              index: 0,
            ),
            // 1: Projects
            _buildNavItem(
              activeIcon: LucideIcons.folderClosed,
              inactiveIcon: LucideIcons.folder,
              index: 1,
            ),
            // 2: Resources
            _buildNavItem(
              activeIcon: LucideIcons.bookOpen,
              inactiveIcon: LucideIcons.bookOpen,
              index: 2,
            ),
            // 3: Earnings
            _buildNavItem(
              activeIcon: LucideIcons.wallet,
              inactiveIcon: LucideIcons.wallet,
              index: 3,
            ),
            // 4: Profile (avatar)
            _buildProfileItem(index: 4),
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
  }) {
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
          child: Icon(
            isActive ? activeIcon : inactiveIcon,
            size: 24,
            color: isActive ? _activeIconColor : _inactiveIconColor,
          ),
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
              color: profileImageUrl == null
                  ? const Color(0xFF3A3A3A)
                  : null,
            ),
            child: profileImageUrl == null
                ? const Icon(
                    LucideIcons.user,
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

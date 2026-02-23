import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';

/// Custom bottom navigation bar with floating pill design.
///
/// Features:
/// - Floating pill-shaped bar (not docked to edge)
/// - Dark background with subtle shadow
/// - 6 navigation items: Home, Projects, Campus Connect, Experts, Wallet, Profile
/// - Active state: filled icon (white), Inactive: outlined icon (gray)
/// - Profile item shows avatar
/// - Settings accessible from Profile screen
///
/// Example:
/// ```dart
/// BottomNavBar(
///   currentIndex: 0,
///   onTap: (index) => handleNavigation(index),
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

  // Dark/black navbar colors
  static const Color _navBackground = Color(0xFF1A1A1A);
  static const Color _activeIconColor = Colors.white;
  static const Color _inactiveIconColor = Color(0xFF8A8A8A); // Light gray

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
          // Dark/black background for navbar
          color: _navBackground,
          borderRadius: BorderRadius.circular(30), // Stadium shape
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
            // 0: Home (Dashboard)
            _buildNavItem(
              activeIcon: LucideIcons.home,
              inactiveIcon: LucideIcons.home,
              index: 0,
            ),
            // 1: Projects
            _buildNavItem(
              activeIcon: LucideIcons.folderClosed,
              inactiveIcon: LucideIcons.folder,
              index: 1,
            ),
            // 2: Campus Connect (Community/People)
            _buildNavItem(
              activeIcon: LucideIcons.users,
              inactiveIcon: LucideIcons.users,
              index: 2,
            ),
            // 3: Experts (stethoscope for doctors focus)
            _buildNavItem(
              activeIcon: LucideIcons.stethoscope,
              inactiveIcon: LucideIcons.stethoscope,
              index: 3,
            ),
            // 4: Wallet
            _buildNavItem(
              activeIcon: LucideIcons.wallet,
              inactiveIcon: LucideIcons.wallet,
              index: 4,
            ),
            // 5: Profile (avatar) - Settings moved inside profile
            _buildProfileItem(index: 5),
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
            color: isActive
                ? _activeIconColor // White for active
                : _inactiveIconColor, // Light gray for inactive
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
                color: isActive
                    ? _activeIconColor // White border when active
                    : _inactiveIconColor, // Gray border when inactive
                width: isActive ? 2 : 1.5,
              ),
              image: profileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: profileImageUrl == null
                  ? const Color(0xFF3A3A3A) // Dark gray placeholder
                  : null,
            ),
            child: profileImageUrl == null
                ? Icon(
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

/// Alternative bottom navigation bar with indicator dot style.
///
/// Features:
/// - Minimalist design with small dot indicator
/// - Icon-only layout with subtle labels
/// - Glass effect background
///
/// Example:
/// ```dart
/// BottomNavBarDotIndicator(
///   currentIndex: 0,
///   onTap: (index) => handleNavigation(index),
/// )
/// ```
class BottomNavBarDotIndicator extends StatelessWidget {
  /// Currently selected index.
  final int currentIndex;

  /// Callback when navigation item is tapped.
  final ValueChanged<int> onTap;

  /// Bottom offset from screen edge. Defaults to 40px.
  final double bottomOffset;

  /// Horizontal padding. Defaults to 20px.
  final double horizontalPadding;

  const BottomNavBarDotIndicator({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.bottomOffset = 40,
    this.horizontalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: bottomOffset,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDotNavItem(
                icon: LucideIcons.home,
                index: 0,
              ),
              _buildDotNavItem(
                icon: LucideIcons.folder,
                index: 1,
              ),
              _buildDotNavItem(
                icon: LucideIcons.wallet,
                index: 2,
              ),
              _buildDotNavItem(
                icon: LucideIcons.user,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single navigation item with dot indicator.
  Widget _buildDotNavItem({
    required IconData icon,
    required int index,
  }) {
    final isActive = currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                icon,
                size: 26,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(height: 4),
              // Dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: isActive ? 6 : 0,
                height: isActive ? 6 : 0,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

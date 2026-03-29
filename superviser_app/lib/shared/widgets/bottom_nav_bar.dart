/// Floating bottom navigation bar for the supervisor app.
///
/// Features:
/// - White background with rounded corners (borderRadius: 24)
/// - Subtle border and shadow
/// - 5 navigation items with labels: Dashboard, Projects, Chat, Earnings, Profile
/// - Active: primary color icon + label + animated orange indicator dot above icon
/// - Inactive: tertiary text color icons + labels
/// - Profile item shows avatar circle
/// - Optional notification badge on Dashboard tab
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

import '../../core/theme/app_colors.dart';

/// Floating bottom navigation bar with white pill design.
class BottomNavBar extends StatelessWidget {
  /// Currently selected index.
  final int currentIndex;

  /// Callback when navigation item is tapped.
  final ValueChanged<int> onTap;

  /// Profile avatar URL (optional).
  final String? profileImageUrl;

  /// Bottom offset from screen edge. Defaults to 16px.
  final double bottomOffset;

  /// Horizontal padding. Defaults to 12px.
  final double horizontalPadding;

  /// Unread notification badge count for the Dashboard tab.
  final int dashboardBadgeCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.bottomOffset = 16,
    this.horizontalPadding = 12,
    this.dashboardBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navHeight = screenWidth < 360 ? 64.0 : 72.0;

    return Positioned(
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: bottomOffset,
      child: Container(
        height: navHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 0: Dashboard
            Expanded(
              child: _NavItem(
                activeIcon: Icons.dashboard_rounded,
                inactiveIcon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                badgeCount: dashboardBadgeCount,
              ),
            ),
            // 1: Projects
            Expanded(
              child: _NavItem(
                activeIcon: Icons.folder_rounded,
                inactiveIcon: Icons.folder_outlined,
                label: 'Projects',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            // 2: Chat
            Expanded(
              child: _NavItem(
                activeIcon: Icons.chat_bubble_rounded,
                inactiveIcon: Icons.chat_bubble_outline,
                label: 'Chat',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            // 3: Earnings
            Expanded(
              child: _NavItem(
                activeIcon: Icons.account_balance_wallet_rounded,
                inactiveIcon: Icons.account_balance_wallet_outlined,
                label: 'Earnings',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ),
            // 4: Profile (avatar)
            Expanded(
              child: _ProfileNavItem(
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
                imageUrl: profileImageUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single navigation item with icon, label, and active indicator.
class _NavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiaryLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 18.0 : 22.0;
    final fontSize = screenWidth < 360 ? 9.0 : 10.0;

    Widget iconWidget = Icon(
      isActive ? activeIcon : inactiveIcon,
      size: iconSize,
      color: color,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated orange indicator dot above icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 20 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              iconWidget,
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile avatar navigation item with label and active indicator.
class _ProfileNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String? imageUrl;

  const _ProfileNavItem({
    required this.isActive,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiaryLight;
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth < 360 ? 20.0 : 24.0;
    final iconSize = screenWidth < 360 ? 11.0 : 13.0;
    final fontSize = screenWidth < 360 ? 9.0 : 10.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated orange indicator dot above avatar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 20 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.borderLight,
                    width: isActive ? 2 : 1.5,
                  ),
                  image: imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: (imageUrl == null || imageUrl!.isEmpty) ? AppColors.surfaceVariantLight : null,
                ),
                child: (imageUrl == null || imageUrl!.isEmpty || !imageUrl!.startsWith('http'))
                    ? Icon(
                        Icons.person,
                        size: iconSize,
                        color: color,
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

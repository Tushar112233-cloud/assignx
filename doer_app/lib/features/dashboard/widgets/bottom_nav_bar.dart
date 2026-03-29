import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';

/// Clean, modern bottom navigation bar matching the doer-web sidebar aesthetic.
///
/// Features:
/// - White frosted glass background with subtle shadow
/// - 5 navigation items with labels: Dashboard, Projects, Resources, Earnings, Profile
/// - Active: primary color icon + label + top indicator line
/// - Inactive: muted gray icons + labels
/// - Profile item shows avatar circle
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? profileImageUrl;
  final double bottomOffset;
  final double horizontalPadding;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.profileImageUrl,
    this.bottomOffset = 16,
    this.horizontalPadding = 12,
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
            color: AppColors.border.withValues(alpha: 0.5),
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
            Expanded(
              child: _NavItem(
                icon: LucideIcons.layoutDashboard,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.folderClosed,
                label: 'Projects',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.bookOpen,
                label: 'Resources',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: LucideIcons.wallet,
                label: 'Earnings',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 18.0 : 22.0;
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
              // Active indicator dot
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
              Icon(
                icon,
                size: iconSize,
                color: color,
              ),
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
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
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
              // Active indicator dot
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
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 2 : 1.5,
                  ),
                  image: imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: (imageUrl == null || imageUrl!.isEmpty)
                      ? AppColors.surfaceVariant
                      : null,
                ),
                child: (imageUrl == null || imageUrl!.isEmpty || !imageUrl!.startsWith('http'))
                    ? Icon(
                        LucideIcons.user,
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

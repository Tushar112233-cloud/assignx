import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';

/// Filter categories for Campus Connect.
enum CampusConnectCategory {
  all('All', Icons.dashboard_outlined),
  questions('Questions', Icons.help_outline),
  housing('Housing', Icons.home_outlined),
  opportunities('Opportunities', Icons.work_outline),
  events('Events', Icons.event_outlined),
  marketplace('Marketplace', Icons.shopping_bag_outlined),
  resources('Resources', Icons.menu_book_outlined),
  lostFound('Lost & Found', Icons.search),
  rides('Rides', Icons.directions_car_outlined),
  studyGroups('Study Groups', Icons.groups_outlined),
  clubs('Clubs', Icons.emoji_events_outlined),
  announcements('Announcements', Icons.campaign_outlined),
  discussions('Discussions', Icons.chat_bubble_outline),
  // Legacy categories kept for backwards compatibility
  community('Community', Icons.people_outline),
  products('Products', Icons.shopping_bag_outlined),
  saved('Saved', Icons.bookmark_outline);

  final String label;
  final IconData icon;

  const CampusConnectCategory(this.label, this.icon);
}

/// Icon-only color — used for the small gradient icon container on each pill.
/// The pill itself stays coffee brown when selected.
Color getCategoryIconColor(CampusConnectCategory category) {
  switch (category) {
    case CampusConnectCategory.all:
      return AppColors.primary;
    case CampusConnectCategory.questions:
      return const Color(0xFF6366F1);
    case CampusConnectCategory.housing:
      return const Color(0xFFF59E0B);
    case CampusConnectCategory.opportunities:
      return const Color(0xFF10B981);
    case CampusConnectCategory.events:
      return const Color(0xFFEC4899);
    case CampusConnectCategory.marketplace:
      return const Color(0xFF3B82F6);
    case CampusConnectCategory.resources:
      return const Color(0xFF8B5CF6);
    case CampusConnectCategory.lostFound:
      return const Color(0xFFEF4444);
    case CampusConnectCategory.rides:
      return const Color(0xFF14B8A6);
    case CampusConnectCategory.studyGroups:
      return const Color(0xFF0EA5E9);
    case CampusConnectCategory.clubs:
      return const Color(0xFFF97316);
    case CampusConnectCategory.announcements:
      return const Color(0xFFDC2626);
    case CampusConnectCategory.discussions:
      return const Color(0xFF6366F1);
    case CampusConnectCategory.community:
      return const Color(0xFF8B5CF6);
    case CampusConnectCategory.products:
      return const Color(0xFF3B82F6);
    case CampusConnectCategory.saved:
      return const Color(0xFFF59E0B);
  }
}

/// Horizontal filter tabs bar — coffee brown selected state,
/// colorful icon pops (like wallet page style).
class FilterTabsBar extends StatelessWidget {
  final CampusConnectCategory? selectedCategory;
  final Function(CampusConnectCategory?) onCategoryChanged;
  final bool isStudent;

  const FilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.isStudent = true,
  });

  static const List<CampusConnectCategory> webStyleCategories = [
    CampusConnectCategory.all,
    CampusConnectCategory.questions,
    CampusConnectCategory.housing,
    CampusConnectCategory.opportunities,
    CampusConnectCategory.events,
    CampusConnectCategory.marketplace,
    CampusConnectCategory.resources,
    CampusConnectCategory.lostFound,
    CampusConnectCategory.rides,
    CampusConnectCategory.studyGroups,
    CampusConnectCategory.clubs,
    CampusConnectCategory.announcements,
    CampusConnectCategory.discussions,
  ];

  static const List<CampusConnectCategory> featuredCategories = [
    CampusConnectCategory.questions,
    CampusConnectCategory.housing,
    CampusConnectCategory.opportunities,
    CampusConnectCategory.events,
    CampusConnectCategory.marketplace,
    CampusConnectCategory.resources,
  ];

  @override
  Widget build(BuildContext context) {
    final availableCategories = webStyleCategories.where((category) {
      if (category == CampusConnectCategory.housing && !isStudent) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: availableCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                right: index < availableCategories.length - 1 ? 6 : 0),
            child: _FilterPill(
              icon: category.icon,
              label: category.label.tr(context),
              isSelected: selectedCategory == category,
              iconColor: getCategoryIconColor(category),
              onTap: () => onCategoryChanged(
                selectedCategory == category ? null : category,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Filter pill — coffee brown when selected, colorful icon pop only.
class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon gets the pop of color
            Icon(
              icon,
              size: 15,
              color: isSelected ? iconColor : AppColors.textTertiary,
            ),
            const SizedBox(width: 5),
            // Text stays coffee brown
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced filter tabs bar with badge counts.
class EnhancedFilterTabsBar extends StatelessWidget {
  final CampusConnectCategory? selectedCategory;
  final Function(CampusConnectCategory?) onCategoryChanged;
  final Map<CampusConnectCategory, int>? filterCounts;
  final bool showIcons;
  final bool isStudent;

  const EnhancedFilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.filterCounts,
    this.showIcons = true,
    this.isStudent = true,
  });

  @override
  Widget build(BuildContext context) {
    final availableCategories =
        FilterTabsBar.webStyleCategories.where((category) {
      if (category == CampusConnectCategory.housing && !isStudent) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: availableCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final count = filterCounts?[category] ?? 0;
          final catIconColor = getCategoryIconColor(category);

          return Padding(
            padding: EdgeInsets.only(
                right: index < availableCategories.length - 1 ? 6 : 0),
            child: _FilterPillWithBadge(
              icon: showIcons ? category.icon : null,
              label: category.label.tr(context),
              isSelected: selectedCategory == category,
              badgeCount: count,
              iconColor: catIconColor,
              onTap: () => onCategoryChanged(
                selectedCategory == category ? null : category,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Filter pill with optional badge count.
class _FilterPillWithBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final Color iconColor;
  final VoidCallback onTap;

  const _FilterPillWithBadge({
    this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? iconColor : AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.textTertiary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

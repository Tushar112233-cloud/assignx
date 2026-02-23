import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Filter categories for Campus Connect.
///
/// Maps to internal filter types:
/// - housing: HousingFilters (location, price, property type, amenities)
/// - opportunities/events: EventFilters (event type, date, location, free/paid)
/// - products/resources: ResourceFilters (subject, type, difficulty, rating)
///
/// Categories match the web app with full feature parity:
/// - All: Shows all posts
/// - Questions: Academic Q&A and doubts
/// - Housing: Accommodation listings (students only)
/// - Opportunities: Jobs & internships
/// - Events: Campus events and activities
/// - Marketplace: Buy & sell items
/// - Resources: Study materials and resources
/// - Lost & Found: Lost items
/// - Rides: Carpool and ride sharing
/// - Study Groups: Study teams
/// - Clubs: Societies and clubs
/// - Announcements: Official announcements
/// - Discussions: General discussions
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

/// Production-grade horizontal filter tabs bar for Campus Connect.
///
/// Features capsule-shaped pills like QuickStatsRow with smooth animations.
/// Selected state shows filled background, unselected shows subtle border.
///
/// The housing category is only shown to students. Non-students will see
/// all other categories but not housing.
class FilterTabsBar extends StatelessWidget {
  final CampusConnectCategory? selectedCategory;
  final Function(CampusConnectCategory?) onCategoryChanged;

  /// Whether the current user is a student.
  /// If false, the housing category will be hidden.
  final bool isStudent;

  const FilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.isStudent = true,
  });

  /// Web-style categories matching the web app's full category list.
  /// Housing is conditionally shown based on student status.
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

  /// Quick access categories shown in featured section
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
    // Use web-style categories, hide housing for non-students
    final availableCategories = webStyleCategories.where((category) {
      if (category == CampusConnectCategory.housing && !isStudent) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: availableCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: index < availableCategories.length - 1 ? 8 : 0),
            child: _FilterCapsule(
              icon: category.icon,
              label: category.label,
              isSelected: selectedCategory == category,
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

/// Individual capsule filter pill - production-grade with smooth animations.
class _FilterCapsule extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterCapsule({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surfaceLight;
    final borderColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.border.withValues(alpha: 0.5);
    final textColor = isSelected ? AppColors.primary : AppColors.textSecondary;
    final iconColor = isSelected ? AppColors.primary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), // Capsule shape
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced filter tabs bar with filter counts.
///
/// Shows badge counts on categories that have active filters.
/// The housing category is only shown to students.
class EnhancedFilterTabsBar extends StatelessWidget {
  final CampusConnectCategory? selectedCategory;
  final Function(CampusConnectCategory?) onCategoryChanged;
  final Map<CampusConnectCategory, int>? filterCounts;
  final bool showIcons;

  /// Whether the current user is a student.
  /// If false, the housing category will be hidden.
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
    // Use web-style categories, hide housing for non-students
    final availableCategories = FilterTabsBar.webStyleCategories.where((category) {
      if (category == CampusConnectCategory.housing && !isStudent) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: availableCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final count = filterCounts?[category] ?? 0;

          return Padding(
            padding: EdgeInsets.only(right: index < availableCategories.length - 1 ? 8 : 0),
            child: _FilterCapsuleWithBadge(
              icon: showIcons ? category.icon : null,
              label: category.label,
              isSelected: selectedCategory == category,
              badgeCount: count,
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

/// Capsule filter pill with optional badge count.
class _FilterCapsuleWithBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _FilterCapsuleWithBadge({
    this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.1)
        : AppColors.surfaceLight;
    final borderColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.border.withValues(alpha: 0.5);
    final textColor = isSelected ? AppColors.primary : AppColors.textSecondary;
    final iconColor = isSelected ? AppColors.primary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20), // Capsule shape
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.textTertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
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

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';

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

/// Color mapping for each category used in the filter pills.
Color _getCategoryColor(CampusConnectCategory category) {
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

/// Production-grade horizontal filter tabs bar for Campus Connect.
///
/// Features capsule-shaped pills with color-coded active states.
/// Selected state shows a filled gradient background.
/// Unselected state shows a clean outlined style.
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
              label: category.label.tr(context),
              isSelected: selectedCategory == category,
              accentColor: _getCategoryColor(category),
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

/// Individual capsule filter pill with color-coded active state.
class _FilterCapsule extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterCapsule({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? accentColor : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : AppColors.textSecondary,
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
          final catColor = _getCategoryColor(category);

          return Padding(
            padding: EdgeInsets.only(right: index < availableCategories.length - 1 ? 8 : 0),
            child: _FilterCapsuleWithBadge(
              icon: showIcons ? category.icon : null,
              label: category.label.tr(context),
              isSelected: selectedCategory == category,
              badgeCount: count,
              accentColor: catColor,
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

/// Capsule filter pill with optional badge count and color-coded active state.
class _FilterCapsuleWithBadge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterCapsuleWithBadge({
    this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? accentColor : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : AppColors.textSecondary,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.2)
                      : AppColors.textTertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? accentColor : AppColors.textSecondary,
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

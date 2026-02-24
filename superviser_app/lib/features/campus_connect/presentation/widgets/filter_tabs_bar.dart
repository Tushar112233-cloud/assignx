library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/community_post_model.dart';

/// Production-grade horizontal filter tabs bar for Business Hub.
///
/// Features capsule-shaped pills with smooth animations.
/// Selected state shows filled background, unselected shows subtle border.
class FilterTabsBar extends StatelessWidget {
  final BusinessCategory? selectedCategory;
  final Function(BusinessCategory?) onCategoryChanged;

  const FilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  /// All categories for display.
  static const List<BusinessCategory> allCategories = BusinessCategory.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: allCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                right: index < allCategories.length - 1 ? 8 : 0),
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

/// Individual capsule filter pill.
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
        ? AppColors.primary.withAlpha(26)
        : AppColors.surfaceLight;
    final borderColor = isSelected
        ? AppColors.primary.withAlpha(77)
        : AppColors.border.withAlpha(128);
    final textColor =
        isSelected ? AppColors.primary : AppColors.textSecondary;
    final iconColor =
        isSelected ? AppColors.primary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
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
              style: AppTypography.labelMedium.copyWith(
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
class EnhancedFilterTabsBar extends StatelessWidget {
  final BusinessCategory? selectedCategory;
  final Function(BusinessCategory?) onCategoryChanged;
  final Map<BusinessCategory, int>? filterCounts;
  final bool showIcons;

  const EnhancedFilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.filterCounts,
    this.showIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: FilterTabsBar.allCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final count = filterCounts?[category] ?? 0;

          return Padding(
            padding: EdgeInsets.only(
                right: index < FilterTabsBar.allCategories.length - 1
                    ? 8
                    : 0),
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
        ? AppColors.primary.withAlpha(26)
        : AppColors.surfaceLight;
    final borderColor = isSelected
        ? AppColors.primary.withAlpha(77)
        : AppColors.border.withAlpha(128);
    final textColor =
        isSelected ? AppColors.primary : AppColors.textSecondary;
    final iconColor =
        isSelected ? AppColors.primary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
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
              style: AppTypography.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(51)
                      : AppColors.textTertiary.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primary
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

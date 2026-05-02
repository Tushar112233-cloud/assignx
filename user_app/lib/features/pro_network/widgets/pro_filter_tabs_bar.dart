library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/pro_network_post_model.dart';

/// Color mapping for each job category.
Color _getJobCategoryColor(JobCategory category) {
  switch (category) {
    case JobCategory.all:
      return const Color(0xFF6366F1);
    case JobCategory.engineering:
      return const Color(0xFF2563EB);
    case JobCategory.design:
      return const Color(0xFF8B5CF6);
    case JobCategory.marketing:
      return const Color(0xFFEC4899);
    case JobCategory.sales:
      return const Color(0xFF059669);
    case JobCategory.finance:
      return const Color(0xFFF59E0B);
    case JobCategory.product:
      return const Color(0xFF14B8A6);
    case JobCategory.data:
      return const Color(0xFF0EA5E9);
    case JobCategory.operations:
      return const Color(0xFFEF4444);
    case JobCategory.hr:
      return const Color(0xFF4F46E5);
  }
}

/// Horizontal scrollable filter pills for job categories.
class ProFilterTabsBar extends StatelessWidget {
  final JobCategory? selectedCategory;
  final Function(JobCategory?) onCategoryChanged;

  const ProFilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<JobCategory> categories = JobCategory.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final catColor = _getJobCategoryColor(category);
          return Padding(
            padding:
                EdgeInsets.only(right: index < categories.length - 1 ? 8 : 0),
            child: _FilterCapsule(
              icon: category.icon,
              label: category.label,
              isSelected: selectedCategory == category,
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

/// Individual capsule filter pill.
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

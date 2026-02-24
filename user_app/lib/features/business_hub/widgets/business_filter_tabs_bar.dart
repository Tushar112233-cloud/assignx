library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';

/// Horizontal filter tabs bar for Business Hub categories.
class BusinessFilterTabsBar extends StatelessWidget {
  final BusinessCategory? selectedCategory;
  final Function(BusinessCategory?) onCategoryChanged;

  const BusinessFilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<BusinessCategory> categories = BusinessCategory.values;

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
          return Padding(
            padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 8 : 0),
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
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
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

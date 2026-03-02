library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/pro_network_post_model.dart';

/// Color mapping for each professional category.
Color _getProCategoryColor(ProfessionalCategory category) {
  switch (category) {
    case ProfessionalCategory.all:
      return const Color(0xFF6366F1);
    case ProfessionalCategory.jobDiscussions:
      return const Color(0xFF2563EB);
    case ProfessionalCategory.portfolioShowcase:
      return const Color(0xFF8B5CF6);
    case ProfessionalCategory.skillExchange:
      return const Color(0xFF14B8A6);
    case ProfessionalCategory.industryNews:
      return const Color(0xFF0EA5E9);
    case ProfessionalCategory.networking:
      return const Color(0xFFEC4899);
    case ProfessionalCategory.freelanceOpportunities:
      return const Color(0xFF059669);
    case ProfessionalCategory.tools:
      return const Color(0xFFF59E0B);
    case ProfessionalCategory.events:
      return const Color(0xFF4F46E5);
    case ProfessionalCategory.helpAdvice:
      return const Color(0xFFEF4444);
  }
}

/// Horizontal filter tabs bar for Pro Network categories.
///
/// Features professional color-coded capsule pills with smooth animations.
/// Dark-themed active state to match the Pro Network's professional look.
class ProFilterTabsBar extends StatelessWidget {
  final ProfessionalCategory? selectedCategory;
  final Function(ProfessionalCategory?) onCategoryChanged;

  const ProFilterTabsBar({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<ProfessionalCategory> categories =
      ProfessionalCategory.values;

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
          final catColor = _getProCategoryColor(category);
          return Padding(
            padding: EdgeInsets.only(
                right: index < categories.length - 1 ? 8 : 0),
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

/// Individual capsule filter pill with professional color-coded active state.
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

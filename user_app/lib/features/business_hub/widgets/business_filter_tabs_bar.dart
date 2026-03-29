library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';

/// Horizontal filter tabs bar for funding stage filters.
class BusinessFilterTabsBar extends StatelessWidget {
  final FundingStage? selectedStage;
  final Function(FundingStage?) onStageChanged;

  const BusinessFilterTabsBar({
    super.key,
    this.selectedStage,
    required this.onStageChanged,
  });

  static const List<FundingStage> stages = FundingStage.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                right: index < stages.length - 1 ? 8 : 0),
            child: _FilterCapsule(
              icon: stage.icon,
              label: stage.label,
              isSelected: selectedStage == stage,
              onTap: () => onStageChanged(
                selectedStage == stage ? null : stage,
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

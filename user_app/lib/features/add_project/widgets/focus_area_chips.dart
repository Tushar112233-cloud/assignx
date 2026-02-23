import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Focus areas for proofreading/editing.
enum FocusArea {
  grammar('Grammar & Punctuation', Icons.spellcheck),
  clarity('Clarity & Flow', Icons.remove_red_eye_outlined),
  structure('Structure & Organization', Icons.account_tree_outlined),
  formatting('Formatting & Layout', Icons.format_align_left),
  citations('Citations & References', Icons.format_quote),
  consistency('Consistency & Style', Icons.style_outlined),
  vocabulary('Vocabulary Enhancement', Icons.abc),
  conciseness('Conciseness', Icons.compress);

  final String displayName;
  final IconData icon;

  const FocusArea(this.displayName, this.icon);
}

/// Multi-select chips for focus areas.
class FocusAreaChips extends StatelessWidget {
  final Set<FocusArea> selectedAreas;
  final ValueChanged<Set<FocusArea>> onChanged;
  final String? errorText;

  const FocusAreaChips({
    super.key,
    required this.selectedAreas,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Focus Areas',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${selectedAreas.length} selected',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select areas you want us to focus on',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),

        // Chips grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FocusArea.values.map((area) {
            final isSelected = selectedAreas.contains(area);
            return _FocusAreaChip(
              area: area,
              isSelected: isSelected,
              onTap: () {
                final newSet = Set<FocusArea>.from(selectedAreas);
                if (isSelected) {
                  newSet.remove(area);
                } else {
                  newSet.add(area);
                }
                onChanged(newSet);
              },
            );
          }).toList(),
        ),

        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        // Select all / Clear buttons
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged(FocusArea.values.toSet()),
              child: Text(
                'Select All',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onChanged({}),
              child: Text(
                'Clear',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FocusAreaChip extends StatelessWidget {
  final FocusArea area;
  final bool isSelected;
  final VoidCallback onTap;

  const _FocusAreaChip({
    required this.area,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              area.icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              area.displayName,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

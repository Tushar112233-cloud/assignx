import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Reference/citation styles available.
enum ReferenceStyle {
  apa7('APA 7th Edition', 'American Psychological Association'),
  apa6('APA 6th Edition', 'American Psychological Association (Legacy)'),
  mla9('MLA 9th Edition', 'Modern Language Association'),
  chicago('Chicago/Turabian', 'Chicago Manual of Style'),
  harvard('Harvard', 'Author-Date System'),
  ieee('IEEE', 'Institute of Electrical and Electronics Engineers'),
  vancouver('Vancouver', 'Numbered Citation System'),
  ama('AMA', 'American Medical Association'),
  acs('ACS', 'American Chemical Society'),
  oscola('OSCOLA', 'Oxford University Standard for Citation of Legal Authorities'),
  bluebook('Bluebook', 'Legal Citation'),
  other('Other', 'Specify in requirements');

  final String displayName;
  final String description;

  const ReferenceStyle(this.displayName, this.description);
}

/// Dropdown for selecting reference/citation style.
class ReferenceStyleDropdown extends StatelessWidget {
  final ReferenceStyle? value;
  final ValueChanged<ReferenceStyle?> onChanged;
  final String? errorText;
  final bool isRequired;

  const ReferenceStyleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reference Style',
              style: AppTextStyles.labelMedium,
            ),
            if (!isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '(Optional)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReferenceStyle>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select reference style',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: AppSpacing.borderRadiusMd,
              dropdownColor: AppColors.surface,
              menuMaxHeight: 300,
              items: ReferenceStyle.values.map((style) {
                return DropdownMenuItem(
                  value: style,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        style.displayName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        style.description,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return ReferenceStyle.values.map((style) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      style.displayName,
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }).toList();
              },
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        // Popular styles hint
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickSelectChip(
              label: 'APA 7',
              isSelected: value == ReferenceStyle.apa7,
              onTap: () => onChanged(ReferenceStyle.apa7),
            ),
            _QuickSelectChip(
              label: 'Harvard',
              isSelected: value == ReferenceStyle.harvard,
              onTap: () => onChanged(ReferenceStyle.harvard),
            ),
            _QuickSelectChip(
              label: 'IEEE',
              isSelected: value == ReferenceStyle.ieee,
              onTap: () => onChanged(ReferenceStyle.ieee),
            ),
            _QuickSelectChip(
              label: 'Chicago',
              isSelected: value == ReferenceStyle.chicago,
              onTap: () => onChanged(ReferenceStyle.chicago),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickSelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickSelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

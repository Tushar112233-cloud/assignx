import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Dropdown for selecting project subject.
class SubjectDropdown extends StatelessWidget {
  final ProjectSubject? value;
  final ValueChanged<ProjectSubject?> onChanged;
  final String? errorText;

  const SubjectDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: AppTextStyles.labelMedium,
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
            child: DropdownButton<ProjectSubject>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select subject',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: AppSpacing.borderRadiusMd,
              dropdownColor: AppColors.surface,
              items: ProjectSubject.values.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: subject.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          subject.icon,
                          size: 16,
                          color: subject.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        subject.displayName,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
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
      ],
    );
  }
}

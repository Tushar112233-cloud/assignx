import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/request_model.dart';

/// Horizontal scrollable filter chips for subjects/fields.
///
/// Allows filtering requests by subject category.
class FieldFilter extends StatelessWidget {
  const FieldFilter({
    super.key,
    required this.selectedField,
    required this.onFieldSelected,
    this.fields = subjectOptions,
    this.padding,
  });

  /// Currently selected field
  final String selectedField;

  /// Called when a field is selected
  final ValueChanged<String> onFieldSelected;

  /// List of field options
  final List<String> fields;

  /// Padding around the filter
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: fields.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final field = fields[index];
          final isSelected = field == selectedField;

          return FilterChip(
            label: Text(field),
            selected: isSelected,
            onSelected: (_) => onFieldSelected(field),
            backgroundColor: Colors.transparent,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

/// Expertise filter for doer selection.
class ExpertiseFilter extends StatelessWidget {
  const ExpertiseFilter({
    super.key,
    required this.selectedExpertise,
    required this.onExpertiseSelected,
    this.expertiseOptions = const [
      'All',
      'Research',
      'Academic Writing',
      'Technical Writing',
      'Programming',
      'Data Analysis',
      'Business Studies',
      'Marketing',
      'Finance',
      'Statistics',
    ],
  });

  final String selectedExpertise;
  final ValueChanged<String> onExpertiseSelected;
  final List<String> expertiseOptions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: expertiseOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final expertise = expertiseOptions[index];
          final isSelected = expertise == selectedExpertise;

          return ChoiceChip(
            label: Text(expertise),
            selected: isSelected,
            onSelected: (_) => onExpertiseSelected(expertise),
            backgroundColor: AppColors.surfaceLight,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              fontSize: 12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}

/// Subject tag chip for display.
class SubjectTag extends StatelessWidget {
  const SubjectTag({
    super.key,
    required this.subject,
    this.color,
  });

  final String subject;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? _getColorForSubject(subject);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        subject,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tagColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Color _getColorForSubject(String subject) {
    // Assign consistent colors based on subject
    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
    ];

    final index = subject.hashCode.abs() % colors.length;
    return colors[index];
  }
}

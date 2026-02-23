/// Project requirements list widgets.
///
/// This file provides widgets for displaying and interacting with
/// project requirements/specifications in the workspace and detail views.
///
/// ## Widgets
/// - [RequirementsList] - Numbered list of requirements with optional checkboxes
/// - [CollapsibleRequirements] - Expandable requirements section
///
/// ## Features
/// - Numbered requirement items
/// - Optional checkbox mode for tracking completion
/// - Completion counter (e.g., "3/5")
/// - Visual completion states (checked items with strikethrough)
/// - Empty state for projects without requirements
/// - Collapsible wrapper for space-efficient display
///
/// ## Example
/// ```dart
/// // Basic requirements list
/// RequirementsList(
///   requirements: ['Use APA format', 'Minimum 2000 words', 'Include citations'],
/// )
///
/// // With checkbox tracking
/// RequirementsList(
///   requirements: project.requirements,
///   checkedItems: checkedState,
///   onItemToggle: (index) => toggleRequirement(index),
///   editable: true,
/// )
///
/// // Collapsible section
/// CollapsibleRequirements(
///   requirements: project.requirements,
///   initiallyExpanded: false,
/// )
/// ```
///
/// See also:
/// - [ProjectDetailScreen] for usage context
/// - [WorkspaceScreen] for workspace usage
/// - [DoerProjectModel] for requirement data
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Numbered list of project requirements.
///
/// Displays requirements with optional checkbox mode for tracking
/// completion. Shows completion counter when checkboxes are enabled.
///
/// ## Props
/// - [requirements]: List of requirement strings
/// - [checkedItems]: Optional list of completion states
/// - [onItemToggle]: Callback when checkbox is toggled
/// - [editable]: Enable checkbox interaction
class RequirementsList extends StatelessWidget {
  final List<String> requirements;
  final List<bool>? checkedItems;
  final ValueChanged<int>? onItemToggle;
  final bool editable;

  const RequirementsList({
    super.key,
    required this.requirements,
    this.checkedItems,
    this.onItemToggle,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (requirements.isEmpty) {
      return Container(
        padding: AppSpacing.paddingMd,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              'No specific requirements listed',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.checklist,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Requirements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (checkedItems != null) ...[
              Text(
                '${checkedItems!.where((c) => c).length}/${requirements.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Requirements list
        ...List.generate(requirements.length, (index) {
          final isChecked = checkedItems?[index] ?? false;
          return _RequirementItem(
            text: requirements[index],
            index: index + 1,
            isChecked: isChecked,
            onToggle: editable && onItemToggle != null
                ? () => onItemToggle!(index)
                : null,
          );
        }),
      ],
    );
  }
}

/// Individual requirement item with number/checkbox.
///
/// Private widget displaying a single requirement with visual
/// feedback for completion state. Used by [RequirementsList].
class _RequirementItem extends StatelessWidget {
  final String text;
  final int index;
  final bool isChecked;
  final VoidCallback? onToggle;

  const _RequirementItem({
    required this.text,
    required this.index,
    this.isChecked = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onToggle,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: isChecked
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusSm,
            border: Border.all(
              color: isChecked
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox or number
              if (onToggle != null)
                Checkbox(
                  value: isChecked,
                  onChanged: (_) => onToggle!(),
                  activeColor: AppColors.success,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isChecked ? AppColors.success : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : Text(
                            '$index',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

              // Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isChecked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable/collapsible requirements section.
///
/// Wraps [RequirementsList] in a card with expand/collapse functionality.
/// Shows requirement count in header and animates open/close state.
///
/// ## Props
/// - [requirements]: List of requirement strings
/// - [initiallyExpanded]: Whether to start expanded (default: false)
class CollapsibleRequirements extends StatefulWidget {
  final List<String> requirements;
  final bool initiallyExpanded;

  const CollapsibleRequirements({
    super.key,
    required this.requirements,
    this.initiallyExpanded = false,
  });

  @override
  State<CollapsibleRequirements> createState() =>
      _CollapsibleRequirementsState();
}

class _CollapsibleRequirementsState extends State<CollapsibleRequirements> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: _isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : AppSpacing.borderRadiusMd,
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  const Icon(
                    Icons.checklist,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Requirements (${widget.requirements.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: AppSpacing.paddingMd,
              child: RequirementsList(requirements: widget.requirements),
            ),
          ],
        ],
      ),
    );
  }
}

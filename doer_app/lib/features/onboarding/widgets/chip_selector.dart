/// Chip-based selection widgets for multi-select and single-select inputs.
///
/// This file provides chip selection components for forms and settings,
/// allowing users to select one or more options from a list of chips.
///
/// ## Widgets
/// - [ChipSelector] - Multi-select chip selector with optional maximum
/// - [SingleChipSelector] - Single-select chip wrapper
/// - [ChipOption] - Data class for chip options
///
/// ## Features
/// - Generic type support for any value type
/// - Wrapped or scrollable horizontal layout
/// - Selection limit with counter display
/// - Optional icons on chips
/// - Animated selection state
/// - Disabled state handling
///
/// ## Example
/// ```dart
/// // Multi-select with max 3 selections
/// ChipSelector<String>(
///   label: 'Select Skills',
///   options: [
///     ChipOption(value: 'dart', label: 'Dart'),
///     ChipOption(value: 'flutter', label: 'Flutter', icon: Icons.phone_android),
///     ChipOption(value: 'python', label: 'Python'),
///   ],
///   selectedValues: ['dart'],
///   onChanged: (values) => setState(() => skills = values),
///   maxSelections: 3,
/// )
///
/// // Single-select
/// SingleChipSelector<String>(
///   options: categoryOptions,
///   selectedValue: selectedCategory,
///   onChanged: (value) => setState(() => selectedCategory = value),
/// )
/// ```
///
/// See also:
/// - [ChoiceChip] for Flutter's built-in choice chip
/// - [FilterChip] for Flutter's built-in filter chip
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A multi-select chip selector widget.
///
/// Displays a list of chips that users can tap to select or deselect.
/// Supports optional maximum selection limit, labels, and helper text.
///
/// ## Usage
/// ```dart
/// ChipSelector<String>(
///   label: 'Subjects',
///   options: [
///     ChipOption(value: 'math', label: 'Mathematics'),
///     ChipOption(value: 'science', label: 'Science'),
///   ],
///   selectedValues: selectedSubjects,
///   onChanged: (values) => setState(() => selectedSubjects = values),
///   maxSelections: 5,
///   helperText: 'Select up to 5 subjects',
/// )
/// ```
///
/// ## Layout Modes
/// - **Wrapped** (default): Chips wrap to multiple lines
/// - **Scrollable**: Chips scroll horizontally in a single row
///
/// ## Selection Behavior
/// - Tapping a chip toggles its selection
/// - When max selections is reached, unselected chips become disabled
/// - Counter shows current/max selections when limit is set
///
/// See also:
/// - [SingleChipSelector] for single-select variant
/// - [ChipOption] for option data structure
class ChipSelector<T> extends StatelessWidget {
  /// Creates a chip selector with the specified options.
  ///
  /// [options], [selectedValues], and [onChanged] are required.
  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.maxSelections,
    this.enabled = true,
    this.label,
    this.helperText,
    this.wrap = true,
  });

  /// List of available options to display as chips.
  final List<ChipOption<T>> options;

  /// Currently selected values.
  final List<T> selectedValues;

  /// Callback when selection changes.
  ///
  /// Called with the updated list of selected values.
  final ValueChanged<List<T>> onChanged;

  /// Maximum number of selections allowed.
  ///
  /// When null, unlimited selections are allowed.
  /// When set, a counter is displayed and excess selections are prevented.
  final int? maxSelections;

  /// Whether the selector is enabled.
  ///
  /// When false, all chips are disabled and cannot be interacted with.
  /// Defaults to true.
  final bool enabled;

  /// Label text displayed above the chips.
  ///
  /// When [maxSelections] is set, a counter is shown opposite the label.
  final String? label;

  /// Helper text displayed below the chips.
  final String? helperText;

  /// Whether to wrap chips to multiple lines.
  ///
  /// When true, chips wrap to new lines as needed.
  /// When false, chips scroll horizontally in a single row.
  /// Defaults to true.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (maxSelections != null)
                Text(
                  '${selectedValues.length}/$maxSelections',
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedValues.length >= maxSelections!
                        ? AppColors.warning
                        : AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        wrap ? _buildWrappedChips() : _buildScrollableChips(),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds chips in a wrapped layout.
  Widget _buildWrappedChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        return _ChipItem<T>(
          option: option,
          isSelected: isSelected,
          enabled: enabled &&
              (isSelected ||
                  maxSelections == null ||
                  selectedValues.length < maxSelections!),
          onTap: () => _toggleSelection(option.value, isSelected),
        );
      }).toList(),
    );
  }

  /// Builds chips in a horizontally scrollable layout.
  Widget _buildScrollableChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = selectedValues.contains(option.value);
          return Padding(
            padding: EdgeInsets.only(
              right: index < options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _ChipItem<T>(
              option: option,
              isSelected: isSelected,
              enabled: enabled &&
                  (isSelected ||
                      maxSelections == null ||
                      selectedValues.length < maxSelections!),
              onTap: () => _toggleSelection(option.value, isSelected),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Toggles selection state for a value.
  void _toggleSelection(T value, bool isCurrentlySelected) {
    if (isCurrentlySelected) {
      onChanged(selectedValues.where((v) => v != value).toList());
    } else {
      if (maxSelections == null || selectedValues.length < maxSelections!) {
        onChanged([...selectedValues, value]);
      }
    }
  }
}

/// Data class representing a single chip option.
///
/// Holds the value, display label, and optional icon for a chip.
///
/// ## Usage
/// ```dart
/// ChipOption<String>(
///   value: 'flutter',
///   label: 'Flutter',
///   icon: Icons.phone_android,
/// )
/// ```
///
/// ## Type Parameter
/// - `T`: The type of value this option represents
class ChipOption<T> {
  /// Creates a chip option.
  ///
  /// [value] and [label] are required.
  const ChipOption({
    required this.value,
    required this.label,
    this.icon,
  });

  /// The value this option represents.
  ///
  /// Used for selection state and returned in [ChipSelector.onChanged].
  final T value;

  /// The display label shown on the chip.
  final String label;

  /// Optional icon displayed before the label.
  final IconData? icon;
}

/// Internal widget for rendering a single chip.
class _ChipItem<T> extends StatelessWidget {
  final ChipOption<T> option;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _ChipItem({
    required this.option,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : enabled
                  ? AppColors.surface
                  : AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : enabled
                    ? AppColors.border
                    : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : enabled
                        ? AppColors.textSecondary
                        : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              option.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : enabled
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single-select chip selector widget.
///
/// Wraps [ChipSelector] to provide single-selection behavior.
/// Only one chip can be selected at a time.
///
/// ## Usage
/// ```dart
/// SingleChipSelector<String>(
///   label: 'Category',
///   options: [
///     ChipOption(value: 'writing', label: 'Writing'),
///     ChipOption(value: 'research', label: 'Research'),
///     ChipOption(value: 'analysis', label: 'Analysis'),
///   ],
///   selectedValue: selectedCategory,
///   onChanged: (value) => setState(() => selectedCategory = value),
/// )
/// ```
///
/// ## Behavior
/// - Selecting a new chip deselects the previous one
/// - Tapping the selected chip does not deselect it
///
/// See also:
/// - [ChipSelector] for multi-select variant
class SingleChipSelector<T> extends StatelessWidget {
  /// Creates a single-select chip selector.
  ///
  /// [options] and [onChanged] are required.
  const SingleChipSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.enabled = true,
    this.label,
    this.wrap = true,
  });

  /// List of available options to display as chips.
  final List<ChipOption<T>> options;

  /// Currently selected value, or null if none selected.
  final T? selectedValue;

  /// Callback when selection changes.
  final ValueChanged<T> onChanged;

  /// Whether the selector is enabled.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Label text displayed above the chips.
  final String? label;

  /// Whether to wrap chips to multiple lines.
  ///
  /// Defaults to true.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    return ChipSelector<T>(
      options: options,
      selectedValues: selectedValue != null ? [selectedValue as T] : [],
      onChanged: (values) {
        if (values.isNotEmpty) {
          onChanged(values.last);
        }
      },
      maxSelections: 1,
      enabled: enabled,
      label: label,
      wrap: wrap,
    );
  }
}

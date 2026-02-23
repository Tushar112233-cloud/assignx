/// Experience level selection widgets for user profiling.
///
/// This file provides widgets for selecting and displaying user experience
/// levels, with visual indicators and contextual descriptions.
///
/// ## Widgets
/// - [ExperienceSlider] - Button-based experience selector with descriptions
/// - [ExperienceSliderBar] - Slider-based alternative
/// - [ExperienceLevel] - Enum for experience levels
///
/// ## Features
/// - Three experience levels (Beginner, Intermediate, Pro)
/// - Animated selection transitions
/// - Contextual description for each level
/// - Icon indicators for visual clarity
/// - Both button and slider variants
///
/// ## Example
/// ```dart
/// // Button-based selector with description
/// ExperienceSlider(
///   label: 'Your Experience Level',
///   value: ExperienceLevel.intermediate,
///   onChanged: (level) => setState(() => experience = level),
/// )
///
/// // Slider-based selector
/// ExperienceSliderBar(
///   value: experience,
///   onChanged: (level) => setState(() => experience = level),
/// )
/// ```
///
/// See also:
/// - [Slider] for Flutter's built-in slider
/// - [SegmentedButton] for Flutter's segmented button
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Experience level enumeration.
///
/// Represents the three levels of user experience:
/// - [beginner]: New to the field, needs guidance
/// - [intermediate]: Has some experience, moderate complexity
/// - [pro]: Highly experienced, handles challenging tasks
enum ExperienceLevel {
  /// New user with limited experience.
  beginner,

  /// User with moderate experience.
  intermediate,

  /// Highly experienced user.
  pro,
}

/// Experience level selector with button-style options.
///
/// Displays three experience levels as selectable buttons,
/// with an animated selection indicator and contextual
/// description below.
///
/// ## Usage
/// ```dart
/// ExperienceSlider(
///   label: 'Experience Level',
///   value: ExperienceLevel.beginner,
///   onChanged: (level) {
///     setState(() => selectedLevel = level);
///   },
/// )
/// ```
///
/// ## Visual Elements
/// - Three horizontally arranged level buttons
/// - Icon and label for each level
/// - Selected state with primary color background
/// - Description box explaining the selected level
///
/// ## Level Descriptions
/// - **Beginner**: Tasks suited for learners with guidance
/// - **Intermediate**: Moderate complexity tasks
/// - **Pro**: Challenging tasks with premium pay
///
/// See also:
/// - [ExperienceSliderBar] for slider-based alternative
/// - [ExperienceLevel] for level enumeration
class ExperienceSlider extends StatelessWidget {
  /// Creates an experience slider.
  ///
  /// [value] and [onChanged] are required.
  const ExperienceSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.label,
  });

  /// Current selected level.
  final ExperienceLevel value;

  /// Callback when level changes.
  final ValueChanged<ExperienceLevel> onChanged;

  /// Whether the selector is enabled.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Label text displayed above the selector.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _ExperienceSelector(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _ExperienceDescription(level: value),
      ],
    );
  }
}

/// Internal selector widget with three level buttons.
class _ExperienceSelector extends StatelessWidget {
  final ExperienceLevel value;
  final ValueChanged<ExperienceLevel>? onChanged;

  const _ExperienceSelector({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: ExperienceLevel.values.map((level) {
          final isSelected = value == level;
          return Expanded(
            child: GestureDetector(
              onTap: onChanged != null ? () => onChanged!(level) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusSm,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(51),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _getLevelIcon(level),
                      size: 24,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _getLevelLabel(level),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Returns the icon for a given experience level.
  IconData _getLevelIcon(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return Icons.school_outlined;
      case ExperienceLevel.intermediate:
        return Icons.trending_up;
      case ExperienceLevel.pro:
        return Icons.star_outline;
    }
  }

  /// Returns the display label for a given experience level.
  String _getLevelLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.pro:
        return 'Pro';
    }
  }
}

/// Internal widget displaying a description for the selected level.
class _ExperienceDescription extends StatelessWidget {
  final ExperienceLevel level;

  const _ExperienceDescription({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.info.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _getDescription(level),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the description text for a given experience level.
  String _getDescription(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'You\'re just starting out. You\'ll receive tasks suited for learners with detailed guidance and support.';
      case ExperienceLevel.intermediate:
        return 'You have some experience in your field. You\'ll receive moderate complexity tasks with reasonable deadlines.';
      case ExperienceLevel.pro:
        return 'You\'re highly experienced. You\'ll receive challenging tasks with premium pay and shorter deadlines.';
    }
  }
}

/// Slider-based experience level selector.
///
/// An alternative to [ExperienceSlider] that uses a Material
/// slider control instead of buttons.
///
/// ## Usage
/// ```dart
/// ExperienceSliderBar(
///   value: ExperienceLevel.intermediate,
///   onChanged: (level) => setState(() => experience = level),
/// )
/// ```
///
/// ## Visual Elements
/// - Material slider with 3 discrete stops
/// - Level labels below the slider
/// - Selected level highlighted in primary color
///
/// See also:
/// - [ExperienceSlider] for button-based alternative
/// - [Slider] for Flutter's built-in slider
class ExperienceSliderBar extends StatelessWidget {
  /// Creates a slider-based experience selector.
  ///
  /// [value] and [onChanged] are required.
  const ExperienceSliderBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Current selected level.
  final ExperienceLevel value;

  /// Callback when level changes.
  final ValueChanged<ExperienceLevel> onChanged;

  /// Whether the slider is enabled.
  ///
  /// Defaults to true.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(31),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          ),
          child: Slider(
            value: value.index.toDouble(),
            min: 0,
            max: 2,
            divisions: 2,
            onChanged: enabled
                ? (v) => onChanged(ExperienceLevel.values[v.round()])
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ExperienceLevel.values.map((level) {
            final isSelected = value == level;
            return Text(
              _getLevelLabel(level),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Returns the display label for a given experience level.
  String _getLevelLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.pro:
        return 'Pro';
    }
  }
}

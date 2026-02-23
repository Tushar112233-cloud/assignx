/// Step progress widgets for multi-step forms and wizards.
///
/// This file provides progress indicators for multi-step workflows,
/// showing the current step and overall progress through a sequence.
///
/// ## Widgets
/// - [StepProgressBar] - Circular step indicators with connector lines
/// - [LinearStepProgress] - Simple linear progress bar with step text
///
/// ## Features
/// - Circular step indicators with numbers or dots
/// - Connector lines between steps
/// - Completed, current, and future step states
/// - Optional step labels below indicators
/// - Percentage display option
/// - Linear alternative for compact spaces
///
/// ## Example
/// ```dart
/// // Step progress with labels
/// StepProgressBar(
///   totalSteps: 4,
///   currentStep: 2,
///   labels: ['Info', 'Skills', 'Bank', 'Done'],
///   showNumbers: true,
///   showPercentage: true,
/// )
///
/// // Linear progress bar
/// LinearStepProgress(
///   totalSteps: 5,
///   currentStep: 3,
/// )
/// ```
///
/// See also:
/// - [Stepper] for Flutter's built-in stepper widget
/// - [LinearProgressIndicator] for simple progress bars
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A circular step progress bar for multi-step forms.
///
/// Displays step circles connected by lines, with visual distinction
/// for completed, current, and future steps.
///
/// ## Usage
/// ```dart
/// StepProgressBar(
///   totalSteps: 4,
///   currentStep: 2,
///   labels: ['Personal', 'Skills', 'Bank', 'Review'],
///   showNumbers: true,
/// )
/// ```
///
/// ## Step States
/// - **Completed**: Filled primary color with check icon
/// - **Current**: Filled primary color with number/dot
/// - **Future**: Bordered circle with number/dot
///
/// ## Display Options
/// - [showNumbers]: Display step numbers in circles
/// - [showPercentage]: Show "Step X of Y" with percentage
/// - [labels]: Optional labels below each step circle
///
/// See also:
/// - [LinearStepProgress] for a simpler linear alternative
class StepProgressBar extends StatelessWidget {
  /// Creates a step progress bar.
  ///
  /// [totalSteps] and [currentStep] are required.
  /// [currentStep] should be 1-indexed (1 to totalSteps).
  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.labels,
    this.showNumbers = true,
    this.showPercentage = false,
  });

  /// Total number of steps in the workflow.
  final int totalSteps;

  /// Current step (1-indexed).
  ///
  /// Steps before this are marked as completed.
  /// This step is marked as current.
  /// Steps after this are marked as future.
  final int currentStep;

  /// Optional labels for each step.
  ///
  /// If provided, must have exactly [totalSteps] labels.
  /// Labels are displayed below the step circles.
  final List<String>? labels;

  /// Whether to display step numbers in the circles.
  ///
  /// When false, displays a dot instead of a number.
  /// Defaults to true.
  final bool showNumbers;

  /// Whether to show step count and percentage.
  ///
  /// Displays "Step X of Y" and "XX%" above the progress bar.
  /// Defaults to false.
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final percentage = ((currentStep / totalSteps) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // Connector line
              final stepIndex = (index ~/ 2) + 1;
              return Expanded(
                child: Container(
                  height: 2,
                  color: stepIndex < currentStep
                      ? AppColors.primary
                      : AppColors.border,
                ),
              );
            } else {
              // Step circle
              final stepIndex = (index ~/ 2) + 1;
              return _StepCircle(
                stepNumber: stepIndex,
                isCompleted: stepIndex < currentStep,
                isCurrent: stepIndex == currentStep,
                showNumber: showNumbers,
              );
            }
          }),
        ),
        if (labels != null && labels!.length == totalSteps) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels!.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isActive = index + 1 <= currentStep;
              return Expanded(
                child: Text(
                  label,
                  textAlign: index == 0
                      ? TextAlign.left
                      : index == labels!.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Internal widget for rendering a single step circle.
class _StepCircle extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool showNumber;

  const _StepCircle({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.showNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: isCompleted || isCurrent ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : showNumber
                ? Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? Colors.white : AppColors.textSecondary,
                    ),
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
      ),
    );
  }
}

/// A linear progress indicator for step-based workflows.
///
/// Displays a simple progress bar with "Step X of Y" text,
/// suitable for compact spaces where circular steps won't fit.
///
/// ## Usage
/// ```dart
/// LinearStepProgress(
///   totalSteps: 5,
///   currentStep: 3,
/// )
/// ```
///
/// ## Visual Elements
/// - Rounded progress bar showing filled portion
/// - Step count text below the bar
///
/// See also:
/// - [StepProgressBar] for circular step indicators
/// - [LinearProgressIndicator] for Flutter's built-in indicator
class LinearStepProgress extends StatelessWidget {
  /// Creates a linear step progress indicator.
  ///
  /// [totalSteps] and [currentStep] are required.
  const LinearStepProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  /// Total number of steps.
  final int totalSteps;

  /// Current step (1-indexed).
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppSpacing.borderRadiusSm,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Step $currentStep of $totalSteps',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Step progress indicator for multi-step forms.
///
/// Shows a horizontal progress bar with step indicators.
class StepProgressBar extends StatelessWidget {
  /// Current step (1-indexed).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Optional step labels.
  final List<String>? labels;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        // Step text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (labels != null &&
                currentStep > 0 &&
                labels!.length >= currentStep)
              Text(
                labels![currentStep - 1],
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Circular step indicator for wizard-style forms.
class CircularStepIndicator extends StatelessWidget {
  /// Current step (1-indexed).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Step labels (optional).
  final List<String>? labels;

  const CircularStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;

        return Row(
          children: [
            // Step circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : Text(
                        '$stepNumber',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
            // Connector line
            if (index < totalSteps - 1)
              Container(
                width: 40,
                height: 2,
                color: isCompleted ? AppColors.primary : AppColors.border,
              ),
          ],
        );
      }),
    );
  }
}

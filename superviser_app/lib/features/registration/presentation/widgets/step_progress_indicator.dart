import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Step progress indicator for multi-step forms.
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.onStepTapped,
    this.allowTapOnCompleted = true,
  });

  /// Current step (0-indexed)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Titles for each step
  final List<String> stepTitles;

  /// Callback when a step is tapped (null to disable)
  final void Function(int step)? onStepTapped;

  /// Whether completed steps can be tapped
  final bool allowTapOnCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (currentStep + 1) / totalSteps,
          backgroundColor: AppColors.borderLight,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 16),

        // Step indicators
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            final isClickable =
                onStepTapped != null && (isCompleted && allowTapOnCompleted);

            return Expanded(
              child: GestureDetector(
                onTap: isClickable ? () => onStepTapped!(index) : null,
                child: Column(
                  children: [
                    // Step circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppColors.primary
                            : AppColors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Step title
                    Text(
                      stepTitles[index],
                      style: AppTypography.labelSmall.copyWith(
                        color: isCompleted || isCurrent
                            ? AppColors.primary
                            : AppColors.textTertiaryLight,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Compact step indicator showing just the current step
class CompactStepIndicator extends StatelessWidget {
  const CompactStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitle,
  });

  final int currentStep;
  final int totalSteps;
  final String? stepTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (stepTitle != null) ...[
              const SizedBox(width: 8),
              Text(
                '- $stepTitle',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: AppColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

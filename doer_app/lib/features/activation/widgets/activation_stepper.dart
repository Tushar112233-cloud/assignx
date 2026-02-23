/// Activation progress stepper widgets.
///
/// This file provides stepper components for visualizing the three-step
/// doer activation process: Training, Quiz, and Bank Details.
///
/// ## Widgets
/// - [ActivationStepper] - Full stepper with step circles and labels
/// - [CompactActivationStepper] - Minimal dot-based progress indicator
///
/// ## Activation Steps
/// 1. **Training**: Complete all training modules
/// 2. **Quiz**: Pass the activation quiz (70%+)
/// 3. **Bank Details**: Add verified bank account
///
/// ## Features
/// - Visual progress bar with percentage
/// - Step circles with number/icon
/// - Locked state for unavailable steps
/// - Completion check marks
/// - Tappable steps for navigation
/// - Compact variant for headers
///
/// ## Step States
/// - **Completed**: Green check mark
/// - **Active**: Primary color with number
/// - **Pending**: Gray with number
/// - **Locked**: Gray with lock icon
///
/// ## Example
/// ```dart
/// // Full stepper
/// ActivationStepper(
///   status: activationStatus,
///   currentStep: ActivationStep.quiz,
///   onStepTapped: (step) => navigateToStep(step),
/// )
///
/// // Compact variant
/// CompactActivationStepper(status: activationStatus)
/// ```
///
/// See also:
/// - [ActivationGateScreen] for usage context
/// - [ActivationStatus] for status data model
/// - [ActivationStep] for step enumeration
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/activation_model.dart';

/// Full activation stepper with three steps.
///
/// Displays the three activation steps with visual progress bar,
/// step circles, and status labels. Steps can be tapped to navigate.
///
/// ## Props
/// - [status]: Current [ActivationStatus]
/// - [onStepTapped]: Callback when a step is tapped
/// - [currentStep]: Currently active step
class ActivationStepper extends StatelessWidget {
  final ActivationStatus status;
  final Function(ActivationStep)? onStepTapped;
  final ActivationStep? currentStep;

  const ActivationStepper({
    super.key,
    required this.status,
    this.onStepTapped,
    this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: LinearProgressIndicator(
                    value: status.completionPercentage / 100,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${status.completionPercentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Steps
          Row(
            children: [
              _buildStep(
                step: ActivationStep.training,
                isCompleted: status.trainingCompleted,
                isActive: currentStep == ActivationStep.training,
              ),
              _buildConnector(status.trainingCompleted),
              _buildStep(
                step: ActivationStep.quiz,
                isCompleted: status.quizPassed,
                isActive: currentStep == ActivationStep.quiz,
                isLocked: !status.trainingCompleted,
              ),
              _buildConnector(status.quizPassed),
              _buildStep(
                step: ActivationStep.bankDetails,
                isCompleted: status.bankDetailsAdded,
                isActive: currentStep == ActivationStep.bankDetails,
                isLocked: !status.quizPassed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required ActivationStep step,
    required bool isCompleted,
    bool isActive = false,
    bool isLocked = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isLocked ? null : () => onStepTapped?.call(step),
        child: Column(
          children: [
            // Circle indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : isActive
                        ? AppColors.primary
                        : isLocked
                            ? AppColors.border
                            : AppColors.background,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.primary
                          : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      )
                    : isLocked
                        ? const Icon(
                            Icons.lock,
                            color: AppColors.textTertiary,
                            size: 20,
                          )
                        : Text(
                            step.number.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              step.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isLocked
                    ? AppColors.textTertiary
                    : isActive
                        ? AppColors.primary
                        : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 2),

            // Status text
            Text(
              isCompleted
                  ? 'Completed'
                  : isLocked
                      ? 'Locked'
                      : 'Pending',
              style: TextStyle(
                fontSize: 12,
                color: isCompleted
                    ? AppColors.success
                    : isLocked
                        ? AppColors.textTertiary
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 40),
      color: isCompleted ? AppColors.success : AppColors.border,
    );
  }
}

/// Compact activation progress indicator.
///
/// Minimal dot-based stepper showing completion status of each
/// step. Suitable for headers or constrained spaces.
///
/// ## Props
/// - [status]: Current [ActivationStatus]
class CompactActivationStepper extends StatelessWidget {
  final ActivationStatus status;

  const CompactActivationStepper({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDot(status.trainingCompleted),
        _buildLine(status.trainingCompleted),
        _buildDot(status.quizPassed),
        _buildLine(status.quizPassed),
        _buildDot(status.bankDetailsAdded),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${status.completedSteps}/${status.totalSteps}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool isCompleted) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.success : AppColors.border,
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              size: 8,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Container(
      width: 20,
      height: 2,
      color: isCompleted ? AppColors.success : AppColors.border,
    );
  }
}

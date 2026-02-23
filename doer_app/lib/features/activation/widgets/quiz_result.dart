/// Quiz result display widgets for activation quizzes.
///
/// This file provides widgets for displaying quiz results after
/// the doer completes the activation quiz, showing score and
/// next steps.
///
/// ## Widgets
/// - [QuizResultWidget] - Full result screen with actions
/// - [QuizResultCard] - Compact result summary card
///
/// ## Features
/// - Pass/fail visual feedback (icon and colors)
/// - Score percentage with large display
/// - Correct/incorrect/total breakdown
/// - Attempt number tracking
/// - Action buttons (Continue, Retry, Review)
///
/// ## Result States
/// - **Passed** (70%+): Green styling, continue option
/// - **Failed** (<70%): Red styling, retry and review options
///
/// ## Example
/// ```dart
/// // Full result display
/// QuizResultWidget(
///   attempt: quizAttempt,
///   onContinue: () => navigateToBankDetails(),
///   onRetry: () => startNewAttempt(),
///   onReviewTraining: () => goToTraining(),
/// )
///
/// // Compact card
/// QuizResultCard(attempt: lastAttempt)
/// ```
///
/// See also:
/// - [QuizScreen] for usage context
/// - [QuizAttempt] for attempt data model
/// - [QuizQuestionWidget] for question display
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/quiz_model.dart';
import '../../../shared/widgets/app_button.dart';

/// Full quiz result screen widget.
///
/// Displays comprehensive quiz results including score, stats,
/// and appropriate action buttons based on pass/fail status.
///
/// ## Props
/// - [attempt]: The [QuizAttempt] with results
/// - [onRetry]: Callback to retry the quiz
/// - [onContinue]: Callback to proceed (passed only)
/// - [onReviewTraining]: Callback to review training
class QuizResultWidget extends StatelessWidget {
  final QuizAttempt attempt;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;
  final VoidCallback? onReviewTraining;

  const QuizResultWidget({
    super.key,
    required this.attempt,
    this.onRetry,
    this.onContinue,
    this.onReviewTraining,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),

          // Result icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: attempt.passed
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
            ),
            child: Icon(
              attempt.passed ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: attempt.passed ? AppColors.success : AppColors.error,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Result title
          Text(
            attempt.passed ? 'Congratulations!' : 'Almost There!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: attempt.passed ? AppColors.success : AppColors.error,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Result message
          Text(
            attempt.passed
                ? 'You have successfully passed the quiz!'
                : 'You need 70% to pass. Keep learning and try again!',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Score card
          Container(
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
                // Score percentage
                Text(
                  '${attempt.percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: attempt.passed ? AppColors.success : AppColors.error,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                const Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Divider
                const Divider(),

                const SizedBox(height: AppSpacing.lg),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      label: 'Correct',
                      value: '${attempt.score}',
                      color: AppColors.success,
                      icon: Icons.check,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _buildStatItem(
                      label: 'Incorrect',
                      value: '${attempt.totalQuestions - attempt.score}',
                      color: AppColors.error,
                      icon: Icons.close,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _buildStatItem(
                      label: 'Total',
                      value: '${attempt.totalQuestions}',
                      color: AppColors.primary,
                      icon: Icons.quiz,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Attempt info
          if (attempt.attemptNumber > 1)
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Attempt #${attempt.attemptNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xxl),

          // Action buttons
          if (attempt.passed) ...[
            AppButton(
              text: 'Continue to Bank Details',
              onPressed: onContinue,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ] else ...[
            AppButton(
              text: 'Review Training Material',
              onPressed: onReviewTraining,
              variant: AppButtonVariant.outline,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Try Again',
              onPressed: onRetry,
              isFullWidth: true,
              size: AppButtonSize.large,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Compact quiz result summary card.
///
/// Displays a brief pass/fail status with score, suitable for
/// showing recent attempt history or status overview.
///
/// ## Props
/// - [attempt]: The [QuizAttempt] with results
class QuizResultCard extends StatelessWidget {
  final QuizAttempt attempt;

  const QuizResultCard({
    super.key,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: attempt.passed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: attempt.passed
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            attempt.passed ? Icons.check_circle : Icons.cancel,
            color: attempt.passed ? AppColors.success : AppColors.error,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.passed ? 'Quiz Passed!' : 'Quiz Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: attempt.passed ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  'Score: ${attempt.score}/${attempt.totalQuestions} (${attempt.percentage.toInt()}%)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

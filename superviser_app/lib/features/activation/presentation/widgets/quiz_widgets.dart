import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/training_module.dart';

/// Quiz timer widget with countdown display.
class QuizTimer extends StatelessWidget {
  const QuizTimer({
    super.key,
    required this.remainingSeconds,
    this.warningThreshold = 60,
  });

  final int remainingSeconds;
  final int warningThreshold;

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final isWarning = remainingSeconds <= warningThreshold;
    final isDanger = remainingSeconds <= 30;

    Color color;
    if (isDanger) {
      color = AppColors.error;
    } else if (isWarning) {
      color = AppColors.warning;
    } else {
      color = AppColors.textPrimaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Quiz question card with options.
class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedOption,
    required this.onOptionSelected,
    this.showCorrectAnswer = false,
  });

  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedOption;
  final ValueChanged<int> onOptionSelected;
  final bool showCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Question $questionNumber of $totalQuestions',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Question text
          Text(
            question.question,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Options
          ...List.generate(question.options.length, (index) {
            return _buildOption(index);
          }),

          // Explanation (if showing correct answer)
          if (showCorrectAnswer && question.explanation != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explanation',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.explanation!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOption(int index) {
    final isSelected = selectedOption == index;
    final isCorrect = index == question.correctOptionIndex;

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? icon;

    if (showCorrectAnswer) {
      if (isCorrect) {
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        borderColor = AppColors.error;
        textColor = AppColors.error;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.1);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: showCorrectAnswer ? null : () => onOptionSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor ?? AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (textColor ?? AppColors.primary)
                      : AppColors.surfaceVariantLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Option text
              Expanded(
                child: Text(
                  question.options[index],
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor ?? AppColors.textPrimaryLight,
                  ),
                ),
              ),

              // Status icon
              if (icon != null)
                Icon(
                  icon,
                  color: textColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiz progress indicator showing answered questions.
class QuizProgressIndicator extends StatelessWidget {
  const QuizProgressIndicator({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answeredQuestions,
    required this.onQuestionTap,
  });

  final int totalQuestions;
  final int currentQuestion;
  final Set<int> answeredQuestions;
  final ValueChanged<int> onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalQuestions,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAnswered = answeredQuestions.contains(index);
          final isCurrent = index == currentQuestion;

          return GestureDetector(
            onTap: () => onQuestionTap(index),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary
                    : isAnswered
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : isAnswered
                          ? AppColors.success
                          : AppColors.borderLight,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Center(
                child: isAnswered && !isCurrent
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.success,
                      )
                    : Text(
                        '${index + 1}',
                        style: AppTypography.labelMedium.copyWith(
                          color: isCurrent
                              ? Colors.white
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Quiz result card showing score and pass/fail status.
class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    super.key,
    required this.result,
    required this.passingScore,
    required this.onRetry,
    required this.onContinue,
    this.canRetry = true,
  });

  final QuizResult result;
  final int passingScore;
  final VoidCallback onRetry;
  final VoidCallback onContinue;
  final bool canRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Result icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: result.passed
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 64,
              color: result.passed ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 24),

          // Result title
          Text(
            result.passed ? 'Congratulations!' : 'Not Quite There',
            style: AppTypography.headlineSmall.copyWith(
              color: result.passed ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Result message
          Text(
            result.passed
                ? 'You passed the assessment!'
                : 'You need $passingScore% to pass. Keep trying!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Score display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${result.score}%',
                  style: AppTypography.displayMedium.copyWith(
                    color: result.passed ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.correctAnswers} of ${result.totalQuestions} correct',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(
                      'Time',
                      _formatTime(result.timeTakenSeconds),
                      Icons.timer_outlined,
                    ),
                    const SizedBox(width: 24),
                    _buildStat(
                      'Attempt',
                      '#${result.attemptNumber}',
                      Icons.refresh,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          if (result.passed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
            )
          else ...[
            if (canRetry)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ),
            if (!canRetry)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have used all attempts. Please contact support.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}

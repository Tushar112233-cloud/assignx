/// Quiz question display widgets for activation quizzes.
///
/// This file provides widgets for displaying quiz questions during
/// the doer activation process, with multiple choice options and
/// result feedback.
///
/// ## Widgets
/// - [QuizQuestionWidget] - Full question display with options
/// - [QuizNavigationDots] - Navigation dots for question jumping
///
/// ## Features
/// - Question text with progress indicator
/// - Multiple choice options (A, B, C, D)
/// - Correct/incorrect visual feedback
/// - Explanation display after answering
/// - Progress bar and percentage
/// - Navigation dots for jumping between questions
///
/// ## Visual States
/// - **Unselected**: Gray border, neutral styling
/// - **Selected**: Primary color border and background
/// - **Correct**: Green with check icon (after answer)
/// - **Incorrect**: Red with X icon (after answer)
///
/// ## Example
/// ```dart
/// QuizQuestionWidget(
///   question: currentQuestion,
///   questionNumber: 3,
///   totalQuestions: 10,
///   selectedOptionIndex: selectedAnswer,
///   showResult: hasAnswered,
///   onOptionSelected: (index) => selectAnswer(index),
/// )
/// ```
///
/// See also:
/// - [QuizScreen] for usage context
/// - [QuizQuestion] for question data model
/// - [QuizResultWidget] for final results display
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/quiz_model.dart';

/// Full quiz question display widget.
///
/// Displays a single quiz question with progress indicator,
/// multiple choice options, and optional result feedback.
///
/// ## Props
/// - [question]: The [QuizQuestion] to display
/// - [questionNumber]: Current question number (1-indexed)
/// - [totalQuestions]: Total number of questions
/// - [selectedOptionIndex]: Index of selected option (null if none)
/// - [showResult]: Show correct/incorrect feedback
/// - [onOptionSelected]: Callback when option is tapped
class QuizQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedOptionIndex;
  final bool showResult;
  final ValueChanged<int>? onOptionSelected;

  const QuizQuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    this.selectedOptionIndex,
    this.showResult = false,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $questionNumber of $totalQuestions',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Text(
                '${((questionNumber / totalQuestions) * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Progress bar
        ClipRRect(
          borderRadius: AppSpacing.borderRadiusSm,
          child: LinearProgressIndicator(
            value: questionNumber / totalQuestions,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Question text
        Text(
          question.question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Options
        ...List.generate(
          question.options.length,
          (index) => _buildOption(
            option: question.options[index],
            index: index,
            isSelected: selectedOptionIndex == index,
            isCorrect: showResult && question.correctOptionIndex == index,
            isWrong: showResult &&
                selectedOptionIndex == index &&
                question.correctOptionIndex != index,
          ),
        ),

        // Explanation (shown after answering)
        if (showResult && question.explanation != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMd,
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
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    question.explanation!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOption({
    required QuizOption option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
  }) {
    Color borderColor;
    Color bgColor;
    Color textColor;
    IconData? trailingIcon;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        trailingIcon = Icons.check_circle;
      } else if (isWrong) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        trailingIcon = Icons.cancel;
      } else {
        borderColor = AppColors.border;
        bgColor = Colors.transparent;
        textColor = AppColors.textSecondary;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
      } else {
        borderColor = AppColors.border;
        bgColor = Colors.transparent;
        textColor = AppColors.textPrimary;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showResult ? null : () => onOptionSelected?.call(index),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: borderColor,
                width: isSelected || isCorrect || isWrong ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Option letter
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected || isCorrect
                        ? borderColor
                        : AppColors.background,
                    border: Border.all(
                      color: borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected || isCorrect
                            ? Colors.white
                            : textColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Option text
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),

                // Result icon
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: borderColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation dots for jumping between quiz questions.
///
/// Displays a grid of numbered dots representing each question,
/// with visual feedback for current position and answered questions.
///
/// ## Visual States
/// - **Current**: Primary color filled
/// - **Answered**: Success color filled
/// - **Unanswered**: Gray border only
///
/// ## Props
/// - [totalQuestions]: Total number of questions
/// - [currentQuestion]: Currently displayed question index
/// - [answers]: Map of question IDs to answer indices
/// - [questions]: List of questions for ID lookup
/// - [onDotTapped]: Callback when dot is tapped
class QuizNavigationDots extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final Map<String, int> answers;
  final List<QuizQuestion> questions;
  final ValueChanged<int>? onDotTapped;

  const QuizNavigationDots({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answers,
    required this.questions,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        totalQuestions,
        (index) {
          final isAnswered = answers.containsKey(questions[index].id);
          final isCurrent = currentQuestion == index;

          return GestureDetector(
            onTap: () => onDotTapped?.call(index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? AppColors.primary
                    : isAnswered
                        ? AppColors.success
                        : AppColors.background,
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : isAnswered
                          ? AppColors.success
                          : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCurrent || isAnswered
                        ? Colors.white
                        : AppColors.textSecondary,
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

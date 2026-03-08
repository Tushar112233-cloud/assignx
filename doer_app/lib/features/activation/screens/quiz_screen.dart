import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/quiz_model.dart';
import '../../../providers/activation_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../widgets/quiz_question.dart';
import '../widgets/quiz_result.dart';
import '../../../core/translation/translation_extensions.dart';

/// Quiz screen for the activation interview quiz.
///
/// Presents a multiple-choice quiz that users must pass to proceed
/// with the activation process. Questions are loaded from the activation state.
///
/// ## Navigation
/// - Entry: From [ActivationGateScreen] (Step 2, requires training completion)
/// - Exit: Confirmation dialog, returns to [ActivationGateScreen]
/// - Pass: Shows result, then [BankDetailsScreen]
/// - Fail: Shows result with retry/review options
///
/// ## Features
/// - One question at a time navigation
/// - Question navigator grid showing progress
/// - Previous/Next navigation buttons
/// - Answer selection with visual feedback
/// - Unanswered question warning before submit
/// - Pass/fail result display with score
/// - Retry quiz or review training options
///
/// ## Quiz Flow
/// 1. Display questions one at a time
/// 2. Track answers in local state
/// 3. Allow navigation between questions
/// 4. Submit all answers together
/// 5. Show result with pass/fail status
///
/// ## State Management
/// Uses [ActivationProvider] to fetch questions and submit answers.
/// Local state tracks current question and user answers.
///
/// See also:
/// - [ActivationProvider] for quiz data and submission
/// - [QuizQuestionWidget] for question display
/// - [QuizResultWidget] for result display
/// - [BankDetailsScreen] for the next activation step
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

/// State class for [QuizScreen].
///
/// Manages quiz navigation, answer collection, and result display.
class _QuizScreenState extends ConsumerState<QuizScreen> {
  /// Index of the currently displayed question (0-based).
  int _currentQuestionIndex = 0;

  /// Map of question ID to selected option index.
  final Map<String, int> _answers = {};

  /// Whether quiz submission is in progress.
  bool _isSubmitting = false;

  /// Quiz attempt result after submission.
  QuizAttempt? _result;

  /// Whether to show the result screen.
  bool _showingResult = false;

  /// Builds the quiz screen UI.
  ///
  /// Shows loading state if questions not loaded, result screen if
  /// quiz submitted, or question navigation otherwise.
  @override
  Widget build(BuildContext context) {
    final activationState = ref.watch(activationProvider);
    final questions = activationState.quizQuestions;

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Quiz'.tr(context)),
        ),
        body: MeshGradientBackground(
          position: MeshPosition.center,
          colors: MeshColors.coolColors,
          opacity: 0.5,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show result screen if quiz is submitted
    if (_showingResult && _result != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Quiz Result'.tr(context),
            style: TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: MeshGradientBackground(
          position: MeshPosition.center,
          colors: MeshColors.defaultColors,
          opacity: 0.5,
          child: SafeArea(
            child: QuizResultWidget(
              attempt: _result!,
              onRetry: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _answers.clear();
                  _result = null;
                  _showingResult = false;
                });
              },
              onContinue: () => context.go(RouteNames.bankDetails),
              onReviewTraining: () => context.go(RouteNames.training),
            ),
          ),
        ),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        title: Text(
          'Interview Quiz'.tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Question navigation
          TextButton(
            onPressed: () => _showQuestionNavigator(context, questions),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_answers.length}/${questions.length}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        colors: MeshColors.coolColors,
        opacity: 0.4,
        child: SafeArea(
          child: Column(
            children: [
              // Step indicator dots - Step 2 active
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: _buildStepIndicatorDots(1),
              ),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLg,
                  child: QuizQuestionWidget(
                    question: currentQuestion,
                    questionNumber: _currentQuestionIndex + 1,
                    totalQuestions: questions.length,
                    selectedOptionIndex: _answers[currentQuestion.id],
                    onOptionSelected: (index) {
                      setState(() {
                        _answers[currentQuestion.id] = index;
                      });
                    },
                  ),
                ),
              ),

              // Bottom navigation in glass container
              GlassContainer(
                blur: 20,
                opacity: 0.9,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                padding: AppSpacing.paddingLg,
                child: SafeArea(
                  child: Row(
                    children: [
                      // Previous button
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: AppButton(
                            text: 'Previous',
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            },
                            variant: AppButtonVariant.outline,
                          ),
                        ),

                      if (_currentQuestionIndex > 0)
                        const SizedBox(width: AppSpacing.md),

                      // Next/Submit button
                      Expanded(
                        flex: _currentQuestionIndex > 0 ? 1 : 2,
                        child: AppButton(
                          text: _currentQuestionIndex == questions.length - 1
                              ? 'Submit Quiz'
                              : 'Next',
                          onPressed: _answers.containsKey(currentQuestion.id)
                              ? () => _handleNextOrSubmit(questions)
                              : null,
                          isLoading: _isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles next button press - advances to next question or submits.
  void _handleNextOrSubmit(List<QuizQuestion> questions) {
    if (_currentQuestionIndex == questions.length - 1) {
      // Submit quiz
      _submitQuiz();
    } else {
      // Go to next question
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  /// Submits the quiz for grading.
  ///
  /// Warns about unanswered questions before submission.
  /// On completion, stores result and shows result screen.
  Future<void> _submitQuiz() async {
    // Check if all questions are answered
    final questions = ref.read(activationProvider).quizQuestions;
    final unanswered = questions.where((q) => !_answers.containsKey(q.id)).toList();

    if (unanswered.isNotEmpty) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unanswered Questions'.tr(context)),
          content: Text(
            'You have ${unanswered.length} unanswered question(s). '
            'Do you want to submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Review'.tr(context)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Submit'.tr(context)),
            ),
          ],
        ),
      );

      if (shouldSubmit != true) return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref.read(activationProvider.notifier).submitQuiz(_answers);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _result = result;
        _showingResult = true;
      });
    }
  }

  /// Shows confirmation dialog before exiting the quiz.
  ///
  /// Warns that progress will be lost.
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Quiz?'.tr(context)),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?'.tr(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.activationGate);
            },
            child: Text(
              'Exit'.tr(context),
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows bottom sheet with question navigation grid.
  ///
  /// Allows jumping to any question and shows answer status
  /// (answered, current, unanswered) with color coding.
  void _showQuestionNavigator(BuildContext context, List<QuizQuestion> questions) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions'.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_answers.length} of ${questions.length} answered',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            QuizNavigationDots(
              totalQuestions: questions.length,
              currentQuestion: _currentQuestionIndex,
              answers: _answers,
              questions: questions,
              onDotTapped: (index) {
                Navigator.pop(context);
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                _buildLegendItem(AppColors.success, 'Answered'),
                const SizedBox(width: AppSpacing.lg),
                _buildLegendItem(AppColors.accent, 'Current'),
                const SizedBox(width: AppSpacing.lg),
                _buildLegendItem(AppColors.border, 'Unanswered'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Builds a legend item for the question navigator.
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
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

  /// Builds the horizontal step indicator dots.
  ///
  /// [activeIndex] indicates which step is currently active (0-based).
  Widget _buildStepIndicatorDots(int activeIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == activeIndex;
        final isCompleted = index < activeIndex;

        return Container(
          width: isActive ? 32 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: isCompleted || isActive
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  )
                : null,
            color: !isCompleted && !isActive ? AppColors.border : null,
          ),
        );
      }),
    );
  }
}

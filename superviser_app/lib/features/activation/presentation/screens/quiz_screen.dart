import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../providers/activation_provider.dart';
import '../widgets/quiz_widgets.dart';

/// Quiz Screen (S15-S16)
///
/// Displays quiz with timer, questions, and result handling.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizId,
  });

  final String quizId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    // Load quiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).loadQuiz(widget.quizId);
    });
  }

  @override
  void dispose() {
    ref.read(quizProvider.notifier).stopTimer();
    super.dispose();
  }

  void _startQuiz() {
    setState(() {
      _hasStarted = true;
    });
    ref.read(quizProvider.notifier).startTimer();
  }

  Future<void> _confirmSubmit() async {
    final state = ref.read(quizProvider);
    final unanswered = state.totalQuestions - state.answeredCount;

    if (unanswered > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submit Quiz?'),
          content: Text(
            'You have $unanswered unanswered question${unanswered > 1 ? 's' : ''}. '
            'Are you sure you want to submit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue Quiz'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        ref.read(quizProvider.notifier).submitQuiz();
      }
    } else {
      ref.read(quizProvider.notifier).submitQuiz();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasStarted) return true;

    final state = ref.read(quizProvider);
    if (state.result != null) return true;

    final shouldLeave = await ConfirmDialog.show(
      context,
      title: 'Leave Quiz?',
      message: 'Your progress will be lost if you leave now.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
      isDestructive: true,
    );

    if (shouldLeave) {
      ref.read(quizProvider.notifier).stopTimer();
    }

    return shouldLeave;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: _hasStarted && state.result == null
            ? AppBar(
                title: Text(state.quiz?.title ?? 'Quiz'),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: QuizTimer(remainingSeconds: state.remainingSeconds),
                  ),
                ],
              )
            : AppBar(
                title: const Text('Supervisor Assessment'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && mounted) {
                      context.pop();
                    }
                  },
                ),
              ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.result != null
                ? _buildResult(state)
                : !_hasStarted
                    ? _buildStartScreen(state)
                    : _buildQuiz(state),
      ),
    );
  }

  Widget _buildStartScreen(QuizState state) {
    final quiz = state.quiz;
    if (quiz == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.quiz_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            quiz.title,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            quiz.description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Quiz info cards
          _buildInfoCard(
            icon: Icons.help_outline,
            title: '${quiz.totalQuestions} Questions',
            subtitle: 'Multiple choice questions',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.timer_outlined,
            title: '${quiz.timeLimitMinutes} Minutes',
            subtitle: 'Time limit for completion',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.check_circle_outline,
            title: '${quiz.passingScore}% to Pass',
            subtitle: 'Minimum score required',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.refresh,
            title: '${quiz.maxAttempts} Attempts',
            subtitle: 'Maximum allowed tries',
          ),
          const SizedBox(height: 32),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startQuiz,
              child: const Text('Start Quiz'),
            ),
          ),
          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(QuizState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: QuizProgressIndicator(
            totalQuestions: state.totalQuestions,
            currentQuestion: state.currentQuestionIndex,
            answeredQuestions: state.answers.keys.toSet(),
            onQuestionTap: ref.read(quizProvider.notifier).goToQuestion,
          ),
        ),

        // Question
        Expanded(
          child: QuizQuestionCard(
            question: question,
            questionNumber: state.currentQuestionIndex + 1,
            totalQuestions: state.totalQuestions,
            selectedOption: state.answers[state.currentQuestionIndex],
            onOptionSelected: ref.read(quizProvider.notifier).selectAnswer,
          ),
        ),

        // Navigation
        _buildNavigation(state),
      ],
    );
  }

  Widget _buildNavigation(QuizState state) {
    final isFirst = state.currentQuestionIndex == 0;
    final isLast = state.currentQuestionIndex == state.totalQuestions - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: ref.read(quizProvider.notifier).previousQuestion,
                child: const Text('Previous'),
              ),
            ),
          if (!isFirst) const SizedBox(width: 16),
          Expanded(
            flex: isFirst ? 2 : 1,
            child: ElevatedButton(
              onPressed: isLast
                  ? _confirmSubmit
                  : ref.read(quizProvider.notifier).nextQuestion,
              child: Text(isLast ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(QuizState state) {
    final result = state.result!;
    final quiz = state.quiz!;

    return QuizResultCard(
      result: result,
      passingScore: quiz.passingScore,
      canRetry: result.attemptNumber < quiz.maxAttempts,
      onRetry: () {
        ref.read(quizProvider.notifier).resetQuiz();
        setState(() {
          _hasStarted = false;
        });
      },
      onContinue: () {
        // Refresh activation state and go back
        ref.read(activationProvider.notifier).loadModules();
        context.pop();
      },
    );
  }
}

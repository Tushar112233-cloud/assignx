import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
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
          title: Text('Submit Quiz?'.tr(context)),
          content: Text(
            '${'You have'.tr(context)} $unanswered ${'unanswered question${unanswered > 1 ? 's' : ''}'.tr(context)}. '
            '${'Are you sure you want to submit?'.tr(context)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Continue Quiz'.tr(context)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Submit'.tr(context)),
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
      title: 'Leave Quiz?'.tr(context),
      message: 'Your progress will be lost if you leave now.'.tr(context),
      confirmLabel: 'Leave'.tr(context),
      cancelLabel: 'Stay'.tr(context),
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
        extendBodyBehindAppBar: true,
        appBar: _hasStarted && state.result == null
            ? AppBar(
                title: Text(state.quiz?.title ?? 'Quiz'.tr(context)),
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child:
                        QuizTimer(remainingSeconds: state.remainingSeconds),
                  ),
                ],
              )
            : AppBar(
                title: Text('Supervisor Assessment'.tr(context)),
                backgroundColor: Colors.transparent,
                elevation: 0,
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
        body: MeshGradientBackground(
          position: MeshPosition.topRight,
          colors: MeshColors.warmColors,
          opacity: 0.4,
          child: SafeArea(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.result != null
                    ? _buildResult(state)
                    : !_hasStarted
                        ? _buildStartScreen(state)
                        : _buildQuiz(state),
          ),
        ),
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
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.quiz_outlined,
              size: 40,
              color: AppColors.accent,
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

          // Quiz info cards in glass containers
          _buildInfoCard(
            icon: Icons.help_outline,
            title: '${quiz.totalQuestions} ${'Questions'.tr(context)}',
            subtitle: 'Multiple choice questions'.tr(context),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.timer_outlined,
            title: '${quiz.timeLimitMinutes} ${'Minutes'.tr(context)}',
            subtitle: 'Time limit for completion'.tr(context),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.check_circle_outline,
            title: '${quiz.passingScore}% ${'to Pass'.tr(context)}',
            subtitle: 'Minimum score required'.tr(context),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.refresh,
            title: '${quiz.maxAttempts} ${'Attempts'.tr(context)}',
            subtitle: 'Maximum allowed tries'.tr(context),
          ),
          const SizedBox(height: 32),

          // Start button with orange accent
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Start Quiz'.tr(context)),
            ),
          ),
          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel'.tr(context)),
          ),
        ],
      ),
    );
  }

  /// Glass info card for quiz metadata.
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
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
        // Progress indicator with orange accent
        Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(14),
            elevation: 1,
            child: QuizProgressIndicator(
              totalQuestions: state.totalQuestions,
              currentQuestion: state.currentQuestionIndex,
              answeredQuestions: state.answers.keys.toSet(),
              onQuestionTap: ref.read(quizProvider.notifier).goToQuestion,
            ),
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

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      opacity: 0.9,
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: ref.read(quizProvider.notifier).previousQuestion,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent),
                  foregroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Previous'.tr(context)),
              ),
            ),
          if (!isFirst) const SizedBox(width: 16),
          Expanded(
            flex: isFirst ? 2 : 1,
            child: ElevatedButton(
              onPressed: isLast
                  ? _confirmSubmit
                  : ref.read(quizProvider.notifier).nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isLast ? 'Submit'.tr(context) : 'Next'.tr(context)),
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

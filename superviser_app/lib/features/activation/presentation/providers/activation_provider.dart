import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/models/training_module.dart';
import '../../data/repositories/activation_repository.dart';

/// Activation state
class ActivationState {
  const ActivationState({
    this.modules = const [],
    this.currentModuleIndex = 0,
    this.isLoading = false,
    this.error,
    this.isActivated = false,
  });

  /// Training modules
  final List<TrainingModule> modules;

  /// Current module index being viewed
  final int currentModuleIndex;

  /// Whether an operation is in progress
  final bool isLoading;

  /// Error message
  final String? error;

  /// Whether activation is complete
  final bool isActivated;

  /// Current module
  TrainingModule? get currentModule =>
      modules.isNotEmpty ? modules[currentModuleIndex] : null;

  /// Number of completed modules
  int get completedCount => modules.where((m) => m.isCompleted).length;

  /// Total number of modules
  int get totalCount => modules.length;

  /// Progress percentage (0.0 - 1.0)
  double get progress => totalCount > 0 ? completedCount / totalCount : 0.0;

  /// Whether all modules are complete
  bool get isAllComplete => completedCount == totalCount && totalCount > 0;

  ActivationState copyWith({
    List<TrainingModule>? modules,
    int? currentModuleIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isActivated,
  }) {
    return ActivationState(
      modules: modules ?? this.modules,
      currentModuleIndex: currentModuleIndex ?? this.currentModuleIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isActivated: isActivated ?? this.isActivated,
    );
  }
}

/// Activation notifier
class ActivationNotifier extends StateNotifier<ActivationState> {
  ActivationNotifier(this._repository) : super(const ActivationState()) {
    loadModules();
  }

  final ActivationRepository _repository;

  /// Loads training modules
  Future<void> loadModules() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final modules = await _repository.getTrainingModules();
      state = state.copyWith(
        modules: modules,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load training modules: $e',
      );
    }
  }

  /// Marks current module as complete
  Future<void> markCurrentModuleComplete() async {
    final currentModule = state.currentModule;
    if (currentModule == null || currentModule.isCompleted) return;

    try {
      state = state.copyWith(isLoading: true);
      await _repository.markModuleComplete(currentModule.id);

      // Update local state
      final updatedModules = state.modules.map((m) {
        if (m.id == currentModule.id) {
          return m.copyWith(isCompleted: true, completedAt: DateTime.now());
        }
        return m;
      }).toList();

      state = state.copyWith(
        modules: updatedModules,
        isLoading: false,
      );

      // Check if all complete
      if (state.isAllComplete) {
        await activateSupervisor();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to mark module complete: $e',
      );
    }
  }

  /// Navigates to next module
  void nextModule() {
    if (state.currentModuleIndex < state.modules.length - 1) {
      state = state.copyWith(
        currentModuleIndex: state.currentModuleIndex + 1,
      );
    }
  }

  /// Navigates to previous module
  void previousModule() {
    if (state.currentModuleIndex > 0) {
      state = state.copyWith(
        currentModuleIndex: state.currentModuleIndex - 1,
      );
    }
  }

  /// Goes to specific module
  void goToModule(int index) {
    if (index >= 0 && index < state.modules.length) {
      state = state.copyWith(currentModuleIndex: index);
    }
  }

  /// Activates the supervisor
  Future<void> activateSupervisor() async {
    try {
      state = state.copyWith(isLoading: true);
      await _repository.activateSupervisor();
      state = state.copyWith(
        isLoading: false,
        isActivated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to activate: $e',
      );
    }
  }

  /// Clears error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Quiz state
class QuizState {
  const QuizState({
    this.quiz,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isLoading = false,
    this.error,
    this.result,
    this.remainingSeconds = 0,
    this.isSubmitting = false,
  });

  /// Quiz data
  final Quiz? quiz;

  /// Current question index
  final int currentQuestionIndex;

  /// User answers (question index -> selected option index)
  final Map<int, int> answers;

  /// Loading state
  final bool isLoading;

  /// Error message
  final String? error;

  /// Quiz result after submission
  final QuizResult? result;

  /// Remaining time in seconds
  final int remainingSeconds;

  /// Whether quiz is being submitted
  final bool isSubmitting;

  /// Current question
  QuizQuestion? get currentQuestion =>
      quiz != null ? quiz!.questions[currentQuestionIndex] : null;

  /// Total questions
  int get totalQuestions => quiz?.questions.length ?? 0;

  /// Answered questions count
  int get answeredCount => answers.length;

  /// Whether all questions are answered
  bool get isComplete => answeredCount == totalQuestions;

  /// Formatted remaining time
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  QuizState copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<int, int>? answers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    QuizResult? result,
    int? remainingSeconds,
    bool? isSubmitting,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: result ?? this.result,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// Quiz notifier
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._repository) : super(const QuizState());

  final ActivationRepository _repository;
  Timer? _timer;

  /// Loads quiz by ID
  Future<void> loadQuiz(String quizId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final quiz = await _repository.getQuiz(quizId);
      state = state.copyWith(
        quiz: quiz,
        isLoading: false,
        remainingSeconds: quiz.timeLimitMinutes * 60,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load quiz: $e',
      );
    }
  }

  /// Starts the quiz timer
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        timer.cancel();
        submitQuiz();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  /// Stops the timer
  void stopTimer() {
    _timer?.cancel();
  }

  /// Selects an answer for current question
  void selectAnswer(int optionIndex) {
    final newAnswers = Map<int, int>.from(state.answers);
    newAnswers[state.currentQuestionIndex] = optionIndex;
    state = state.copyWith(answers: newAnswers);
  }

  /// Goes to next question
  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Goes to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// Goes to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// Submits the quiz
  Future<void> submitQuiz() async {
    if (state.quiz == null || state.isSubmitting) return;

    stopTimer();
    state = state.copyWith(isSubmitting: true);

    try {
      // Calculate score
      int correctCount = 0;
      for (int i = 0; i < state.quiz!.questions.length; i++) {
        final question = state.quiz!.questions[i];
        final userAnswer = state.answers[i];
        if (userAnswer == question.correctOptionIndex) {
          correctCount++;
        }
      }

      final score = (correctCount / state.totalQuestions * 100).round();
      final passed = score >= state.quiz!.passingScore;
      final timeTaken =
          (state.quiz!.timeLimitMinutes * 60) - state.remainingSeconds;

      // Get attempt number
      final attempts = await _repository.getQuizAttempts(state.quiz!.id);

      final result = QuizResult(
        quizId: state.quiz!.id,
        score: score,
        totalQuestions: state.totalQuestions,
        correctAnswers: correctCount,
        timeTakenSeconds: timeTaken,
        passed: passed,
        attemptNumber: attempts + 1,
        completedAt: DateTime.now(),
      );

      // Submit result
      await _repository.submitQuizResult(result);

      state = state.copyWith(
        result: result,
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quiz: $e',
      );
    }
  }

  /// Resets quiz for retry
  void resetQuiz() {
    state = QuizState(
      quiz: state.quiz,
      remainingSeconds: state.quiz?.timeLimitMinutes ?? 0 * 60,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Repository provider
final activationRepositoryProvider = Provider<ActivationRepository>((ref) {
  return ActivationRepository(ref.watch(supabaseClientProvider));
});

/// Activation state provider
final activationProvider =
    StateNotifierProvider<ActivationNotifier, ActivationState>((ref) {
  return ActivationNotifier(ref.watch(activationRepositoryProvider));
});

/// Quiz state provider
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref.watch(activationRepositoryProvider));
});

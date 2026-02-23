/// Doer activation state management provider.
///
/// This file manages the multi-step activation process that new doers must
/// complete before they can accept projects. The activation flow includes:
/// 1. Training module completion
/// 2. Quiz assessment
/// 3. Bank details submission
///
/// ## Architecture
///
/// The activation system follows a step-by-step flow:
/// - **Training**: Doers complete required training modules
/// - **Quiz**: Doers pass a knowledge assessment quiz
/// - **Bank Details**: Doers submit payment information
///
/// ## Usage
///
/// ```dart
/// // Watch activation state in a widget
/// final activationState = ref.watch(activationProvider);
///
/// // Check if user is fully activated
/// if (activationState.status.isFullyActivated) {
///   // User can access full dashboard
/// }
///
/// // Complete a training module
/// final success = await ref.read(activationProvider.notifier)
///     .completeTrainingModule(moduleId);
///
/// // Submit quiz answers
/// final result = await ref.read(activationProvider.notifier)
///     .submitQuiz(answers);
/// ```
///
/// ## State Flow
///
/// ```
/// initial -> loading activation data
///     |
///     v
/// training modules -> quiz -> bank details -> fully activated
/// ```
///
/// ## Database Integration
///
/// The provider interacts with several Supabase tables:
/// - `doer_activation`: Tracks overall activation status
/// - `training_modules`: Available training content
/// - `training_progress`: User's progress on modules
/// - `quiz_questions`: Assessment questions
/// - `quiz_attempts`: Quiz submission history
/// - `bank_details`: Payment information
///
/// See also:
/// - [AuthNotifier] for user authentication
/// - [ActivationStatus] for activation state tracking
/// - [TrainingModule] for training content model
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../data/models/activation_model.dart';
import '../data/models/bank_details_model.dart' hide BankDetailsFormData;
import '../data/models/quiz_model.dart';
import '../data/models/training_model.dart';
import 'auth_provider.dart';

/// Notifier class that manages doer activation state and workflow.
///
/// This class handles the entire activation process for new doers, including:
/// - Loading and tracking activation status
/// - Managing training module progress
/// - Processing quiz submissions
/// - Handling bank details submission
/// - Checking and updating full activation status
///
/// ## Lifecycle
///
/// The notifier initializes by:
/// 1. Watching the current user from [currentUserProvider]
/// 2. Loading activation data if user has a doer profile
/// 3. Creating initial activation status if none exists
///
/// ## State Management
///
/// State is managed through [ActivationState] which contains:
/// - [ActivationStatus]: Overall activation progress
/// - [List<TrainingModule>]: Available training modules
/// - [Map<String, TrainingProgress>]: Per-module progress
/// - [List<QuizQuestion>]: Quiz assessment questions
/// - [QuizAttempt]: Last quiz attempt results
/// - [BankDetails]: Saved bank information
///
/// ## Usage
///
/// ```dart
/// // Access the notifier
/// final notifier = ref.read(activationProvider.notifier);
///
/// // Complete a training module
/// await notifier.completeTrainingModule('module-123');
///
/// // Submit quiz
/// final result = await notifier.submitQuiz({
///   'question-1': 0,  // Answer index 0 for question 1
///   'question-2': 2,  // Answer index 2 for question 2
/// });
///
/// // Submit bank details
/// await notifier.submitBankDetails(BankDetailsFormData(
///   accountHolderName: 'John Doe',
///   accountNumber: '1234567890',
///   ifscCode: 'SBIN0001234',
/// ));
/// ```
class ActivationNotifier extends Notifier<ActivationState> {
  /// Builds and initializes the activation state.
  ///
  /// This method is called when the provider is first read. It:
  /// 1. Watches the current user from [currentUserProvider]
  /// 2. Loads activation data if the user has a doer ID
  /// 3. Returns an initial empty state
  ///
  /// ## Returns
  ///
  /// An [ActivationState] with empty status if no user or doer profile,
  /// or triggers loading of activation data in the background.
  @override
  ActivationState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null && user.doerId != null) {
      _loadActivationData(user.doerId!);
    }
    return ActivationState(
      status: _createEmptyStatus(user?.doerId ?? ''),
    );
  }

  /// Creates an empty activation status placeholder.
  ///
  /// Used when no activation record exists yet for a new doer.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to associate with the status
  ///
  /// ## Returns
  ///
  /// An [ActivationStatus] with default values (all steps incomplete).
  ActivationStatus _createEmptyStatus(String doerId) {
    return ActivationStatus(
      id: '',
      doerId: doerId,
      createdAt: DateTime.now(),
    );
  }

  /// The Supabase client instance for database operations.
  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads all activation-related data from the database.
  ///
  /// This method orchestrates loading of:
  /// - Activation status
  /// - Training modules and progress
  /// - Quiz questions
  /// - Last quiz attempt
  /// - Bank details
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to load data for
  ///
  /// ## State Updates
  ///
  /// Sets [isLoading] to true during load, false on completion.
  /// Sets [errorMessage] if loading fails.
  Future<void> _loadActivationData(String doerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load activation status
      await _loadActivationStatus(doerId);

      // Load training modules
      await _loadTrainingModules(doerId);

      // Load quiz questions
      await _loadQuizQuestions();

      // Load last quiz attempt
      await _loadLastQuizAttempt(doerId);

      // Load bank details
      await _loadBankDetails(doerId);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load activation data',
      );
    }
  }

  /// Loads the doer's activation status from the database.
  ///
  /// If no status record exists, creates a new one.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to load status for
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.status] with the loaded or created status.
  Future<void> _loadActivationStatus(String doerId) async {
    try {
      final response = await _client
          .from('doer_activation')
          .select()
          .eq('doer_id', doerId)
          .maybeSingle();

      if (response != null) {
        state = state.copyWith(
          status: ActivationStatus.fromJson(response),
        );
      } else {
        // Create initial activation status
        await _createInitialActivationStatus(doerId);
      }
    } catch (e) {
      // Status might not exist yet, create it
      await _createInitialActivationStatus(doerId);
    }
  }

  /// Creates the initial activation status record for a new doer.
  ///
  /// Inserts a new record in the `doer_activation` table with all
  /// steps marked as incomplete.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to create status for
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.status] with the newly created status.
  Future<void> _createInitialActivationStatus(String doerId) async {
    try {
      final response = await _client.from('doer_activation').insert({
        'doer_id': doerId,
        'training_completed': false,
        'quiz_passed': false,
        'bank_details_added': false,
        'is_fully_activated': false,
      }).select().single();

      state = state.copyWith(
        status: ActivationStatus.fromJson(response),
      );
    } catch (e) {
      // Ignore duplicate key errors, use empty status
      state = state.copyWith(
        status: _createEmptyStatus(doerId),
      );
    }
  }

  /// Loads training modules and the doer's progress.
  ///
  /// Fetches all available training modules and the doer's
  /// progress on each module.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to load progress for
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.trainingModules] and
  /// [ActivationState.trainingProgress].
  Future<void> _loadTrainingModules(String doerId) async {
    try {
      final modulesResponse = await _client
          .from('training_modules')
          .select()
          .order('order_index');

      final modules = (modulesResponse as List)
          .map((e) => TrainingModule.fromJson(e))
          .toList();

      // Load progress for each module
      final progressResponse = await _client
          .from('training_progress')
          .select()
          .eq('doer_id', doerId);

      final progressMap = <String, TrainingProgress>{};
      for (final p in progressResponse) {
        final progress = TrainingProgress.fromJson(p);
        progressMap[progress.moduleId] = progress;
      }

      state = state.copyWith(
        trainingModules: modules,
        trainingProgress: progressMap,
      );
    } catch (e) {
      // Log error and set empty state - do not use mock data in production
      state = state.copyWith(
        trainingModules: [],
        trainingProgress: {},
        errorMessage: 'Failed to load training modules. Please try again.',
      );
    }
  }

  /// Loads quiz questions from the database.
  ///
  /// Fetches all quiz questions ordered by their display order.
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.quizQuestions] with loaded questions,
  /// or empty list and error message on failure.
  Future<void> _loadQuizQuestions() async {
    try {
      final response = await _client
          .from('quiz_questions')
          .select()
          .order('order_index');

      final questions = (response as List)
          .map((e) => QuizQuestion.fromJson(e))
          .toList();

      state = state.copyWith(quizQuestions: questions);
    } catch (e) {
      // Log error and set empty state - do not use mock data in production
      state = state.copyWith(
        quizQuestions: [],
        errorMessage: 'Failed to load quiz questions. Please try again.',
      );
    }
  }

  /// Loads the doer's last quiz attempt.
  ///
  /// Fetches the most recent quiz attempt to show previous results
  /// and determine if retakes are allowed.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to load attempt for
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.lastQuizAttempt] if a previous attempt exists.
  Future<void> _loadLastQuizAttempt(String doerId) async {
    try {
      final response = await _client
          .from('quiz_attempts')
          .select()
          .eq('doer_id', doerId)
          .order('attempted_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        state = state.copyWith(
          lastQuizAttempt: QuizAttempt.fromJson(response),
        );
      }
    } catch (e) {
      // No previous attempt
    }
  }

  /// Loads the doer's bank details.
  ///
  /// Fetches saved bank account information if it exists.
  ///
  /// ## Parameters
  ///
  /// - [doerId]: The doer's ID to load bank details for
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.bankDetails] if bank details exist.
  Future<void> _loadBankDetails(String doerId) async {
    try {
      final response = await _client
          .from('bank_details')
          .select()
          .eq('doer_id', doerId)
          .maybeSingle();

      if (response != null) {
        state = state.copyWith(
          bankDetails: BankDetails.fromJson(response),
        );
      }
    } catch (e) {
      // No bank details yet
    }
  }

  /// Marks a training module as complete.
  ///
  /// Updates or creates a progress record for the specified module
  /// and checks if all training is now complete.
  ///
  /// ## Parameters
  ///
  /// - [moduleId]: The ID of the training module to mark complete
  ///
  /// ## Returns
  ///
  /// `true` if the module was successfully marked complete, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.trainingProgress] with 100% completion.
  /// May also update [ActivationState.status] if all training is complete.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(activationProvider.notifier)
  ///     .completeTrainingModule('module-getting-started');
  ///
  /// if (success) {
  ///   // Show completion message
  /// }
  /// ```
  Future<bool> completeTrainingModule(String moduleId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      final now = DateTime.now();

      // Check if progress exists
      final existing = state.trainingProgress[moduleId];

      if (existing != null) {
        await _client
            .from('training_progress')
            .update({
              'is_completed': true,
              'progress_percent': 100,
              'completed_at': now.toIso8601String(),
            })
            .eq('id', existing.id);
      } else {
        await _client.from('training_progress').insert({
          'profile_id': user.id,
          'module_id': moduleId,
          'status': 'completed',
          'progress_percentage': 100,
          'started_at': now.toIso8601String(),
          'completed_at': now.toIso8601String(),
        });
      }

      // Update local state
      final updatedProgress = Map<String, TrainingProgress>.from(state.trainingProgress);
      updatedProgress[moduleId] = TrainingProgress(
        id: existing?.id ?? moduleId,
        doerId: user.doerId ?? user.id,
        moduleId: moduleId,
        isCompleted: true,
        progressPercent: 100,
        completedAt: now,
        startedAt: existing?.startedAt ?? now,
      );

      state = state.copyWith(trainingProgress: updatedProgress);

      // Check if all training is complete
      await _checkTrainingCompletion();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if all training modules are complete and updates status.
  ///
  /// Called after a module is completed to check if the training
  /// step of activation is now finished.
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationStatus.trainingCompleted] to true if all
  /// modules are complete.
  Future<void> _checkTrainingCompletion() async {
    if (state.allTrainingCompleted) {
      await _updateActivationStatus(trainingCompleted: true);
    }
  }

  /// Submits quiz answers and calculates the result.
  ///
  /// Processes the user's answers, calculates score, determines
  /// pass/fail status, and saves the attempt.
  ///
  /// ## Parameters
  ///
  /// - [answers]: Map of question IDs to selected answer indices
  ///
  /// ## Returns
  ///
  /// A [QuizAttempt] containing the results, or null on failure.
  ///
  /// ## Passing Criteria
  ///
  /// A score of 70% or higher is required to pass the quiz.
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.lastQuizAttempt] with the new attempt.
  /// Updates [ActivationStatus.quizPassed] if the user passes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await ref.read(activationProvider.notifier).submitQuiz({
  ///   'q1': 0,  // Selected first option for question 1
  ///   'q2': 2,  // Selected third option for question 2
  ///   'q3': 1,  // Selected second option for question 3
  /// });
  ///
  /// if (result != null) {
  ///   if (result.passed) {
  ///     // Congratulations!
  ///   } else {
  ///     // Show retry option
  ///   }
  /// }
  /// ```
  Future<QuizAttempt?> submitQuiz(Map<String, int> answers) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      int score = 0;
      final quizAnswers = <QuizAnswer>[];

      for (final question in state.quizQuestions) {
        final selectedIndex = answers[question.id] ?? -1;
        final isCorrect = question.isCorrect(selectedIndex);
        if (isCorrect) score++;

        quizAnswers.add(QuizAnswer(
          questionId: question.id,
          selectedOptionIndex: selectedIndex,
          isCorrect: isCorrect,
        ));
      }

      final totalQuestions = state.quizQuestions.length;
      final passed = (score / totalQuestions) >= 0.7; // 70% passing threshold
      final attemptNumber = (state.lastQuizAttempt?.attemptNumber ?? 0) + 1;

      final attempt = QuizAttempt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doerId: user.id,
        score: score,
        totalQuestions: totalQuestions,
        passed: passed,
        attemptNumber: attemptNumber,
        answers: quizAnswers,
        attemptedAt: DateTime.now(),
      );

      // Save to database
      await _client.from('quiz_attempts').insert({
        'doer_id': user.id,
        'score': score,
        'total_questions': totalQuestions,
        'passed': passed,
        'attempt_number': attemptNumber,
        'attempted_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(lastQuizAttempt: attempt);

      if (passed) {
        await _updateActivationStatus(quizPassed: true);
      }

      return attempt;
    } catch (e) {
      // Do not use mock data - properly report error
      state = state.copyWith(
        errorMessage: 'Failed to submit quiz. Please try again.',
      );
      return null;
    }
  }

  /// Submits bank details for the doer.
  ///
  /// Saves bank account information required for payment processing.
  ///
  /// ## Parameters
  ///
  /// - [formData]: [BankDetailsFormData] containing bank account information
  ///
  /// ## Returns
  ///
  /// `true` if bank details were saved successfully, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.bankDetails] with the new details.
  /// Updates [ActivationStatus.bankDetailsAdded] to true.
  /// May trigger full activation if all steps are complete.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(activationProvider.notifier)
  ///     .submitBankDetails(BankDetailsFormData(
  ///       accountHolderName: 'John Doe',
  ///       accountNumber: '1234567890',
  ///       ifscCode: 'SBIN0001234',
  ///       upiId: 'john@upi',
  ///     ));
  ///
  /// if (success) {
  ///   // Bank details saved, check if fully activated
  /// }
  /// ```
  Future<bool> submitBankDetails(BankDetailsFormData formData) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      final now = DateTime.now();

      final bankDetails = BankDetails(
        id: now.millisecondsSinceEpoch.toString(),
        doerId: user.id,
        accountHolderName: formData.accountHolderName,
        accountNumber: formData.accountNumber,
        ifscCode: formData.ifscCode,
        upiId: formData.upiId,
        isVerified: false,
        createdAt: now,
      );

      await _client.from('bank_details').insert(bankDetails.toJson());

      state = state.copyWith(bankDetails: bankDetails);
      await _updateActivationStatus(bankDetailsAdded: true);

      return true;
    } catch (e) {
      // Do not use mock data - properly report error
      state = state.copyWith(
        errorMessage: 'Failed to save bank details. Please try again.',
      );
      return false;
    }
  }

  /// Updates the activation status in the database.
  ///
  /// Updates specific fields of the activation status and checks
  /// if full activation should be triggered.
  ///
  /// ## Parameters
  ///
  /// - [trainingCompleted]: Set to true when all training is done
  /// - [quizPassed]: Set to true when quiz is passed
  /// - [bankDetailsAdded]: Set to true when bank details are saved
  ///
  /// ## State Updates
  ///
  /// Updates [ActivationState.status] with the new values.
  /// Triggers [_checkFullActivation] to check for complete activation.
  Future<void> _updateActivationStatus({
    bool? trainingCompleted,
    bool? quizPassed,
    bool? bankDetailsAdded,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updatedStatus = state.status.copyWith(
      trainingCompleted: trainingCompleted ?? state.status.trainingCompleted,
      quizPassed: quizPassed ?? state.status.quizPassed,
      bankDetailsAdded: bankDetailsAdded ?? state.status.bankDetailsAdded,
    );

    try {
      await _client
          .from('doer_activation')
          .update({
            'training_completed': updatedStatus.trainingCompleted,
            'quiz_passed': updatedStatus.quizPassed,
            'bank_details_added': updatedStatus.bankDetailsAdded,
          })
          .eq('doer_id', user.id);
    } catch (e) {
      // Continue with local state update
    }

    state = state.copyWith(status: updatedStatus);
    _checkFullActivation();
  }

  /// Checks if all activation steps are complete and activates the doer.
  ///
  /// When training, quiz, and bank details are all complete, this method
  /// marks the doer as fully activated in both the activation and doers tables.
  ///
  /// ## State Updates
  ///
  /// Sets [ActivationStatus.isFullyActivated] to true.
  /// Sets [ActivationStatus.activatedAt] to current time.
  /// Triggers [AuthNotifier.refreshProfile] to update auth state.
  void _checkFullActivation() async {
    if (state.status.trainingCompleted &&
        state.status.quizPassed &&
        state.status.bankDetailsAdded) {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final now = DateTime.now();

      try {
        await _client
            .from('doer_activation')
            .update({
              'is_fully_activated': true,
              'activated_at': now.toIso8601String(),
            })
            .eq('doer_id', user.id);

        // Update doer table as well
        await _client
            .from('doers')
            .update({'is_activated': true})
            .eq('id', user.id);
      } catch (e) {
        // Continue with local state update
      }

      state = state.copyWith(
        status: state.status.copyWith(
          isFullyActivated: true,
          activatedAt: now,
        ),
      );

      // Update auth state - use the proper method on AuthNotifier
      ref.read(authProvider.notifier).refreshProfile();
    }
  }

  /// Refreshes all activation data from the database.
  ///
  /// Use this method to reload activation state after external changes
  /// or to recover from errors.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Pull-to-refresh in activation screen
  /// await ref.read(activationProvider.notifier).refresh();
  /// ```
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _loadActivationData(user.id);
    }
  }
}

/// The main activation provider.
///
/// Use this provider to access activation state and manage the
/// doer activation workflow.
///
/// ## Watching State
///
/// ```dart
/// // In a widget
/// final activationState = ref.watch(activationProvider);
///
/// if (activationState.isLoading) {
///   return LoadingScreen();
/// }
///
/// // Show current activation step
/// return ActivationStepper(
///   trainingComplete: activationState.status.trainingCompleted,
///   quizPassed: activationState.status.quizPassed,
///   bankDetailsAdded: activationState.status.bankDetailsAdded,
/// );
/// ```
///
/// ## Performing Operations
///
/// ```dart
/// // Complete training
/// await ref.read(activationProvider.notifier)
///     .completeTrainingModule(moduleId);
///
/// // Submit quiz
/// final result = await ref.read(activationProvider.notifier)
///     .submitQuiz(answers);
/// ```
final activationProvider = NotifierProvider<ActivationNotifier, ActivationState>(() {
  return ActivationNotifier();
});

/// Convenience provider for accessing the activation status.
///
/// Returns the current [ActivationStatus] with completion flags.
///
/// ## Usage
///
/// ```dart
/// final status = ref.watch(activationStatusProvider);
///
/// if (status.isFullyActivated) {
///   // Navigate to dashboard
/// }
/// ```
final activationStatusProvider = Provider<ActivationStatus>((ref) {
  return ref.watch(activationProvider).status;
});

/// Convenience provider for checking if doer is fully activated.
///
/// Returns `true` if all activation steps are complete, `false` otherwise.
///
/// ## Usage
///
/// ```dart
/// final isActivated = ref.watch(isActivatedProvider);
/// return isActivated ? DashboardScreen() : ActivationScreen();
/// ```
final isActivatedProvider = Provider<bool>((ref) {
  return ref.watch(activationProvider).status.isFullyActivated;
});

/// Convenience provider for accessing training modules.
///
/// Returns the list of available [TrainingModule] objects.
///
/// ## Usage
///
/// ```dart
/// final modules = ref.watch(trainingModulesProvider);
///
/// return ListView.builder(
///   itemCount: modules.length,
///   itemBuilder: (context, index) => TrainingModuleCard(
///     module: modules[index],
///   ),
/// );
/// ```
final trainingModulesProvider = Provider<List<TrainingModule>>((ref) {
  return ref.watch(activationProvider).trainingModules;
});

/// Convenience provider for accessing quiz questions.
///
/// Returns the list of [QuizQuestion] objects for the assessment.
///
/// ## Usage
///
/// ```dart
/// final questions = ref.watch(quizQuestionsProvider);
///
/// return QuizWidget(
///   questions: questions,
///   onSubmit: (answers) => ref.read(activationProvider.notifier)
///       .submitQuiz(answers),
/// );
/// ```
final quizQuestionsProvider = Provider<List<QuizQuestion>>((ref) {
  return ref.watch(activationProvider).quizQuestions;
});

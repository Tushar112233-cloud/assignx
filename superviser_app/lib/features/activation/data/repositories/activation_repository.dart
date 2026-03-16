import '../../../../core/api/api_client.dart';
import '../models/training_module.dart';

/// Repository for activation-related operations.
class ActivationRepository {
  ActivationRepository();

  /// Fetches training modules for the current user.
  Future<List<TrainingModule>> getTrainingModules() async {
    try {
      final response = await ApiClient.get('/training/modules?role=supervisor');
      final modulesList = response is List
          ? response
          : (response is Map<String, dynamic>
              ? response['modules'] as List?
              : null);

      if (modulesList != null && modulesList.isNotEmpty) {
        return modulesList
            .map((json) => TrainingModule.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // If API returns user progress, merge it with default modules
      final progressData = response is Map<String, dynamic>
          ? response['progress'] as Map<String, dynamic>?
          : null;

      final progress = <String, bool>{};
      if (progressData != null) {
        for (final entry in progressData.entries) {
          progress[entry.key] = entry.value == true || entry.value == 'completed';
        }
      }

      return defaultTrainingModules.map((module) {
        final isCompleted = progress[module.id] ?? false;
        return module.copyWith(isCompleted: isCompleted);
      }).toList();
    } catch (e) {
      // Return default modules on error
      return defaultTrainingModules;
    }
  }

  /// Marks a training module as complete.
  Future<void> markModuleComplete(String moduleId) async {
    await ApiClient.put('/training/progress/$moduleId', {
      'progress': 100,
    });
  }

  /// Fetches the supervisor quiz.
  Future<Quiz> getQuiz(String quizId) async {
    try {
      final response = await ApiClient.get('/training/quiz?moduleId=$quizId');
      if (response != null) {
        // Parse quiz from API response if available
        return defaultSupervisorQuiz;
      }
      return defaultSupervisorQuiz;
    } catch (e) {
      return defaultSupervisorQuiz;
    }
  }

  /// Submits quiz result.
  Future<void> submitQuizResult(QuizResult result) async {
    await ApiClient.post('/training/quiz/attempt', {
      'moduleId': result.quizId,
      'answers': result.toJson()['answers'] ?? [],
    });

    // If passed, mark the quiz module as complete
    if (result.passed) {
      await markModuleComplete(result.quizId);
    }
  }

  /// Gets the number of quiz attempts for current user.
  Future<int> getQuizAttempts(String quizId) async {
    try {
      final response = await ApiClient.get(
        '/training/quiz/attempts?moduleId=$quizId',
      );
      if (response is Map<String, dynamic>) {
        final attempts = response['attempts'] as List?;
        return attempts?.length ?? 0;
      }
      if (response is List) {
        return response.length;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Checks if all training is complete.
  Future<bool> isTrainingComplete() async {
    final modules = await getTrainingModules();
    return modules.every((m) => m.isCompleted);
  }

  /// Activates the supervisor account.
  Future<void> activateSupervisor() async {
    await ApiClient.put('/supervisors/me/activation', {
      'trainingCompleted': true,
      'quizPassed': true,
    });
  }
}

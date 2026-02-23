import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/training_module.dart';

/// Repository for activation-related operations.
class ActivationRepository {
  ActivationRepository(this._client);

  final SupabaseClient _client;

  /// Fetches training modules for the current user.
  Future<List<TrainingModule>> getTrainingModules() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      // In production, fetch from Supabase
      // For now, return default modules with user progress
      final progress = await _getModuleProgress(userId);

      return defaultTrainingModules.map((module) {
        final isCompleted = progress[module.id] ?? false;
        return module.copyWith(isCompleted: isCompleted);
      }).toList();
    } catch (e) {
      // Return default modules on error
      return defaultTrainingModules;
    }
  }

  /// Gets module completion progress for a user.
  Future<Map<String, bool>> _getModuleProgress(String userId) async {
    try {
      final response = await _client
          .from('training_progress')
          .select('module_id, is_completed')
          .eq('user_id', userId);

      final Map<String, bool> progress = {};
      for (final row in response as List) {
        progress[row['module_id'] as String] = row['is_completed'] as bool;
      }
      return progress;
    } catch (e) {
      return {};
    }
  }

  /// Marks a training module as complete.
  Future<void> markModuleComplete(String moduleId) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('training_progress').upsert({
      'user_id': userId,
      'module_id': moduleId,
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fetches the supervisor quiz.
  Future<Quiz> getQuiz(String quizId) async {
    try {
      // In production, fetch from Supabase
      // For now, return default quiz
      return defaultSupervisorQuiz;
    } catch (e) {
      return defaultSupervisorQuiz;
    }
  }

  /// Submits quiz result.
  Future<void> submitQuizResult(QuizResult result) async {
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('quiz_results').insert({
      'user_id': userId,
      ...result.toJson(),
    });

    // If passed, mark the quiz module as complete
    if (result.passed) {
      await markModuleComplete(result.quizId);
    }
  }

  /// Gets the number of quiz attempts for current user.
  Future<int> getQuizAttempts(String quizId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return 0;

      final response = await _client
          .from('quiz_results')
          .select('id')
          .eq('user_id', userId)
          .eq('quiz_id', quizId);

      return (response as List).length;
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
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('supervisors').update({
      'status': 'active',
      'activated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }
}

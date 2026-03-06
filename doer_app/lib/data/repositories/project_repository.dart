import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/doer_project_model.dart';

/// Repository for doer project-related operations.
///
/// Uses the standard /projects endpoint which auto-filters by doer role
/// based on the JWT token.
class DoerProjectRepository {
  DoerProjectRepository();

  /// Fetches projects assigned to the current doer.
  ///
  /// The API auto-filters by doerId from the JWT token for doer role.
  Future<List<DoerProjectModel>> getAssignedProjects() async {
    try {
      final response = await ApiClient.get('/projects', queryParams: {'limit': '50'});
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => DoerProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getAssignedProjects error: $e');
      }
      rethrow;
    }
  }

  /// Fetches projects in the open pool available for the doer to accept.
  Future<List<DoerProjectModel>> getOpenPoolProjects() async {
    try {
      final response = await ApiClient.get('/projects', queryParams: {'pool': 'true', 'limit': '50'});
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => DoerProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getOpenPoolProjects error: $e');
      }
      rethrow;
    }
  }

  /// Fetches a single project by ID.
  Future<DoerProjectModel?> getProject(String projectId) async {
    try {
      final response = await ApiClient.get('/projects/$projectId');
      if (response == null) return null;
      final data = response is Map<String, dynamic>
          ? (response.containsKey('project') ? response['project'] as Map<String, dynamic> : response)
          : null;
      if (data == null) return null;
      return DoerProjectModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getProject error: $e');
      }
      rethrow;
    }
  }

  /// Claims a project from the open pool.
  Future<bool> acceptProject(String projectId) async {
    try {
      await ApiClient.post('/projects/$projectId/claim-from-pool');
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.acceptProject error: $e');
      }
      rethrow;
    }
  }

  /// Starts working on a project (changes status to in_progress).
  Future<bool> startProject(String projectId) async {
    try {
      await ApiClient.put('/projects/$projectId/status', {
        'status': 'in_progress',
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.startProject error: $e');
      }
      rethrow;
    }
  }

  /// Updates project progress percentage.
  Future<bool> updateProgress(String projectId, int progressPercentage) async {
    try {
      await ApiClient.put('/projects/$projectId', {
        'progressPercentage': progressPercentage,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.updateProgress error: $e');
      }
      rethrow;
    }
  }

  /// Submits project for supervisor review (changes status to submitted).
  Future<bool> submitForReview(String projectId, {String? notes}) async {
    try {
      await ApiClient.put('/projects/$projectId/status', {
        'status': 'submitted',
        if (notes != null) 'notes': notes,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.submitForReview error: $e');
      }
      rethrow;
    }
  }

  /// Fetches completed projects for the doer.
  Future<List<DoerProjectModel>> getCompletedProjects() async {
    try {
      final response = await ApiClient.get('/projects', queryParams: {'status': 'completed', 'limit': '50'});
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => DoerProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getCompletedProjects error: $e');
      }
      rethrow;
    }
  }

  /// Fetches doer statistics from the doer profile.
  Future<DoerStatistics> getDoerStatistics() async {
    try {
      final response = await ApiClient.get('/doers/me');
      if (response is Map<String, dynamic>) {
        return DoerStatistics(
          activeProjects: response['active_projects'] as int? ?? response['activeProjects'] as int? ?? 0,
          completedProjects: response['total_projects_completed'] as int? ?? response['totalProjectsCompleted'] as int? ?? 0,
          totalEarnings: (response['total_earnings'] as num?)?.toDouble() ?? (response['totalEarnings'] as num?)?.toDouble() ?? 0.0,
          averageRating: (response['average_rating'] as num?)?.toDouble() ?? (response['averageRating'] as num?)?.toDouble() ?? 0.0,
          successRate: (response['success_rate'] as num?)?.toDouble() ?? (response['successRate'] as num?)?.toDouble() ?? 100.0,
          onTimeRate: (response['on_time_delivery_rate'] as num?)?.toDouble() ?? (response['onTimeDeliveryRate'] as num?)?.toDouble() ?? 100.0,
        );
      }
      return const DoerStatistics();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getDoerStatistics error: $e');
      }
      rethrow;
    }
  }

  /// Watches projects for real-time updates.
  Stream<List<DoerProjectModel>> watchAssignedProjects() {
    return Stream.fromFuture(getAssignedProjects());
  }
}

/// Doer statistics model.
class DoerStatistics {
  final int activeProjects;
  final int completedProjects;
  final double totalEarnings;
  final double averageRating;
  final double successRate;
  final double onTimeRate;

  const DoerStatistics({
    this.activeProjects = 0,
    this.completedProjects = 0,
    this.totalEarnings = 0.0,
    this.averageRating = 0.0,
    this.successRate = 100.0,
    this.onTimeRate = 100.0,
  });

  String get formattedEarnings => '\u20B9${totalEarnings.toStringAsFixed(0)}';
}

/// Provider for the doer project repository.
final doerProjectRepositoryProvider = Provider<DoerProjectRepository>((ref) {
  return DoerProjectRepository();
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/doer_project_model.dart';

/// Repository for doer project-related operations.
///
/// Handles fetching assigned projects, open pool, accepting projects,
/// updating progress, and submitting work for review.
class DoerProjectRepository {
  DoerProjectRepository();

  /// Fetches projects assigned to the current doer.
  ///
  /// Returns projects with status: assigned, in_progress, delivered, in_revision.
  Future<List<DoerProjectModel>> getAssignedProjects() async {
    try {
      final response = await ApiClient.get('/doer/projects/assigned');
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
      final response = await ApiClient.get('/doer/projects/pool');
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
      final response = await ApiClient.get('/doer/projects/$projectId');
      if (response == null) return null;
      return DoerProjectModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getProject error: $e');
      }
      rethrow;
    }
  }

  /// Accepts a project from the open pool.
  Future<bool> acceptProject(String projectId) async {
    try {
      await ApiClient.post('/doer/projects/$projectId/accept');
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.acceptProject error: $e');
      }
      rethrow;
    }
  }

  /// Starts working on a project.
  Future<bool> startProject(String projectId) async {
    try {
      await ApiClient.post('/doer/projects/$projectId/start');
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
      await ApiClient.put('/doer/projects/$projectId/progress', {
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

  /// Submits project for supervisor review (delivers to QC).
  Future<bool> submitForReview(String projectId, {String? notes}) async {
    try {
      await ApiClient.post('/doer/projects/$projectId/submit', {
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
      final response = await ApiClient.get('/doer/projects/completed');
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

  /// Fetches doer statistics from the API.
  Future<DoerStatistics> getDoerStatistics() async {
    try {
      final response = await ApiClient.get('/doer/statistics');
      if (response is Map<String, dynamic>) {
        return DoerStatistics(
          activeProjects: response['activeProjects'] as int? ?? 0,
          completedProjects: response['completedProjects'] as int? ?? 0,
          totalEarnings: (response['totalEarnings'] as num?)?.toDouble() ?? 0.0,
          averageRating: (response['averageRating'] as num?)?.toDouble() ?? 0.0,
          successRate: (response['successRate'] as num?)?.toDouble() ?? 100.0,
          onTimeRate: (response['onTimeRate'] as num?)?.toDouble() ?? 100.0,
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
  ///
  /// Note: With the API backend, polling is used instead of real-time streams.
  /// Consumers should use periodic refresh or Socket.IO events.
  Stream<List<DoerProjectModel>> watchAssignedProjects() {
    // Emit once from the API, consumers can periodically refresh
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

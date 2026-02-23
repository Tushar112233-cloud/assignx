import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/doer_project_model.dart';

/// Repository for doer project-related operations.
///
/// Handles fetching assigned projects, open pool, accepting projects,
/// updating progress, and submitting work for review.
class DoerProjectRepository {
  DoerProjectRepository(this._client);

  final SupabaseClient _client;

  /// Gets the current user's profile ID (auth ID).
  String? get _userId => _client.auth.currentUser?.id;

  /// Cached doer ID to avoid repeated lookups.
  String? _cachedDoerId;

  /// Looks up the doer table ID from the profile ID.
  Future<String?> _getDoerId() async {
    if (_cachedDoerId != null) return _cachedDoerId;
    try {
      if (_userId == null) return null;
      final response = await _client
          .from('doers')
          .select('id')
          .eq('profile_id', _userId!)
          .maybeSingle();
      _cachedDoerId = response?['id'] as String?;
      return _cachedDoerId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository._getDoerId error: $e');
      }
      return null;
    }
  }

  /// Fetches projects assigned to the current doer.
  ///
  /// Returns projects with status: assigned, in_progress, delivered, in_revision.
  Future<List<DoerProjectModel>> getAssignedProjects() async {
    try {
      final doerId = await _getDoerId();
      if (doerId == null) return [];
      final response = await _client.from('projects').select('''
        *,
        subject:subjects(id, name),
        reference_style:reference_styles(id, name, slug)
      ''').eq('doer_id', doerId).inFilter('status', [
        'assigned',
        'in_progress',
        'delivered',
        'in_revision',
        'revision_requested',
      ]).order('deadline', ascending: true);

      return (response as List)
          .map((json) => DoerProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getAssignedProjects error: $e');
      }
      rethrow;
    }
  }

  /// Fetches projects in the open pool available for the doer to accept.
  ///
  /// Returns projects with status 'pending_assignment' that match doer's subjects.
  Future<List<DoerProjectModel>> getOpenPoolProjects() async {
    try {
      // First get doer's subjects
      final doerId = await _getDoerId();
      if (doerId == null) return [];
      final doerSubjects = await _client
          .from('doer_subjects')
          .select('subject_id')
          .eq('doer_id', doerId);

      final subjectIds = (doerSubjects as List)
          .map((e) => e['subject_id'] as String)
          .toList();

      // Then get projects in those subjects
      var query = _client.from('projects').select('''
        *,
        subject:subjects(id, name),
        reference_style:reference_styles(id, name, slug)
      ''').eq('status', 'assigning').isFilter('doer_id', null);

      if (subjectIds.isNotEmpty) {
        query = query.inFilter('subject_id', subjectIds);
      }

      final response = await query.order('deadline', ascending: true).limit(50);

      return (response as List)
          .map((json) => DoerProjectModel.fromJson(json))
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
      final response = await _client.from('projects').select('''
        *,
        subject:subjects(id, name),
        user:profiles!user_id(id, full_name),
        reference_style:reference_styles(id, name, slug)
      ''').eq('id', projectId).single();

      return DoerProjectModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getProject error: $e');
      }
      rethrow;
    }
  }

  /// Accepts a project from the open pool.
  ///
  /// Updates the project's doer_id and status to 'assigned'.
  Future<bool> acceptProject(String projectId) async {
    try {
      final doerId = await _getDoerId();
      if (doerId == null) return false;
      await _client.from('projects').update({
        'doer_id': doerId,
        'status': 'assigned',
        'doer_assigned_at': DateTime.now().toIso8601String(),
        'status_updated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.acceptProject error: $e');
      }
      rethrow;
    }
  }

  /// Starts working on a project.
  ///
  /// Updates status to 'in_progress'.
  Future<bool> startProject(String projectId) async {
    try {
      await _client.from('projects').update({
        'status': 'in_progress',
        'status_updated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

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
      await _client.from('projects').update({
        'progress_percentage': progressPercentage,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.updateProgress error: $e');
      }
      rethrow;
    }
  }

  /// Submits project for supervisor review (delivers to QC).
  ///
  /// Updates status to 'delivered'.
  Future<bool> submitForReview(String projectId, {String? notes}) async {
    try {
      await _client.from('projects').update({
        'status': 'delivered',
        'delivered_at': DateTime.now().toIso8601String(),
        'progress_percentage': 100,
        'completion_notes': notes,
        'status_updated_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

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
      final doerId = await _getDoerId();
      if (doerId == null) return [];
      final response = await _client.from('projects').select('''
        *,
        subject:subjects(id, name)
      ''').eq('doer_id', doerId).inFilter('status', [
        'completed',
        'auto_approved',
      ]).order('completed_at', ascending: false).limit(50);

      return (response as List)
          .map((json) => DoerProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getCompletedProjects error: $e');
      }
      rethrow;
    }
  }

  /// Fetches doer statistics from the database.
  Future<DoerStatistics> getDoerStatistics() async {
    try {
      final doerId = await _getDoerId();
      // Get active projects count
      final activeResponse = doerId != null
          ? await _client
              .from('projects')
              .select('id')
              .eq('doer_id', doerId)
              .inFilter('status', ['assigned', 'in_progress', 'delivered', 'in_revision'])
          : [];

      // Get completed projects count
      final completedResponse = doerId != null
          ? await _client
              .from('projects')
              .select('id')
              .eq('doer_id', doerId)
              .eq('status', 'completed')
          : [];

      // Get doer record for earnings and rating
      if (_userId == null) {
        return DoerStatistics(
          activeProjects: (activeResponse as List).length,
          completedProjects: (completedResponse as List).length,
        );
      }
      final doerResponse = await _client
          .from('doers')
          .select('total_earnings, average_rating, total_projects_completed, success_rate, on_time_delivery_rate')
          .eq('profile_id', _userId!)
          .maybeSingle();

      return DoerStatistics(
        activeProjects: (activeResponse as List).length,
        completedProjects: doerResponse?['total_projects_completed'] as int? ?? (completedResponse as List).length,
        totalEarnings: (doerResponse?['total_earnings'] as num?)?.toDouble() ?? 0.0,
        averageRating: (doerResponse?['average_rating'] as num?)?.toDouble() ?? 0.0,
        successRate: (doerResponse?['success_rate'] as num?)?.toDouble() ?? 100.0,
        onTimeRate: (doerResponse?['on_time_delivery_rate'] as num?)?.toDouble() ?? 100.0,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerProjectRepository.getDoerStatistics error: $e');
      }
      rethrow;
    }
  }

  /// Watches projects for real-time updates.
  ///
  /// Uses the cached doer table ID (not profile_id) for correct filtering.
  /// Returns an empty stream if no doer ID is available.
  Stream<List<DoerProjectModel>> watchAssignedProjects() {
    final doerId = _cachedDoerId;
    if (doerId == null) {
      return const Stream.empty();
    }
    return _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('doer_id', doerId)
        .order('deadline', ascending: true)
        .map((data) => data.map((json) => DoerProjectModel.fromJson(json)).toList());
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

  String get formattedEarnings => '₹${totalEarnings.toStringAsFixed(0)}';
}

/// Provider for the doer project repository.
final doerProjectRepositoryProvider = Provider<DoerProjectRepository>((ref) {
  return DoerProjectRepository(SupabaseConfig.client);
});

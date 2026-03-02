import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../core/api/api_client.dart';
import '../../core/socket/socket_client.dart';
import '../models/project_model.dart';

/// Repository for project-related operations.
class ProjectRepository {
  ProjectRepository();

  /// Fetches all projects for the current user.
  Future<List<Project>> getProjects() async {
    final response = await ApiClient.get('/projects');
    // API may return a list or { projects: [...] }
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['projects'] as List? ?? [];
    return list
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches projects by status tab (matching web app).
  ///
  /// Tab indices (matching web):
  /// - 0: In Review (submitted, analyzing, quoted, payment_pending)
  /// - 1: In Progress (paid, assigning, assigned, in_progress, qc states, revision)
  /// - 2: For Review (delivered)
  /// - 3: History (completed, auto_approved, cancelled, refunded)
  Future<List<Project>> getProjectsByTab(int tabIndex) async {
    final allProjects = await getProjects();

    switch (tabIndex) {
      case 0:
        return allProjects.where((p) => _isInReviewStatus(p.status)).toList();
      case 1:
        return allProjects.where((p) => _isInProgressStatus(p.status)).toList();
      case 2:
        return allProjects.where((p) => _isForReviewStatus(p.status)).toList();
      case 3:
        return allProjects.where((p) => _isHistoryStatus(p.status)).toList();
      default:
        return allProjects;
    }
  }

  bool _isInReviewStatus(ProjectStatus status) {
    return [
      ProjectStatus.draft,
      ProjectStatus.submitted,
      ProjectStatus.analyzing,
      ProjectStatus.quoted,
      ProjectStatus.paymentPending,
    ].contains(status);
  }

  bool _isInProgressStatus(ProjectStatus status) {
    return [
      ProjectStatus.paid,
      ProjectStatus.assigning,
      ProjectStatus.assigned,
      ProjectStatus.inProgress,
      ProjectStatus.submittedForQc,
      ProjectStatus.qcInProgress,
      ProjectStatus.qcApproved,
      ProjectStatus.qcRejected,
      ProjectStatus.revisionRequested,
      ProjectStatus.inRevision,
    ].contains(status);
  }

  bool _isForReviewStatus(ProjectStatus status) {
    return [ProjectStatus.delivered].contains(status);
  }

  bool _isHistoryStatus(ProjectStatus status) {
    return [
      ProjectStatus.completed,
      ProjectStatus.autoApproved,
      ProjectStatus.cancelled,
      ProjectStatus.refunded,
    ].contains(status);
  }

  /// Fetches projects with pending payments.
  Future<List<Project>> getPendingPaymentProjects() async {
    final response = await ApiClient.get('/projects', queryParams: {
      'status': 'payment_pending,quoted',
    });
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['projects'] as List? ?? [];
    return list
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single project by ID.
  Future<Project?> getProject(String projectId) async {
    try {
      final response = await ApiClient.get('/projects/$projectId');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      // API may return flat project or { project: {...} }
      final projectData = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
      return Project.fromJson(projectData);
    } catch (_) {
      return null;
    }
  }

  /// Creates a new project.
  Future<Project> createProject({
    required String title,
    String? description,
    required ServiceType serviceType,
    String? subjectId,
    required DateTime deadline,
    String? topic,
    int? wordCount,
    int? pageCount,
    String? referenceStyleId,
    String? specificInstructions,
    List<String>? focusAreas,
  }) async {
    final projectData = {
      'title': title,
      'description': description,
      'serviceType': serviceType.toDbString(),
      'subjectId': subjectId,
      'topic': topic,
      'wordCount': wordCount,
      'pageCount': pageCount,
      'referenceStyleId': referenceStyleId,
      'specificInstructions': specificInstructions,
      'focusAreas': focusAreas,
      'deadline': deadline.toIso8601String(),
    };

    final response = await ApiClient.post('/projects', projectData);
    final data = response as Map<String, dynamic>;
    final projectJson = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
    return Project.fromJson(projectJson);
  }

  /// Updates project status.
  Future<Project> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    final response = await ApiClient.put('/projects/$projectId/status', {
      'status': status.toDbString(),
    });
    final data = response as Map<String, dynamic>;
    final projectJson = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
    return Project.fromJson(projectJson);
  }

  /// Approves a project (moves to completed).
  Future<Project> approveProject(String projectId) async {
    return updateProjectStatus(projectId, ProjectStatus.completed);
  }

  /// Requests changes for a project.
  Future<Project> requestChanges(String projectId, String feedback) async {
    final response = await ApiClient.put('/projects/$projectId/status', {
      'status': ProjectStatus.revisionRequested.toDbString(),
      'userFeedback': feedback,
    });
    final data = response as Map<String, dynamic>;
    final projectJson = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
    return Project.fromJson(projectJson);
  }

  /// Updates the grade received by user for a completed project.
  Future<Project> updateFinalGrade(String projectId, String grade) async {
    final response = await ApiClient.put('/projects/$projectId', {
      'userGrade': grade,
    });
    final data = response as Map<String, dynamic>;
    final projectJson = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
    return Project.fromJson(projectJson);
  }

  /// Records payment for a project.
  Future<Project> recordPayment(String projectId, String paymentId) async {
    final response = await ApiClient.post('/payments/verify', {
      'projectId': projectId,
      'gatewayPaymentId': paymentId,
    });
    final data = response as Map<String, dynamic>;
    final projectJson = data.containsKey('title') ? data : (data['project'] as Map<String, dynamic>? ?? data);
    return Project.fromJson(projectJson);
  }

  /// Gets the project timeline events.
  Future<List<ProjectTimelineEvent>> getProjectTimeline(
    String projectId,
  ) async {
    final response = await ApiClient.get('/projects/$projectId/timeline');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['timeline'] as List? ?? [];
    return list
        .map((json) => ProjectTimelineEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Gets the deliverables for a project.
  Future<List<ProjectDeliverable>> getDeliverables(String projectId) async {
    final response = await ApiClient.get('/projects/$projectId/deliverables');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['deliverables'] as List? ?? [];
    return list
        .map((json) => ProjectDeliverable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Subscribes to real-time project updates via Socket.IO.
  Stream<List<Project>> watchProjects() {
    final controller = StreamController<List<Project>>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getSocket();
        socket.on('projects:updated', (data) {
          try {
            if (data is List) {
              final projects = data
                  .map((json) => Project.fromJson(json as Map<String, dynamic>))
                  .toList();
              controller.add(projects);
            }
          } catch (_) {}
        });
      } catch (e) {
        controller.addError(e);
      }
    }();

    return controller.stream;
  }

  /// Subscribes to a single project's updates via Socket.IO.
  Stream<Project?> watchProject(String projectId) {
    final controller = StreamController<Project?>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getSocket();
        socket.on('project:$projectId', (data) {
          try {
            if (data != null) {
              controller.add(Project.fromJson(data as Map<String, dynamic>));
            }
          } catch (_) {}
        });
      } catch (e) {
        controller.addError(e);
      }
    }();

    return controller.stream;
  }

  /// Cancels a project.
  Future<Project> cancelProject(String projectId) async {
    return updateProjectStatus(projectId, ProjectStatus.cancelled);
  }

  /// Gets project count by status tab.
  Future<Map<int, int>> getProjectCounts() async {
    final projects = await getProjects();

    final inReviewCount = projects.where((p) => _isInReviewStatus(p.status)).length;
    final inProgressCount = projects.where((p) => _isInProgressStatus(p.status)).length;
    final forReviewCount = projects.where((p) => _isForReviewStatus(p.status)).length;
    final historyCount = projects.where((p) => _isHistoryStatus(p.status)).length;
    final completedCount = projects.where((p) => _isCompletedStatus(p.status)).length;

    return {
      0: inReviewCount,
      1: inProgressCount,
      2: forReviewCount,
      3: historyCount,
      4: completedCount,
      5: projects.length,
    };
  }

  bool _isCompletedStatus(ProjectStatus status) {
    return [
      ProjectStatus.completed,
      ProjectStatus.autoApproved,
    ].contains(status);
  }
}

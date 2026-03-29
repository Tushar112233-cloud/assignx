import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/project_model.dart';
import '../models/deliverable_model.dart';
import '../../domain/entities/project_status.dart';

/// Repository for project-related operations.
///
/// Handles CRUD operations for projects via the Express API.
class ProjectRepository {
  ProjectRepository();

  /// Fetches projects for the current supervisor.
  ///
  /// Can filter by [status] if provided.
  Future<List<ProjectModel>> getProjects({ProjectStatus? status}) async {
    try {
      final statusParam = status != null ? '?status=${status.value}' : '';
      final response = await ApiClient.get('/supervisor/projects$statusParam');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getProjects error: $e');
        return _getMockProjects(status: status);
      }
      rethrow;
    }
  }

  /// Fetches active projects (quoted, paid, assigned, in progress, etc.).
  Future<List<ProjectModel>> getActiveProjects() async {
    try {
      final statuses = [
        'submitted',
        'analyzing',
        'quoted',
        'paid',
        ProjectStatus.assigned.value,
        ProjectStatus.inProgress.value,
        ProjectStatus.delivered.value,
        ProjectStatus.inRevision.value,
      ].join(',');

      final response = await ApiClient.get(
        '/supervisor/projects?statuses=$statuses&sort=deadline&order=asc',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getActiveProjects error: $e');
        return _getMockProjects().where((p) => p.status.isActive).toList();
      }
      rethrow;
    }
  }

  /// Fetches projects ready for QC review.
  Future<List<ProjectModel>> getForReviewProjects() async {
    try {
      final statuses = [
        ProjectStatus.delivered.value,
        ProjectStatus.forReview.value,
      ].join(',');

      final response = await ApiClient.get(
        '/supervisor/projects?statuses=$statuses&sort=delivered_at&order=asc',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getForReviewProjects error: $e');
        return _getMockProjects().where((p) => p.status.isForReview).toList();
      }
      rethrow;
    }
  }

  /// Fetches completed projects.
  Future<List<ProjectModel>> getCompletedProjects() async {
    try {
      final statuses = [
        ProjectStatus.completed.value,
        ProjectStatus.cancelled.value,
        ProjectStatus.refunded.value,
      ].join(',');

      final response = await ApiClient.get(
        '/supervisor/projects?statuses=$statuses&sort=completed_at&order=desc&limit=50',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => ProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getCompletedProjects error: $e');
        return _getMockProjects().where((p) => p.status.isFinal).toList();
      }
      rethrow;
    }
  }

  /// Fetches a single project by ID.
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final response = await ApiClient.get('/supervisor/projects/$projectId');
      if (response == null) return null;
      return ProjectModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getProject error: $e');
        return _getMockProjects().firstWhere(
          (p) => p.id == projectId,
          orElse: () => _getMockProjects().first,
        );
      }
      rethrow;
    }
  }

  /// Fetches deliverables for a project.
  Future<List<DeliverableModel>> getDeliverables(String projectId) async {
    try {
      final response = await ApiClient.get(
        '/supervisor/projects/$projectId/deliverables',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['deliverables'] as List? ?? [];

      return list
          .map((json) => DeliverableModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getDeliverables error: $e');
        return _getMockDeliverables(projectId);
      }
      rethrow;
    }
  }

  /// Updates project status.
  Future<bool> updateProjectStatus(
    String projectId,
    ProjectStatus status, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await ApiClient.put('/supervisor/projects/$projectId/status', {
        'status': status.value,
        ...?additionalData,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.updateProjectStatus error: $e');
        return false;
      }
      rethrow;
    }
  }

  /// Approves a project deliverable.
  Future<bool> approveDeliverable(
    String projectId,
    String deliverableId, {
    String? notes,
  }) async {
    try {
      await ApiClient.put(
        '/supervisor/projects/$projectId/deliverables/$deliverableId/approve',
        {
          if (notes != null) 'qc_notes': notes,
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.approveDeliverable error: $e');
        return false;
      }
      rethrow;
    }
  }

  /// Requests revision for a project.
  Future<bool> requestRevision(
    String projectId, {
    required String feedback,
    List<String>? issues,
  }) async {
    try {
      await ApiClient.post('/supervisor/projects/$projectId/revisions', {
        'feedback': feedback,
        if (issues != null) 'specific_changes': issues.join('; '),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.requestRevision error: $e');
        return true;
      }
      rethrow;
    }
  }

  /// Delivers project to client.
  Future<bool> deliverToClient(String projectId) async {
    try {
      await updateProjectStatus(projectId, ProjectStatus.deliveredToClient);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.deliverToClient error: $e');
        return false;
      }
      rethrow;
    }
  }

  /// Watches projects for real-time updates.
  /// Note: Real-time handled via Socket.IO at the provider level.
  Stream<List<ProjectModel>> watchProjects() {
    // Real-time updates handled via Socket.IO
    return Stream.value([]);
  }

  /// Mock data for development.
  List<ProjectModel> _getMockProjects({ProjectStatus? status}) {
    final now = DateTime.now();
    final projects = [
      ProjectModel(
        id: 'proj_1',
        projectNumber: 'PRJ-2025-0001',
        title: 'Research Paper on Machine Learning',
        description:
            'A comprehensive research paper analyzing machine learning algorithms and their applications in healthcare.',
        subject: 'Computer Science',
        status: ProjectStatus.inProgress,
        userId: 'user_1',
        supervisorId: 'sup_1',
        doerId: 'doer_1',
        deadline: now.add(const Duration(days: 3)),
        wordCount: 5000,
        pageCount: 20,
        userQuote: 250.00,
        doerAmount: 175.00,
        supervisorAmount: 50.00,
        platformAmount: 25.00,
        clientName: 'John Smith',
        clientEmail: 'john@example.com',
        doerName: 'Alice Writer',
        chatRoomId: 'chat_1',
        createdAt: now.subtract(const Duration(days: 5)),
        paidAt: now.subtract(const Duration(days: 4)),
        assignedAt: now.subtract(const Duration(days: 3)),
        startedAt: now.subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: 'proj_2',
        projectNumber: 'PRJ-2025-0002',
        title: 'Business Plan for Tech Startup',
        description: 'Complete business plan including market analysis and financial projections.',
        subject: 'Business Studies',
        status: ProjectStatus.delivered,
        userId: 'user_2',
        supervisorId: 'sup_1',
        doerId: 'doer_2',
        deadline: now.add(const Duration(days: 1)),
        wordCount: 8000,
        pageCount: 30,
        userQuote: 400.00,
        doerAmount: 280.00,
        supervisorAmount: 80.00,
        platformAmount: 40.00,
        clientName: 'Sarah Johnson',
        clientEmail: 'sarah@example.com',
        doerName: 'Bob Expert',
        chatRoomId: 'chat_2',
        isUrgent: true,
        createdAt: now.subtract(const Duration(days: 7)),
        paidAt: now.subtract(const Duration(days: 6)),
        assignedAt: now.subtract(const Duration(days: 5)),
        startedAt: now.subtract(const Duration(days: 4)),
        deliveredAt: now.subtract(const Duration(hours: 6)),
      ),
      ProjectModel(
        id: 'proj_3',
        projectNumber: 'PRJ-2025-0003',
        title: 'Literature Review: Climate Change',
        description: 'Academic literature review on climate change policies.',
        subject: 'Environmental Science',
        status: ProjectStatus.forReview,
        userId: 'user_3',
        supervisorId: 'sup_1',
        doerId: 'doer_3',
        deadline: now.add(const Duration(days: 2)),
        wordCount: 3000,
        pageCount: 12,
        userQuote: 180.00,
        doerAmount: 126.00,
        supervisorAmount: 36.00,
        platformAmount: 18.00,
        clientName: 'Mike Brown',
        clientEmail: 'mike@example.com',
        doerName: 'Carol Researcher',
        chatRoomId: 'chat_3',
        createdAt: now.subtract(const Duration(days: 4)),
        paidAt: now.subtract(const Duration(days: 3)),
        assignedAt: now.subtract(const Duration(days: 2)),
        startedAt: now.subtract(const Duration(days: 1)),
        deliveredAt: now.subtract(const Duration(hours: 2)),
      ),
      ProjectModel(
        id: 'proj_4',
        projectNumber: 'PRJ-2025-0004',
        title: 'Marketing Strategy Analysis',
        description: 'Analysis of digital marketing strategies for e-commerce.',
        subject: 'Marketing',
        status: ProjectStatus.completed,
        userId: 'user_4',
        supervisorId: 'sup_1',
        doerId: 'doer_1',
        deadline: now.subtract(const Duration(days: 2)),
        wordCount: 4000,
        pageCount: 15,
        userQuote: 200.00,
        doerAmount: 140.00,
        supervisorAmount: 40.00,
        platformAmount: 20.00,
        clientName: 'Emily Davis',
        clientEmail: 'emily@example.com',
        doerName: 'Alice Writer',
        chatRoomId: 'chat_4',
        createdAt: now.subtract(const Duration(days: 10)),
        paidAt: now.subtract(const Duration(days: 9)),
        assignedAt: now.subtract(const Duration(days: 8)),
        startedAt: now.subtract(const Duration(days: 7)),
        deliveredAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 2)),
      ),
      ProjectModel(
        id: 'proj_5',
        projectNumber: 'PRJ-2025-0005',
        title: 'Statistical Analysis Report',
        description: 'Data analysis using SPSS for psychology research.',
        subject: 'Statistics',
        status: ProjectStatus.assigned,
        userId: 'user_5',
        supervisorId: 'sup_1',
        doerId: 'doer_4',
        deadline: now.add(const Duration(days: 5)),
        wordCount: 2500,
        pageCount: 10,
        userQuote: 150.00,
        doerAmount: 105.00,
        supervisorAmount: 30.00,
        platformAmount: 15.00,
        clientName: 'Tom Wilson',
        clientEmail: 'tom@example.com',
        doerName: 'David Stats',
        chatRoomId: 'chat_5',
        createdAt: now.subtract(const Duration(days: 2)),
        paidAt: now.subtract(const Duration(days: 1)),
        assignedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    if (status != null) {
      return projects.where((p) => p.status == status).toList();
    }
    return projects;
  }

  /// Mock deliverables for development.
  List<DeliverableModel> _getMockDeliverables(String projectId) {
    final now = DateTime.now();
    return [
      DeliverableModel(
        id: 'del_1',
        projectId: projectId,
        fileUrl: 'https://example.com/files/draft_v2.docx',
        fileName: 'research_paper_v2.docx',
        fileType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        fileSize: 1024 * 512,
        uploadedBy: 'doer_1',
        uploaderName: 'Alice Writer',
        description: 'Final draft with all revisions incorporated',
        version: 2,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      DeliverableModel(
        id: 'del_2',
        projectId: projectId,
        fileUrl: 'https://example.com/files/draft_v1.docx',
        fileName: 'research_paper_v1.docx',
        fileType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        fileSize: 1024 * 480,
        uploadedBy: 'doer_1',
        uploaderName: 'Alice Writer',
        description: 'Initial draft submission',
        version: 1,
        isApproved: false,
        reviewerNotes: 'Please add more citations to section 3',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}

/// Provider for the project repository.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

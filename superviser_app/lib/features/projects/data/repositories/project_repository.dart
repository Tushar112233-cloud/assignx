import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/project_model.dart';
import '../models/deliverable_model.dart';
import '../../domain/entities/project_status.dart';

/// Repository for project-related operations.
///
/// Handles CRUD operations and real-time subscriptions for projects.
class ProjectRepository {
  ProjectRepository(this._client);

  final SupabaseClient _client;

  /// Cached supervisor ID to avoid repeated lookups.
  String? _cachedSupervisorId;

  /// Gets the current user ID (profile ID).
  String? get _userId => getCurrentUserId();

  /// Gets the supervisor table ID from the supervisors table.
  Future<String?> _getSupervisorId() async {
    if (_cachedSupervisorId != null) return _cachedSupervisorId;
    final userId = getCurrentUserId();
    if (userId == null) return null;
    try {
      final response = await _client
          .from('supervisors')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();
      _cachedSupervisorId = response?['id'] as String?;
      return _cachedSupervisorId;
    } catch (e) {
      debugPrint('ProjectRepository._getSupervisorId error: $e');
      return null;
    }
  }

  /// Fetches projects for the current supervisor.
  ///
  /// Can filter by [status] if provided.
  Future<List<ProjectModel>> getProjects({ProjectStatus? status}) async {
    try {
      final supervisorId = await _getSupervisorId();
      if (supervisorId == null) throw Exception('Supervisor not found');
      var query = _client.from('projects').select('''
        *,
        user:profiles!user_id(full_name, email, avatar_url),
        doer:doers!doer_id(
          id,
          profile:profiles!profile_id(full_name, email, avatar_url)
        ),
        subject:subjects(id, name)
      ''').eq('supervisor_id', supervisorId);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final response = await query.order('updated_at', ascending: false);
      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProjectRepository.getProjects error: $e');
        return _getMockProjects(status: status);
      }
      rethrow;
    }
  }

  /// Fetches active projects (in progress, assigned, etc.).
  Future<List<ProjectModel>> getActiveProjects() async {
    try {
      final supervisorId = await _getSupervisorId();
      if (supervisorId == null) throw Exception('Supervisor not found');
      final response = await _client.from('projects').select('''
        *,
        user:profiles!user_id(full_name, email, avatar_url),
        doer:doers!doer_id(
          id,
          profile:profiles!profile_id(full_name, email, avatar_url)
        ),
        subject:subjects(id, name)
      ''').eq('supervisor_id', supervisorId).inFilter('status', [
        ProjectStatus.assigned.value,
        ProjectStatus.inProgress.value,
        ProjectStatus.delivered.value,
        ProjectStatus.inRevision.value,
      ]).order('deadline', ascending: true);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
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
      final supervisorId = await _getSupervisorId();
      if (supervisorId == null) throw Exception('Supervisor not found');
      final response = await _client.from('projects').select('''
        *,
        user:profiles!user_id(full_name, email, avatar_url),
        doer:doers!doer_id(
          id,
          profile:profiles!profile_id(full_name, email, avatar_url)
        ),
        subject:subjects(id, name)
      ''').eq('supervisor_id', supervisorId).inFilter('status', [
        ProjectStatus.delivered.value,
        ProjectStatus.forReview.value,
      ]).order('delivered_at', ascending: true);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
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
      final supervisorId = await _getSupervisorId();
      if (supervisorId == null) throw Exception('Supervisor not found');
      final response = await _client.from('projects').select('''
        *,
        user:profiles!user_id(full_name, email, avatar_url),
        doer:doers!doer_id(
          id,
          profile:profiles!profile_id(full_name, email, avatar_url)
        ),
        subject:subjects(id, name)
      ''').eq('supervisor_id', supervisorId).inFilter('status', [
        ProjectStatus.completed.value,
        ProjectStatus.cancelled.value,
        ProjectStatus.refunded.value,
      ]).order('completed_at', ascending: false).limit(50);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
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
      final response = await _client.from('projects').select('''
        *,
        user:profiles!user_id(full_name, email, avatar_url),
        doer:doers!doer_id(
          id,
          profile:profiles!profile_id(full_name, email, avatar_url)
        ),
        subject:subjects(id, name)
      ''').eq('id', projectId).single();

      return ProjectModel.fromJson(response);
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
      final response = await _client.from('project_deliverables').select('''
        *,
        uploader:profiles!uploaded_by(full_name, avatar_url)
      ''').eq('project_id', projectId).order('version', ascending: false);

      return (response as List)
          .map((json) => DeliverableModel.fromJson(json))
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
      final data = {
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // Add timestamp for specific status changes
      switch (status) {
        case ProjectStatus.assigned:
          data['assigned_at'] = DateTime.now().toIso8601String();
          break;
        case ProjectStatus.inProgress:
          data['started_at'] = DateTime.now().toIso8601String();
          break;
        case ProjectStatus.delivered:
          data['delivered_at'] = DateTime.now().toIso8601String();
          break;
        case ProjectStatus.completed:
          data['completed_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _client.from('projects').update(data).eq('id', projectId);
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
      // Update deliverable
      await _client.from('project_deliverables').update({
        'is_approved': true,
        'reviewer_notes': notes,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', deliverableId);

      // Update project status
      await updateProjectStatus(projectId, ProjectStatus.approved);

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
      // Update project status
      await _client.from('projects').update({
        'status': ProjectStatus.revisionRequested.value,
        'revision_count': SupabaseClient as dynamic,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', projectId);

      // Create revision request record
      await _client.from('project_revisions').insert({
        'project_id': projectId,
        'requested_by': _userId,
        'feedback': feedback,
        'issues': issues,
        'created_at': DateTime.now().toIso8601String(),
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
      await updateProjectStatus(
        projectId,
        ProjectStatus.deliveredToClient,
        additionalData: {
          'delivered_to_client_at': DateTime.now().toIso8601String(),
        },
      );
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
  Stream<List<ProjectModel>> watchProjects() async* {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) return;
    yield* _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .eq('supervisor_id', supervisorId)
        .order('updated_at', ascending: false)
        .map((data) => data.map((json) => ProjectModel.fromJson(json)).toList());
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
        supervisorId: _userId ?? 'sup_1',
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
        supervisorId: _userId ?? 'sup_1',
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
        supervisorId: _userId ?? 'sup_1',
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
        supervisorId: _userId ?? 'sup_1',
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
        supervisorId: _userId ?? 'sup_1',
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
        fileSize: 1024 * 512, // 512KB
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
        fileSize: 1024 * 480, // 480KB
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
  return ProjectRepository(Supabase.instance.client);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/models/deliverable_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../domain/entities/project_status.dart';

/// State for the projects screen.
class ProjectsState {
  const ProjectsState({
    this.activeProjects = const [],
    this.forReviewProjects = const [],
    this.completedProjects = const [],
    this.isLoading = false,
    this.error,
    this.selectedTab = 0,
    this.selectedProject,
  });

  /// Active projects (assigned, in progress)
  final List<ProjectModel> activeProjects;

  /// Projects awaiting QC review
  final List<ProjectModel> forReviewProjects;

  /// Completed/historical projects
  final List<ProjectModel> completedProjects;

  /// Whether data is loading
  final bool isLoading;

  /// Error message
  final String? error;

  /// Currently selected tab index
  final int selectedTab;

  /// Currently selected project for detail view
  final ProjectModel? selectedProject;

  /// Creates a copy with updated fields.
  ProjectsState copyWith({
    List<ProjectModel>? activeProjects,
    List<ProjectModel>? forReviewProjects,
    List<ProjectModel>? completedProjects,
    bool? isLoading,
    String? error,
    int? selectedTab,
    ProjectModel? selectedProject,
  }) {
    return ProjectsState(
      activeProjects: activeProjects ?? this.activeProjects,
      forReviewProjects: forReviewProjects ?? this.forReviewProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  /// Total count of all projects.
  int get totalCount =>
      activeProjects.length + forReviewProjects.length + completedProjects.length;

  /// Count of projects requiring action.
  int get actionRequiredCount => forReviewProjects.length;
}

/// Notifier for projects state management.
class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier(this._repository) : super(const ProjectsState()) {
    loadProjects();
  }

  final ProjectRepository _repository;

  /// Loads all projects.
  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getActiveProjects(),
        _repository.getForReviewProjects(),
        _repository.getCompletedProjects(),
      ]);

      state = state.copyWith(
        activeProjects: results[0],
        forReviewProjects: results[1],
        completedProjects: results[2],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load projects: $e',
      );
    }
  }

  /// Refreshes all project data.
  Future<void> refresh() async {
    await loadProjects();
  }

  /// Changes the selected tab.
  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  /// Selects a project for detail view.
  Future<void> selectProject(String projectId) async {
    final project = await _repository.getProject(projectId);
    state = state.copyWith(selectedProject: project);
  }

  /// Clears the selected project.
  void clearSelectedProject() {
    state = state.copyWith(selectedProject: null);
  }

  /// Updates project status.
  Future<bool> updateStatus(String projectId, ProjectStatus status) async {
    final success = await _repository.updateProjectStatus(projectId, status);
    if (success) {
      await loadProjects();
    }
    return success;
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for projects state.
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectsNotifier(repository);
});

// ============================================================================
// Project Detail Provider
// ============================================================================

/// State for project detail screen.
class ProjectDetailState {
  const ProjectDetailState({
    this.project,
    this.deliverables = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
  });

  /// The project being viewed
  final ProjectModel? project;

  /// Project deliverables
  final List<DeliverableModel> deliverables;

  /// Whether data is loading
  final bool isLoading;

  /// Whether an update operation is in progress
  final bool isUpdating;

  /// Error message
  final String? error;

  ProjectDetailState copyWith({
    ProjectModel? project,
    List<DeliverableModel>? deliverables,
    bool? isLoading,
    bool? isUpdating,
    String? error,
  }) {
    return ProjectDetailState(
      project: project ?? this.project,
      deliverables: deliverables ?? this.deliverables,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
    );
  }

  /// Latest deliverable.
  DeliverableModel? get latestDeliverable =>
      deliverables.isNotEmpty ? deliverables.first : null;

  /// Whether project can be approved.
  bool get canApprove =>
      project?.status.isForReview == true && latestDeliverable != null;

  /// Whether revision can be requested.
  bool get canRequestRevision =>
      project?.status.isForReview == true && latestDeliverable != null;
}

/// Notifier for project detail.
class ProjectDetailNotifier extends StateNotifier<ProjectDetailState> {
  ProjectDetailNotifier(this._repository) : super(const ProjectDetailState());

  final ProjectRepository _repository;

  /// Loads project details.
  Future<void> loadProject(String projectId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getProject(projectId),
        _repository.getDeliverables(projectId),
      ]);

      state = state.copyWith(
        project: results[0] as ProjectModel?,
        deliverables: results[1] as List<DeliverableModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load project: $e',
      );
    }
  }

  /// Approves the latest deliverable.
  Future<bool> approveDeliverable({String? notes}) async {
    if (state.project == null || state.latestDeliverable == null) return false;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final success = await _repository.approveDeliverable(
        state.project!.id,
        state.latestDeliverable!.id,
        notes: notes,
      );

      if (success) {
        await loadProject(state.project!.id);
      }

      state = state.copyWith(isUpdating: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to approve: $e',
      );
      return false;
    }
  }

  /// Requests revision for the project.
  Future<bool> requestRevision({
    required String feedback,
    List<String>? issues,
  }) async {
    if (state.project == null) return false;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final success = await _repository.requestRevision(
        state.project!.id,
        feedback: feedback,
        issues: issues,
      );

      if (success) {
        await loadProject(state.project!.id);
      }

      state = state.copyWith(isUpdating: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to request revision: $e',
      );
      return false;
    }
  }

  /// Delivers project to client.
  Future<bool> deliverToClient() async {
    if (state.project == null) return false;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      final success = await _repository.deliverToClient(state.project!.id);

      if (success) {
        await loadProject(state.project!.id);
      }

      state = state.copyWith(isUpdating: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to deliver: $e',
      );
      return false;
    }
  }

  /// Clears error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for project detail.
final projectDetailProvider =
    StateNotifierProvider<ProjectDetailNotifier, ProjectDetailState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectDetailNotifier(repository);
});

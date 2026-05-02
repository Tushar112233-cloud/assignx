import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/project_model.dart';
import '../data/repositories/project_repository.dart';

/// Provider for project repository.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

/// Provider for all projects.
final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});

/// Provider for projects by tab index.
final projectsByTabProvider = FutureProvider.autoDispose.family<List<Project>, int>(
  (ref, tabIndex) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProjectsByTab(tabIndex);
  },
);

/// Provider for pending payment projects.
final pendingPaymentProjectsProvider = FutureProvider.autoDispose<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getPendingPaymentProjects();
});

/// Provider for a single project by ID.
final projectProvider = FutureProvider.autoDispose.family<Project?, String>(
  (ref, projectId) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProject(projectId);
  },
);

/// Provider for project counts by tab.
final projectCountsProvider = FutureProvider.autoDispose<Map<int, int>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectCounts();
});

/// Provider for current selected tab index.
final selectedProjectTabProvider = StateProvider<int>((ref) => 0);

/// Stream provider for real-time project updates.
final projectsStreamProvider = StreamProvider.autoDispose<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});

/// Stream provider for single project updates.
final projectStreamProvider = StreamProvider.autoDispose.family<Project?, String>(
  (ref, projectId) {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.watchProject(projectId);
  },
);

/// Provider for project timeline.
final projectTimelineProvider = FutureProvider.autoDispose.family<List<ProjectTimelineEvent>, String>(
  (ref, projectId) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getProjectTimeline(projectId);
  },
);

/// Provider for project deliverables.
final projectDeliverablesProvider = FutureProvider.autoDispose.family<List<ProjectDeliverable>, String>(
  (ref, projectId) async {
    final repository = ref.watch(projectRepositoryProvider);
    return repository.getDeliverables(projectId);
  },
);

/// State notifier for project operations.
class ProjectNotifier extends StateNotifier<AsyncValue<void>> {
  final ProjectRepository _repository;
  final Ref _ref;

  ProjectNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Approves a project.
  Future<void> approveProject(String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.approveProject(projectId);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Requests changes for a project.
  Future<void> requestChanges(String projectId, String feedback) async {
    state = const AsyncValue.loading();
    try {
      await _repository.requestChanges(projectId, feedback);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Records payment for a project.
  Future<void> recordPayment(String projectId, String paymentId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.recordPayment(projectId, paymentId);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates final grade for a project.
  Future<void> updateFinalGrade(String projectId, String grade) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateFinalGrade(projectId, grade);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cancels a project.
  Future<void> cancelProject(String projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelProject(projectId);
      _invalidateProviders();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Creates a new project.
  Future<Project?> createProject({
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
    state = const AsyncValue.loading();
    try {
      final project = await _repository.createProject(
        title: title,
        description: description,
        serviceType: serviceType,
        subjectId: subjectId,
        deadline: deadline,
        topic: topic,
        wordCount: wordCount,
        pageCount: pageCount,
        referenceStyleId: referenceStyleId,
        specificInstructions: specificInstructions,
        focusAreas: focusAreas,
      );
      _invalidateProviders();
      state = const AsyncValue.data(null);
      return project;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void _invalidateProviders() {
    _ref.invalidate(projectsProvider);
    _ref.invalidate(projectCountsProvider);
    _ref.invalidate(pendingPaymentProjectsProvider);
  }
}

/// Provider for project operations.
final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(projectRepositoryProvider);
    return ProjectNotifier(repository, ref);
  },
);

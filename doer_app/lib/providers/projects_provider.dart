/// Projects state management provider for the My Projects screen.
///
/// Manages fetching, filtering, and searching projects by status tabs
/// (Active, Under Review, Completed) with computed stats.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../data/models/doer_project_model.dart';
import '../data/repositories/project_repository.dart';
import 'auth_provider.dart';

/// Stats summary for the My Projects hero banner.
class ProjectStats {
  final int activeCount;
  final int completedCount;
  final double totalEarnings;

  const ProjectStats({
    this.activeCount = 0,
    this.completedCount = 0,
    this.totalEarnings = 0.0,
  });

  String get formattedEarnings => '₹${totalEarnings.toStringAsFixed(0)}';
}

/// State for the My Projects screen.
class MyProjectsState {
  final List<DoerProjectModel> activeProjects;
  final List<DoerProjectModel> underReviewProjects;
  final List<DoerProjectModel> completedProjects;
  final ProjectStats stats;
  final String searchQuery;
  final String? subjectFilter;
  final bool isLoading;
  final String? errorMessage;

  const MyProjectsState({
    this.activeProjects = const [],
    this.underReviewProjects = const [],
    this.completedProjects = const [],
    this.stats = const ProjectStats(),
    this.searchQuery = '',
    this.subjectFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Returns active projects filtered by search query and subject.
  List<DoerProjectModel> get filteredActiveProjects =>
      _applyFilters(activeProjects);

  /// Returns under-review projects filtered by search query and subject.
  List<DoerProjectModel> get filteredUnderReviewProjects =>
      _applyFilters(underReviewProjects);

  /// Returns completed projects filtered by search query and subject.
  List<DoerProjectModel> get filteredCompletedProjects =>
      _applyFilters(completedProjects);

  /// All unique subjects across all projects for filter chips.
  List<String> get availableSubjects {
    final subjects = <String>{};
    for (final p in [...activeProjects, ...underReviewProjects, ...completedProjects]) {
      if (p.subjectName != null && p.subjectName!.isNotEmpty) {
        subjects.add(p.subjectName!);
      }
    }
    return subjects.toList()..sort();
  }

  List<DoerProjectModel> _applyFilters(List<DoerProjectModel> projects) {
    var result = projects;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(query) ||
            (p.topic?.toLowerCase().contains(query) ?? false) ||
            (p.subjectName?.toLowerCase().contains(query) ?? false) ||
            p.projectNumber.toLowerCase().contains(query);
      }).toList();
    }

    if (subjectFilter != null && subjectFilter!.isNotEmpty) {
      result = result.where((p) => p.subjectName == subjectFilter).toList();
    }

    return result;
  }

  MyProjectsState copyWith({
    List<DoerProjectModel>? activeProjects,
    List<DoerProjectModel>? underReviewProjects,
    List<DoerProjectModel>? completedProjects,
    ProjectStats? stats,
    String? searchQuery,
    String? subjectFilter,
    bool clearSubjectFilter = false,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyProjectsState(
      activeProjects: activeProjects ?? this.activeProjects,
      underReviewProjects: underReviewProjects ?? this.underReviewProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      subjectFilter: clearSubjectFilter ? null : (subjectFilter ?? this.subjectFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier that manages My Projects state.
class MyProjectsNotifier extends Notifier<MyProjectsState> {
  late DoerProjectRepository _projectRepository;

  @override
  MyProjectsState build() {
    _projectRepository = ref.watch(doerProjectRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => _loadAllProjects());
    }
    return const MyProjectsState(isLoading: true);
  }

  SupabaseClient get _client => SupabaseConfig.client;
  String? get _userId => _client.auth.currentUser?.id;
  String? _cachedDoerId;

  /// Looks up the doer table ID from profile ID.
  Future<String?> _getDoerId() async {
    if (_cachedDoerId != null) return _cachedDoerId;
    if (_userId == null) return null;
    try {
      final response = await _client
          .from('doers')
          .select('id')
          .eq('profile_id', _userId!)
          .maybeSingle();
      _cachedDoerId = response?['id'] as String?;
      return _cachedDoerId;
    } catch (_) {
      return null;
    }
  }

  /// Loads all project categories in parallel.
  Future<void> _loadAllProjects() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.wait([
        _loadActiveProjects(),
        _loadUnderReviewProjects(),
        _loadCompletedProjects(),
        _loadStats(),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyProjectsNotifier._loadAllProjects error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load projects',
      );
    }
  }

  /// Loads active projects (in_progress, assigned, revision_requested, in_revision).
  Future<void> _loadActiveProjects() async {
    try {
      final doerId = await _getDoerId();
      if (doerId == null) return;
      final response = await _client.from('projects').select('''
        *,
        subject:subjects(id, name),
        reference_style:reference_styles(id, name, slug)
      ''').eq('doer_id', doerId).inFilter('status', [
        'in_progress',
        'assigned',
        'revision_requested',
        'in_revision',
      ]).order('deadline', ascending: true);

      final projects = (response as List)
          .map((json) => DoerProjectModel.fromJson(json))
          .toList();

      state = state.copyWith(activeProjects: projects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyProjectsNotifier._loadActiveProjects error: $e');
      }
    }
  }

  /// Loads projects under review (delivered, for_review).
  Future<void> _loadUnderReviewProjects() async {
    try {
      final doerId = await _getDoerId();
      if (doerId == null) return;
      final response = await _client.from('projects').select('''
        *,
        subject:subjects(id, name),
        reference_style:reference_styles(id, name, slug)
      ''').eq('doer_id', doerId).inFilter('status', [
        'delivered',
        'submitted_for_qc',
      ]).order('delivered_at', ascending: false);

      final projects = (response as List)
          .map((json) => DoerProjectModel.fromJson(json))
          .toList();

      state = state.copyWith(underReviewProjects: projects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyProjectsNotifier._loadUnderReviewProjects error: $e');
      }
    }
  }

  /// Loads completed projects.
  Future<void> _loadCompletedProjects() async {
    try {
      final projects = await _projectRepository.getCompletedProjects();
      state = state.copyWith(completedProjects: projects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyProjectsNotifier._loadCompletedProjects error: $e');
      }
    }
  }

  /// Loads aggregated stats.
  Future<void> _loadStats() async {
    try {
      final stats = await _projectRepository.getDoerStatistics();
      state = state.copyWith(
        stats: ProjectStats(
          activeCount: stats.activeProjects,
          completedCount: stats.completedProjects,
          totalEarnings: stats.totalEarnings,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MyProjectsNotifier._loadStats error: $e');
      }
    }
  }

  /// Updates the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Sets the subject filter.
  void setSubjectFilter(String? subject) {
    if (subject == null) {
      state = state.copyWith(clearSubjectFilter: true);
    } else {
      state = state.copyWith(subjectFilter: subject);
    }
  }

  /// Refreshes all projects data.
  Future<void> refresh() async {
    await _loadAllProjects();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Providers
// ══════════════════════════════════════════════════════════════════════════════

/// Main My Projects provider.
final myProjectsProvider =
    NotifierProvider<MyProjectsNotifier, MyProjectsState>(() {
  return MyProjectsNotifier();
});

/// Convenience provider for project stats.
final projectStatsProvider = Provider<ProjectStats>((ref) {
  return ref.watch(myProjectsProvider).stats;
});

/// Convenience provider for filtered active projects.
final filteredActiveProjectsProvider = Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(myProjectsProvider).filteredActiveProjects;
});

/// Convenience provider for filtered under-review projects.
final filteredUnderReviewProjectsProvider =
    Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(myProjectsProvider).filteredUnderReviewProjects;
});

/// Convenience provider for filtered completed projects.
final filteredCompletedProjectsProvider =
    Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(myProjectsProvider).filteredCompletedProjects;
});

/// Convenience provider for available subject filters in the My Projects screen.
final projectSubjectFiltersProvider = Provider<List<String>>((ref) {
  return ref.watch(myProjectsProvider).availableSubjects;
});

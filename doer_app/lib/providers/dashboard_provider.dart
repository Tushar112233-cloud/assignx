/// Dashboard state management provider for the Doer App.
///
/// This file manages the main dashboard view that activated doers see,
/// including their assigned projects, open pool projects available for
/// claiming, statistics, reviews, and availability status.
///
/// Integrated with Supabase for real-time data sync.
library;

import 'package:flutter/foundation.dart';
import '../data/models/project_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../data/models/doer_project_model.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/wallet_repository.dart';
import 'auth_provider.dart';

/// Immutable state class representing the dashboard data.
class DashboardState {
  /// List of projects currently assigned to the doer.
  final List<DoerProjectModel> assignedProjects;

  /// List of projects available in the open pool.
  final List<DoerProjectModel> openPoolProjects;

  /// Aggregated statistics for the doer.
  final DoerStats stats;

  /// Recent reviews from completed projects.
  final List<ReviewModel> reviews;

  /// Wallet information with balance.
  final WalletModel? wallet;

  /// Pending earnings from delivered projects.
  final double pendingEarnings;

  /// Whether dashboard data is currently being loaded.
  final bool isLoading;

  /// Whether the doer is available to accept new projects.
  final bool isAvailable;

  /// Error message if loading failed, null otherwise.
  final String? errorMessage;

  const DashboardState({
    this.assignedProjects = const [],
    this.openPoolProjects = const [],
    this.stats = const DoerStats(),
    this.reviews = const [],
    this.wallet,
    this.pendingEarnings = 0.0,
    this.isLoading = false,
    this.isAvailable = true,
    this.errorMessage,
  });

  /// Total active projects count.
  int get activeProjectCount => assignedProjects
      .where((p) => p.status == DoerProjectStatus.inProgress ||
                    p.status == DoerProjectStatus.assigned)
      .length;

  /// Projects due soon (within 24 hours).
  List<DoerProjectModel> get urgentProjects => assignedProjects
      .where((p) => p.hoursUntilDeadline <= 24 && p.hoursUntilDeadline > 0)
      .toList();

  DashboardState copyWith({
    List<DoerProjectModel>? assignedProjects,
    List<DoerProjectModel>? openPoolProjects,
    DoerStats? stats,
    List<ReviewModel>? reviews,
    WalletModel? wallet,
    double? pendingEarnings,
    bool? isLoading,
    bool? isAvailable,
    String? errorMessage,
  }) {
    return DashboardState(
      assignedProjects: assignedProjects ?? this.assignedProjects,
      openPoolProjects: openPoolProjects ?? this.openPoolProjects,
      stats: stats ?? this.stats,
      reviews: reviews ?? this.reviews,
      wallet: wallet ?? this.wallet,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      isLoading: isLoading ?? this.isLoading,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier class that manages dashboard state and operations.
class DashboardNotifier extends Notifier<DashboardState> {
  late DoerProjectRepository _projectRepository;
  late DoerWalletRepository _walletRepository;

  @override
  DashboardState build() {
    _projectRepository = ref.watch(doerProjectRepositoryProvider);
    _walletRepository = ref.watch(doerWalletRepositoryProvider);

    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => _loadDashboardData(user.id));
    }
    return const DashboardState(isLoading: true);
  }

  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads all dashboard data from Supabase.
  Future<void> _loadDashboardData(String doerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load all data in parallel using repositories
      await Future.wait([
        _loadAssignedProjects(),
        _loadOpenPoolProjects(),
        _loadStats(doerId),
        _loadReviews(doerId),
        _loadWalletInfo(),
        _loadAvailability(doerId),
      ]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadDashboardData error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data',
      );
    }
  }

  /// Loads projects assigned to the doer using repository.
  Future<void> _loadAssignedProjects() async {
    try {
      final projects = await _projectRepository.getAssignedProjects();
      state = state.copyWith(assignedProjects: projects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadAssignedProjects error: $e');
      }
    }
  }

  /// Loads open pool projects using repository.
  Future<void> _loadOpenPoolProjects() async {
    try {
      final projects = await _projectRepository.getOpenPoolProjects();
      state = state.copyWith(openPoolProjects: projects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadOpenPoolProjects error: $e');
      }
    }
  }

  /// Loads doer statistics from Supabase.
  Future<void> _loadStats(String profileId) async {
    try {
      // Get doer record for stats (using profile_id)
      final doerResponse = await _client
          .from('doers')
          .select('id, total_projects_completed, total_earnings, average_rating, success_rate, on_time_delivery_rate')
          .eq('profile_id', profileId)
          .maybeSingle();

      final actualDoerId = doerResponse?['id'] as String?;

      // Get in-progress count (using doer table ID)
      final inProgressResponse = actualDoerId != null
          ? await _client
              .from('projects')
              .select('id')
              .eq('doer_id', actualDoerId)
              .inFilter('status', ['assigned', 'in_progress'])
          : [];

      state = state.copyWith(
        stats: DoerStats(
          totalEarnings: (doerResponse?['total_earnings'] as num?)?.toDouble() ?? 0,
          completedProjects: doerResponse?['total_projects_completed'] as int? ?? 0,
          activeProjects: (inProgressResponse as List).length,
          rating: (doerResponse?['average_rating'] as num?)?.toDouble() ?? 0,
          onTimeDeliveryRate: (doerResponse?['on_time_delivery_rate'] as num?)?.toDouble() ?? 0.95,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadStats error: $e');
      }
    }
  }

  /// Loads recent reviews from Supabase doer_reviews table.
  Future<void> _loadReviews(String profileId) async {
    try {
      // Look up the actual doer ID
      final doerRecord = await _client
          .from('doers')
          .select('id')
          .eq('profile_id', profileId)
          .maybeSingle();
      final actualDoerId = doerRecord?['id'] as String?;
      if (actualDoerId == null) {
        state = state.copyWith(reviews: []);
        return;
      }

      final response = await _client
          .from('doer_reviews')
          .select('''
            *,
            project:projects(id, title, project_number),
            reviewer:profiles!reviewer_id(id, full_name, avatar_url)
          ''')
          .eq('doer_id', actualDoerId)
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .limit(50);

      final reviews = (response as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList();

      state = state.copyWith(reviews: reviews);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadReviews error: $e');
      }
      state = state.copyWith(reviews: []);
    }
  }

  /// Loads wallet information using repository.
  Future<void> _loadWalletInfo() async {
    try {
      final wallet = await _walletRepository.getWallet();
      final pendingEarnings = await _walletRepository.getPendingEarnings();

      state = state.copyWith(
        wallet: wallet,
        pendingEarnings: pendingEarnings,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadWalletInfo error: $e');
      }
    }
  }

  /// Loads doer availability status from doers table.
  Future<void> _loadAvailability(String doerId) async {
    try {
      final response = await _client
          .from('doers')
          .select('is_available')
          .eq('profile_id', doerId)
          .maybeSingle();

      state = state.copyWith(isAvailable: response?['is_available'] as bool? ?? true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier._loadAvailability error: $e');
      }
    }
  }

  /// Toggles the doer's availability status.
  Future<void> toggleAvailability() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final newStatus = !state.isAvailable;

    try {
      await _client
          .from('doers')
          .update({
            'is_available': newStatus,
            'availability_updated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('profile_id', user.id);

      state = state.copyWith(isAvailable: newStatus);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier.toggleAvailability error: $e');
      }
      // Revert to previous state on failure
      state = state.copyWith(isAvailable: !newStatus);
    }
  }

  /// Accepts a project from the open pool using repository.
  Future<bool> acceptProject(String projectId) async {
    try {
      final success = await _projectRepository.acceptProject(projectId);

      if (success) {
        // Move project from open pool to assigned
        final projectIndex = state.openPoolProjects
            .indexWhere((p) => p.id == projectId);

        if (projectIndex != -1) {
          final project = state.openPoolProjects[projectIndex];
          final updatedProject = project.copyWith(
            status: DoerProjectStatus.assigned,
            doerAssignedAt: DateTime.now(),
          );

          state = state.copyWith(
            openPoolProjects: state.openPoolProjects
                .where((p) => p.id != projectId)
                .toList(),
            assignedProjects: [...state.assignedProjects, updatedProject],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier.acceptProject error: $e');
      }
      return false;
    }
  }

  /// Starts working on a project.
  Future<bool> startProject(String projectId) async {
    try {
      final success = await _projectRepository.startProject(projectId);

      if (success) {
        // Update local state
        final updatedProjects = state.assignedProjects.map((p) {
          if (p.id == projectId) {
            return p.copyWith(
              status: DoerProjectStatus.inProgress,
            );
          }
          return p;
        }).toList();

        state = state.copyWith(assignedProjects: updatedProjects);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier.startProject error: $e');
      }
      return false;
    }
  }

  /// Updates project progress.
  Future<void> updateProgress(String projectId, int percentage) async {
    try {
      await _projectRepository.updateProgress(projectId, percentage);

      // Update local state
      final updatedProjects = state.assignedProjects.map((p) {
        if (p.id == projectId) {
          return p.copyWith(progressPercentage: percentage);
        }
        return p;
      }).toList();

      state = state.copyWith(assignedProjects: updatedProjects);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DashboardNotifier.updateProgress error: $e');
      }
    }
  }

  /// Refreshes all dashboard data.
  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _loadDashboardData(user.id);
    }
  }

}

/// The main dashboard provider.
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

/// Convenience provider for assigned projects.
final assignedProjectsProvider = Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(dashboardProvider).assignedProjects;
});

/// Convenience provider for open pool projects.
final openPoolProjectsProvider = Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(dashboardProvider).openPoolProjects;
});

/// Convenience provider for doer statistics.
final doerStatsProvider = Provider<DoerStats>((ref) {
  return ref.watch(dashboardProvider).stats;
});

/// Convenience provider for doer reviews.
final doerReviewsProvider = Provider<List<ReviewModel>>((ref) {
  return ref.watch(dashboardProvider).reviews;
});

/// Convenience provider for availability status.
final isAvailableProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isAvailable;
});

/// Convenience provider for dashboard loading state.
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

/// Convenience provider for urgent projects.
final urgentProjectsProvider = Provider<List<DoerProjectModel>>((ref) {
  return ref.watch(dashboardProvider).urgentProjects;
});

/// Convenience provider for wallet balance.
final walletBalanceProvider = Provider<double>((ref) {
  return ref.watch(dashboardProvider).wallet?.balance ?? 0.0;
});

/// Convenience provider for pending earnings.
final pendingEarningsProvider = Provider<double>((ref) {
  return ref.watch(dashboardProvider).pendingEarnings;
});

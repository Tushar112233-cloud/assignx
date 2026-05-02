import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/data/models/doer_model.dart';
import '../../data/repositories/doers_repository.dart';

/// Provider for doers repository.
final doersRepositoryProvider = Provider<DoersRepository>((ref) {
  return DoersRepository();
});

/// State for doers list.
class DoersState {
  const DoersState({
    this.doers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.searchQuery = '',
    this.selectedExpertise,
    this.isAvailableOnly = false,
    this.minRating,
    this.sortBy = 'rating',
    this.ascending = false,
  });

  final List<DoerModel> doers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String searchQuery;
  final String? selectedExpertise;
  final bool isAvailableOnly;
  final double? minRating;
  final String sortBy;
  final bool ascending;

  DoersState copyWith({
    List<DoerModel>? doers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? searchQuery,
    String? selectedExpertise,
    bool? isAvailableOnly,
    double? minRating,
    String? sortBy,
    bool? ascending,
    bool clearExpertise = false,
    bool clearRating = false,
  }) {
    return DoersState(
      doers: doers ?? this.doers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedExpertise: clearExpertise ? null : (selectedExpertise ?? this.selectedExpertise),
      isAvailableOnly: isAvailableOnly ?? this.isAvailableOnly,
      minRating: clearRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Notifier for doers list.
class DoersNotifier extends StateNotifier<DoersState> {
  DoersNotifier(this._repository) : super(const DoersState());

  final DoersRepository _repository;
  static const _pageSize = 20;

  /// Load doers.
  Future<void> loadDoers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final doers = await _repository.getDoers(
        limit: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        expertise: state.selectedExpertise,
        isAvailable: state.isAvailableOnly ? true : null,
        minRating: state.minRating,
        sortBy: state.sortBy,
        ascending: state.ascending,
      );

      state = state.copyWith(
        doers: doers,
        isLoading: false,
        hasMore: doers.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more doers.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final doers = await _repository.getDoers(
        limit: _pageSize,
        offset: state.doers.length,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        expertise: state.selectedExpertise,
        isAvailable: state.isAvailableOnly ? true : null,
        minRating: state.minRating,
        sortBy: state.sortBy,
        ascending: state.ascending,
      );

      state = state.copyWith(
        doers: [...state.doers, ...doers],
        isLoadingMore: false,
        hasMore: doers.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh doers.
  Future<void> refresh() async {
    await loadDoers();
  }

  /// Search doers.
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadDoers();
  }

  /// Filter by expertise.
  Future<void> setExpertiseFilter(String? expertise) async {
    state = state.copyWith(
      selectedExpertise: expertise,
      clearExpertise: expertise == null,
    );
    await loadDoers();
  }

  /// Toggle available only filter.
  Future<void> setAvailableOnly(bool value) async {
    state = state.copyWith(isAvailableOnly: value);
    await loadDoers();
  }

  /// Set minimum rating filter.
  Future<void> setMinRating(double? rating) async {
    state = state.copyWith(
      minRating: rating,
      clearRating: rating == null,
    );
    await loadDoers();
  }

  /// Sort doers.
  Future<void> sort(String sortBy, {bool ascending = false}) async {
    state = state.copyWith(sortBy: sortBy, ascending: ascending);
    await loadDoers();
  }

  /// Clear all filters.
  Future<void> clearFilters() async {
    state = state.copyWith(
      searchQuery: '',
      clearExpertise: true,
      isAvailableOnly: false,
      clearRating: true,
    );
    await loadDoers();
  }
}

/// Provider for doers list.
final doersProvider =
    StateNotifierProvider<DoersNotifier, DoersState>((ref) {
  final repository = ref.watch(doersRepositoryProvider);
  return DoersNotifier(repository);
});

/// State for doer detail.
class DoerDetailState {
  const DoerDetailState({
    this.doer,
    this.reviews = const [],
    this.projects = const [],
    this.isLoading = false,
    this.isLoadingReviews = false,
    this.hasMoreReviews = true,
    this.error,
  });

  final DoerModel? doer;
  final List<DoerReview> reviews;
  final List<Map<String, dynamic>> projects;
  final bool isLoading;
  final bool isLoadingReviews;
  final bool hasMoreReviews;
  final String? error;

  DoerDetailState copyWith({
    DoerModel? doer,
    List<DoerReview>? reviews,
    List<Map<String, dynamic>>? projects,
    bool? isLoading,
    bool? isLoadingReviews,
    bool? hasMoreReviews,
    String? error,
  }) {
    return DoerDetailState(
      doer: doer ?? this.doer,
      reviews: reviews ?? this.reviews,
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      error: error,
    );
  }
}

/// Notifier for doer detail.
class DoerDetailNotifier extends StateNotifier<DoerDetailState> {
  DoerDetailNotifier(this._repository) : super(const DoerDetailState());

  final DoersRepository _repository;
  static const _pageSize = 20;

  /// Load doer detail.
  Future<void> loadDoer(String doerId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final doer = await _repository.getDoerById(doerId);

      if (doer == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Doer not found',
        );
        return;
      }

      state = state.copyWith(
        doer: doer,
        isLoading: false,
      );

      // Load reviews and projects
      await _loadReviews(doerId);
      await _loadProjects(doerId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadReviews(String doerId) async {
    state = state.copyWith(isLoadingReviews: true);

    try {
      final reviews = await _repository.getDoerReviews(doerId, limit: _pageSize);
      state = state.copyWith(
        reviews: reviews,
        isLoadingReviews: false,
        hasMoreReviews: reviews.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingReviews: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadProjects(String doerId) async {
    try {
      final projects = await _repository.getDoerProjects(doerId, limit: 10);
      state = state.copyWith(projects: projects);
    } catch (e) {
      // Non-critical, don't update error
    }
  }

  /// Load more reviews.
  Future<void> loadMoreReviews(String doerId) async {
    if (state.isLoadingReviews || !state.hasMoreReviews) return;

    state = state.copyWith(isLoadingReviews: true);

    try {
      final reviews = await _repository.getDoerReviews(
        doerId,
        limit: _pageSize,
        offset: state.reviews.length,
      );

      state = state.copyWith(
        reviews: [...state.reviews, ...reviews],
        isLoadingReviews: false,
        hasMoreReviews: reviews.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingReviews: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for doer detail.
final doerDetailProvider =
    StateNotifierProvider<DoerDetailNotifier, DoerDetailState>((ref) {
  final repository = ref.watch(doersRepositoryProvider);
  return DoerDetailNotifier(repository);
});

/// Provider for expertise areas.
final expertiseAreasProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(doersRepositoryProvider);
  return repository.getExpertiseAreas();
});

/// Provider for doers count.
final doersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(doersRepositoryProvider);
  return repository.getDoersCount();
});

/// Provider for available doers count.
final availableDoersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(doersRepositoryProvider);
  return repository.getAvailableDoersCount();
});

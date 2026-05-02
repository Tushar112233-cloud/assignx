import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/profile_repository.dart';

/// Provider for profile repository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// ==================== PROFILE STATE ====================

/// State for profile.
class ProfileState {
  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final SupervisorProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  ProfileState copyWith({
    SupervisorProfile? profile,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Notifier for profile state.
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._repository) : super(const ProfileState()) {
    loadProfile();
  }

  final ProfileRepository _repository;

  /// Load profile.
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  /// Update profile.
  Future<bool> updateProfile(SupervisorProfile profile) async {
    state = state.copyWith(isSaving: true);

    try {
      final updated = await _repository.updateProfile(profile);
      state = state.copyWith(
        profile: updated,
        isSaving: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile: $e',
      );
      return false;
    }
  }

  /// Upload avatar.
  Future<bool> uploadAvatar(File imageFile) async {
    state = state.copyWith(isSaving: true);

    try {
      final url = await _repository.uploadAvatar(imageFile);
      if (url != null && state.profile != null) {
        final updated = state.profile!.copyWith(avatarUrl: url);
        state = state.copyWith(
          profile: updated,
          isSaving: false,
        );
        return true;
      }
      state = state.copyWith(isSaving: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to upload avatar: $e',
      );
      return false;
    }
  }

  /// Update availability.
  Future<void> updateAvailability(bool isAvailable) async {
    if (state.profile == null) return;

    final updated = state.profile!.copyWith(isAvailable: isAvailable);
    state = state.copyWith(profile: updated);

    await _repository.updateAvailability(isAvailable);
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for profile.
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

// ==================== REVIEWS STATE ====================

/// State for reviews.
class ReviewsState {
  const ReviewsState({
    this.reviews = const [],
    this.summary,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = const ReviewFilter(),
  });

  final List<ReviewModel> reviews;
  final ReviewsSummary? summary;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final ReviewFilter filter;

  ReviewsState copyWith({
    List<ReviewModel>? reviews,
    ReviewsSummary? summary,
    bool? isLoading,
    bool? hasMore,
    String? error,
    ReviewFilter? filter,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

/// Notifier for reviews.
class ReviewsNotifier extends StateNotifier<ReviewsState> {
  ReviewsNotifier(this._repository) : super(const ReviewsState()) {
    loadReviews();
    loadSummary();
  }

  final ProfileRepository _repository;
  static const _pageSize = 20;

  /// Load reviews.
  Future<void> loadReviews({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final reviews = await _repository.getReviews(
        limit: _pageSize,
        offset: refresh ? 0 : state.reviews.length,
        filter: state.filter,
      );

      state = state.copyWith(
        reviews: refresh ? reviews : [...state.reviews, ...reviews],
        isLoading: false,
        hasMore: reviews.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reviews: $e',
      );
    }
  }

  /// Load summary.
  Future<void> loadSummary() async {
    try {
      final summary = await _repository.getReviewsSummary();
      state = state.copyWith(summary: summary);
    } catch (e) {
      // Ignore summary errors
    }
  }

  /// Refresh reviews.
  Future<void> refresh() async {
    await loadReviews(refresh: true);
    await loadSummary();
  }

  /// Load more reviews.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadReviews();
  }

  /// Update filter.
  void updateFilter(ReviewFilter filter) {
    state = state.copyWith(filter: filter);
    loadReviews(refresh: true);
  }

  /// Respond to review.
  Future<bool> respondToReview(String reviewId, String response) async {
    try {
      final success = await _repository.respondToReview(reviewId, response);
      if (success) {
        final updatedReviews = state.reviews.map((r) {
          if (r.id == reviewId) {
            return r.copyWith(
              response: response,
              respondedAt: DateTime.now(),
            );
          }
          return r;
        }).toList();
        state = state.copyWith(reviews: updatedReviews);
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to respond: $e');
      return false;
    }
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for reviews.
final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, ReviewsState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ReviewsNotifier(repository);
});

// ==================== BLACKLIST STATE ====================

/// State for doer blacklist.
class BlacklistState {
  const BlacklistState({
    this.blacklistedDoers = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DoerInfo> blacklistedDoers;
  final bool isLoading;
  final String? error;

  BlacklistState copyWith({
    List<DoerInfo>? blacklistedDoers,
    bool? isLoading,
    String? error,
  }) {
    return BlacklistState(
      blacklistedDoers: blacklistedDoers ?? this.blacklistedDoers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for blacklist.
class BlacklistNotifier extends StateNotifier<BlacklistState> {
  BlacklistNotifier(this._repository) : super(const BlacklistState()) {
    loadBlacklist();
  }

  final ProfileRepository _repository;

  /// Load blacklisted doers.
  Future<void> loadBlacklist() async {
    state = state.copyWith(isLoading: true);

    try {
      final doers = await _repository.getBlacklistedDoers();
      state = state.copyWith(
        blacklistedDoers: doers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load blacklist: $e',
      );
    }
  }

  /// Add doer to blacklist.
  Future<bool> blacklistDoer(String doerId, String reason) async {
    try {
      final success = await _repository.blacklistDoer(doerId, reason);
      if (success) {
        await loadBlacklist();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to blacklist: $e');
      return false;
    }
  }

  /// Remove doer from blacklist.
  Future<bool> unblacklistDoer(String doerId) async {
    try {
      final success = await _repository.unblacklistDoer(doerId);
      if (success) {
        final updated = state.blacklistedDoers
            .where((d) => d.id != doerId)
            .toList();
        state = state.copyWith(blacklistedDoers: updated);
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove from blacklist: $e');
      return false;
    }
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for blacklist.
final blacklistProvider =
    StateNotifierProvider<BlacklistNotifier, BlacklistState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return BlacklistNotifier(repository);
});

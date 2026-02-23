import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/marketplace_model.dart';
import '../data/models/project_subject.dart';
import '../data/models/question_model.dart';
import '../data/models/tutor_model.dart';
import '../data/repositories/marketplace_repository.dart';

/// Provider for marketplace repository.
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

/// State for marketplace filters.
class MarketplaceFilterState {
  final MarketplaceCategory? category;
  final String? city;
  final String? searchQuery;

  const MarketplaceFilterState({
    this.category,
    this.city,
    this.searchQuery,
  });

  MarketplaceFilterState copyWith({
    MarketplaceCategory? category,
    String? city,
    String? searchQuery,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearSearch = false,
  }) {
    return MarketplaceFilterState(
      category: clearCategory ? null : (category ?? this.category),
      city: clearCity ? null : (city ?? this.city),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasFilters => category != null || city != null || searchQuery != null;
}

/// Provider for marketplace filters.
final marketplaceFilterProvider =
    StateNotifierProvider<MarketplaceFilterNotifier, MarketplaceFilterState>(
        (ref) {
  return MarketplaceFilterNotifier();
});

/// Notifier for marketplace filters.
class MarketplaceFilterNotifier extends StateNotifier<MarketplaceFilterState> {
  MarketplaceFilterNotifier() : super(const MarketplaceFilterState());

  void setCategory(MarketplaceCategory? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }

  void setCity(String? city) {
    state = state.copyWith(
      city: city,
      clearCity: city == null,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    );
  }

  void clearFilters() {
    state = const MarketplaceFilterState();
  }
}

/// Provider for marketplace listings.
final marketplaceListingsProvider =
    FutureProvider.autoDispose<List<MarketplaceListing>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final filters = ref.watch(marketplaceFilterProvider);

  return repository.getListings(
    category: filters.category,
    city: filters.city,
    searchQuery: filters.searchQuery,
  );
});

/// Provider for a single listing.
final listingDetailProvider =
    FutureProvider.autoDispose.family<MarketplaceListing?, String>(
        (ref, listingId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getListingById(listingId);
});

/// Provider for user's own listings.
final userListingsProvider =
    FutureProvider.autoDispose<List<MarketplaceListing>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getUserListings();
});

/// Provider to toggle like.
final toggleLikeProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, listingId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.toggleLike(listingId);
});

// ============================================================
// TUTOR PROVIDERS
// ============================================================

/// State for tutor filters.
class TutorFilterState {
  final List<String>? subjects;
  final String? searchQuery;
  final double? minRating;
  final double? maxRate;

  const TutorFilterState({
    this.subjects,
    this.searchQuery,
    this.minRating,
    this.maxRate,
  });

  TutorFilterState copyWith({
    List<String>? subjects,
    String? searchQuery,
    double? minRating,
    double? maxRate,
    bool clearSubjects = false,
    bool clearSearch = false,
    bool clearRating = false,
    bool clearRate = false,
  }) {
    return TutorFilterState(
      subjects: clearSubjects ? null : (subjects ?? this.subjects),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      maxRate: clearRate ? null : (maxRate ?? this.maxRate),
    );
  }

  bool get hasFilters =>
      subjects != null ||
      searchQuery != null ||
      minRating != null ||
      maxRate != null;
}

/// Provider for tutor filters.
final tutorFilterProvider =
    StateNotifierProvider<TutorFilterNotifier, TutorFilterState>((ref) {
  return TutorFilterNotifier();
});

/// Notifier for tutor filters.
class TutorFilterNotifier extends StateNotifier<TutorFilterState> {
  TutorFilterNotifier() : super(const TutorFilterState());

  void setSubjects(List<String>? subjects) {
    state = state.copyWith(
      subjects: subjects,
      clearSubjects: subjects == null || subjects.isEmpty,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    );
  }

  void setMinRating(double? rating) {
    state = state.copyWith(
      minRating: rating,
      clearRating: rating == null,
    );
  }

  void setMaxRate(double? rate) {
    state = state.copyWith(
      maxRate: rate,
      clearRate: rate == null,
    );
  }

  void clearFilters() {
    state = const TutorFilterState();
  }
}

/// Provider for all tutors with filters applied.
final tutorsProvider =
    FutureProvider.autoDispose<List<Tutor>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final filters = ref.watch(tutorFilterProvider);

  return repository.getTutors(
    subjects: filters.subjects,
    searchQuery: filters.searchQuery,
    minRating: filters.minRating,
    maxRate: filters.maxRate,
  );
});

/// Provider for featured/top-rated tutors.
final featuredTutorsProvider =
    FutureProvider.autoDispose<List<Tutor>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getFeaturedTutors(limit: 5);
});

/// Provider for a single tutor by ID.
final tutorDetailProvider =
    FutureProvider.autoDispose.family<Tutor?, String>((ref, tutorId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getTutorById(tutorId);
});

/// Provider for tutor reviews.
final tutorReviewsProvider =
    FutureProvider.autoDispose.family<List<TutorReview>, String>(
        (ref, tutorId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getTutorReviews(tutorId);
});

/// Provider for user's booked sessions.
final userSessionsProvider =
    FutureProvider.autoDispose<List<BookedSession>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getUserSessions();
});

// ============================================================
// Q&A PROVIDERS
// ============================================================

/// Provider for Q&A filters.
final qaFilterProvider =
    StateNotifierProvider<QAFilterNotifier, QAFilterState>((ref) {
  return QAFilterNotifier();
});

/// Notifier for Q&A filters.
class QAFilterNotifier extends StateNotifier<QAFilterState> {
  QAFilterNotifier() : super(const QAFilterState());

  /// Set subject filter.
  void setSubject(ProjectSubject? subject) {
    state = state.copyWith(
      subject: subject,
      clearSubject: subject == null,
    );
  }

  /// Set tag filter.
  void setTag(String? tag) {
    state = state.copyWith(
      tag: tag,
      clearTag: tag == null || tag.isEmpty,
    );
  }

  /// Set search query.
  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    );
  }

  /// Set sort option.
  void setSortBy(QuestionSortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Set status filter.
  void setStatusFilter({
    bool showAnsweredOnly = false,
    bool showUnansweredOnly = false,
  }) {
    state = state.copyWith(
      showAnsweredOnly: showAnsweredOnly,
      showUnansweredOnly: showUnansweredOnly,
    );
  }

  /// Clear all filters.
  void clearFilters() {
    state = const QAFilterState();
  }
}

/// Provider for questions with filters applied.
final questionsProvider =
    FutureProvider.autoDispose<List<Question>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final filters = ref.watch(qaFilterProvider);

  return repository.getQuestions(
    subject: filters.subject,
    tag: filters.tag,
    searchQuery: filters.searchQuery,
    sortBy: filters.sortBy,
    showAnsweredOnly: filters.showAnsweredOnly,
    showUnansweredOnly: filters.showUnansweredOnly,
  );
});

/// Provider for a single question by ID.
final questionDetailProvider =
    FutureProvider.autoDispose.family<Question?, String>(
        (ref, questionId) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getQuestionById(questionId);
});

/// Provider to submit a new question.
final submitQuestionProvider =
    FutureProvider.autoDispose.family<Question, Map<String, dynamic>>(
        (ref, data) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.submitQuestion(
    title: data['title'] as String,
    content: data['content'] as String?,
    subject: data['subject'] as String,
    tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    isAnonymous: data['is_anonymous'] as bool? ?? false,
  );
});

/// Provider to submit an answer.
final submitAnswerProvider =
    FutureProvider.autoDispose.family<Answer, Map<String, dynamic>>(
        (ref, data) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  return repository.submitAnswer(
    questionId: data['question_id'] as String,
    content: data['content'] as String,
  );
});

/// Provider to vote on a question.
final voteQuestionProvider = FutureProvider.autoDispose
    .family<void, ({String questionId, bool isUpvote})>((ref, params) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  await repository.voteQuestion(
    questionId: params.questionId,
    isUpvote: params.isUpvote,
  );
  // Invalidate questions to refresh
  ref.invalidate(questionsProvider);
});

/// Provider to vote on an answer.
final voteAnswerProvider = FutureProvider.autoDispose
    .family<void, ({String answerId, bool isUpvote})>((ref, params) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  await repository.voteAnswer(
    answerId: params.answerId,
    isUpvote: params.isUpvote,
  );
});

/// Provider to accept an answer.
final acceptAnswerProvider = FutureProvider.autoDispose
    .family<void, ({String questionId, String answerId})>((ref, params) async {
  final repository = ref.read(marketplaceRepositoryProvider);
  await repository.acceptAnswer(
    questionId: params.questionId,
    answerId: params.answerId,
  );
  // Invalidate question detail to refresh
  ref.invalidate(questionDetailProvider(params.questionId));
});

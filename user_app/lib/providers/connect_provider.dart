import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/connect_models.dart';
import '../data/models/tutor_model.dart';

/// Connect tab enum for navigation.
enum ConnectTab { tutors, studyGroups, resources }

/// State for connect filters.
class ConnectFilterState {
  final String? searchQuery;
  final String? subject;
  final double? minRating;
  final double? maxPrice;
  final List<String>? availability;
  final String? sortBy;
  final ResourceType? resourceType;

  const ConnectFilterState({
    this.searchQuery,
    this.subject,
    this.minRating,
    this.maxPrice,
    this.availability,
    this.sortBy,
    this.resourceType,
  });

  ConnectFilterState copyWith({
    String? searchQuery,
    String? subject,
    double? minRating,
    double? maxPrice,
    List<String>? availability,
    String? sortBy,
    ResourceType? resourceType,
    bool clearSearch = false,
    bool clearSubject = false,
    bool clearRating = false,
    bool clearPrice = false,
    bool clearAvailability = false,
    bool clearSort = false,
    bool clearResourceType = false,
  }) {
    return ConnectFilterState(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      subject: clearSubject ? null : (subject ?? this.subject),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      availability: clearAvailability ? null : (availability ?? this.availability),
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
      resourceType: clearResourceType ? null : (resourceType ?? this.resourceType),
    );
  }

  bool get hasFilters =>
      searchQuery != null ||
      subject != null ||
      minRating != null ||
      maxPrice != null ||
      availability != null ||
      sortBy != null ||
      resourceType != null;

  int get activeFilterCount {
    int count = 0;
    if (subject != null) count++;
    if (minRating != null) count++;
    if (maxPrice != null) count++;
    if (availability != null && availability!.isNotEmpty) count++;
    if (resourceType != null) count++;
    return count;
  }
}

/// Provider for active connect tab.
final connectTabProvider = StateProvider<ConnectTab>((ref) => ConnectTab.tutors);

/// Provider for connect filters.
final connectFilterProvider =
    StateNotifierProvider<ConnectFilterNotifier, ConnectFilterState>((ref) {
  return ConnectFilterNotifier();
});

/// Notifier for connect filters.
class ConnectFilterNotifier extends StateNotifier<ConnectFilterState> {
  ConnectFilterNotifier() : super(const ConnectFilterState());

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    );
  }

  void setSubject(String? subject) {
    state = state.copyWith(
      subject: subject,
      clearSubject: subject == null,
    );
  }

  void setMinRating(double? rating) {
    state = state.copyWith(
      minRating: rating,
      clearRating: rating == null,
    );
  }

  void setMaxPrice(double? price) {
    state = state.copyWith(
      maxPrice: price,
      clearPrice: price == null,
    );
  }

  void setAvailability(List<String>? availability) {
    state = state.copyWith(
      availability: availability,
      clearAvailability: availability == null || availability.isEmpty,
    );
  }

  void setSortBy(String? sortBy) {
    state = state.copyWith(
      sortBy: sortBy,
      clearSort: sortBy == null,
    );
  }

  void setResourceType(ResourceType? type) {
    state = state.copyWith(
      resourceType: type,
      clearResourceType: type == null,
    );
  }

  void clearFilters() {
    state = const ConnectFilterState();
  }
}

/// Provider for recent searches (populated from user activity).
final recentSearchesProvider = StateProvider<List<String>>((ref) => []);

/// Provider for study groups with filtering.
final studyGroupsProvider =
    FutureProvider.autoDispose<List<StudyGroup>>((ref) async {
  return [];
});

/// Provider for shared resources with filtering.
final sharedResourcesProvider =
    FutureProvider.autoDispose<List<SharedResource>>((ref) async {
  return [];
});

/// Provider for featured tutors on Connect screen.
final connectTutorsProvider =
    FutureProvider.autoDispose<List<Tutor>>((ref) async {
  return [];
});

/// Provider for user's joined study groups.
final userStudyGroupsProvider =
    FutureProvider.autoDispose<List<StudyGroup>>((ref) async {
  return [];
});

/// Provider for saved resources.
final savedResourcesProvider =
    FutureProvider.autoDispose<List<SharedResource>>((ref) async {
  return [];
});

/// Available subjects for filtering.
final connectSubjectsProvider = Provider<List<String>>((ref) => [
      'Mathematics',
      'Physics',
      'Chemistry',
      'Computer Science',
      'Data Structures',
      'Machine Learning',
      'Economics',
      'Statistics',
      'English',
      'Biology',
    ]);

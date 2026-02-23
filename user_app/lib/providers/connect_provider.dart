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

/// Provider for recent searches.
final recentSearchesProvider = StateProvider<List<String>>((ref) => [
      'Calculus',
      'Physics tutor',
      'Data Structures notes',
      'Machine Learning',
    ]);

/// Provider for study groups with filtering.
final studyGroupsProvider =
    FutureProvider.autoDispose<List<StudyGroup>>((ref) async {
  final filters = ref.watch(connectFilterProvider);

  // Simulate API call with mock data
  await Future.delayed(const Duration(milliseconds: 500));

  var groups = _mockStudyGroups;

  // Apply filters
  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    groups = groups
        .where((g) =>
            g.name.toLowerCase().contains(query) ||
            g.subject.toLowerCase().contains(query) ||
            g.tags.any((t) => t.toLowerCase().contains(query)))
        .toList();
  }

  if (filters.subject != null) {
    groups = groups.where((g) => g.subject == filters.subject).toList();
  }

  return groups;
});

/// Provider for shared resources with filtering.
final sharedResourcesProvider =
    FutureProvider.autoDispose<List<SharedResource>>((ref) async {
  final filters = ref.watch(connectFilterProvider);

  // Simulate API call with mock data
  await Future.delayed(const Duration(milliseconds: 500));

  var resources = _mockResources;

  // Apply filters
  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    resources = resources
        .where((r) =>
            r.title.toLowerCase().contains(query) ||
            r.subject.toLowerCase().contains(query) ||
            r.tags.any((t) => t.toLowerCase().contains(query)))
        .toList();
  }

  if (filters.subject != null) {
    resources = resources.where((r) => r.subject == filters.subject).toList();
  }

  if (filters.resourceType != null) {
    resources = resources.where((r) => r.type == filters.resourceType).toList();
  }

  // Sort
  if (filters.sortBy != null) {
    switch (filters.sortBy) {
      case 'rating':
        resources.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'downloads':
        resources.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
        break;
      case 'recent':
        resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  return resources;
});

/// Provider for featured tutors on Connect screen.
final connectTutorsProvider =
    FutureProvider.autoDispose<List<Tutor>>((ref) async {
  final filters = ref.watch(connectFilterProvider);

  // Simulate API call with mock data
  await Future.delayed(const Duration(milliseconds: 500));

  var tutors = _mockTutors;

  // Apply filters
  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    tutors = tutors
        .where((t) =>
            t.name.toLowerCase().contains(query) ||
            t.subjects.any((s) => s.toLowerCase().contains(query)))
        .toList();
  }

  if (filters.subject != null) {
    tutors = tutors.where((t) => t.subjects.contains(filters.subject)).toList();
  }

  if (filters.minRating != null) {
    tutors = tutors.where((t) => t.rating >= filters.minRating!).toList();
  }

  if (filters.maxPrice != null) {
    tutors = tutors.where((t) => t.hourlyRate <= filters.maxPrice!).toList();
  }

  // Sort
  if (filters.sortBy != null) {
    switch (filters.sortBy) {
      case 'rating':
        tutors.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        tutors.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case 'price_high':
        tutors.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
        break;
      case 'reviews':
        tutors.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
  }

  return tutors;
});

/// Provider for user's joined study groups.
final userStudyGroupsProvider =
    FutureProvider.autoDispose<List<StudyGroup>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // Return first 2 groups as "joined" for demo
  return _mockStudyGroups.take(2).toList();
});

/// Provider for saved resources.
final savedResourcesProvider =
    FutureProvider.autoDispose<List<SharedResource>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  // Return first 3 resources as "saved" for demo
  return _mockResources.take(3).toList();
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

// ============================================================
// MOCK DATA
// ============================================================

final _mockStudyGroups = [
  StudyGroup(
    id: 'sg1',
    name: 'Calculus Study Group',
    subject: 'Mathematics',
    description: 'Weekly sessions covering calculus problems and exam prep',
    creatorId: 'u1',
    creatorName: 'Priya Sharma',
    memberCount: 8,
    maxMembers: 12,
    nextSessionTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    tags: ['calculus', 'math', 'exam prep'],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  StudyGroup(
    id: 'sg2',
    name: 'DSA Problem Solving',
    subject: 'Data Structures',
    description: 'Practice coding problems together for placements',
    creatorId: 'u2',
    creatorName: 'Rahul Verma',
    memberCount: 15,
    maxMembers: 20,
    nextSessionTime: DateTime.now().add(const Duration(hours: 5)),
    tags: ['dsa', 'coding', 'placements'],
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    lastActivityAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  StudyGroup(
    id: 'sg3',
    name: 'Machine Learning Basics',
    subject: 'Machine Learning',
    description: 'Learning ML fundamentals with hands-on projects',
    creatorId: 'u3',
    creatorName: 'Ananya Patel',
    memberCount: 6,
    maxMembers: 10,
    nextSessionTime: DateTime.now().add(const Duration(days: 3)),
    tags: ['ml', 'ai', 'python'],
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    lastActivityAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  StudyGroup(
    id: 'sg4',
    name: 'Physics Problem Club',
    subject: 'Physics',
    description: 'Solving JEE level physics problems together',
    creatorId: 'u4',
    creatorName: 'Vikram Singh',
    memberCount: 12,
    maxMembers: 15,
    nextSessionTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
    tags: ['physics', 'jee', 'mechanics'],
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    lastActivityAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  StudyGroup(
    id: 'sg5',
    name: 'Economics Discussion',
    subject: 'Economics',
    description: 'Discussing microeconomics and macroeconomics concepts',
    creatorId: 'u5',
    creatorName: 'Sneha Gupta',
    memberCount: 5,
    maxMembers: 8,
    tags: ['economics', 'micro', 'macro'],
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    lastActivityAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final _mockResources = [
  SharedResource(
    id: 'r1',
    title: 'Calculus Complete Notes',
    description: 'Comprehensive notes covering all calculus topics',
    type: ResourceType.notes,
    subject: 'Mathematics',
    uploaderId: 'u1',
    uploaderName: 'Priya Sharma',
    downloadCount: 234,
    saveCount: 89,
    rating: 4.8,
    ratingCount: 45,
    tags: ['calculus', 'derivatives', 'integrals'],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  SharedResource(
    id: 'r2',
    title: 'Data Structures Video Series',
    description: 'Complete DSA course with examples',
    type: ResourceType.video,
    subject: 'Data Structures',
    uploaderId: 'u2',
    uploaderName: 'Rahul Verma',
    url: 'https://example.com/dsa-videos',
    downloadCount: 567,
    saveCount: 203,
    rating: 4.9,
    ratingCount: 112,
    tags: ['dsa', 'arrays', 'linked lists', 'trees'],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  SharedResource(
    id: 'r3',
    title: 'Machine Learning Cheat Sheet',
    description: 'Quick reference for ML algorithms',
    type: ResourceType.notes,
    subject: 'Machine Learning',
    uploaderId: 'u3',
    uploaderName: 'Ananya Patel',
    downloadCount: 189,
    saveCount: 67,
    rating: 4.5,
    ratingCount: 28,
    tags: ['ml', 'algorithms', 'cheat sheet'],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  SharedResource(
    id: 'r4',
    title: 'Physics Previous Year Papers',
    description: 'JEE Physics papers from 2020-2024',
    type: ResourceType.pastPaper,
    subject: 'Physics',
    uploaderId: 'u4',
    uploaderName: 'Vikram Singh',
    downloadCount: 892,
    saveCount: 445,
    rating: 4.7,
    ratingCount: 89,
    tags: ['physics', 'jee', 'papers'],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 21)),
  ),
  SharedResource(
    id: 'r5',
    title: 'Economic Theory Resources',
    description: 'Collection of useful economics links',
    type: ResourceType.link,
    subject: 'Economics',
    uploaderId: 'u5',
    uploaderName: 'Sneha Gupta',
    url: 'https://example.com/economics',
    downloadCount: 45,
    saveCount: 23,
    rating: 4.2,
    ratingCount: 12,
    tags: ['economics', 'theory'],
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  SharedResource(
    id: 'r6',
    title: 'Chemistry Organic Reactions',
    description: 'Complete organic chemistry reaction mechanisms',
    type: ResourceType.notes,
    subject: 'Chemistry',
    uploaderId: 'u6',
    uploaderName: 'Amit Kumar',
    downloadCount: 345,
    saveCount: 156,
    rating: 4.6,
    ratingCount: 67,
    tags: ['chemistry', 'organic', 'reactions'],
    isVerified: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];

final _mockTutors = [
  Tutor(
    id: 't1',
    userId: 'u1',
    name: 'Dr. Priya Sharma',
    bio: 'PhD in Mathematics, 10+ years teaching experience',
    subjects: ['Mathematics', 'Calculus', 'Linear Algebra'],
    hourlyRate: 800,
    rating: 4.9,
    reviewCount: 156,
    sessionsCompleted: 234,
    isAvailable: true,
    isVerified: true,
    university: 'IIT Delhi',
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
  ),
  Tutor(
    id: 't2',
    userId: 'u2',
    name: 'Rahul Verma',
    bio: 'Software Engineer at Google, DSA expert',
    subjects: ['Data Structures', 'Algorithms', 'Computer Science'],
    hourlyRate: 1200,
    rating: 4.8,
    reviewCount: 89,
    sessionsCompleted: 123,
    isAvailable: true,
    isVerified: true,
    university: 'NIT Trichy',
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
  ),
  Tutor(
    id: 't3',
    userId: 'u3',
    name: 'Ananya Patel',
    bio: 'ML Researcher, specializing in deep learning',
    subjects: ['Machine Learning', 'Python', 'Statistics'],
    hourlyRate: 1000,
    rating: 4.7,
    reviewCount: 67,
    sessionsCompleted: 98,
    isAvailable: true,
    isVerified: true,
    university: 'IISc Bangalore',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
  ),
  Tutor(
    id: 't4',
    userId: 'u4',
    name: 'Vikram Singh',
    bio: 'Physics teacher with JEE coaching experience',
    subjects: ['Physics', 'Mathematics'],
    hourlyRate: 600,
    rating: 4.6,
    reviewCount: 112,
    sessionsCompleted: 189,
    isAvailable: false,
    isVerified: true,
    university: 'Delhi University',
    createdAt: DateTime.now().subtract(const Duration(days: 200)),
  ),
  Tutor(
    id: 't5',
    userId: 'u5',
    name: 'Sneha Gupta',
    bio: 'Economics graduate from LSE',
    subjects: ['Economics', 'Statistics'],
    hourlyRate: 700,
    rating: 4.5,
    reviewCount: 45,
    sessionsCompleted: 67,
    isAvailable: true,
    isVerified: false,
    university: 'LSE London',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  ),
];

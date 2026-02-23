import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expert_model.dart';

/// Provider for expert filters.
final expertFilterProvider =
    StateNotifierProvider<ExpertFilterNotifier, ExpertFilterState>((ref) {
  return ExpertFilterNotifier();
});

/// State for expert filters.
class ExpertFilterState {
  final ExpertSpecialization? specialization;
  final String? searchQuery;
  final double? minRating;
  final double? maxPrice;
  final ExpertAvailability? availability;

  const ExpertFilterState({
    this.specialization,
    this.searchQuery,
    this.minRating,
    this.maxPrice,
    this.availability,
  });

  ExpertFilterState copyWith({
    ExpertSpecialization? specialization,
    String? searchQuery,
    double? minRating,
    double? maxPrice,
    ExpertAvailability? availability,
    bool clearSpecialization = false,
    bool clearSearch = false,
    bool clearRating = false,
    bool clearPrice = false,
    bool clearAvailability = false,
  }) {
    return ExpertFilterState(
      specialization:
          clearSpecialization ? null : (specialization ?? this.specialization),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      availability:
          clearAvailability ? null : (availability ?? this.availability),
    );
  }

  bool get hasFilters =>
      specialization != null ||
      searchQuery != null ||
      minRating != null ||
      maxPrice != null ||
      availability != null;
}

/// Notifier for expert filters.
class ExpertFilterNotifier extends StateNotifier<ExpertFilterState> {
  ExpertFilterNotifier() : super(const ExpertFilterState());

  void setSpecialization(ExpertSpecialization? specialization) {
    state = state.copyWith(
      specialization: specialization,
      clearSpecialization: specialization == null,
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

  void setMaxPrice(double? price) {
    state = state.copyWith(
      maxPrice: price,
      clearPrice: price == null,
    );
  }

  void setAvailability(ExpertAvailability? availability) {
    state = state.copyWith(
      availability: availability,
      clearAvailability: availability == null,
    );
  }

  void clearFilters() {
    state = const ExpertFilterState();
  }
}

/// Provider for experts list.
final expertsProvider = FutureProvider.autoDispose<List<Expert>>((ref) async {
  final filters = ref.watch(expertFilterProvider);

  // Simulate API call with mock data
  await Future.delayed(const Duration(milliseconds: 500));

  var experts = _mockExperts;

  // Apply filters
  if (filters.specialization != null) {
    experts = experts
        .where((e) => e.specializations.contains(filters.specialization))
        .toList();
  }

  if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
    final query = filters.searchQuery!.toLowerCase();
    experts = experts
        .where((e) =>
            e.name.toLowerCase().contains(query) ||
            e.designation.toLowerCase().contains(query) ||
            e.specializations.any((s) => s.label.toLowerCase().contains(query)))
        .toList();
  }

  if (filters.minRating != null) {
    experts = experts.where((e) => e.rating >= filters.minRating!).toList();
  }

  if (filters.maxPrice != null) {
    experts =
        experts.where((e) => e.pricePerSession <= filters.maxPrice!).toList();
  }

  if (filters.availability != null) {
    experts =
        experts.where((e) => e.availability == filters.availability).toList();
  }

  return experts;
});

/// Provider for featured experts.
final featuredExpertsProvider =
    FutureProvider.autoDispose<List<Expert>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockExperts.where((e) => e.rating >= 4.5 && e.verified).take(5).toList();
});

/// Provider for single expert detail.
final expertDetailProvider =
    FutureProvider.autoDispose.family<Expert?, String>((ref, expertId) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockExperts.firstWhere(
    (e) => e.id == expertId,
    orElse: () => _mockExperts.first,
  );
});

/// Provider for expert reviews.
final expertReviewsProvider =
    FutureProvider.autoDispose.family<List<ExpertReview>, String>(
        (ref, expertId) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockReviews.where((r) => r.expertId == expertId).toList();
});

/// Provider for user bookings.
final userBookingsProvider =
    FutureProvider.autoDispose<List<ConsultationBooking>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockBookings;
});

/// Provider for available time slots.
final availableSlotsProvider = FutureProvider.autoDispose
    .family<List<ExpertTimeSlot>, ({String expertId, DateTime date})>(
        (ref, params) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return _generateTimeSlots(params.date);
});

/// Generate mock time slots for a date.
List<ExpertTimeSlot> _generateTimeSlots(DateTime date) {
  final slots = <ExpertTimeSlot>[];
  final times = [
    ('09:00', '9:00 AM'),
    ('10:00', '10:00 AM'),
    ('11:00', '11:00 AM'),
    ('14:00', '2:00 PM'),
    ('15:00', '3:00 PM'),
    ('16:00', '4:00 PM'),
    ('17:00', '5:00 PM'),
    ('18:00', '6:00 PM'),
    ('19:00', '7:00 PM'),
  ];

  for (var i = 0; i < times.length; i++) {
    final (time, display) = times[i];
    slots.add(ExpertTimeSlot(
      id: '${date.toIso8601String().split('T')[0]}-$time',
      time: time,
      displayTime: display,
      available: i % 3 != 0, // Some slots unavailable
    ));
  }

  return slots;
}

// Mock data
final _mockExperts = [
  Expert(
    id: 'exp-1',
    userId: 'user-1',
    name: 'Dr. Priya Sharma',
    avatar: null,
    designation: 'PhD, Research Methodology',
    bio:
        'Expert in qualitative and quantitative research methods with 10+ years of experience helping students design robust research frameworks.',
    specializations: [
      ExpertSpecialization.researchMethodology,
      ExpertSpecialization.academicWriting,
      ExpertSpecialization.statistics,
    ],
    qualifications: ['PhD in Research Methods', 'M.Phil Statistics'],
    pricePerSession: 1500,
    rating: 4.9,
    reviewCount: 156,
    totalSessions: 420,
    availability: ExpertAvailability.available,
    verified: true,
    responseTime: 'Within 2 hours',
    languages: ['English', 'Hindi'],
    experienceYears: 12,
    institution: 'IIT Delhi',
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
  ),
  Expert(
    id: 'exp-2',
    userId: 'user-2',
    name: 'Prof. Rajesh Kumar',
    avatar: null,
    designation: 'Senior Data Analyst',
    bio:
        'Specializing in statistical analysis, machine learning, and data visualization. Published researcher with expertise in SPSS, R, and Python.',
    specializations: [
      ExpertSpecialization.dataAnalysis,
      ExpertSpecialization.statistics,
      ExpertSpecialization.programming,
    ],
    qualifications: ['M.Tech Data Science', 'Certified Data Analyst'],
    pricePerSession: 1200,
    rating: 4.8,
    reviewCount: 89,
    totalSessions: 310,
    availability: ExpertAvailability.available,
    verified: true,
    responseTime: 'Within 4 hours',
    languages: ['English', 'Hindi', 'Telugu'],
    experienceYears: 8,
    institution: 'BITS Pilani',
    createdAt: DateTime.now().subtract(const Duration(days: 200)),
  ),
  Expert(
    id: 'exp-3',
    userId: 'user-3',
    name: 'Dr. Anita Desai',
    avatar: null,
    designation: 'Academic Writing Expert',
    bio:
        'Former university professor with expertise in thesis writing, academic publishing, and literature reviews. Helped 500+ students complete their dissertations.',
    specializations: [
      ExpertSpecialization.academicWriting,
      ExpertSpecialization.technicalWriting,
      ExpertSpecialization.researchMethodology,
    ],
    qualifications: ['PhD English Literature', 'MA Academic Writing'],
    pricePerSession: 1800,
    rating: 4.7,
    reviewCount: 234,
    totalSessions: 580,
    availability: ExpertAvailability.busy,
    verified: true,
    responseTime: 'Within 6 hours',
    languages: ['English'],
    experienceYears: 15,
    institution: 'University of Delhi',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
  ),
  Expert(
    id: 'exp-4',
    userId: 'user-4',
    name: 'Vikram Patel',
    avatar: null,
    designation: 'Software Engineer & Mentor',
    bio:
        'Full-stack developer with experience at top tech companies. Specializes in helping students with programming assignments and career guidance.',
    specializations: [
      ExpertSpecialization.programming,
      ExpertSpecialization.careerCounseling,
      ExpertSpecialization.engineering,
    ],
    qualifications: ['B.Tech Computer Science', 'AWS Certified'],
    pricePerSession: 1000,
    rating: 4.6,
    reviewCount: 67,
    totalSessions: 180,
    availability: ExpertAvailability.available,
    verified: false,
    responseTime: 'Within 12 hours',
    languages: ['English', 'Hindi', 'Gujarati'],
    experienceYears: 6,
    institution: 'Google',
    createdAt: DateTime.now().subtract(const Duration(days: 100)),
  ),
  Expert(
    id: 'exp-5',
    userId: 'user-5',
    name: 'Dr. Meera Nair',
    avatar: null,
    designation: 'Business Strategy Consultant',
    bio:
        'MBA from IIM-A with 20 years of industry experience. Expert in case studies, business plans, and management projects.',
    specializations: [
      ExpertSpecialization.business,
      ExpertSpecialization.careerCounseling,
    ],
    qualifications: ['MBA IIM Ahmedabad', 'CFA Level 2'],
    pricePerSession: 2500,
    rating: 4.9,
    reviewCount: 112,
    totalSessions: 350,
    availability: ExpertAvailability.available,
    verified: true,
    responseTime: 'Within 24 hours',
    languages: ['English', 'Malayalam'],
    experienceYears: 20,
    institution: 'McKinsey & Company',
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
  ),
  Expert(
    id: 'exp-6',
    userId: 'user-6',
    name: 'Prof. Suresh Iyer',
    avatar: null,
    designation: 'Mathematics Expert',
    bio:
        'Professor of Applied Mathematics with expertise in calculus, linear algebra, and mathematical modeling. Patient teacher who simplifies complex concepts.',
    specializations: [
      ExpertSpecialization.mathematics,
      ExpertSpecialization.engineering,
      ExpertSpecialization.statistics,
    ],
    qualifications: ['PhD Mathematics', 'M.Sc Applied Mathematics'],
    pricePerSession: 900,
    rating: 4.5,
    reviewCount: 198,
    totalSessions: 620,
    availability: ExpertAvailability.available,
    verified: true,
    responseTime: 'Within 3 hours',
    languages: ['English', 'Hindi', 'Tamil'],
    experienceYears: 18,
    institution: 'IISc Bangalore',
    createdAt: DateTime.now().subtract(const Duration(days: 600)),
  ),
];

final _mockReviews = [
  ExpertReview(
    id: 'rev-1',
    expertId: 'exp-1',
    userId: 'student-1',
    userName: 'Rahul M.',
    rating: 5.0,
    comment:
        'Dr. Sharma helped me design my entire research framework. Her guidance was invaluable for my thesis.',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ExpertReview(
    id: 'rev-2',
    expertId: 'exp-1',
    userId: 'student-2',
    userName: 'Sneha K.',
    rating: 4.8,
    comment:
        'Very knowledgeable and patient. Explained complex concepts in simple terms.',
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
  ExpertReview(
    id: 'rev-3',
    expertId: 'exp-2',
    userId: 'student-3',
    userName: 'Amit P.',
    rating: 5.0,
    comment:
        'Professor Kumar is amazing with data analysis. He helped me complete my SPSS work in just one session.',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

final _mockBookings = [
  ConsultationBooking(
    id: 'book-1',
    expertId: 'exp-1',
    userId: 'current-user',
    date: DateTime.now().add(const Duration(days: 2)),
    startTime: '14:00',
    endTime: '15:00',
    sessionType: ExpertSessionType.oneHour,
    topic: 'Research methodology discussion',
    totalAmount: 1500,
    status: BookingStatus.upcoming,
    meetLink: 'https://meet.google.com/abc-defg-hij',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ConsultationBooking(
    id: 'book-2',
    expertId: 'exp-2',
    userId: 'current-user',
    date: DateTime.now().subtract(const Duration(days: 5)),
    startTime: '10:00',
    endTime: '11:00',
    sessionType: ExpertSessionType.oneHour,
    topic: 'SPSS data analysis help',
    totalAmount: 1200,
    status: BookingStatus.completed,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
];

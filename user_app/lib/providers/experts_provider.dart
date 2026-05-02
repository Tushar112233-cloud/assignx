import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
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

/// Provider for experts list from the API.
final expertsProvider = FutureProvider.autoDispose<List<Expert>>((ref) async {
  final filters = ref.watch(expertFilterProvider);

  try {
    // Build query parameters for server-side filtering
    final queryParams = <String, String>{};
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      queryParams['search'] = filters.searchQuery!;
    }
    if (filters.specialization != null) {
      queryParams['specialization'] = filters.specialization!.value;
    }
    if (filters.availability != null) {
      queryParams['availability'] = filters.availability!.value;
    }
    if (filters.minRating != null) {
      queryParams['minRating'] = filters.minRating.toString();
    }
    if (filters.maxPrice != null) {
      queryParams['maxPrice'] = filters.maxPrice.toString();
    }

    final response = await ApiClient.get(
      '/experts',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response as Map<String, dynamic>;
    final list = data['experts'] as List<dynamic>? ?? [];

    var experts = list
        .map((json) => Expert.fromJson(json as Map<String, dynamic>))
        .toList();

    // Apply client-side filters as fallback in case the API doesn't support them
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final query = filters.searchQuery!.toLowerCase();
      experts = experts
          .where((e) =>
              e.name.toLowerCase().contains(query) ||
              e.designation.toLowerCase().contains(query) ||
              e.specializations
                  .any((s) => s.label.toLowerCase().contains(query)))
          .toList();
    }

    if (filters.minRating != null) {
      experts = experts.where((e) => e.rating >= filters.minRating!).toList();
    }

    if (filters.maxPrice != null) {
      experts = experts
          .where((e) => e.pricePerSession <= filters.maxPrice!)
          .toList();
    }

    if (filters.availability != null) {
      experts = experts
          .where((e) => e.availability == filters.availability)
          .toList();
    }

    return experts;
  } catch (e) {
    debugPrint('Failed to fetch experts: $e');
    rethrow;
  }
});

/// Provider for featured experts — only shows experts flagged as featured by admin.
final featuredExpertsProvider =
    FutureProvider.autoDispose<List<Expert>>((ref) async {
  try {
    final response = await ApiClient.get(
      '/experts',
      queryParams: {'featured': 'true'},
    );
    final data = response as Map<String, dynamic>;
    final list = data['experts'] as List<dynamic>? ?? [];
    final experts = list
        .map((json) => Expert.fromJson(json as Map<String, dynamic>))
        .toList();

    // Only return experts explicitly marked as featured by admin
    return experts.where((e) => e.featured).toList();
  } catch (e) {
    debugPrint('Failed to fetch featured experts: $e');
    rethrow;
  }
});

/// Provider for single expert detail from the API.
final expertDetailProvider =
    FutureProvider.autoDispose.family<Expert?, String>((ref, expertId) async {
  try {
    final response = await ApiClient.get('/experts/$expertId');
    final data = response as Map<String, dynamic>;
    final expertJson = data['expert'] as Map<String, dynamic>?;
    if (expertJson == null) return null;
    return Expert.fromJson(expertJson);
  } catch (e) {
    debugPrint('Failed to fetch expert detail: $e');
    rethrow;
  }
});

/// Provider for expert reviews from the API.
final expertReviewsProvider =
    FutureProvider.autoDispose.family<List<ExpertReview>, String>(
        (ref, expertId) async {
  try {
    final response = await ApiClient.get('/experts/$expertId/reviews');
    final data = response as Map<String, dynamic>;
    final list = data['reviews'] as List<dynamic>? ?? [];
    return list
        .map((json) => ExpertReview.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('Failed to fetch expert reviews: $e');
    return [];
  }
});

/// Provider for user bookings from the API.
final userBookingsProvider =
    FutureProvider.autoDispose<List<ConsultationBooking>>((ref) async {
  try {
    final response = await ApiClient.get('/experts/bookings/me');
    final data = response as Map<String, dynamic>;
    final list = data['bookings'] as List<dynamic>? ?? [];
    return list
        .map((json) =>
            ConsultationBooking.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('Failed to fetch user bookings: $e');
    rethrow;
  }
});

/// Provider for available time slots.
///
/// Fetches slots from the API which includes booked-slot information.
/// Falls back to client-side generation if the API call fails.
final availableSlotsProvider = FutureProvider.autoDispose
    .family<List<ExpertTimeSlot>, ({String expertId, DateTime date})>(
        (ref, params) async {
  try {
    final dateStr =
        '${params.date.year}-${params.date.month.toString().padLeft(2, '0')}-${params.date.day.toString().padLeft(2, '0')}';
    final response = await ApiClient.get(
      '/experts/${params.expertId}/availability',
      queryParams: {'date': dateStr},
    );
    final data = response as Map<String, dynamic>;
    final slotsJson = data['slots'] as List<dynamic>? ?? [];
    if (slotsJson.isNotEmpty) {
      return slotsJson
          .map((json) =>
              ExpertTimeSlot.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  } catch (e) {
    debugPrint('Failed to fetch availability from API, falling back: $e');
  }
  // Fallback to client-side generation
  return _generateTimeSlots(params.date);
});

/// Generate time slots for a date (fallback when API is unavailable).
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
    // For past dates/times, mark as unavailable
    final now = DateTime.now();
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time.split(':')[0]),
    );
    final isAvailable = slotDateTime.isAfter(now);

    slots.add(ExpertTimeSlot(
      id: '${date.toIso8601String().split('T')[0]}-$time',
      time: time,
      displayTime: display,
      available: isAvailable,
    ));
  }

  return slots;
}

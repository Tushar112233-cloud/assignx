/// Expert model for the Experts/Consultations feature.
///
/// Represents an expert available for consultations.
class Expert {
  /// Unique identifier for the expert.
  final String id;

  /// User ID from the profiles table.
  final String userId;

  /// Display name of the expert.
  final String name;

  /// URL to the expert's avatar image.
  final String? avatar;

  /// Professional designation (e.g., "PhD, Research Methodology").
  final String designation;

  /// Short bio or description.
  final String? bio;

  /// List of specializations.
  final List<ExpertSpecialization> specializations;

  /// List of qualifications or certifications.
  final List<String> qualifications;

  /// Price per session in INR.
  final double pricePerSession;

  /// Average rating (0-5).
  final double rating;

  /// Total number of reviews.
  final int reviewCount;

  /// Total number of sessions completed.
  final int totalSessions;

  /// Availability status.
  final ExpertAvailability availability;

  /// Whether the expert is verified.
  final bool verified;

  /// Response time string.
  final String responseTime;

  /// Languages spoken.
  final List<String> languages;

  /// Experience in years.
  final int experienceYears;

  /// Experience description from API (free-form string).
  final String? experience;

  /// Education description from API (free-form string).
  final String? education;

  /// Institution or organization.
  final String? institution;

  /// Currency for pricing.
  final String currency;

  /// Whether the expert is featured.
  final bool featured;

  /// Availability slots defining which days/times the expert is available.
  final List<AvailabilitySlot> availabilitySlots;

  /// Created timestamp.
  final DateTime createdAt;

  /// Last active timestamp.
  final DateTime? lastActiveAt;

  const Expert({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
    required this.designation,
    this.bio,
    this.specializations = const [],
    this.qualifications = const [],
    required this.pricePerSession,
    this.rating = 0,
    this.reviewCount = 0,
    this.totalSessions = 0,
    this.availability = ExpertAvailability.available,
    this.verified = false,
    this.responseTime = 'Within 24 hours',
    this.languages = const ['English'],
    this.experienceYears = 0,
    this.experience,
    this.education,
    this.institution,
    this.currency = 'INR',
    this.featured = false,
    this.availabilitySlots = const [],
    required this.createdAt,
    this.lastActiveAt,
  });

  /// Get initials from name for avatar fallback.
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get formatted price string.
  String get priceString => '\u20B9${pricePerSession.toStringAsFixed(0)}';

  /// Get formatted rating string.
  String get ratingString => rating.toStringAsFixed(1);

  /// Check if expert has any reviews.
  bool get hasReviews => reviewCount > 0;

  /// Get primary specialization for display.
  String? get primarySpecialization =>
      specializations.isNotEmpty ? specializations.first.label : null;

  /// Returns the set of weekday numbers the expert is available.
  /// If no availability slots are defined, all weekdays (Mon-Sat) are available.
  Set<int> get availableWeekdays {
    if (availabilitySlots.isEmpty) {
      return {1, 2, 3, 4, 5, 6}; // Mon-Sat
    }
    return availabilitySlots.map((s) => s.weekday).where((w) => w > 0).toSet();
  }

  /// Whether the expert is available on the given date.
  bool isAvailableOnDate(DateTime date) {
    return availableWeekdays.contains(date.weekday);
  }

  /// Create from JSON.
  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      name: json['name'] as String? ?? 'Anonymous',
      avatar: json['avatar'] as String?,
      designation: json['designation'] as String? ?? 'Expert',
      bio: json['bio'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((s) => ExpertSpecialization.fromString(s as String))
              .toList() ??
          [],
      qualifications:
          (json['qualifications'] as List<dynamic>?)?.cast<String>() ?? [],
      pricePerSession: ((json['price_per_session'] ?? json['pricePerSession']) as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] ?? json['reviewCount']) as int? ?? 0,
      totalSessions: (json['total_sessions'] ?? json['totalSessions']) as int? ?? 0,
      availability: ExpertAvailability.fromString(
          json['availability'] as String? ?? 'available'),
      verified: json['verified'] as bool? ?? false,
      responseTime: (json['response_time'] ?? json['responseTime']) as String? ?? 'Within 24 hours',
      languages:
          (json['languages'] as List<dynamic>?)?.cast<String>() ?? ['English'],
      experienceYears: _parseExperienceYears(json),
      experience: (json['experience'] as String?),
      education: (json['education'] as String?),
      institution: json['institution'] as String?,
      currency: json['currency'] as String? ?? 'INR',
      featured: json['featured'] as bool? ?? false,
      availabilitySlots: (json['availability_slots'] as List<dynamic>? ??
              json['availabilitySlots'] as List<dynamic>? ??
              [])
          .map((s) => AvailabilitySlot.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      lastActiveAt: (json['last_active_at'] ?? json['lastActiveAt']) != null
          ? DateTime.tryParse((json['last_active_at'] ?? json['lastActiveAt']).toString())
          : null,
    );
  }

  /// Parse experience years from various possible formats.
  static int _parseExperienceYears(Map<String, dynamic> json) {
    // Try explicit experienceYears / experience_years first
    final explicit = json['experience_years'] ?? json['experienceYears'];
    if (explicit is int) return explicit;
    if (explicit is num) return explicit.toInt();
    // Try parsing numeric value from experience string (e.g. "10 years")
    final exp = json['experience'];
    if (exp is int) return exp;
    if (exp is num) return exp.toInt();
    if (exp is String) {
      final match = RegExp(r'(\d+)').firstMatch(exp);
      if (match != null) return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'avatar': avatar,
      'designation': designation,
      'bio': bio,
      'specializations': specializations.map((s) => s.value).toList(),
      'qualifications': qualifications,
      'price_per_session': pricePerSession,
      'rating': rating,
      'review_count': reviewCount,
      'total_sessions': totalSessions,
      'availability': availability.value,
      'verified': verified,
      'response_time': responseTime,
      'languages': languages,
      'experience_years': experienceYears,
      'experience': experience,
      'education': education,
      'institution': institution,
      'currency': currency,
      'featured': featured,
      'availability_slots': availabilitySlots.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields.
  Expert copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatar,
    String? designation,
    String? bio,
    List<ExpertSpecialization>? specializations,
    List<String>? qualifications,
    double? pricePerSession,
    double? rating,
    int? reviewCount,
    int? totalSessions,
    ExpertAvailability? availability,
    bool? verified,
    String? responseTime,
    List<String>? languages,
    int? experienceYears,
    String? experience,
    String? education,
    String? institution,
    String? currency,
    bool? featured,
    List<AvailabilitySlot>? availabilitySlots,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return Expert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      designation: designation ?? this.designation,
      bio: bio ?? this.bio,
      specializations: specializations ?? this.specializations,
      qualifications: qualifications ?? this.qualifications,
      pricePerSession: pricePerSession ?? this.pricePerSession,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      totalSessions: totalSessions ?? this.totalSessions,
      availability: availability ?? this.availability,
      verified: verified ?? this.verified,
      responseTime: responseTime ?? this.responseTime,
      languages: languages ?? this.languages,
      experienceYears: experienceYears ?? this.experienceYears,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      institution: institution ?? this.institution,
      currency: currency ?? this.currency,
      featured: featured ?? this.featured,
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

/// Expert specialization categories.
enum ExpertSpecialization {
  academicWriting('academic_writing', 'Academic Writing'),
  researchMethodology('research_methodology', 'Research Methodology'),
  dataAnalysis('data_analysis', 'Data Analysis'),
  programming('programming', 'Programming'),
  mathematics('mathematics', 'Mathematics'),
  science('science', 'Science'),
  business('business', 'Business'),
  engineering('engineering', 'Engineering'),
  law('law', 'Law'),
  medicine('medicine', 'Medicine'),
  arts('arts', 'Arts'),
  careerCounseling('career_counseling', 'Career Counseling'),
  technicalWriting('technical_writing', 'Technical Writing'),
  statistics('statistics', 'Statistics'),
  other('other', 'Other');

  final String value;
  final String label;

  const ExpertSpecialization(this.value, this.label);

  static ExpertSpecialization fromString(String value) {
    return ExpertSpecialization.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ExpertSpecialization.other,
    );
  }
}

/// Availability slot defining a day and time range.
class AvailabilitySlot {
  final String day;
  final String startTime;
  final String endTime;

  const AvailabilitySlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      day: (json['day'] as String? ?? '').toLowerCase(),
      startTime: json['startTime'] as String? ?? json['start_time'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };

  /// Returns the weekday number (1=Monday, 7=Sunday) for this slot.
  int get weekday {
    switch (day.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 0;
    }
  }
}

/// Expert availability status.
enum ExpertAvailability {
  available('available', 'Available'),
  busy('busy', 'Busy'),
  offline('offline', 'Offline');

  final String value;
  final String label;

  const ExpertAvailability(this.value, this.label);

  static ExpertAvailability fromString(String value) {
    return ExpertAvailability.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ExpertAvailability.offline,
    );
  }
}

/// Time slot for booking.
class ExpertTimeSlot {
  final String id;
  final String time;
  final String displayTime;
  final bool available;

  const ExpertTimeSlot({
    required this.id,
    required this.time,
    required this.displayTime,
    this.available = true,
  });

  factory ExpertTimeSlot.fromJson(Map<String, dynamic> json) {
    return ExpertTimeSlot(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      time: (json['time'] as String?) ?? '',
      displayTime: (json['display_time'] ?? json['displayTime'] ?? '').toString(),
      available: json['available'] as bool? ?? true,
    );
  }
}

/// Session type for booking.
enum ExpertSessionType {
  thirtyMinutes(30, '30 minutes', 0.5),
  oneHour(60, '60 minutes', 1.0),
  ninetyMinutes(90, '90 minutes', 1.5);

  final int minutes;
  final String displayName;
  final double priceMultiplier;

  const ExpertSessionType(this.minutes, this.displayName, this.priceMultiplier);
}

/// Consultation booking model.
class ConsultationBooking {
  final String id;
  final String expertId;
  final String userId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final ExpertSessionType sessionType;
  final String? topic;
  final String? notes;
  final double totalAmount;
  final BookingStatus status;
  final String? meetLink;
  final DateTime createdAt;

  const ConsultationBooking({
    required this.id,
    required this.expertId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    this.topic,
    this.notes,
    required this.totalAmount,
    this.status = BookingStatus.upcoming,
    this.meetLink,
    required this.createdAt,
  });

  factory ConsultationBooking.fromJson(Map<String, dynamic> json) {
    return ConsultationBooking(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      expertId: (json['expert_id'] ?? json['expertId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      startTime: (json['start_time'] ?? json['startTime'] ?? '').toString(),
      endTime: (json['end_time'] ?? json['endTime'] ?? '').toString(),
      sessionType: ExpertSessionType.values.firstWhere(
        (t) => t.minutes == (json['duration_minutes'] ?? json['durationMinutes']),
        orElse: () => ExpertSessionType.oneHour,
      ),
      topic: json['topic'] as String?,
      notes: json['notes'] as String?,
      totalAmount: ((json['total_amount'] ?? json['totalAmount'] ?? 0) as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String? ?? 'upcoming'),
      meetLink: (json['meet_link'] ?? json['meetLink']) as String?,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expert_id': expertId,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': sessionType.minutes,
      'topic': topic,
      'notes': notes,
      'total_amount': totalAmount,
      'status': status.value,
      'meet_link': meetLink,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Booking status.
enum BookingStatus {
  upcoming('upcoming', 'Upcoming'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  noShow('no_show', 'No Show');

  final String value;
  final String label;

  const BookingStatus(this.value, this.label);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BookingStatus.upcoming,
    );
  }
}

/// Expert review model.
class ExpertReview {
  final String id;
  final String expertId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ExpertReview({
    required this.id,
    required this.expertId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ExpertReview.fromJson(Map<String, dynamic> json) {
    return ExpertReview(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      expertId: (json['expert_id'] ?? json['expertId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      userName: (json['user_name'] ?? json['userName']) as String? ?? 'Anonymous',
      userAvatar: (json['user_avatar'] ?? json['userAvatar']) as String?,
      rating: ((json['rating'] ?? 0) as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

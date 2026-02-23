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

  /// Institution or organization.
  final String? institution;

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
    this.institution,
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

  /// Create from JSON.
  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] as String,
      userId: json['user_id'] as String,
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
      pricePerSession: (json['price_per_session'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      availability: ExpertAvailability.fromString(
          json['availability'] as String? ?? 'available'),
      verified: json['verified'] as bool? ?? false,
      responseTime: json['response_time'] as String? ?? 'Within 24 hours',
      languages:
          (json['languages'] as List<dynamic>?)?.cast<String>() ?? ['English'],
      experienceYears: json['experience_years'] as int? ?? 0,
      institution: json['institution'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
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
      'institution': institution,
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
    String? institution,
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
      institution: institution ?? this.institution,
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
      id: json['id'] as String,
      time: json['time'] as String,
      displayTime: json['display_time'] as String,
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
      id: json['id'] as String,
      expertId: json['expert_id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      sessionType: ExpertSessionType.values.firstWhere(
        (t) => t.minutes == json['duration_minutes'],
        orElse: () => ExpertSessionType.oneHour,
      ),
      topic: json['topic'] as String?,
      notes: json['notes'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: BookingStatus.fromString(json['status'] as String? ?? 'upcoming'),
      meetLink: json['meet_link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      id: json['id'] as String,
      expertId: json['expert_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

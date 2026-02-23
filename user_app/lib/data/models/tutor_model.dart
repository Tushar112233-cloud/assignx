/// Tutor model for the Connect/Marketplace section.
///
/// Represents a tutor/expert available for booking sessions.
class Tutor {
  /// Unique identifier for the tutor.
  final String id;

  /// User ID from the profiles table.
  final String userId;

  /// Display name of the tutor.
  final String name;

  /// URL to the tutor's avatar image.
  final String? avatar;

  /// Short bio or description.
  final String? bio;

  /// List of subjects/expertise areas.
  final List<String> subjects;

  /// List of qualifications or certifications.
  final List<String> qualifications;

  /// Hourly rate in INR.
  final double hourlyRate;

  /// Average rating (0-5).
  final double rating;

  /// Total number of reviews.
  final int reviewCount;

  /// Total number of sessions completed.
  final int sessionsCompleted;

  /// Whether the tutor is currently available.
  final bool isAvailable;

  /// Whether the tutor is verified.
  final bool isVerified;

  /// University or institution name.
  final String? university;

  /// Year of study or graduation year.
  final String? yearOfStudy;

  /// Response time in minutes (average).
  final int? responseTimeMinutes;

  /// Created timestamp.
  final DateTime createdAt;

  /// Last active timestamp.
  final DateTime? lastActiveAt;

  const Tutor({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
    this.bio,
    this.subjects = const [],
    this.qualifications = const [],
    required this.hourlyRate,
    this.rating = 0,
    this.reviewCount = 0,
    this.sessionsCompleted = 0,
    this.isAvailable = true,
    this.isVerified = false,
    this.university,
    this.yearOfStudy,
    this.responseTimeMinutes,
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

  /// Get formatted hourly rate string.
  String get hourlyRateString => '\u20B9${hourlyRate.toStringAsFixed(0)}/hr';

  /// Get formatted rating string.
  String get ratingString => rating.toStringAsFixed(1);

  /// Check if tutor has any reviews.
  bool get hasReviews => reviewCount > 0;

  /// Get formatted response time string.
  String? get responseTimeString {
    if (responseTimeMinutes == null) return null;
    if (responseTimeMinutes! < 60) {
      return 'Responds in ${responseTimeMinutes}m';
    }
    final hours = responseTimeMinutes! ~/ 60;
    return 'Responds in ${hours}h';
  }

  /// Get primary subject for display.
  String? get primarySubject => subjects.isNotEmpty ? subjects.first : null;

  /// Create from JSON.
  factory Tutor.fromJson(Map<String, dynamic> json) {
    return Tutor(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? 'Anonymous',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)?.cast<String>() ?? [],
      qualifications:
          (json['qualifications'] as List<dynamic>?)?.cast<String>() ?? [],
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      sessionsCompleted: json['sessions_completed'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      university: json['university'] as String?,
      yearOfStudy: json['year_of_study'] as String?,
      responseTimeMinutes: json['response_time_minutes'] as int?,
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
      'bio': bio,
      'subjects': subjects,
      'qualifications': qualifications,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'review_count': reviewCount,
      'sessions_completed': sessionsCompleted,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'university': university,
      'year_of_study': yearOfStudy,
      'response_time_minutes': responseTimeMinutes,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields.
  Tutor copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatar,
    String? bio,
    List<String>? subjects,
    List<String>? qualifications,
    double? hourlyRate,
    double? rating,
    int? reviewCount,
    int? sessionsCompleted,
    bool? isAvailable,
    bool? isVerified,
    String? university,
    String? yearOfStudy,
    int? responseTimeMinutes,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return Tutor(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      subjects: subjects ?? this.subjects,
      qualifications: qualifications ?? this.qualifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      isAvailable: isAvailable ?? this.isAvailable,
      isVerified: isVerified ?? this.isVerified,
      university: university ?? this.university,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      responseTimeMinutes: responseTimeMinutes ?? this.responseTimeMinutes,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

/// Session type for booking.
enum SessionType {
  oneOnOne('1-on-1', 'Private session with the tutor'),
  group('Group', 'Join a group session (lower rate)');

  final String displayName;
  final String description;

  const SessionType(this.displayName, this.description);
}

/// Session duration options.
enum SessionDuration {
  thirtyMinutes(30, '30 minutes', 0.5),
  oneHour(60, '1 hour', 1.0),
  ninetyMinutes(90, '1.5 hours', 1.5),
  twoHours(120, '2 hours', 2.0);

  final int minutes;
  final String displayName;
  final double multiplier;

  const SessionDuration(this.minutes, this.displayName, this.multiplier);
}

/// Time slot for booking.
class TimeSlot {
  final String id;
  final String time;
  final bool isAvailable;
  final String period; // morning, afternoon, evening

  const TimeSlot({
    required this.id,
    required this.time,
    this.isAvailable = true,
    required this.period,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] as String,
      time: json['time'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      period: json['period'] as String? ?? 'morning',
    );
  }
}

/// Booked session model.
class BookedSession {
  final String id;
  final String tutorId;
  final String studentId;
  final DateTime date;
  final String timeSlot;
  final SessionType sessionType;
  final SessionDuration duration;
  final String? topic;
  final String? notes;
  final double totalPrice;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  const BookedSession({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.date,
    required this.timeSlot,
    required this.sessionType,
    required this.duration,
    this.topic,
    this.notes,
    required this.totalPrice,
    this.status = 'pending',
    required this.createdAt,
  });

  factory BookedSession.fromJson(Map<String, dynamic> json) {
    return BookedSession(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String,
      studentId: json['student_id'] as String,
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['time_slot'] as String,
      sessionType: SessionType.values.firstWhere(
        (t) => t.name == json['session_type'],
        orElse: () => SessionType.oneOnOne,
      ),
      duration: SessionDuration.values.firstWhere(
        (d) => d.minutes == json['duration_minutes'],
        orElse: () => SessionDuration.oneHour,
      ),
      topic: json['topic'] as String?,
      notes: json['notes'] as String?,
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'student_id': studentId,
      'date': date.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'session_type': sessionType.name,
      'duration_minutes': duration.minutes,
      'topic': topic,
      'notes': notes,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Review model for tutors.
class TutorReview {
  final String id;
  final String tutorId;
  final String studentId;
  final String studentName;
  final String? studentAvatar;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const TutorReview({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory TutorReview.fromJson(Map<String, dynamic> json) {
    return TutorReview(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String,
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String? ?? 'Anonymous',
      studentAvatar: json['student_avatar'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

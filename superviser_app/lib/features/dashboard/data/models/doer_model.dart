/// Doer model and related classes for the supervisor dashboard.
///
/// This file contains:
/// - [DoerModel]: The main data model for writers/doers
/// - [DoerReview]: Model for doer reviews/ratings
///
/// The models map to the `doers` table in Supabase with joins to
/// `profiles` and `doer_subjects` tables.
library;

/// A data model representing a writer/doer who can be assigned to projects.
///
/// This model encapsulates all information about a doer including their
/// profile, expertise areas, ratings, and availability status. It maps to
/// the `doers` table in Supabase with joined data from `profiles` and
/// `doer_subjects` tables.
///
/// ## Usage
///
/// ```dart
/// final doer = DoerModel.fromJson(supabaseResponse);
/// print(doer.initials); // "JD"
/// print(doer.qualificationDisplay); // "Postgraduate"
/// ```
///
/// ## Database Mapping
///
/// The model expects joined data in the following format:
/// - `profile`: from `profiles` table via `profile_id`
/// - `subjects`: from `doer_subjects` with nested `subject` from `subjects`
///
/// See also:
/// - [DoerReview] for doer reviews
/// - [RequestModel] for project assignments
class DoerModel {
  /// Creates a new [DoerModel] instance.
  ///
  /// Required fields are [id], [profileId], [name], [email], and [expertise].
  /// Other fields have sensible defaults.
  const DoerModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.email,
    required this.expertise,
    this.avatarUrl,
    this.rating = 0.0,
    this.completedProjects = 0,
    this.isAvailable = true,
    this.isActivated = false,
    this.qualification,
    this.experienceLevel,
    this.yearsOfExperience = 0,
    this.bio,
    this.successRate = 100.0,
    this.onTimeDeliveryRate = 100.0,
    this.totalReviews = 0,
    this.activeProjects = 0,
    this.createdAt,
  });

  /// Unique identifier for the doer.
  ///
  /// This is the primary key from the `doers` table (UUID format).
  final String id;

  /// The profile ID linking to the user's profile.
  ///
  /// References `profiles.id` via the `doers.profile_id` foreign key.
  final String profileId;

  /// The doer's full name.
  ///
  /// Retrieved from `profiles.full_name` via the profile relationship.
  final String name;

  /// The doer's email address.
  ///
  /// Retrieved from `profiles.email` via the profile relationship.
  final String email;

  /// List of expertise areas/subjects the doer specializes in.
  ///
  /// Retrieved from `doer_subjects` table joined with `subjects`.
  /// Each entry is a subject name string.
  final List<String> expertise;

  /// URL to the doer's profile avatar image.
  ///
  /// Retrieved from `profiles.avatar_url`. May be null if no avatar is set.
  final String? avatarUrl;

  /// The doer's average rating (0.0 to 5.0).
  ///
  /// Stored in `doers.average_rating`. Calculated from completed project reviews.
  final double rating;

  /// Total number of projects completed by this doer.
  ///
  /// Stored in `doers.total_projects_completed`.
  final int completedProjects;

  /// Whether the doer is currently available for new assignments.
  ///
  /// Stored in `doers.is_available`. Doers can toggle this themselves.
  final bool isAvailable;

  /// Whether the doer's account has been activated/verified.
  ///
  /// Stored in `doers.is_activated`. Only activated doers can be assigned work.
  final bool isActivated;

  /// The doer's highest qualification level.
  ///
  /// Stored in `doers.qualification`. Values: "high_school", "undergraduate",
  /// "postgraduate", "phd".
  final String? qualification;

  /// The doer's experience level.
  ///
  /// Stored in `doers.experience_level`. Values: "beginner", "intermediate", "pro".
  final String? experienceLevel;

  /// Number of years of experience in their field.
  ///
  /// Stored in `doers.years_of_experience`.
  final int yearsOfExperience;

  /// Short biography or description about the doer.
  ///
  /// Stored in `doers.bio`. Used for doer profiles.
  final String? bio;

  /// Percentage of projects successfully completed (0-100).
  ///
  /// Stored in `doers.success_rate`. Calculated based on completed vs failed projects.
  final double successRate;

  /// Percentage of projects delivered on time (0-100).
  ///
  /// Stored in `doers.on_time_delivery_rate`. Important metric for reliability.
  final double onTimeDeliveryRate;

  /// Total number of reviews received by this doer.
  ///
  /// Stored in `doers.total_reviews`.
  final int totalReviews;

  /// When the doer account was created.
  ///
  /// Stored in `doers.created_at`.
  final DateTime? createdAt;

  /// Generates initials from the doer's name for avatar display.
  ///
  /// Returns the first letter of the first and last name in uppercase.
  /// If only one name is available, returns up to 2 characters.
  /// Falls back to "D" if the name is empty.
  ///
  /// Example:
  /// ```dart
  /// final doer = DoerModel(name: 'John Doe', ...);
  /// print(doer.initials); // "JD"
  /// ```
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'D';
  }

  /// Returns a human-readable display string for the qualification level.
  ///
  /// Converts database values to user-friendly labels:
  /// - "high_school" -> "High School"
  /// - "undergraduate" -> "Undergraduate"
  /// - "postgraduate" -> "Postgraduate"
  /// - "phd" -> "PhD"
  ///
  /// Returns the raw value or "Unknown" if not recognized.
  String get qualificationDisplay {
    switch (qualification) {
      case 'high_school':
        return 'High School';
      case 'undergraduate':
        return 'Undergraduate';
      case 'postgraduate':
        return 'Postgraduate';
      case 'phd':
        return 'PhD';
      default:
        return qualification ?? 'Unknown';
    }
  }

  /// Returns a human-readable display string for the experience level.
  ///
  /// Converts database values to user-friendly labels:
  /// - "beginner" -> "Beginner"
  /// - "intermediate" -> "Intermediate"
  /// - "pro" -> "Expert"
  ///
  /// Returns the raw value or "Unknown" if not recognized.
  String get experienceLevelDisplay {
    switch (experienceLevel) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'pro':
        return 'Expert';
      default:
        return experienceLevel ?? 'Unknown';
    }
  }

  /// Number of currently active projects assigned to this doer.
  final int activeProjects;

  /// Creates a copy of this [DoerModel] with the specified fields replaced.
  ///
  /// All parameters are optional. If not provided, the current value is retained.
  ///
  /// Returns a new [DoerModel] instance with the updated values.
  DoerModel copyWith({
    String? id,
    String? profileId,
    String? name,
    String? email,
    List<String>? expertise,
    String? avatarUrl,
    double? rating,
    int? completedProjects,
    bool? isAvailable,
    bool? isActivated,
    String? qualification,
    String? experienceLevel,
    int? yearsOfExperience,
    String? bio,
    double? successRate,
    double? onTimeDeliveryRate,
    int? totalReviews,
    int? activeProjects,
    DateTime? createdAt,
  }) {
    return DoerModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      email: email ?? this.email,
      expertise: expertise ?? this.expertise,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      completedProjects: completedProjects ?? this.completedProjects,
      isAvailable: isAvailable ?? this.isAvailable,
      isActivated: isActivated ?? this.isActivated,
      qualification: qualification ?? this.qualification,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      successRate: successRate ?? this.successRate,
      onTimeDeliveryRate: onTimeDeliveryRate ?? this.onTimeDeliveryRate,
      totalReviews: totalReviews ?? this.totalReviews,
      activeProjects: activeProjects ?? this.activeProjects,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a [DoerModel] from Supabase JSON with joined profile and subjects data.
  ///
  /// Expects the following query structure:
  /// ```sql
  /// SELECT *,
  ///   profile:profiles!profile_id(id, full_name, email, avatar_url),
  ///   subjects:doer_subjects(subject:subjects(name))
  /// FROM doers
  /// ```
  ///
  /// The method extracts:
  /// - Profile data (name, email, avatarUrl) from the nested `profile` object
  /// - Subject names from the nested `subjects` array with `subject.name`
  ///
  /// Throws [FormatException] if required fields are missing or malformed.
  factory DoerModel.fromJson(Map<String, dynamic> json) {
    // Helper to extract ID from a field that may be a string or populated object.
    String _extractProfileId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value.toString();
    }

    // Extract profile data from join or populated profileId object
    String name = 'Unknown';
    String email = '';
    String? avatarUrl;
    String profileId = '';

    if (json['profile'] is Map) {
      final profile = json['profile'] as Map<String, dynamic>;
      name = (profile['fullName'] ?? profile['full_name']) as String? ?? 'Unknown';
      email = profile['email'] as String? ?? '';
      avatarUrl = (profile['avatarUrl'] ?? profile['avatar_url']) as String?;
    }

    // Handle populated profileId object (MongoDB)
    final profileIdRaw = json['profileId'] ?? json['profile_id'];
    if (profileIdRaw is Map<String, dynamic>) {
      profileId = (profileIdRaw['_id'] ?? profileIdRaw['id'] ?? '').toString();
      if (name == 'Unknown') {
        name = (profileIdRaw['fullName'] ?? profileIdRaw['full_name']) as String? ?? 'Unknown';
      }
      if (email.isEmpty) {
        email = profileIdRaw['email'] as String? ?? '';
      }
      avatarUrl ??= (profileIdRaw['avatarUrl'] ?? profileIdRaw['avatar_url']) as String?;
    } else {
      profileId = _extractProfileId(profileIdRaw);
    }

    // Fallback: try top-level name/email fields (flat API response)
    if (name == 'Unknown') {
      name = (json['fullName'] ?? json['full_name'] ?? json['name']) as String? ?? 'Unknown';
    }
    if (email.isEmpty) {
      email = json['email'] as String? ?? '';
    }
    avatarUrl ??= (json['avatarUrl'] ?? json['avatar_url']) as String?;

    // Extract subject names from doer_subjects join or flat expertise array
    List<String> expertise = [];
    if (json['subjects'] is List) {
      for (final subjectEntry in json['subjects'] as List) {
        if (subjectEntry is Map && subjectEntry['subject'] is Map) {
          final subjectName = subjectEntry['subject']['name'] as String?;
          if (subjectName != null) {
            expertise.add(subjectName);
          }
        } else if (subjectEntry is String) {
          expertise.add(subjectEntry);
        }
      }
    }
    if (expertise.isEmpty && json['expertise'] is List) {
      expertise = (json['expertise'] as List).map((e) => e.toString()).toList();
    }

    return DoerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      profileId: profileId,
      name: name,
      email: email,
      expertise: expertise,
      avatarUrl: avatarUrl,
      rating: ((json['averageRating'] ?? json['average_rating'] ?? json['rating']) as num?)?.toDouble() ?? 0.0,
      completedProjects: (json['totalProjectsCompleted'] ?? json['total_projects_completed'] ?? json['completedProjects']) as int? ?? 0,
      isAvailable: (json['isAvailable'] ?? json['is_available']) as bool? ?? true,
      isActivated: (json['isActivated'] ?? json['is_activated']) as bool? ?? false,
      qualification: json['qualification'] as String?,
      experienceLevel: (json['experienceLevel'] ?? json['experience_level']) as String?,
      yearsOfExperience: (json['yearsOfExperience'] ?? json['years_of_experience']) as int? ?? 0,
      bio: json['bio'] as String?,
      successRate: ((json['successRate'] ?? json['success_rate']) as num?)?.toDouble() ?? 100.0,
      onTimeDeliveryRate: ((json['onTimeDeliveryRate'] ?? json['on_time_delivery_rate']) as num?)?.toDouble() ?? 100.0,
      totalReviews: (json['totalReviews'] ?? json['total_reviews']) as int? ?? 0,
      activeProjects: (json['activeProjects'] ?? json['active_projects'] ?? json['totalActiveProjects'] ?? json['total_active_projects']) as int? ?? 0,
      createdAt: _tryParseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  /// Safely parse a DateTime from dynamic value.
  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// Converts this [DoerModel] to a JSON map for Supabase operations.
  ///
  /// Returns a [Map] suitable for INSERT or UPDATE operations on the
  /// `doers` table. Note that profile fields (name, email, avatarUrl) and
  /// expertise are not included as they are read-only computed fields
  /// from related tables.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'qualification': qualification,
      'experience_level': experienceLevel,
      'years_of_experience': yearsOfExperience,
      'bio': bio,
      'is_available': isAvailable,
      'is_activated': isActivated,
      'average_rating': rating,
      'total_projects_completed': completedProjects,
      'success_rate': successRate,
      'on_time_delivery_rate': onTimeDeliveryRate,
      'total_reviews': totalReviews,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// A data model representing a review/rating for a doer.
///
/// This model captures feedback from clients or supervisors about
/// a doer's performance on a specific project.
///
/// ## Usage
///
/// ```dart
/// final review = DoerReview.fromJson(supabaseResponse);
/// print('${review.rating}/5 - ${review.comment}');
/// ```
///
/// See also:
/// - [DoerModel.rating] for the average rating calculated from reviews
/// - [DoerModel.totalReviews] for the review count
class DoerReview {
  /// Creates a new [DoerReview] instance.
  ///
  /// Required fields are [id], [doerId], [rating], [comment], and [createdAt].
  const DoerReview({
    required this.id,
    required this.doerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.projectTitle,
    this.reviewerName,
  });

  /// Unique identifier for this review.
  ///
  /// Primary key from the reviews table (UUID format).
  final String id;

  /// The ID of the doer being reviewed.
  ///
  /// References `doers.id`.
  final String doerId;

  /// The rating given (typically 1-5).
  ///
  /// Integer rating where higher is better.
  final int rating;

  /// The review comment/feedback text.
  ///
  /// Written feedback about the doer's performance.
  final String comment;

  /// When this review was created.
  ///
  /// Timestamp of the review submission.
  final DateTime createdAt;

  /// Title of the project this review is for.
  ///
  /// Retrieved from the related project. May be null.
  final String? projectTitle;

  /// Name of the person who wrote the review.
  ///
  /// Retrieved from the reviewer's profile. May be null.
  final String? reviewerName;

  /// Creates a [DoerReview] from Supabase JSON response.
  ///
  /// Expects standard review fields with optional joined data for
  /// `project_title` and `reviewer_name`.
  ///
  /// Throws [FormatException] if required fields are missing or malformed.
  factory DoerReview.fromJson(Map<String, dynamic> json) {
    // Handle populated project and reviewer objects
    String? projectTitle;
    if (json['project'] is Map<String, dynamic>) {
      projectTitle = json['project']['title'] as String?;
    }
    projectTitle ??= (json['projectTitle'] ?? json['project_title']) as String?;

    String? reviewerName;
    if (json['reviewer'] is Map<String, dynamic>) {
      reviewerName = (json['reviewer']['fullName'] ?? json['reviewer']['full_name']) as String?;
    }
    reviewerName ??= (json['reviewerName'] ?? json['reviewer_name']) as String?;

    // Handle doerId which may be populated
    String doerId = '';
    final doerIdRaw = json['doerId'] ?? json['doer_id'];
    if (doerIdRaw is String) {
      doerId = doerIdRaw;
    } else if (doerIdRaw is Map<String, dynamic>) {
      doerId = (doerIdRaw['_id'] ?? doerIdRaw['id'] ?? '').toString();
    }

    return DoerReview(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      doerId: doerId,
      rating: ((json['overallRating'] ?? json['overall_rating'] ?? json['rating']) as num?)?.toInt() ?? 0,
      comment: (json['reviewText'] ?? json['review_text'] ?? json['comment']) as String? ?? '',
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['created_at'] ?? '').toString()) ?? DateTime.now(),
      projectTitle: projectTitle,
      reviewerName: reviewerName,
    );
  }
}

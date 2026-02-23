/// Extended profile model for supervisors.
class SupervisorProfile {
  const SupervisorProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.specializations = const [],
    this.languages = const [],
    this.timezone,
    this.isAvailable = true,
    this.maxConcurrentProjects = 5,
    this.preferredSubjects = const [],
    this.qualifications = const [],
    this.experience,
    this.joinedAt,
    this.lastActiveAt,
    this.isVerified = false,
    this.rating,
    this.totalProjects = 0,
    this.completedProjects = 0,
  });

  /// Unique profile ID.
  final String id;

  /// User ID from auth.
  final String userId;

  /// Full name.
  final String fullName;

  /// Email address.
  final String email;

  /// Phone number.
  final String? phone;

  /// Profile picture URL.
  final String? avatarUrl;

  /// Bio/description.
  final String? bio;

  /// Areas of specialization.
  final List<String> specializations;

  /// Languages spoken.
  final List<String> languages;

  /// Preferred timezone.
  final String? timezone;

  /// Whether currently accepting new projects.
  final bool isAvailable;

  /// Maximum concurrent projects.
  final int maxConcurrentProjects;

  /// Preferred subject areas.
  final List<String> preferredSubjects;

  /// Educational qualifications.
  final List<Qualification> qualifications;

  /// Years of experience.
  final int? experience;

  /// When joined the platform.
  final DateTime? joinedAt;

  /// Last activity timestamp.
  final DateTime? lastActiveAt;

  /// Whether profile is verified.
  final bool isVerified;

  /// Average rating.
  final double? rating;

  /// Total projects assigned.
  final int totalProjects;

  /// Projects completed.
  final int completedProjects;

  /// First name only.
  String get firstName => fullName.split(' ').first;

  /// Initials for avatar.
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  /// Completion rate.
  double get completionRate =>
      totalProjects > 0 ? (completedProjects / totalProjects) * 100 : 0;

  factory SupervisorProfile.fromJson(Map<String, dynamic> json) {
    return SupervisorProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      specializations: (json['specializations'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      languages:
          (json['languages'] as List?)?.map((e) => e as String).toList() ?? [],
      timezone: json['timezone'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      maxConcurrentProjects: json['max_concurrent_projects'] as int? ?? 5,
      preferredSubjects: (json['preferred_subjects'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      qualifications: (json['qualifications'] as List?)
              ?.map((e) => Qualification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      experience: json['experience'] as int?,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalProjects: json['total_projects'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'specializations': specializations,
      'languages': languages,
      'timezone': timezone,
      'is_available': isAvailable,
      'max_concurrent_projects': maxConcurrentProjects,
      'preferred_subjects': preferredSubjects,
      'qualifications': qualifications.map((q) => q.toJson()).toList(),
      'experience': experience,
      'joined_at': joinedAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_verified': isVerified,
      'rating': rating,
      'total_projects': totalProjects,
      'completed_projects': completedProjects,
    };
  }

  SupervisorProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    List<String>? specializations,
    List<String>? languages,
    String? timezone,
    bool? isAvailable,
    int? maxConcurrentProjects,
    List<String>? preferredSubjects,
    List<Qualification>? qualifications,
    int? experience,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    bool? isVerified,
    double? rating,
    int? totalProjects,
    int? completedProjects,
  }) {
    return SupervisorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      specializations: specializations ?? this.specializations,
      languages: languages ?? this.languages,
      timezone: timezone ?? this.timezone,
      isAvailable: isAvailable ?? this.isAvailable,
      maxConcurrentProjects:
          maxConcurrentProjects ?? this.maxConcurrentProjects,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      qualifications: qualifications ?? this.qualifications,
      experience: experience ?? this.experience,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
    );
  }
}

/// Educational qualification.
class Qualification {
  const Qualification({
    required this.degree,
    required this.field,
    this.institution,
    this.year,
    this.isVerified = false,
  });

  final String degree;
  final String field;
  final String? institution;
  final int? year;
  final bool isVerified;

  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      degree: json['degree'] as String? ?? '',
      field: json['field'] as String? ?? '',
      institution: json['institution'] as String?,
      year: json['year'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'field': field,
      'institution': institution,
      'year': year,
      'is_verified': isVerified,
    };
  }
}

/// Doer for blacklist management.
class DoerInfo {
  const DoerInfo({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.rating,
    this.completedProjects = 0,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.blacklistedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final double? rating;
  final int completedProjects;
  final bool isBlacklisted;
  final String? blacklistReason;
  final DateTime? blacklistedAt;

  factory DoerInfo.fromJson(Map<String, dynamic> json) {
    return DoerInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      completedProjects: json['completed_projects'] as int? ?? 0,
      isBlacklisted: json['is_blacklisted'] as bool? ?? false,
      blacklistReason: json['blacklist_reason'] as String?,
      blacklistedAt: json['blacklisted_at'] != null
          ? DateTime.parse(json['blacklisted_at'] as String)
          : null,
    );
  }

  DoerInfo copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    double? rating,
    int? completedProjects,
    bool? isBlacklisted,
    String? blacklistReason,
    DateTime? blacklistedAt,
  }) {
    return DoerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      completedProjects: completedProjects ?? this.completedProjects,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: blacklistReason ?? this.blacklistReason,
      blacklistedAt: blacklistedAt ?? this.blacklistedAt,
    );
  }
}

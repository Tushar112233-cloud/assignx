// Copyright 2024 Doer App. All rights reserved.
// Use of this source code is governed by a BSD-style license.

/// User model combining profile and doer data for the Doer application.
///
/// This file contains the [UserModel] class which provides a unified view
/// of user data from both the `profiles` and `doers` tables, along with
/// supporting data classes for registration and profile setup.
///
/// ## Models in this file
///
/// - [UserModel] - Combined user data for UI consumption
/// - [RegistrationData] - Data transfer object for new user signup
/// - [ProfileSetupData] - Data transfer object for doer profile completion
/// - [BankDetailsFormData] - Form data for bank account submission
library user_model;

import 'doer_model.dart';
import 'profile_model.dart';

/// Combined user model representing a DOER user with both profile and doer data.
///
/// This is a convenience model that combines data from the `profiles` and `doers`
/// tables for use in the UI layer. It provides a unified view of the user,
/// eliminating the need to manage two separate models in widgets and providers.
///
/// ## JSON Structure
///
/// The model can be constructed from a joined query response:
///
/// ```json
/// {
///   "id": "uuid",
///   "email": "user@example.com",
///   "full_name": "John Doe",
///   "phone": "+919876543210",
///   "phone_verified": false,
///   "avatar_url": null,
///   "user_type": "doer",
///   "is_active": true,
///   "city": "Mumbai",
///   "state": "Maharashtra",
///   "country": "India",
///   "onboarding_step": "role_selection",
///   "onboarding_completed": false,
///   "referral_code": "JOHN123",
///   "created_at": "2024-01-01T00:00:00Z",
///   "updated_at": null,
///   "doer": {
///     "id": "doer-uuid",
///     "qualification": "B.Tech",
///     "university_name": "IIT Mumbai",
///     "experience_level": "intermediate",
///     "years_of_experience": 2,
///     "is_activated": true,
///     "bank_verified": false
///   },
///   "doer_skills": [
///     { "skill": { "id": "skill-uuid", "name": "Essay Writing", "slug": "essay-writing" } }
///   ],
///   "doer_subjects": [
///     { "subject": { "id": "subject-uuid", "name": "Computer Science", "slug": "computer-science" } }
///   ]
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// // From JSON (database response)
/// final user = UserModel.fromJson(jsonData);
///
/// // From separate models
/// final user = UserModel.fromModels(
///   profile: profileModel,
///   doer: doerModel,
///   skills: skillsList,
/// );
///
/// // Check activation status
/// if (user.isActivated) {
///   // User can accept projects
/// }
///
/// // Access computed properties
/// print(user.skillNames); // ['Essay Writing', 'Research']
/// ```
///
/// ## See Also
///
/// - [ProfileModel] for the base profile data structure
/// - [DoerModel] for doer-specific data structure
/// - [SkillModel] and [SubjectModel] for skill/subject details
class UserModel {
  // ═══════════════════════════════════════════════════════════════════════════
  // Profile Fields
  // ═══════════════════════════════════════════════════════════════════════════

  /// Unique identifier for the user.
  ///
  /// This is the UUID from Supabase Auth, used as the primary key in the
  /// `profiles` table and referenced by the `doers` table.
  final String id;

  /// User's email address.
  ///
  /// Must be unique across all users. Used for authentication and
  /// communication. Cannot be null.
  final String email;

  /// User's full name as displayed in the application.
  ///
  /// Used for display purposes throughout the app and in project assignments.
  final String fullName;

  /// User's phone number with country code.
  ///
  /// Format: `+919876543210` (with country code prefix).
  /// Used for SMS verification and contact purposes.
  final String? phone;

  /// Whether the user's phone number has been verified via OTP.
  ///
  /// Defaults to `false`. Set to `true` after successful OTP verification.
  final bool phoneVerified;

  /// URL to the user's avatar/profile image.
  ///
  /// Points to a Supabase Storage URL or external image URL.
  /// `null` if no avatar has been uploaded.
  final String? avatarUrl;

  /// The type of user account.
  ///
  /// Valid values: `'doer'`, `'student'`, `'supervisor'`, `'admin'`.
  /// For this app, typically `'doer'`.
  final String userType;

  /// Whether the user account is active.
  ///
  /// Inactive users cannot log in or use the application.
  /// Can be set to `false` by administrators.
  final bool isActive;

  /// User's city of residence.
  ///
  /// Optional. Used for location-based features and analytics.
  final String? city;

  /// User's state/province of residence.
  ///
  /// Optional. Used for location-based features and analytics.
  final String? state;

  /// User's country of residence.
  ///
  /// Defaults to `'India'`. Used for localization and payment processing.
  final String country;

  /// Current step in the onboarding flow.
  ///
  /// Tracks where the user is in the onboarding process.
  /// Values: `'role_selection'`, `'profile_setup'`, `'activation'`, `'completed'`.
  final String onboardingStep;

  /// Whether the user has completed the onboarding process.
  ///
  /// Set to `true` when all onboarding steps are finished.
  final bool onboardingCompleted;

  /// User's unique referral code for inviting others.
  ///
  /// Auto-generated based on name. Used for referral tracking.
  final String? referralCode;

  /// Timestamp when the user account was created.
  ///
  /// Set automatically by the database on insert.
  final DateTime createdAt;

  /// Timestamp when the user profile was last updated.
  ///
  /// `null` if never updated after creation.
  final DateTime? updatedAt;

  // ═══════════════════════════════════════════════════════════════════════════
  // Doer-Specific Fields
  // ═══════════════════════════════════════════════════════════════════════════

  /// Unique identifier for the doer record.
  ///
  /// `null` if the doer record doesn't exist yet (profile not completed).
  /// This is separate from the user [id] and lives in the `doers` table.
  final String? doerId;

  /// Doer's highest educational qualification.
  ///
  /// Examples: `'B.Tech'`, `'M.Sc'`, `'PhD'`, `'12th Pass'`.
  /// Required for doer profile completion.
  final String? qualification;

  /// Name of the university/institution the doer attended.
  ///
  /// Optional but recommended for credibility.
  final String? universityName;

  /// Doer's experience level in their field.
  ///
  /// Valid values: `'beginner'`, `'intermediate'`, `'expert'`.
  /// Defaults to `'beginner'`.
  final String experienceLevel;

  /// Number of years of relevant experience.
  ///
  /// Must be non-negative. Used with [experienceLevel] for matching.
  final int yearsOfExperience;

  /// Doer's bio or self-introduction.
  ///
  /// Optional free-text field for the doer to describe themselves.
  /// Displayed on their profile and to supervisors.
  final String? bio;

  /// Whether the doer is currently available for new projects.
  ///
  /// Doers can toggle this to pause receiving new project assignments
  /// without deactivating their account.
  final bool isAvailable;

  /// Whether the doer has completed the activation process.
  ///
  /// Activation requires: training completion, quiz pass, bank details.
  /// Only activated doers can accept and work on projects.
  final bool isActivated;

  /// Timestamp when the doer was fully activated.
  ///
  /// `null` if not yet activated.
  final DateTime? activatedAt;

  // ═══════════════════════════════════════════════════════════════════════════
  // Performance Statistics
  // ═══════════════════════════════════════════════════════════════════════════

  /// Total number of projects completed by the doer.
  ///
  /// Incremented when a project reaches `'completed'` or `'paid'` status.
  final int totalProjectsCompleted;

  /// Total earnings accumulated by the doer in INR.
  ///
  /// Sum of all payments received for completed projects.
  final double totalEarnings;

  /// Average rating from project reviews (0.0 to 5.0).
  ///
  /// Calculated as the mean of all review ratings received.
  /// `0.0` if no reviews yet.
  final double averageRating;

  /// Total number of reviews received.
  ///
  /// Count of all project reviews submitted for this doer.
  final int totalReviews;

  // ═══════════════════════════════════════════════════════════════════════════
  // Bank Details
  // ═══════════════════════════════════════════════════════════════════════════

  /// Name of the bank account holder.
  ///
  /// Should match the name on the bank account for successful transfers.
  final String? bankAccountName;

  /// Bank account number.
  ///
  /// Sensitive data - should be masked when displayed.
  /// Required for payment processing.
  final String? bankAccountNumber;

  /// IFSC code of the bank branch.
  ///
  /// 11-character code identifying the bank and branch.
  /// Format: `ABCD0123456` (4 letters + 0 + 6 alphanumeric).
  final String? bankIfscCode;

  /// Name of the bank.
  ///
  /// Auto-populated from IFSC code lookup or manually entered.
  final String? bankName;

  /// UPI ID for instant payments.
  ///
  /// Optional alternative to bank transfer.
  /// Format: `username@upi` or `phonenumber@bank`.
  final String? upiId;

  /// Whether the bank details have been verified.
  ///
  /// Verification may be done via penny drop or manual review.
  final bool bankVerified;

  // ═══════════════════════════════════════════════════════════════════════════
  // Skills and Subjects
  // ═══════════════════════════════════════════════════════════════════════════

  /// List of skills the doer possesses.
  ///
  /// Fetched from the `doer_skills` junction table joined with `skills`.
  /// Used for project matching and profile display.
  final List<SkillModel> skills;

  /// List of subjects the doer specializes in.
  ///
  /// Fetched from the `doer_subjects` junction table joined with `subjects`.
  /// Used for project matching and profile display.
  final List<SubjectModel> subjects;

  /// Creates a new [UserModel] with the specified values.
  ///
  /// Required parameters:
  /// - [id]: User's unique identifier (UUID from Supabase Auth)
  /// - [email]: User's email address
  /// - [fullName]: User's display name
  /// - [createdAt]: Account creation timestamp
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.phoneVerified = false,
    this.avatarUrl,
    this.userType = 'doer',
    this.isActive = true,
    this.city,
    this.state,
    this.country = 'India',
    this.onboardingStep = 'role_selection',
    this.onboardingCompleted = false,
    this.referralCode,
    required this.createdAt,
    this.updatedAt,
    // Doer fields
    this.doerId,
    this.qualification,
    this.universityName,
    this.experienceLevel = 'beginner',
    this.yearsOfExperience = 0,
    this.bio,
    this.isAvailable = true,
    this.isActivated = false,
    this.activatedAt,
    this.totalProjectsCompleted = 0,
    this.totalEarnings = 0.0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    this.upiId,
    this.bankVerified = false,
    this.skills = const [],
    this.subjects = const [],
  });

  /// Creates a [UserModel] from a joined query response.
  ///
  /// Parses JSON data from a database query that joins the `profiles` table
  /// with the `doers` table, along with nested `doer_skills` and `doer_subjects`.
  ///
  /// Expected query structure:
  /// ```sql
  /// SELECT *, doer:doers(*), doer_skills(skill:skills(*)), doer_subjects(subject:subjects(*))
  /// FROM profiles WHERE id = ?
  /// ```
  ///
  /// @param json The JSON map from the database response.
  /// @returns A new [UserModel] instance populated from the JSON data.
  ///
  /// @throws FormatException if required fields are missing or malformed.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested doer data if present
    final doerData = json['doer'] as Map<String, dynamic>?;

    // Parse skills if present (from nested join)
    final skillsList = <SkillModel>[];
    if (json['doer_skills'] != null) {
      for (final item in json['doer_skills'] as List) {
        if (item['skill'] != null) {
          skillsList.add(SkillModel.fromJson(item['skill'] as Map<String, dynamic>));
        }
      }
    }

    // Parse subjects if present (from nested join)
    final subjectsList = <SubjectModel>[];
    if (json['doer_subjects'] != null) {
      for (final item in json['doer_subjects'] as List) {
        if (item['subject'] != null) {
          subjectsList.add(SubjectModel.fromJson(item['subject'] as Map<String, dynamic>));
        }
      }
    }

    return UserModel(
      // Profile fields
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      userType: json['user_type'] as String? ?? 'doer',
      isActive: json['is_active'] as bool? ?? true,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'India',
      onboardingStep: json['onboarding_step'] as String? ?? 'role_selection',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      referralCode: json['referral_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      // Doer fields - from nested doer object or flat structure
      doerId: doerData?['id'] as String? ?? json['doer_id'] as String?,
      qualification: doerData?['qualification'] as String? ?? json['qualification'] as String?,
      universityName: doerData?['university_name'] as String? ?? json['university_name'] as String?,
      experienceLevel: doerData?['experience_level'] as String? ?? json['experience_level'] as String? ?? 'beginner',
      yearsOfExperience: doerData?['years_of_experience'] as int? ?? json['years_of_experience'] as int? ?? 0,
      bio: doerData?['bio'] as String? ?? json['bio'] as String?,
      isAvailable: doerData?['is_available'] as bool? ?? json['is_available'] as bool? ?? true,
      isActivated: doerData?['is_activated'] as bool? ?? json['is_activated'] as bool? ?? false,
      activatedAt: _parseDateTime(doerData?['activated_at'] ?? json['activated_at']),
      totalProjectsCompleted: doerData?['total_projects_completed'] as int? ?? json['total_projects_completed'] as int? ?? 0,
      totalEarnings: (doerData?['total_earnings'] as num?)?.toDouble() ?? (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      averageRating: (doerData?['average_rating'] as num?)?.toDouble() ?? (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: doerData?['total_reviews'] as int? ?? json['total_reviews'] as int? ?? 0,
      bankAccountName: doerData?['bank_account_name'] as String? ?? json['bank_account_name'] as String?,
      bankAccountNumber: doerData?['bank_account_number'] as String? ?? json['bank_account_number'] as String?,
      bankIfscCode: doerData?['bank_ifsc_code'] as String? ?? json['bank_ifsc_code'] as String?,
      bankName: doerData?['bank_name'] as String? ?? json['bank_name'] as String?,
      upiId: doerData?['upi_id'] as String? ?? json['upi_id'] as String?,
      bankVerified: doerData?['bank_verified'] as bool? ?? json['bank_verified'] as bool? ?? false,
      skills: skillsList,
      subjects: subjectsList,
    );
  }

  /// Parses a DateTime from various input types.
  ///
  /// Handles `null`, [DateTime], and ISO 8601 [String] formats.
  ///
  /// @param value The value to parse.
  /// @returns The parsed [DateTime], or `null` if parsing fails.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return null;
  }

  /// Creates a [UserModel] from separate profile and doer models.
  ///
  /// Useful when you have already parsed [ProfileModel] and [DoerModel]
  /// separately and want to combine them for UI consumption.
  ///
  /// @param profile The base profile model (required).
  /// @param doer The doer-specific model (optional, `null` if not yet created).
  /// @param skills List of skills (optional).
  /// @param subjects List of subjects (optional).
  /// @returns A new [UserModel] combining all the provided data.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final user = UserModel.fromModels(
  ///   profile: await fetchProfile(userId),
  ///   doer: await fetchDoer(userId),
  ///   skills: await fetchDoerSkills(doerId),
  ///   subjects: await fetchDoerSubjects(doerId),
  /// );
  /// ```
  factory UserModel.fromModels({
    required ProfileModel profile,
    DoerModel? doer,
    List<SkillModel>? skills,
    List<SubjectModel>? subjects,
  }) {
    return UserModel(
      id: profile.id,
      email: profile.email,
      fullName: profile.fullName,
      phone: profile.phone,
      phoneVerified: profile.phoneVerified,
      avatarUrl: profile.avatarUrl,
      userType: profile.userType,
      isActive: profile.isActive,
      city: profile.city,
      state: profile.state,
      country: profile.country,
      onboardingStep: profile.onboardingStep,
      onboardingCompleted: profile.onboardingCompleted,
      referralCode: profile.referralCode,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      // Doer fields
      doerId: doer?.id,
      qualification: doer?.qualification,
      universityName: doer?.universityName,
      experienceLevel: doer?.experienceLevel ?? 'beginner',
      yearsOfExperience: doer?.yearsOfExperience ?? 0,
      bio: doer?.bio,
      isAvailable: doer?.isAvailable ?? true,
      isActivated: doer?.isActivated ?? false,
      activatedAt: doer?.activatedAt,
      totalProjectsCompleted: doer?.totalProjectsCompleted ?? 0,
      totalEarnings: doer?.totalEarnings ?? 0.0,
      averageRating: doer?.averageRating ?? 0.0,
      totalReviews: doer?.totalReviews ?? 0,
      bankAccountName: doer?.bankAccountName,
      bankAccountNumber: doer?.bankAccountNumber,
      bankIfscCode: doer?.bankIfscCode,
      bankName: doer?.bankName,
      upiId: doer?.upiId,
      bankVerified: doer?.bankVerified ?? false,
      skills: skills ?? [],
      subjects: subjects ?? [],
    );
  }

  /// Whether the user has a doer record in the database.
  ///
  /// Returns `true` if [doerId] is not null, indicating the doer profile
  /// has been created. A user without a doer profile cannot proceed with
  /// activation or project work.
  bool get hasDoerProfile => doerId != null;

  /// Whether bank details have been submitted.
  ///
  /// Returns `true` if all required bank fields are present:
  /// [bankAccountName], [bankAccountNumber], and [bankIfscCode].
  ///
  /// Note: This doesn't indicate verification status - use [bankVerified]
  /// to check if details are verified.
  bool get hasBankDetails =>
      bankAccountName != null &&
      bankAccountNumber != null &&
      bankIfscCode != null;

  /// Gets skill names as a list of strings.
  ///
  /// Convenience getter for displaying skills without full [SkillModel] details.
  ///
  /// @returns List of skill name strings.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Text('Skills: ${user.skillNames.join(", ")}')
  /// // Output: "Skills: Essay Writing, Research, Programming"
  /// ```
  List<String> get skillNames => skills.map((s) => s.name).toList();

  /// Gets subject names as a list of strings.
  ///
  /// Convenience getter for displaying subjects without full [SubjectModel] details.
  ///
  /// @returns List of subject name strings.
  List<String> get subjectNames => subjects.map((s) => s.name).toList();

  /// Creates a copy of this [UserModel] with updated fields.
  ///
  /// All parameters are optional. Omitted parameters retain their original values.
  ///
  /// @returns A new [UserModel] instance with the specified changes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updatedUser = user.copyWith(
  ///   isActivated: true,
  ///   activatedAt: DateTime.now(),
  /// );
  /// ```
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    bool? phoneVerified,
    String? avatarUrl,
    String? userType,
    bool? isActive,
    String? city,
    String? state,
    String? country,
    String? onboardingStep,
    bool? onboardingCompleted,
    String? referralCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? doerId,
    String? qualification,
    String? universityName,
    String? experienceLevel,
    int? yearsOfExperience,
    String? bio,
    bool? isAvailable,
    bool? isActivated,
    DateTime? activatedAt,
    int? totalProjectsCompleted,
    double? totalEarnings,
    double? averageRating,
    int? totalReviews,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    String? upiId,
    bool? bankVerified,
    List<SkillModel>? skills,
    List<SubjectModel>? subjects,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doerId: doerId ?? this.doerId,
      qualification: qualification ?? this.qualification,
      universityName: universityName ?? this.universityName,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      isActivated: isActivated ?? this.isActivated,
      activatedAt: activatedAt ?? this.activatedAt,
      totalProjectsCompleted: totalProjectsCompleted ?? this.totalProjectsCompleted,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankName: bankName ?? this.bankName,
      upiId: upiId ?? this.upiId,
      bankVerified: bankVerified ?? this.bankVerified,
      skills: skills ?? this.skills,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, isActivated: $isActivated)';
  }
}

// =============================================================================
// Registration Data Transfer Objects
// =============================================================================

/// Data transfer object for new user registration.
///
/// Contains the minimum required information for creating a new user account.
/// Used by the registration form to collect user input before sending to
/// the authentication service.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "full_name": "John Doe",
///   "email": "john@example.com",
///   "phone": "+919876543210",
///   "password": "securePassword123"
/// }
/// ```
///
/// ## Example
///
/// ```dart
/// final registration = RegistrationData(
///   fullName: 'John Doe',
///   email: 'john@example.com',
///   phone: '+919876543210',
///   password: 'securePassword123',
/// );
///
/// await authRepository.register(registration);
/// ```
///
/// ## See Also
///
/// - [AuthRepository.register] for the registration implementation
/// - [ProfileSetupData] for completing the doer profile after registration
class RegistrationData {
  /// User's full name as they want it displayed.
  ///
  /// Will be used as the display name throughout the app.
  final String fullName;

  /// User's email address for login and communication.
  ///
  /// Must be a valid email format. Will receive verification email.
  final String email;

  /// User's phone number with country code.
  ///
  /// Format: `+919876543210`. Will be used for OTP verification.
  final String phone;

  /// User's chosen password.
  ///
  /// Should meet security requirements (min 8 characters, etc.).
  /// Never stored in plain text.
  final String password;

  /// Creates a new [RegistrationData] instance.
  ///
  /// All parameters are required for registration.
  const RegistrationData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });
}

/// Data transfer object for completing doer profile setup.
///
/// Contains professional information collected during the profile setup step
/// of onboarding. This data is used to create the doer record in the database.
///
/// ## JSON Structure (for doer insert)
///
/// ```json
/// {
///   "profile_id": "uuid",
///   "qualification": "B.Tech",
///   "university_name": "IIT Mumbai",
///   "experience_level": "intermediate",
///   "years_of_experience": 2,
///   "bio": "Experienced academic writer..."
/// }
/// ```
///
/// ## Example
///
/// ```dart
/// final profileData = ProfileSetupData(
///   qualification: 'B.Tech',
///   universityName: 'IIT Mumbai',
///   experienceLevel: 'intermediate',
///   yearsOfExperience: 2,
///   skillIds: ['skill-uuid-1', 'skill-uuid-2'],
///   subjectIds: ['subject-uuid-1'],
///   primarySubjectId: 'subject-uuid-1',
/// );
///
/// await authRepository.setupProfile(profileData);
/// ```
///
/// ## See Also
///
/// - [DoerModel] for the resulting database model
/// - [UserModel] for the combined user view
class ProfileSetupData {
  /// User's highest educational qualification.
  ///
  /// Examples: `'B.Tech'`, `'M.Sc'`, `'PhD'`, `'12th Pass'`.
  /// Required field.
  final String qualification;

  /// Name of the university or institution attended.
  ///
  /// Optional but recommended for credibility.
  final String? universityName;

  /// User's experience level in academic/professional work.
  ///
  /// Valid values: `'beginner'`, `'intermediate'`, `'expert'`.
  /// Affects project matching and visibility.
  final String experienceLevel;

  /// Number of years of relevant experience.
  ///
  /// Must be non-negative. Defaults to 0.
  final int yearsOfExperience;

  /// User's bio or self-introduction.
  ///
  /// Optional. Displayed on profile and to supervisors.
  final String? bio;

  /// List of skill IDs the user has selected.
  ///
  /// References UUIDs from the `skills` table.
  /// Used to populate the `doer_skills` junction table.
  final List<String> skillIds;

  /// List of subject IDs the user specializes in.
  ///
  /// References UUIDs from the `subjects` table.
  /// Used to populate the `doer_subjects` junction table.
  final List<String> subjectIds;

  /// The primary subject ID (main area of expertise).
  ///
  /// Must be one of the [subjectIds]. Marked as `is_primary = true`
  /// in the `doer_subjects` table.
  final String? primarySubjectId;

  /// Creates a new [ProfileSetupData] instance.
  ///
  /// Only [qualification] is strictly required; other fields have defaults.
  const ProfileSetupData({
    required this.qualification,
    this.universityName,
    this.experienceLevel = 'beginner',
    this.yearsOfExperience = 0,
    this.bio,
    this.skillIds = const [],
    this.subjectIds = const [],
    this.primarySubjectId,
  });

  /// Creates insert data for the `doers` table.
  ///
  /// Generates a map suitable for Supabase insert operation.
  /// Only includes non-null optional fields.
  ///
  /// @param profileId The profile UUID to link this doer record to.
  /// @returns A map of column names to values for database insert.
  Map<String, dynamic> toDoerInsertData(String profileId) {
    return {
      'profile_id': profileId,
      'qualification': qualification,
      if (universityName != null) 'university_name': universityName,
      'experience_level': experienceLevel,
      'years_of_experience': yearsOfExperience,
      if (bio != null) 'bio': bio,
    };
  }

  /// Creates update data for existing doer record.
  ///
  /// Generates a map suitable for Supabase update operation.
  /// Only includes non-null optional fields.
  ///
  /// @returns A map of column names to values for database update.
  Map<String, dynamic> toDoerUpdateData() {
    return {
      'qualification': qualification,
      if (universityName != null) 'university_name': universityName,
      'experience_level': experienceLevel,
      'years_of_experience': yearsOfExperience,
      if (bio != null) 'bio': bio,
    };
  }
}

/// Form data for bank account details submission.
///
/// Contains all fields collected from the bank details form during
/// the activation process. Includes validation for data integrity.
///
/// ## JSON Structure
///
/// ```json
/// {
///   "bank_account_name": "John Doe",
///   "bank_account_number": "1234567890123",
///   "bank_ifsc_code": "SBIN0001234",
///   "bank_name": "State Bank of India",
///   "upi_id": "john@upi"
/// }
/// ```
///
/// ## Example
///
/// ```dart
/// final bankData = BankDetailsFormData(
///   accountHolderName: 'John Doe',
///   accountNumber: '1234567890123',
///   confirmAccountNumber: '1234567890123',
///   ifscCode: 'SBIN0001234',
///   bankName: 'State Bank of India',
///   upiId: 'john@upi',
/// );
///
/// if (bankData.isValid) {
///   await updateBankDetails(bankData.toDoerUpdateData());
/// }
/// ```
///
/// ## See Also
///
/// - [BankDetails] in bank_details_model.dart for the database model
class BankDetailsFormData {
  /// Name of the bank account holder.
  ///
  /// Should match the name on the bank account for successful transfers.
  /// Used for verification purposes.
  final String accountHolderName;

  /// The bank account number.
  ///
  /// Typically 9-18 digits depending on the bank.
  /// Must match [confirmAccountNumber] for validation.
  final String accountNumber;

  /// Confirmation entry of the account number.
  ///
  /// Must exactly match [accountNumber] for the form to be valid.
  /// Used to prevent typos in account number entry.
  final String confirmAccountNumber;

  /// IFSC code of the bank branch.
  ///
  /// Must be exactly 11 characters.
  /// Format: 4 letters + 0 + 6 alphanumeric (e.g., `SBIN0001234`).
  final String ifscCode;

  /// Name of the bank (optional).
  ///
  /// Can be auto-populated from IFSC lookup or manually entered.
  final String? bankName;

  /// UPI ID for instant payments (optional).
  ///
  /// Alternative payment method. Format: `username@upi`.
  final String? upiId;

  /// Creates a new [BankDetailsFormData] instance.
  ///
  /// Required fields: [accountHolderName], [accountNumber],
  /// [confirmAccountNumber], [ifscCode].
  const BankDetailsFormData({
    required this.accountHolderName,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
    this.bankName,
    this.upiId,
  });

  /// Creates update data for the `doers` table bank fields.
  ///
  /// Generates a map suitable for Supabase update operation.
  ///
  /// @returns A map of column names to values for database update.
  Map<String, dynamic> toDoerUpdateData() {
    return {
      'bank_account_name': accountHolderName,
      'bank_account_number': accountNumber,
      'bank_ifsc_code': ifscCode,
      if (bankName != null) 'bank_name': bankName,
      if (upiId != null) 'upi_id': upiId,
    };
  }

  /// Validates the form data.
  ///
  /// Returns `true` if:
  /// - Account holder name is not empty
  /// - Account number is not empty
  /// - Account number matches confirmation
  /// - IFSC code is not empty and exactly 11 characters
  ///
  /// @returns `true` if all validation rules pass.
  bool get isValid =>
      accountHolderName.isNotEmpty &&
      accountNumber.isNotEmpty &&
      accountNumber == confirmAccountNumber &&
      ifscCode.isNotEmpty &&
      ifscCode.length == 11;
}

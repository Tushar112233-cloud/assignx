// Copyright 2024 Doer App. All rights reserved.
// Use of this source code is governed by a BSD-style license.

/// Profile model for the Doer application.
///
/// This file contains the [ProfileModel] class representing base user profile
/// data stored in the `profiles` table. This is the foundation for all user
/// types in the system.
///
/// ## Database Table
///
/// The `profiles` table is the central user table that stores common data
/// for all user types. It has a 1:1 relationship with Supabase Auth users.
///
/// ```sql
/// CREATE TABLE profiles (
///   id UUID PRIMARY KEY REFERENCES auth.users(id),
///   email TEXT UNIQUE NOT NULL,
///   full_name TEXT NOT NULL,
///   phone TEXT,
///   phone_verified BOOLEAN DEFAULT FALSE,
///   user_type TEXT NOT NULL CHECK (user_type IN ('doer', 'student', 'supervisor', 'admin')),
///   ...
/// );
/// ```
///
/// ## User Type Hierarchy
///
/// - **doer**: Task executors who complete projects (extends to `doers` table)
/// - **student**: Clients who submit projects
/// - **supervisor**: Manage doers and projects
/// - **admin**: Full system access
library profile_model;

/// Profile model representing base user profile in the `profiles` table.
///
/// This is the common user data shared across all user types (doer, student,
/// supervisor, admin). For doer-specific fields, see [DoerModel].
///
/// ## JSON Structure
///
/// ```json
/// {
///   "id": "uuid",
///   "email": "user@example.com",
///   "full_name": "John Doe",
///   "phone": "+919876543210",
///   "phone_verified": false,
///   "avatar_url": "https://storage.supabase.co/...",
///   "user_type": "doer",
///   "is_active": true,
///   "is_blocked": false,
///   "block_reason": null,
///   "city": "Mumbai",
///   "state": "Maharashtra",
///   "country": "India",
///   "last_login_at": "2024-01-15T10:30:00Z",
///   "login_count": 42,
///   "device_tokens": ["token1", "token2"],
///   "onboarding_step": "completed",
///   "onboarding_completed": true,
///   "onboarding_completed_at": "2024-01-01T12:00:00Z",
///   "referral_code": "JOHN123",
///   "referred_by": "referrer-uuid",
///   "created_at": "2024-01-01T00:00:00Z",
///   "updated_at": "2024-01-15T10:30:00Z"
/// }
/// ```
///
/// ## Usage
///
/// ```dart
/// // Parse from database response
/// final profile = ProfileModel.fromJson(jsonData);
///
/// // Create insert data for new profile
/// final insertData = ProfileModel.createInsertData(
///   id: authUser.id,
///   email: 'user@example.com',
///   fullName: 'John Doe',
///   userType: 'doer',
/// );
///
/// // Update profile
/// final updatedProfile = profile.copyWith(
///   city: 'Delhi',
///   onboardingStep: 'profile_setup',
/// );
/// ```
///
/// ## See Also
///
/// - [DoerModel] for doer-specific data (extends this profile)
/// - [UserModel] for the combined view used in UI
class ProfileModel {
  /// Unique identifier for the user profile.
  ///
  /// This is the UUID from Supabase Auth, used as the primary key.
  /// Same as `auth.users.id`.
  final String id;

  /// User's email address.
  ///
  /// Must be unique across all users. Used for authentication,
  /// password recovery, and communication.
  final String email;

  /// User's full name as displayed in the application.
  ///
  /// Used for display purposes throughout the app, in communications,
  /// and on project assignments.
  final String fullName;

  /// User's phone number with country code.
  ///
  /// Format: `+919876543210` (with country code prefix).
  /// Used for SMS verification, OTP, and contact purposes.
  final String? phone;

  /// Whether the user's phone number has been verified via OTP.
  ///
  /// Defaults to `false`. Set to `true` after successful OTP verification.
  /// Some features may require phone verification.
  final bool phoneVerified;

  /// URL to the user's avatar/profile image.
  ///
  /// Points to a Supabase Storage URL or external image URL.
  /// `null` if no avatar has been uploaded.
  final String? avatarUrl;

  /// The type of user account.
  ///
  /// Determines the user's role and permissions in the system.
  /// - `'doer'`: Can complete projects and earn money
  /// - `'student'`: Can submit projects
  /// - `'supervisor'`: Can manage doers and projects
  /// - `'admin'`: Full system access
  final String userType;

  /// Whether the user account is active.
  ///
  /// Inactive users cannot log in or use the application.
  /// Can be set to `false` by administrators for account suspension.
  final bool isActive;

  /// Whether the user account is blocked.
  ///
  /// Blocked users are prevented from all activities.
  /// More severe than `isActive = false`.
  final bool isBlocked;

  /// Reason for blocking the account.
  ///
  /// Set by administrators when [isBlocked] is `true`.
  /// Examples: `'Violation of terms'`, `'Fraud detected'`.
  final String? blockReason;

  /// User's city of residence.
  ///
  /// Optional. Used for location-based features, analytics, and
  /// matching with local projects.
  final String? city;

  /// User's state/province of residence.
  ///
  /// Optional. Used for location-based features and analytics.
  final String? state;

  /// User's country of residence.
  ///
  /// Defaults to `'India'`. Used for localization, payment processing,
  /// and compliance.
  final String country;

  /// Timestamp of the user's last login.
  ///
  /// Updated each time the user successfully authenticates.
  /// Used for activity tracking and security.
  final DateTime? lastLoginAt;

  /// Total number of times the user has logged in.
  ///
  /// Incremented on each successful login.
  /// Used for engagement tracking.
  final int loginCount;

  /// List of device tokens for push notifications.
  ///
  /// FCM tokens for Android, APNs tokens for iOS.
  /// Multiple tokens for users with multiple devices.
  final List<String>? deviceTokens;

  /// Current step in the onboarding flow.
  ///
  /// Tracks where the user is in the onboarding process.
  /// Values vary by user type but commonly include:
  /// - `'role_selection'`: Initial step
  /// - `'profile_setup'`: Setting up profile details
  /// - `'activation'`: Doer activation steps
  /// - `'completed'`: Onboarding finished
  final String onboardingStep;

  /// Whether the user has completed the onboarding process.
  ///
  /// Set to `true` when all onboarding steps are finished.
  /// Users with incomplete onboarding may have limited access.
  final bool onboardingCompleted;

  /// Timestamp when onboarding was completed.
  ///
  /// `null` if onboarding is not yet complete.
  final DateTime? onboardingCompletedAt;

  /// User's unique referral code for inviting others.
  ///
  /// Auto-generated based on name (e.g., `'JOHN123'`).
  /// Used for tracking referrals and awarding bonuses.
  final String? referralCode;

  /// Referral code used when this user signed up.
  ///
  /// References another user's [referralCode].
  /// Used for tracking who referred this user.
  final String? referredBy;

  /// Timestamp when the user profile was created.
  ///
  /// Set automatically by the database on insert.
  /// Typically matches the auth user creation time.
  final DateTime createdAt;

  /// Timestamp when the user profile was last updated.
  ///
  /// `null` if never updated after creation.
  /// Updated automatically by database triggers.
  final DateTime? updatedAt;

  /// Creates a new [ProfileModel] with the specified values.
  ///
  /// Required parameters:
  /// - [id]: User's unique identifier (UUID from Supabase Auth)
  /// - [email]: User's email address
  /// - [fullName]: User's display name
  /// - [userType]: Type of user account
  /// - [createdAt]: Account creation timestamp
  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.phoneVerified = false,
    this.avatarUrl,
    required this.userType,
    this.isActive = true,
    this.isBlocked = false,
    this.blockReason,
    this.city,
    this.state,
    this.country = 'India',
    this.lastLoginAt,
    this.loginCount = 0,
    this.deviceTokens,
    this.onboardingStep = 'role_selection',
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
    this.referralCode,
    this.referredBy,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [ProfileModel] from a JSON map (database response).
  ///
  /// Parses all fields from the database response, applying default values
  /// for optional fields that may be null.
  ///
  /// @param json The JSON map from the database response.
  /// @returns A new [ProfileModel] instance populated from the JSON data.
  ///
  /// @throws FormatException if required fields are missing or malformed.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      userType: json['user_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'India',
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      loginCount: json['login_count'] as int? ?? 0,
      deviceTokens: (json['device_tokens'] as List<dynamic>?)?.cast<String>(),
      onboardingStep: json['onboarding_step'] as String? ?? 'role_selection',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
      referralCode: json['referral_code'] as String?,
      referredBy: json['referred_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [ProfileModel] to a JSON map for database insert/update.
  ///
  /// Includes all fields with their current values. DateTime fields are
  /// converted to ISO 8601 strings.
  ///
  /// @returns A map of column names to values.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'phone_verified': phoneVerified,
      'avatar_url': avatarUrl,
      'user_type': userType,
      'is_active': isActive,
      'is_blocked': isBlocked,
      'block_reason': blockReason,
      'city': city,
      'state': state,
      'country': country,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'login_count': loginCount,
      'device_tokens': deviceTokens,
      'onboarding_step': onboardingStep,
      'onboarding_completed': onboardingCompleted,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
      'referral_code': referralCode,
      'referred_by': referredBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates insert data for a new profile record.
  ///
  /// Generates a minimal map with only the required fields.
  /// Other fields will use database defaults.
  ///
  /// @param id The user's UUID from Supabase Auth (required).
  /// @param email The user's email address (required).
  /// @param fullName The user's display name (required).
  /// @param phone The user's phone number (optional).
  /// @param userType The type of user account (required).
  /// @returns A map suitable for Supabase insert operation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final insertData = ProfileModel.createInsertData(
  ///   id: authUser.id,
  ///   email: 'user@example.com',
  ///   fullName: 'John Doe',
  ///   phone: '+919876543210',
  ///   userType: 'doer',
  /// );
  /// await supabase.from('profiles').insert(insertData);
  /// ```
  static Map<String, dynamic> createInsertData({
    required String id,
    required String email,
    required String fullName,
    String? phone,
    required String userType,
  }) {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType,
    };
  }

  /// Creates a copy of this [ProfileModel] with updated fields.
  ///
  /// All parameters are optional. Omitted parameters retain their
  /// original values.
  ///
  /// @returns A new [ProfileModel] instance with the specified changes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updatedProfile = profile.copyWith(
  ///   city: 'Delhi',
  ///   onboardingStep: 'activation',
  /// );
  /// ```
  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    bool? phoneVerified,
    String? avatarUrl,
    String? userType,
    bool? isActive,
    bool? isBlocked,
    String? blockReason,
    String? city,
    String? state,
    String? country,
    DateTime? lastLoginAt,
    int? loginCount,
    List<String>? deviceTokens,
    String? onboardingStep,
    bool? onboardingCompleted,
    DateTime? onboardingCompletedAt,
    String? referralCode,
    String? referredBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginCount: loginCount ?? this.loginCount,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, email: $email, fullName: $fullName, userType: $userType)';
  }
}

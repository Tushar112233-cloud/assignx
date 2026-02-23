import 'onboarding_step.dart';
import 'user_type.dart';

/// User profile model representing a registered user's information.
///
/// This model maps directly to the `profiles` table in Supabase and serves
/// as the central user data model throughout the application. It combines
/// authentication profile data with display profile information.
///
/// ## Database Table: `profiles`
///
/// ```sql
/// CREATE TABLE profiles (
///   id UUID PRIMARY KEY REFERENCES auth.users(id),
///   email TEXT NOT NULL,
///   full_name TEXT,
///   phone TEXT,
///   phone_verified BOOLEAN DEFAULT FALSE,
///   user_type TEXT CHECK (user_type IN ('student', 'professional')),
///   avatar_url TEXT,
///   city TEXT,
///   state TEXT,
///   country TEXT DEFAULT 'IN',
///   onboarding_step TEXT DEFAULT 'role_selection',
///   onboarding_completed BOOLEAN DEFAULT FALSE,
///   referral_code TEXT UNIQUE,
///   ...
/// );
/// ```
///
/// ## Usage
///
/// ```dart
/// // Fetch from Supabase
/// final response = await supabase.from('profiles')
///     .select()
///     .eq('id', userId)
///     .single();
/// final profile = UserProfile.fromJson(response);
///
/// // Display user info
/// Text(profile.displayName);
/// CircleAvatar(child: Text(profile.initials));
///
/// // Check onboarding status
/// if (!profile.isComplete) {
///   navigateToOnboarding(profile.onboardingStep);
/// }
///
/// // Update profile
/// final updated = profile.copyWith(fullName: 'New Name');
/// await supabase.from('profiles')
///     .update(updated.toJson())
///     .eq('id', profile.id);
/// ```
///
/// ## Related Models
///
/// - [StudentData] - Extended data for student users (separate table)
/// - [ProfessionalData] - Extended data for professional users (separate table)
/// - [UserType] - Enum for user categorization
/// - [OnboardingStep] - Enum for onboarding progress
///
/// See also:
/// - [ProfileRepository] for data access methods
/// - [ProfileProvider] for state management
class UserProfile {
  /// Unique identifier (UUID) from Supabase auth.
  ///
  /// This ID is automatically generated when the user signs up and
  /// references the `auth.users` table.
  final String id;

  /// User's email address from OAuth provider.
  ///
  /// This is the primary contact email and is always available
  /// after authentication.
  final String email;

  /// User's full name as displayed throughout the app.
  ///
  /// May be `null` if not yet provided during onboarding.
  /// Use [displayName] for safe display with fallback.
  final String? fullName;

  /// User's phone number with country code.
  ///
  /// Format: '+919876543210' (E.164 format)
  /// May be `null` if not yet provided during onboarding.
  final String? phone;

  /// Whether the phone number has been verified via OTP.
  final bool phoneVerified;

  /// The type of user account (Student or Professional).
  ///
  /// Determines which features and flows are available.
  /// May be `null` until selected during onboarding.
  final UserType? userType;

  /// URL to the user's profile picture.
  ///
  /// May be from OAuth provider (Google) or uploaded to Supabase Storage.
  final String? avatarUrl;

  /// User's city of residence.
  final String? city;

  /// User's state/province of residence.
  final String? state;

  /// User's country code (ISO 3166-1 alpha-2).
  ///
  /// Defaults to 'IN' (India).
  final String country;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Timestamp of the last profile update.
  final DateTime? updatedAt;

  /// Whether the user account is active.
  ///
  /// Inactive accounts cannot access the platform.
  final bool isActive;

  /// Whether the user account is blocked by admin.
  ///
  /// Blocked users see a specific message and cannot use the app.
  final bool isBlocked;

  /// Reason for account block (if [isBlocked] is true).
  final String? blockReason;

  /// Timestamp of the user's last login.
  final DateTime? lastLoginAt;

  /// Total number of times the user has logged in.
  final int loginCount;

  /// FCM device tokens for push notifications.
  ///
  /// Users may have multiple devices registered.
  final List<String>? deviceTokens;

  /// Current step in the onboarding flow.
  ///
  /// Use this to determine which onboarding screen to show.
  final OnboardingStep onboardingStep;

  /// Whether the user has completed onboarding.
  ///
  /// Once `true`, the user has full access to the platform.
  final bool onboardingCompleted;

  /// Timestamp when onboarding was completed.
  final DateTime? onboardingCompletedAt;

  /// User's unique referral code for sharing.
  ///
  /// Format: 'XXXX-XXXX' (8 alphanumeric characters)
  final String? referralCode;

  /// Referral code of the user who referred this user.
  final String? referredBy;

  /// Timestamp when the account was soft-deleted.
  ///
  /// `null` for active accounts. Check [isDeleted] for convenience.
  final DateTime? deletedAt;

  /// Creates a new [UserProfile] instance.
  ///
  /// Required fields: [id], [email], [createdAt]
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.phoneVerified = false,
    this.userType,
    this.avatarUrl,
    this.city,
    this.state,
    this.country = 'IN',
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isBlocked = false,
    this.blockReason,
    this.lastLoginAt,
    this.loginCount = 0,
    this.deviceTokens,
    this.onboardingStep = OnboardingStep.roleSelection,
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
    this.referralCode,
    this.referredBy,
    this.deletedAt,
  });

  /// Returns the display name with a fallback to 'User'.
  ///
  /// Use this instead of [fullName] directly to avoid null checks.
  ///
  /// Example:
  /// ```dart
  /// Text('Hello, ${profile.displayName}!'); // "Hello, John!" or "Hello, User!"
  /// ```
  String get displayName => fullName ?? 'User';

  /// Alias for [fullName] for backward compatibility.
  ///
  /// Prefer using [fullName] or [displayName] in new code.
  String? get name => fullName;

  /// Returns the user's initials for avatar display.
  ///
  /// - For "John Doe" returns "JD"
  /// - For "John" returns "J"
  /// - For empty/null name returns "?"
  ///
  /// Example:
  /// ```dart
  /// CircleAvatar(
  ///   child: Text(profile.initials),
  /// )
  /// ```
  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';

    final parts = fullName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName![0].toUpperCase();
  }

  /// Whether the profile has all required fields for platform access.
  ///
  /// A profile is complete when:
  /// - [fullName] is set
  /// - [userType] is selected
  /// - [onboardingCompleted] is true
  bool get isComplete =>
      fullName != null && userType != null && onboardingCompleted;

  /// Whether the account has been soft-deleted.
  bool get isDeleted => deletedAt != null;

  /// Returns a formatted location string.
  ///
  /// Combines [city] and [state] with a comma separator.
  /// Returns `null` if neither is set.
  ///
  /// Example:
  /// ```dart
  /// profile.locationInfo // "Mumbai, Maharashtra" or null
  /// ```
  String? get locationInfo {
    if (city == null && state == null) return null;
    final parts = [city, state].where((p) => p != null).join(', ');
    return parts.isNotEmpty ? parts : null;
  }

  /// Placeholder for university info (populated from StudentData join).
  ///
  /// Returns `null` - use [StudentData] for university information.
  /// This getter exists for API compatibility with legacy code.
  String? get university => null;

  /// Placeholder for formatted university info string.
  ///
  /// Returns `null` - use [StudentData] for university information.
  String? get universityInfo => null;

  /// Placeholder for course name (populated from StudentData join).
  ///
  /// Returns `null` - use [StudentData] for course information.
  String? get course => null;

  /// Placeholder for year of study (populated from StudentData join).
  ///
  /// Returns `null` - use [StudentData] for year information.
  String? get year => null;

  /// Returns the user role as a display string.
  ///
  /// Returns the [userType] display name or 'User' if not set.
  String get role => userType?.displayName ?? 'User';

  /// Whether the user is considered verified.
  ///
  /// A user is verified if:
  /// - Phone number is verified, OR
  /// - Email is present (OAuth verification)
  bool get isVerified => phoneVerified || email.isNotEmpty;

  /// Creates a [UserProfile] from a Supabase JSON response.
  ///
  /// Handles null values and type conversions for all fields.
  ///
  /// Example:
  /// ```dart
  /// final response = await supabase.from('profiles').select().single();
  /// final profile = UserProfile.fromJson(response);
  /// ```
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] as bool? ?? false,
      userType: UserType.fromString(json['user_type'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'IN',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isBlocked: json['is_blocked'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      loginCount: json['login_count'] as int? ?? 0,
      deviceTokens: json['device_tokens'] != null
          ? List<String>.from(json['device_tokens'] as List)
          : null,
      onboardingStep:
          OnboardingStep.fromString(json['onboarding_step'] as String?) ??
              OnboardingStep.roleSelection,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
      referralCode: json['referral_code'] as String?,
      referredBy: json['referred_by'] as String?,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Converts this profile to a JSON map for Supabase operations.
  ///
  /// Used for insert and update operations.
  ///
  /// Example:
  /// ```dart
  /// await supabase.from('profiles')
  ///     .update(profile.toJson())
  ///     .eq('id', profile.id);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'phone_verified': phoneVerified,
      'user_type': userType?.toDbString(),
      'avatar_url': avatarUrl,
      'city': city,
      'state': state,
      'country': country,
      'is_active': isActive,
      'is_blocked': isBlocked,
      'block_reason': blockReason,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'login_count': loginCount,
      'device_tokens': deviceTokens,
      'onboarding_step': onboardingStep.toDbString(),
      'onboarding_completed': onboardingCompleted,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
      'referral_code': referralCode,
      'referred_by': referredBy,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this profile with the specified fields updated.
  ///
  /// All fields are optional. Only provided fields are updated.
  ///
  /// Example:
  /// ```dart
  /// final updated = profile.copyWith(
  ///   fullName: 'New Name',
  ///   city: 'Mumbai',
  /// );
  /// ```
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    bool? phoneVerified,
    UserType? userType,
    String? avatarUrl,
    String? city,
    String? state,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isBlocked,
    String? blockReason,
    DateTime? lastLoginAt,
    int? loginCount,
    List<String>? deviceTokens,
    OnboardingStep? onboardingStep,
    bool? onboardingCompleted,
    DateTime? onboardingCompletedAt,
    String? referralCode,
    String? referredBy,
    DateTime? deletedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      userType: userType ?? this.userType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      blockReason: blockReason ?? this.blockReason,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginCount: loginCount ?? this.loginCount,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Equality comparison based on [id].
  ///
  /// Two profiles are considered equal if they have the same ID.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// Hash code based on [id].
  @override
  int get hashCode => id.hashCode;
}

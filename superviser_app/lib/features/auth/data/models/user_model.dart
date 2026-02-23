/// {@template user_model}
/// Data model representing an authenticated user in the Superviser App.
///
/// This model serves as the primary representation of a user throughout the
/// application, mapping data from both Supabase Authentication and the
/// `profiles` database table.
///
/// ## Overview
/// [UserModel] provides a unified interface for user data regardless of its
/// source (authentication provider or database). It includes essential user
/// information such as contact details, role, and activation status.
///
/// ## Data Sources
/// - **Supabase Auth**: Basic user data (id, email, metadata)
/// - **Profiles Table**: Extended profile data (role, activation status)
///
/// ## Usage
/// ```dart
/// // From Supabase Auth user
/// final user = UserModel.fromSupabaseUser(supabaseUser);
///
/// // From database JSON
/// final user = UserModel.fromJson(profileData);
///
/// // Create a modified copy
/// final updatedUser = user.copyWith(fullName: 'New Name');
///
/// // Access computed properties
/// print(user.displayName); // Full name or email username
/// print(user.initials);    // "JD" for "John Doe"
/// ```
///
/// ## See Also
/// - [AuthRepository] for authentication operations
/// - [AuthProvider] for state management
/// {@endtemplate}
library;

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// {@macro user_model}
class UserModel {
  /// Creates a [UserModel] with the specified properties.
  ///
  /// Required parameters:
  /// - [id]: Unique identifier from Supabase Auth
  /// - [email]: User's email address
  ///
  /// Optional parameters allow for flexible construction when not all
  /// profile data is available.
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.role,
    this.isActivated = false,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  /// User's unique identifier from Supabase Auth.
  ///
  /// This UUID is the primary key that links authentication data
  /// with the user's profile in the database.
  final String id;

  /// User's email address.
  ///
  /// Used for authentication and communication. This is the primary
  /// identifier for password-based authentication flows.
  final String email;

  /// User's full name as entered during registration or profile setup.
  ///
  /// May be `null` if the user hasn't completed their profile or
  /// signed up via OAuth without providing a name.
  final String? fullName;

  /// URL to the user's avatar image.
  ///
  /// Can be sourced from:
  /// - OAuth provider (Google, etc.)
  /// - Manually uploaded image
  /// - `null` if no avatar is set
  final String? avatarUrl;

  /// User's phone number in international format.
  ///
  /// Optional contact information that may be used for
  /// SMS notifications or two-factor authentication.
  final String? phone;

  /// User's role within the application.
  ///
  /// Common values:
  /// - `'supervisor'`: Project supervisor with management access
  /// - `'admin'`: System administrator
  ///
  /// The role determines feature access and permissions throughout
  /// the application.
  final String? role;

  /// Indicates whether the user has completed the supervisor activation process.
  ///
  /// Supervisors must be activated by an administrator before they can
  /// access the full functionality of the application. Inactive users
  /// are redirected to an activation pending screen.
  final bool isActivated;

  /// Indicates whether the user's email address has been verified.
  ///
  /// Email verification is typically completed by clicking a link
  /// sent to the user's email during registration.
  final bool isVerified;

  /// Timestamp of when the user account was created.
  ///
  /// Sourced from Supabase Auth's `created_at` field.
  final DateTime? createdAt;

  /// Timestamp of when the user's profile was last updated.
  ///
  /// Updated whenever profile data is modified in the database.
  final DateTime? updatedAt;

  /// Creates a [UserModel] from a Supabase Auth [User] object.
  ///
  /// This factory extracts core user data from the authentication response.
  /// Additional profile data (role, activation status) must be fetched
  /// separately from the database.
  ///
  /// The [user] parameter is the Supabase Auth user object received
  /// after successful authentication.
  ///
  /// ## Example
  /// ```dart
  /// final response = await supabase.auth.signInWithPassword(...);
  /// final userModel = UserModel.fromSupabaseUser(response.user!);
  /// ```
  factory UserModel.fromSupabaseUser(supabase.User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      phone: user.phone,
      isVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  /// Creates a [UserModel] from a JSON map, typically from the `profiles` table.
  ///
  /// This factory handles the database schema's snake_case field naming
  /// and provides default values for missing optional fields.
  ///
  /// The [json] parameter should be a row from the `profiles` table
  /// with the following expected keys:
  /// - `id` (required): User's UUID
  /// - `email` (optional): Email address
  /// - `full_name` (optional): Display name
  /// - `avatar_url` (optional): Profile image URL
  /// - `phone` (optional): Phone number
  /// - `role` (optional): User role string
  /// - `is_activated` (optional): Boolean activation status
  /// - `is_verified` (optional): Boolean verification status
  /// - `created_at` (optional): ISO 8601 timestamp
  /// - `updated_at` (optional): ISO 8601 timestamp
  ///
  /// ## Example
  /// ```dart
  /// final response = await supabase.from('profiles').select().eq('id', id).single();
  /// final user = UserModel.fromJson(response);
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      isActivated: json['is_activated'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [UserModel] to a JSON map for database operations.
  ///
  /// Returns a [Map] with snake_case keys matching the `profiles` table schema.
  /// Useful for creating or updating user profiles in the database.
  ///
  /// ## Example
  /// ```dart
  /// await supabase.from('profiles').upsert(user.toJson());
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'role': role,
      'is_activated': isActivated,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [UserModel] with the specified fields replaced.
  ///
  /// All parameters are optional. Only the provided parameters will be
  /// updated; all other fields retain their current values.
  ///
  /// ## Example
  /// ```dart
  /// final updatedUser = user.copyWith(
  ///   fullName: 'Updated Name',
  ///   isActivated: true,
  /// );
  /// ```
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? role,
    bool? isActivated,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActivated: isActivated ?? this.isActivated,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a user-friendly display name.
  ///
  /// If [fullName] is available, returns it. Otherwise, extracts the
  /// username portion from [email] (everything before the `@` symbol).
  ///
  /// ## Example
  /// ```dart
  /// UserModel(email: 'john@example.com', fullName: 'John Doe').displayName
  /// // Returns: 'John Doe'
  ///
  /// UserModel(email: 'john@example.com', fullName: null).displayName
  /// // Returns: 'john'
  /// ```
  String get displayName => fullName ?? email.split('@').first;

  /// Returns the user's initials for avatar display.
  ///
  /// Generates initials based on [fullName] if available:
  /// - Single name: First letter (e.g., "John" -> "J")
  /// - Multiple names: First letter of first and second names (e.g., "John Doe" -> "JD")
  ///
  /// Falls back to the first letter of [email] if no name is set.
  ///
  /// ## Example
  /// ```dart
  /// UserModel(fullName: 'John Doe', email: '...').initials // "JD"
  /// UserModel(fullName: 'Madonna', email: '...').initials  // "M"
  /// UserModel(fullName: null, email: 'test@...').initials  // "T"
  /// ```
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.trim().split(RegExp(r'\s+'));
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, fullName: $fullName)';

  /// Two [UserModel] instances are equal if they have the same [id].
  ///
  /// This allows for proper comparison and use in collections even when
  /// other properties may differ (e.g., before and after a profile update).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

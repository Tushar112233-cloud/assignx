/// User type enumeration for the AssignX platform.
///
/// Defines the two primary user categories in the system:
/// - [student]: Users currently pursuing education
/// - [professional]: Working professionals
///
/// This enum maps directly to the `user_type` column in the `profiles` table
/// in Supabase. The database stores values as lowercase strings ('student', 'professional').
///
/// ## Usage
///
/// ```dart
/// // Parse from database value
/// final userType = UserType.fromString('student');
///
/// // Display in UI
/// Text(userType.displayName); // "Student"
///
/// // Save to database
/// final dbValue = userType.toDbString(); // "student"
/// ```
///
/// ## Database Schema
///
/// ```sql
/// CREATE TYPE user_type AS ENUM ('student', 'professional');
/// ```
///
/// See also:
/// - [UserProfile] which contains the user type
/// - [StudentData] for student-specific profile data
/// - [ProfessionalData] for professional-specific profile data
enum UserType {
  /// A user currently pursuing education (school, college, university).
  ///
  /// Students have access to:
  /// - Academic assignment submission
  /// - Student marketplace
  /// - Campus-specific features
  student,

  /// A working professional user.
  ///
  /// Professionals have access to:
  /// - Business document services
  /// - Professional networking features
  professional;

  /// Internal map of display names for each user type.
  static const _displayNames = {
    UserType.student: 'Student',
    UserType.professional: 'Professional',
  };

  /// Internal map of descriptions for each user type.
  static const _descriptions = {
    UserType.student: 'Currently pursuing education',
    UserType.professional: 'Working professional',
  };

  /// Returns the human-readable display name for this user type.
  ///
  /// Example:
  /// ```dart
  /// UserType.student.displayName // Returns "Student"
  /// UserType.professional.displayName // Returns "Professional"
  /// ```
  String get displayName => _displayNames[this]!;

  /// Alias for [displayName] for backward compatibility.
  ///
  /// Prefer using [displayName] in new code.
  String get label => displayName;

  /// Returns a brief description of this user type.
  ///
  /// Useful for onboarding screens and tooltips.
  String get description => _descriptions[this]!;

  /// Parses a [UserType] from a string value.
  ///
  /// The parsing is case-insensitive.
  ///
  /// Returns `null` if [value] is null or doesn't match any user type.
  ///
  /// Example:
  /// ```dart
  /// UserType.fromString('student') // Returns UserType.student
  /// UserType.fromString('PROFESSIONAL') // Returns UserType.professional
  /// UserType.fromString('invalid') // Returns null
  /// UserType.fromString(null) // Returns null
  /// ```
  static UserType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'student':
        return UserType.student;
      case 'professional':
        return UserType.professional;
      default:
        return null;
    }
  }

  /// Converts this user type to its database string representation.
  ///
  /// Returns the enum name in lowercase (e.g., 'student', 'professional').
  ///
  /// Example:
  /// ```dart
  /// UserType.student.toDbString() // Returns "student"
  /// UserType.professional.toDbString() // Returns "professional"
  /// ```
  String toDbString() => name;
}

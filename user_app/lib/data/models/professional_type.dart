/// Professional type enumeration for the AssignX platform.
///
/// Defines the categories of professional users in the system:
/// - [jobSeeker]: Professionals looking for employment opportunities
/// - [business]: Business owners or managers
/// - [creator]: Content creators, freelancers, and independent contractors
///
/// This enum maps directly to the `professional_type` column in the
/// `professionals` table in Supabase. The database stores values as
/// snake_case strings ('job_seeker', 'business', 'creator').
///
/// ## Usage
///
/// ```dart
/// // Parse from database value
/// final type = ProfessionalType.fromString('job_seeker');
///
/// // Display in UI
/// Text(type.displayName); // "Job Seeker"
/// Text(type.description); // "Looking for job opportunities"
///
/// // Save to database
/// final dbValue = type.toDbString(); // "job_seeker"
/// ```
///
/// ## Database Schema
///
/// ```sql
/// CREATE TYPE professional_type AS ENUM ('job_seeker', 'business', 'creator');
/// ```
///
/// ## Feature Access by Type
///
/// | Type | Resume Services | Business Docs | Content Services |
/// |------|-----------------|---------------|------------------|
/// | Job Seeker | ✓ | - | - |
/// | Business | - | ✓ | - |
/// | Creator | - | - | ✓ |
///
/// See also:
/// - [ProfessionalData] which contains the professional type
/// - [UserType] for the top-level user categorization
/// - [UserProfile] for the main user profile model
enum ProfessionalType {
  /// A professional seeking employment opportunities.
  ///
  /// Job seekers typically need:
  /// - Resume writing and review
  /// - Cover letter assistance
  /// - LinkedIn profile optimization
  /// - Interview preparation materials
  jobSeeker,

  /// A business owner or manager.
  ///
  /// Business professionals typically need:
  /// - Business proposals and plans
  /// - Marketing materials
  /// - Corporate documentation
  /// - Financial reports
  business,

  /// A content creator or freelancer.
  ///
  /// Creators typically need:
  /// - Content writing and editing
  /// - Social media content
  /// - Blog posts and articles
  /// - Creative writing assistance
  creator;

  /// Internal map of human-readable display names for each type.
  static const _displayNames = {
    ProfessionalType.jobSeeker: 'Job Seeker',
    ProfessionalType.business: 'Business',
    ProfessionalType.creator: 'Creator',
  };

  /// Internal map of descriptions for each professional type.
  static const _descriptions = {
    ProfessionalType.jobSeeker: 'Looking for job opportunities',
    ProfessionalType.business: 'Running or managing a business',
    ProfessionalType.creator: 'Content creator or freelancer',
  };

  /// Internal map of database string values for each type.
  static const _toDbValues = {
    ProfessionalType.jobSeeker: 'job_seeker',
    ProfessionalType.business: 'business',
    ProfessionalType.creator: 'creator',
  };

  /// Returns the human-readable display name for this professional type.
  ///
  /// Example:
  /// ```dart
  /// ProfessionalType.jobSeeker.displayName // Returns "Job Seeker"
  /// ProfessionalType.business.displayName  // Returns "Business"
  /// ProfessionalType.creator.displayName   // Returns "Creator"
  /// ```
  String get displayName => _displayNames[this]!;

  /// Alias for [displayName] for backward compatibility.
  ///
  /// Prefer using [displayName] in new code.
  String get label => displayName;

  /// Returns a brief description of this professional type.
  ///
  /// Useful for onboarding screens, tooltips, and selection dialogs.
  ///
  /// Example:
  /// ```dart
  /// ProfessionalType.jobSeeker.description
  /// // Returns "Looking for job opportunities"
  /// ```
  String get description => _descriptions[this]!;

  /// Parses a [ProfessionalType] from a database string value.
  ///
  /// The parsing supports both snake_case and camelCase formats
  /// for flexibility with different data sources.
  ///
  /// Returns `null` if [value] is null or doesn't match any type.
  ///
  /// Example:
  /// ```dart
  /// ProfessionalType.fromString('job_seeker')  // Returns jobSeeker
  /// ProfessionalType.fromString('jobseeker')   // Returns jobSeeker
  /// ProfessionalType.fromString('business')    // Returns business
  /// ProfessionalType.fromString('invalid')     // Returns null
  /// ProfessionalType.fromString(null)          // Returns null
  /// ```
  static ProfessionalType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'job_seeker':
      case 'jobseeker':
        return ProfessionalType.jobSeeker;
      case 'business':
        return ProfessionalType.business;
      case 'creator':
        return ProfessionalType.creator;
      default:
        return null;
    }
  }

  /// Converts this professional type to its database string representation.
  ///
  /// Returns the value in snake_case format as stored in the database.
  ///
  /// Example:
  /// ```dart
  /// ProfessionalType.jobSeeker.toDbString() // Returns "job_seeker"
  /// ProfessionalType.business.toDbString()  // Returns "business"
  /// ProfessionalType.creator.toDbString()   // Returns "creator"
  /// ```
  String toDbString() => _toDbValues[this]!;
}

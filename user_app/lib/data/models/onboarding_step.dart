/// Onboarding step enumeration for tracking user registration progress.
///
/// Defines the sequential steps in the user onboarding flow:
/// 1. [roleSelection] - User selects their type (Student/Professional)
/// 2. [basicInfo] - User provides name, phone, and location
/// 3. [academicInfo] - Student/professional-specific information
/// 4. [verification] - Phone or email verification
/// 5. [complete] - Onboarding finished
///
/// This enum maps directly to the `onboarding_step` column in the
/// `profiles` table in Supabase.
///
/// ## Database Constraint
///
/// ```sql
/// CHECK (onboarding_step IN (
///   'role_selection',
///   'basic_info',
///   'academic_info',
///   'verification',
///   'complete'
/// ))
/// ```
///
/// ## Usage
///
/// ```dart
/// // Check current step
/// if (profile.onboardingStep == OnboardingStep.basicInfo) {
///   // Show basic info form
/// }
///
/// // Get step number for progress indicator
/// final progress = step.stepNumber / OnboardingStep.complete.stepNumber;
///
/// // Parse from database
/// final step = OnboardingStep.fromString('basic_info');
///
/// // Save to database
/// final dbValue = step.toDbString(); // "basic_info"
/// ```
///
/// ## Step Flow Diagram
///
/// ```
/// ┌─────────────────┐
/// │ Role Selection  │ Step 1
/// └────────┬────────┘
///          ▼
/// ┌─────────────────┐
/// │   Basic Info    │ Step 2
/// └────────┬────────┘
///          ▼
/// ┌─────────────────┐
/// │  Academic Info  │ Step 3 (Student/Professional specific)
/// └────────┬────────┘
///          ▼
/// ┌─────────────────┐
/// │  Verification   │ Step 4
/// └────────┬────────┘
///          ▼
/// ┌─────────────────┐
/// │    Complete     │ Step 5
/// └─────────────────┘
/// ```
///
/// See also:
/// - [UserProfile] which contains the onboarding step
/// - [OnboardingProgress] widget for displaying step progress
enum OnboardingStep {
  /// Initial step where user selects their account type.
  ///
  /// User chooses between [UserType.student] and [UserType.professional].
  /// This determines which subsequent screens and data fields are shown.
  roleSelection,

  /// User provides basic profile information.
  ///
  /// Collects:
  /// - Full name
  /// - Phone number
  /// - City and state
  basicInfo,

  /// User provides role-specific information.
  ///
  /// For students:
  /// - University/college
  /// - Course/program
  /// - Year of study
  /// - Student ID (optional)
  ///
  /// For professionals:
  /// - Professional type
  /// - Industry
  /// - Job title/company
  academicInfo,

  /// User verifies their identity.
  ///
  /// May include:
  /// - Phone number OTP verification
  /// - College email verification
  /// - Student ID verification
  verification,

  /// Onboarding process completed.
  ///
  /// User has full access to the platform. The [UserProfile.onboardingCompleted]
  /// flag is set to `true` and [UserProfile.onboardingCompletedAt] is recorded.
  complete;

  /// Internal map of human-readable display names for each step.
  static const _displayNames = {
    OnboardingStep.roleSelection: 'Role Selection',
    OnboardingStep.basicInfo: 'Basic Info',
    OnboardingStep.academicInfo: 'Academic Info',
    OnboardingStep.verification: 'Verification',
    OnboardingStep.complete: 'Complete',
  };

  /// Internal map of 1-based step numbers for progress tracking.
  static const _stepNumbers = {
    OnboardingStep.roleSelection: 1,
    OnboardingStep.basicInfo: 2,
    OnboardingStep.academicInfo: 3,
    OnboardingStep.verification: 4,
    OnboardingStep.complete: 5,
  };

  /// Internal map of database string values for each step.
  static const _toDbValues = {
    OnboardingStep.roleSelection: 'role_selection',
    OnboardingStep.basicInfo: 'basic_info',
    OnboardingStep.academicInfo: 'academic_info',
    OnboardingStep.verification: 'verification',
    OnboardingStep.complete: 'complete',
  };

  /// Returns the human-readable display name for this step.
  ///
  /// Example:
  /// ```dart
  /// OnboardingStep.basicInfo.displayName // Returns "Basic Info"
  /// ```
  String get displayName => _displayNames[this]!;

  /// Returns the 1-based step number for progress indicators.
  ///
  /// Example:
  /// ```dart
  /// OnboardingStep.basicInfo.stepNumber   // Returns 2
  /// OnboardingStep.complete.stepNumber    // Returns 5
  ///
  /// // Calculate progress percentage
  /// final progress = currentStep.stepNumber / 5 * 100;
  /// ```
  int get stepNumber => _stepNumbers[this]!;

  /// Returns the total number of onboarding steps.
  ///
  /// Useful for progress calculations.
  ///
  /// Example:
  /// ```dart
  /// final totalSteps = OnboardingStep.totalSteps; // Returns 5
  /// final progress = currentStep.stepNumber / totalSteps;
  /// ```
  static int get totalSteps => _stepNumbers.length;

  /// Parses an [OnboardingStep] from a database string value.
  ///
  /// The parsing supports both snake_case and camelCase formats
  /// for flexibility with different data sources.
  ///
  /// Returns `null` if [value] is null or doesn't match any step.
  ///
  /// Example:
  /// ```dart
  /// OnboardingStep.fromString('basic_info')   // Returns basicInfo
  /// OnboardingStep.fromString('basicinfo')    // Returns basicInfo
  /// OnboardingStep.fromString('complete')     // Returns complete
  /// OnboardingStep.fromString('invalid')      // Returns null
  /// OnboardingStep.fromString(null)           // Returns null
  /// ```
  static OnboardingStep? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'role_selection':
      case 'roleselection':
        return OnboardingStep.roleSelection;
      case 'basic_info':
      case 'basicinfo':
        return OnboardingStep.basicInfo;
      case 'academic_info':
      case 'academicinfo':
        return OnboardingStep.academicInfo;
      case 'verification':
        return OnboardingStep.verification;
      case 'complete':
        return OnboardingStep.complete;
      default:
        return null;
    }
  }

  /// Converts this step to its database string representation.
  ///
  /// Returns the value in snake_case format as stored in the database.
  ///
  /// Example:
  /// ```dart
  /// OnboardingStep.basicInfo.toDbString()    // Returns "basic_info"
  /// OnboardingStep.roleSelection.toDbString() // Returns "role_selection"
  /// ```
  String toDbString() => _toDbValues[this]!;
}

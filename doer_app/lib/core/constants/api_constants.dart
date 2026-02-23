/// API and configuration constants.
///
/// This file contains all external service configurations, API settings,
/// and application-wide constants used throughout the DOER app.
///
/// ## Categories
/// - **Supabase Configuration**: Backend connection settings
/// - **OAuth Configuration**: Third-party authentication
/// - **Storage Buckets**: File storage bucket names
/// - **Timeouts**: Network timeout durations
/// - **Pagination**: List loading settings
/// - **File Uploads**: Upload constraints and allowed types
/// - **Quiz Settings**: Training module configuration
/// - **Activation Requirements**: User onboarding thresholds
/// - **Payout Settings**: Payment processing configuration
/// - **Cache Durations**: Data caching timeframes
///
/// ## Environment Variables
/// Several constants are loaded from `--dart-define` environment variables:
/// - `SUPABASE_URL`: Supabase project URL
/// - `SUPABASE_ANON_KEY`: Supabase anonymous key
/// - `GOOGLE_WEB_CLIENT_ID`: Google OAuth web client ID
/// - `DEFAULT_COUNTRY_CODE`: Default phone country code
library;

/// API and configuration constants.
///
/// Provides centralized access to all configuration values.
/// Environment-specific values are loaded at compile time via `--dart-define`.
///
/// ## Usage
/// ```dart
/// // Access timeout duration
/// final timeout = ApiConstants.connectionTimeout;
///
/// // Check file size limit
/// if (fileSize > ApiConstants.maxFileSize) {
///   throw FileTooLargeException();
/// }
///
/// // Get storage bucket name
/// final bucket = ApiConstants.profileImagesBucket;
/// ```
class ApiConstants {
  /// Private constructor to prevent instantiation.
  ApiConstants._();

  // ---------------------------------------------------------------------------
  // Supabase Configuration
  // ---------------------------------------------------------------------------

  /// Supabase project URL.
  ///
  /// Loaded from `SUPABASE_URL` environment variable.
  /// Must be provided via `--dart-define` during build.
  ///
  /// Example: `https://xxxxx.supabase.co`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous/public API key.
  ///
  /// Loaded from `SUPABASE_ANON_KEY` environment variable.
  /// Must be provided via `--dart-define` during build.
  ///
  /// This is the public key safe for client-side use.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ---------------------------------------------------------------------------
  // OAuth Configuration
  // ---------------------------------------------------------------------------

  /// Google OAuth Web Client ID (required for Android native sign-in).
  ///
  /// This is the WEB client ID from Google Cloud Console, NOT the Android client ID.
  /// Required for Google Sign-In to work correctly on Android.
  ///
  /// Loaded from `GOOGLE_WEB_CLIENT_ID` environment variable.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Default country code for phone numbers.
  ///
  /// Used as the default prefix for phone number inputs.
  /// Configure via `--dart-define=DEFAULT_COUNTRY_CODE=+1` (or other country code).
  ///
  /// Default: `+91` (India)
  static const String defaultCountryCode = String.fromEnvironment(
    'DEFAULT_COUNTRY_CODE',
    defaultValue: '+91',
  );

  // ---------------------------------------------------------------------------
  // Storage Bucket Names
  // ---------------------------------------------------------------------------

  /// Supabase storage bucket for user profile images.
  static const String profileImagesBucket = 'profile-images';

  /// Supabase storage bucket for project-related files.
  static const String projectFilesBucket = 'project-files';

  /// Supabase storage bucket for submitted deliverables.
  static const String deliverablesBucket = 'deliverables';

  /// Supabase storage bucket for training module media.
  static const String trainingMediaBucket = 'training-media';

  // ---------------------------------------------------------------------------
  // Timeout Durations
  // ---------------------------------------------------------------------------

  /// Connection timeout for HTTP requests.
  ///
  /// The maximum time to wait for a connection to be established.
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Receive timeout for HTTP requests.
  ///
  /// The maximum time to wait for the complete response.
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  /// Default number of items per page for paginated lists.
  static const int defaultPageSize = 20;

  /// Maximum number of items per page for paginated lists.
  static const int maxPageSize = 100;

  // ---------------------------------------------------------------------------
  // File Upload Limits
  // ---------------------------------------------------------------------------

  /// Maximum file size in bytes (50 MB).
  ///
  /// Files larger than this will be rejected.
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB

  /// List of allowed file extensions for uploads.
  ///
  /// Includes documents, images, videos, and archives.
  static const List<String> allowedFileTypes = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
    'jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'zip',
  ];

  // ---------------------------------------------------------------------------
  // Quiz Settings
  // ---------------------------------------------------------------------------

  /// Minimum percentage required to pass a quiz.
  ///
  /// Users must score at least this percentage to complete a training module.
  static const int quizPassPercentage = 70;

  /// Time limit for quiz completion in minutes.
  static const int quizTimeLimitMinutes = 30;

  // ---------------------------------------------------------------------------
  // Activation Requirements
  // ---------------------------------------------------------------------------

  /// Number of training modules required for activation.
  ///
  /// Users must complete this many modules before being activated.
  static const int requiredTrainingModules = 3;

  /// Minimum quiz score required for activation.
  ///
  /// Users must achieve this score on the activation quiz.
  static const int requiredQuizScore = 70;

  // ---------------------------------------------------------------------------
  // Payout Settings
  // ---------------------------------------------------------------------------

  /// Minimum amount required to request a payout.
  ///
  /// In the default currency (INR).
  static const double minimumPayoutAmount = 500.0;

  /// Number of days for payout processing.
  ///
  /// Payouts are processed within this many business days.
  static const int payoutProcessingDays = 7;

  // ---------------------------------------------------------------------------
  // Cache Durations
  // ---------------------------------------------------------------------------

  /// Short cache duration (5 minutes).
  ///
  /// Use for frequently changing data like active projects.
  static const Duration shortCacheDuration = Duration(minutes: 5);

  /// Medium cache duration (1 hour).
  ///
  /// Use for moderately stable data like user profiles.
  static const Duration mediumCacheDuration = Duration(hours: 1);

  /// Long cache duration (24 hours).
  ///
  /// Use for stable data like reference lists and configuration.
  static const Duration longCacheDuration = Duration(hours: 24);
}

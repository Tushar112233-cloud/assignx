/// Application-wide constants and configuration values for the Superviser App.
///
/// This file centralizes all static configuration values used throughout the
/// application, including timing constants, validation rules, and storage keys.
/// Unlike [Env], these values are not sensitive and are the same across all
/// environments.
///
/// ## Categories
///
/// - **App Identity**: App name, tagline, branding
/// - **Animation Durations**: Standard timing for UI animations
/// - **Network Configuration**: Timeouts and connection settings
/// - **Pagination**: Default page sizes for list views
/// - **Form Validation**: Min/max lengths for user input
/// - **Storage Keys**: Keys for local storage persistence
///
/// ## Usage
///
/// ```dart
/// // Animation duration
/// AnimatedContainer(
///   duration: AppConstants.defaultAnimationDuration,
///   child: content,
/// );
///
/// // Validation
/// if (password.length < AppConstants.minPasswordLength) {
///   return 'Password too short';
/// }
/// ```
///
/// See also:
/// - [Env] for environment-specific configuration
/// - [Validators] for form validation utilities
library;

/// Abstract class containing application-wide constants.
///
/// This class cannot be instantiated and serves as a namespace for
/// static configuration values. All values are compile-time constants.
///
/// ## Example
///
/// ```dart
/// // Using animation duration
/// await Future.delayed(AppConstants.splashDuration);
///
/// // Using storage keys
/// prefs.setString(AppConstants.storageKeyThemeMode, 'dark');
/// ```
abstract class AppConstants {
  // ============ App Identity ============

  /// The application name displayed throughout the UI.
  ///
  /// Used in app bars, splash screen, and anywhere the app name appears.
  static const appName = 'AdminX';

  /// The application tagline or slogan.
  ///
  /// Displayed on splash screen and marketing materials.
  static const tagline = 'Quality. Integrity. Supervision.';

  /// Google OAuth Web Client ID required for Android native sign-in.
  ///
  /// **Important**: This is the WEB client ID from Google Cloud Console,
  /// NOT the Android client ID. The Web client ID is required for the
  /// native Google Sign-In flow on Android.
  ///
  /// Set via `--dart-define=GOOGLE_WEB_CLIENT_ID=your_client_id` during build.
  /// Returns an empty string if not configured.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  // ============ Animation Durations ============

  /// Standard animation duration for most UI transitions.
  ///
  /// Use this for:
  /// - Page transitions
  /// - Container animations
  /// - Opacity fades
  ///
  /// Duration: 300 milliseconds
  static const defaultAnimationDuration = Duration(milliseconds: 300);

  /// Fast animation duration for quick UI feedback.
  ///
  /// Use this for:
  /// - Button press feedback
  /// - Icon changes
  /// - Micro-interactions
  ///
  /// Duration: 150 milliseconds
  static const fastAnimationDuration = Duration(milliseconds: 150);

  /// Slow animation duration for prominent transitions.
  ///
  /// Use this for:
  /// - Hero animations
  /// - Complex transitions
  /// - Emphasis animations
  ///
  /// Duration: 500 milliseconds
  static const slowAnimationDuration = Duration(milliseconds: 500);

  /// Duration to display the splash screen on app launch.
  ///
  /// During this time, the app initializes services and checks
  /// authentication state.
  ///
  /// Duration: 2 seconds
  static const splashDuration = Duration(seconds: 2);

  // ============ Network Configuration ============

  /// Timeout duration for establishing a network connection.
  ///
  /// If a connection cannot be established within this duration,
  /// a [NetworkException] with timeout is thrown.
  ///
  /// Duration: 30 seconds
  static const connectionTimeout = Duration(seconds: 30);

  /// Timeout duration for receiving a response after connection.
  ///
  /// If the server does not respond within this duration after
  /// the connection is established, a timeout error occurs.
  ///
  /// Duration: 30 seconds
  static const receiveTimeout = Duration(seconds: 30);

  // ============ Pagination ============

  /// Default number of items per page for paginated lists.
  ///
  /// Used by repositories and providers when fetching paginated data.
  ///
  /// Value: 20 items
  static const defaultPageSize = 20;

  // ============ Form Validation ============

  /// Minimum required password length for user accounts.
  ///
  /// Used by [Validators.password] to validate password input.
  ///
  /// Value: 8 characters
  static const minPasswordLength = 8;

  /// Maximum allowed password length for user accounts.
  ///
  /// Used to prevent excessively long passwords that could cause issues.
  ///
  /// Value: 128 characters
  static const maxPasswordLength = 128;

  /// Minimum required length for name fields.
  ///
  /// Used by [Validators.name] to validate user names.
  ///
  /// Value: 2 characters
  static const minNameLength = 2;

  /// Maximum allowed length for name fields.
  ///
  /// Used to prevent excessively long names in the UI.
  ///
  /// Value: 100 characters
  static const maxNameLength = 100;

  // ============ Storage Keys ============

  /// Storage key for persisting the user's theme mode preference.
  ///
  /// Values: 'light', 'dark', or 'system'
  static const storageKeyThemeMode = 'theme_mode';

  /// Storage key for tracking onboarding completion status.
  ///
  /// Value: 'true' if onboarding has been completed
  static const storageKeyOnboardingComplete = 'onboarding_complete';

  /// Storage key for the user's access token (if stored locally).
  ///
  /// **Note**: Supabase handles token storage automatically. This key
  /// is for custom token management if needed.
  static const storageKeyAccessToken = 'access_token';

  /// Storage key for the user's refresh token (if stored locally).
  ///
  /// **Note**: Supabase handles token storage automatically. This key
  /// is for custom token management if needed.
  static const storageKeyRefreshToken = 'refresh_token';
}

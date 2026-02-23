/// Environment configuration for the Superviser App.
///
/// This file provides compile-time constants loaded from `--dart-define` flags
/// during the build process. Use this for sensitive configuration that varies
/// between development, staging, and production environments.
///
/// ## Configuration
///
/// Environment variables are set during build using:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your_anon_key \
///   --dart-define=DEBUG=false
/// ```
///
/// ## Usage
///
/// ```dart
/// // Check if configuration is complete before initialization
/// if (Env.isConfigured) {
///   await SupabaseService.initialize();
/// }
///
/// // Access individual values
/// final url = Env.supabaseUrl;
/// final isDebug = Env.isDebug;
/// ```
///
/// ## Security Note
///
/// Never commit actual environment values to version control. Use CI/CD
/// pipelines or local configuration files to inject these values at build time.
///
/// See also:
/// - [SupabaseService] for Supabase client initialization
/// - [AppConstants] for non-sensitive app configuration
library;

/// Abstract class containing environment configuration constants.
///
/// This class cannot be instantiated and serves as a namespace for
/// compile-time environment configuration. All values are loaded from
/// `--dart-define` flags at build time.
///
/// ## Example
///
/// ```dart
/// // Check configuration before using Supabase
/// if (!Env.isConfigured) {
///   throw StateError('Missing Supabase configuration');
/// }
///
/// await Supabase.initialize(
///   url: Env.supabaseUrl,
///   anonKey: Env.supabaseAnonKey,
/// );
/// ```
abstract class Env {
  /// The Supabase project URL.
  ///
  /// This is the base URL for your Supabase project, typically in the format:
  /// `https://your-project-ref.supabase.co`
  ///
  /// Set via `--dart-define=SUPABASE_URL=your_url` during build.
  ///
  /// Returns an empty string if not configured. Use [isConfigured] to verify
  /// that all required environment variables are set before using this value.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// The Supabase anonymous key for public API access.
  ///
  /// This key allows unauthenticated access to public data and is safe to
  /// include in client-side code. It is used for:
  /// - User authentication (sign up, sign in)
  /// - Accessing public database tables
  /// - Public storage operations
  ///
  /// Set via `--dart-define=SUPABASE_ANON_KEY=your_key` during build.
  ///
  /// Returns an empty string if not configured. Use [isConfigured] to verify
  /// that all required environment variables are set before using this value.
  ///
  /// **Security Note**: Never expose your service role key in client code.
  /// Only use the anon key for client-side operations.
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Whether the app is running in debug mode.
  ///
  /// When `true`, enables additional logging and debugging features:
  /// - Supabase debug logging
  /// - Verbose error messages
  /// - Development-only features
  ///
  /// Set via `--dart-define=DEBUG=true|false` during build.
  /// Defaults to `true` if not specified.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (Env.isDebug) {
  ///   print('Debug mode enabled - showing verbose logs');
  /// }
  /// ```
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: true,
  );

  /// Validates that all required environment variables are configured.
  ///
  /// Returns `true` if both [supabaseUrl] and [supabaseAnonKey] are non-empty,
  /// indicating that the minimum required configuration is present.
  ///
  /// Use this getter before attempting to initialize Supabase to provide
  /// helpful error messages to developers.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Future<void> main() async {
  ///   if (!Env.isConfigured) {
  ///     throw Exception(
  ///       'Missing environment configuration. '
  ///       'Run with: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
  ///     );
  ///   }
  ///   await SupabaseService.initialize();
  ///   runApp(const MyApp());
  /// }
  /// ```
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

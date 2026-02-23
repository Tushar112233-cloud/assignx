import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization.
///
/// Handles Supabase client setup with environment variables
/// for URL and anonymous key.
///
/// ## Build Configuration
///
/// Credentials must be provided at build time via --dart-define:
/// ```bash
/// flutter build apk \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
///
/// For development, create a `.env` file and use a build script,
/// or configure your IDE to pass these arguments.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL from environment variable.
  ///
  /// Must be provided via --dart-define=SUPABASE_URL=...
  /// Throws [AssertionError] if not configured.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous key from environment variable.
  ///
  /// Must be provided via --dart-define=SUPABASE_ANON_KEY=...
  /// Throws [AssertionError] if not configured.
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Validates that required environment variables are configured.
  ///
  /// Call this before [initialize] to get clear error messages.
  static void validateConfiguration() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL not configured. '
        'Build with: --dart-define=SUPABASE_URL=https://your-project.supabase.co',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY not configured. '
        'Build with: --dart-define=SUPABASE_ANON_KEY=your-anon-key',
      );
    }
  }

  /// Initialize Supabase client.
  ///
  /// Must be called before runApp() in main.dart.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user.
  static User? get currentUser => client.auth.currentUser;

  /// Get the current session.
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is authenticated.
  static bool get isAuthenticated => currentUser != null;
}

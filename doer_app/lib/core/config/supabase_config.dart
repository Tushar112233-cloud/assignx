/// Supabase configuration and client management.
///
/// This file provides centralized configuration for connecting to the
/// Supabase backend, including initialization, client access, and
/// authentication state management.
///
/// ## Environment Variables
/// The following environment variables must be provided via `--dart-define`:
/// - `SUPABASE_URL`: The Supabase project URL
/// - `SUPABASE_ANON_KEY`: The anonymous/public API key
///
/// ## Build Command Example
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///              --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
///
/// ## Features
/// - PKCE authentication flow for enhanced security
/// - Real-time client configuration with error-level logging
/// - Convenient getters for current user, session, and auth state
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

/// Supabase configuration and client access.
///
/// Provides static methods and getters for Supabase initialization
/// and client access throughout the application.
///
/// ## Usage
/// ```dart
/// // Initialize at app startup
/// await SupabaseConfig.initialize();
///
/// // Access the client
/// final client = SupabaseConfig.client;
///
/// // Check authentication status
/// if (SupabaseConfig.isAuthenticated) {
///   final user = SupabaseConfig.currentUser;
///   print('Logged in as: ${user?.email}');
/// }
///
/// // Listen to auth state changes
/// SupabaseConfig.authStateChanges.listen((state) {
///   print('Auth event: ${state.event}');
/// });
/// ```
///
/// ## Thread Safety
/// This class uses a private constructor pattern to prevent instantiation.
/// All members are static and can be accessed from any context.
class SupabaseConfig {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is designed to be used statically only.
  SupabaseConfig._();

  /// Initializes Supabase with environment variables.
  ///
  /// This method must be called before accessing any Supabase functionality,
  /// typically in the `main()` function before `runApp()`.
  ///
  /// ## Configuration
  /// - Uses PKCE authentication flow for enhanced security
  /// - Configures real-time client with error-level logging only
  ///
  /// ## Throws
  /// - [StateError] if `SUPABASE_URL` or `SUPABASE_ANON_KEY` are missing
  ///   or empty in the environment configuration
  ///
  /// ## Example
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await SupabaseConfig.initialize();
  ///   runApp(const MyApp());
  /// }
  /// ```
  static Future<void> initialize() async {
    const url = ApiConstants.supabaseUrl;
    const anonKey = ApiConstants.supabaseAnonKey;

    // Validate required configuration
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase configuration missing. Ensure SUPABASE_URL and '
        'SUPABASE_ANON_KEY are passed via --dart-define during build.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.error,
      ),
    );
  }

  /// Returns the Supabase client instance.
  ///
  /// This getter provides access to the singleton Supabase client
  /// for performing database operations, authentication, storage,
  /// and real-time subscriptions.
  ///
  /// ## Throws
  /// May throw if [initialize] has not been called.
  ///
  /// ## Example
  /// ```dart
  /// final response = await SupabaseConfig.client
  ///     .from('users')
  ///     .select()
  ///     .single();
  /// ```
  static SupabaseClient get client => Supabase.instance.client;

  /// Returns the current authenticated user.
  ///
  /// Returns `null` if no user is currently authenticated.
  ///
  /// ## Example
  /// ```dart
  /// final user = SupabaseConfig.currentUser;
  /// if (user != null) {
  ///   print('User ID: ${user.id}');
  ///   print('Email: ${user.email}');
  /// }
  /// ```
  static User? get currentUser => client.auth.currentUser;

  /// Returns the current session.
  ///
  /// Returns `null` if there is no active session.
  /// The session contains the access token, refresh token,
  /// and expiration information.
  ///
  /// ## Example
  /// ```dart
  /// final session = SupabaseConfig.currentSession;
  /// if (session != null) {
  ///   print('Token expires at: ${session.expiresAt}');
  /// }
  /// ```
  static Session? get currentSession => client.auth.currentSession;

  /// Checks if user is authenticated.
  ///
  /// Returns `true` if there is a current user, `false` otherwise.
  ///
  /// ## Example
  /// ```dart
  /// if (SupabaseConfig.isAuthenticated) {
  ///   // User is logged in, show dashboard
  /// } else {
  ///   // Show login screen
  /// }
  /// ```
  static bool get isAuthenticated => currentUser != null;

  /// Returns the auth state stream.
  ///
  /// This stream emits [AuthState] events whenever the authentication
  /// state changes, such as sign in, sign out, token refresh, etc.
  ///
  /// ## Events
  /// - [AuthChangeEvent.signedIn] - User signed in
  /// - [AuthChangeEvent.signedOut] - User signed out
  /// - [AuthChangeEvent.tokenRefreshed] - Token was refreshed
  /// - [AuthChangeEvent.userUpdated] - User metadata updated
  /// - [AuthChangeEvent.passwordRecovery] - Password recovery initiated
  ///
  /// ## Example
  /// ```dart
  /// SupabaseConfig.authStateChanges.listen((state) {
  ///   switch (state.event) {
  ///     case AuthChangeEvent.signedIn:
  ///       print('User signed in: ${state.session?.user.email}');
  ///       break;
  ///     case AuthChangeEvent.signedOut:
  ///       print('User signed out');
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

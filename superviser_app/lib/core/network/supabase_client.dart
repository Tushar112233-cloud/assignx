/// Supabase client initialization and service layer for the Superviser App.
///
/// This file provides a centralized service for initializing and accessing
/// the Supabase client, along with Riverpod providers for dependency injection.
///
/// ## Initialization
///
/// The Supabase service must be initialized before running the app:
///
/// ```dart
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await SupabaseService.initialize();
///   runApp(const ProviderScope(child: MyApp()));
/// }
/// ```
///
/// ## Providers
///
/// This file exports the following providers:
/// - [supabaseClientProvider]: Access to the raw Supabase client
/// - [authStateChangesProvider]: Stream of authentication state changes
///
/// ## Architecture
///
/// ```
/// main.dart
///     |
///     v
/// SupabaseService.initialize()
///     |
///     v
/// Supabase.instance.client
///     |
///     +---> supabaseClientProvider (for repositories)
///     +---> authStateChangesProvider (for auth state)
/// ```
///
/// See also:
/// - [Env] for Supabase configuration
/// - [AuthRepository] for authentication operations
/// - [ApiException] for error handling
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Gets the current authenticated user ID.
///
/// Returns the actual Supabase auth user ID, or null if not authenticated.
String? getCurrentUserId() {
  return SupabaseService._client?.auth.currentUser?.id;
}

/// Service class for initializing and accessing the Supabase client.
///
/// This class provides static methods and getters for interacting with
/// Supabase throughout the application. It must be initialized before
/// use by calling [initialize].
///
/// ## Lifecycle
///
/// 1. Call [initialize] in `main()` before `runApp()`
/// 2. Access the client via [client] getter
/// 3. Use convenience getters like [currentUser], [isAuthenticated]
///
/// ## Example
///
/// ```dart
/// // Initialize in main
/// await SupabaseService.initialize();
///
/// // Use in repository
/// final client = SupabaseService.client;
/// final response = await client.from('users').select();
///
/// // Check auth state
/// if (SupabaseService.isAuthenticated) {
///   final user = SupabaseService.currentUser!;
///   print('Logged in as: ${user.email}');
/// }
/// ```
class SupabaseService {
  /// Internal reference to the Supabase client instance.
  ///
  /// This is `null` until [initialize] is called.
  static SupabaseClient? _client;

  /// Initializes the Supabase client with environment configuration.
  ///
  /// This method must be called before any Supabase operations and before
  /// calling [runApp]. It configures the client with:
  /// - PKCE authentication flow for secure OAuth
  /// - Realtime logging (info level)
  /// - Debug mode based on [Env.isDebug]
  ///
  /// ## Throws
  ///
  /// - [Exception] if [Env.isConfigured] is `false`, indicating missing
  ///   environment variables.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   try {
  ///     await SupabaseService.initialize();
  ///   } catch (e) {
  ///     // Handle missing configuration
  ///     print('Failed to initialize Supabase: $e');
  ///   }
  ///
  ///   runApp(const MyApp());
  /// }
  /// ```
  static Future<void> initialize() async {
    if (!Env.isConfigured) {
      throw Exception(
        'Supabase configuration missing. '
        'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define',
      );
    }

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
      debug: Env.isDebug,
    );

    _client = Supabase.instance.client;
  }

  /// Returns the initialized Supabase client instance.
  ///
  /// ## Throws
  ///
  /// - [Exception] if accessed before [initialize] has been called.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final client = SupabaseService.client;
  /// final response = await client.from('projects').select();
  /// ```
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Returns the currently authenticated user, or `null` if not authenticated.
  ///
  /// This is a convenience getter for `client.auth.currentUser`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final user = SupabaseService.currentUser;
  /// if (user != null) {
  ///   print('User ID: ${user.id}');
  ///   print('Email: ${user.email}');
  /// }
  /// ```
  static User? get currentUser => client.auth.currentUser;

  /// Returns the current session, or `null` if no active session exists.
  ///
  /// The session contains the access token, refresh token, and expiration info.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = SupabaseService.currentSession;
  /// if (session != null) {
  ///   print('Token expires at: ${session.expiresAt}');
  /// }
  /// ```
  static Session? get currentSession => client.auth.currentSession;

  /// Returns `true` if a user is currently authenticated.
  ///
  /// This checks if [currentUser] is not `null`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// if (SupabaseService.isAuthenticated) {
  ///   // Navigate to dashboard
  /// } else {
  ///   // Navigate to login
  /// }
  /// ```
  static bool get isAuthenticated => currentUser != null;

  /// Returns a stream of authentication state changes.
  ///
  /// Use this to reactively respond to sign in, sign out, and token refresh events.
  ///
  /// ## Events
  ///
  /// - [AuthChangeEvent.signedIn]: User signed in
  /// - [AuthChangeEvent.signedOut]: User signed out
  /// - [AuthChangeEvent.tokenRefreshed]: Access token was refreshed
  /// - [AuthChangeEvent.userUpdated]: User metadata was updated
  ///
  /// ## Example
  ///
  /// ```dart
  /// SupabaseService.authStateChanges.listen((state) {
  ///   switch (state.event) {
  ///     case AuthChangeEvent.signedIn:
  ///       print('User signed in');
  ///       break;
  ///     case AuthChangeEvent.signedOut:
  ///       print('User signed out');
  ///       break;
  ///     // ...
  ///   }
  /// });
  /// ```
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

/// Riverpod provider for the Supabase client.
///
/// Use this provider to inject the Supabase client into repositories
/// and services that need direct database or storage access.
///
/// ## Example
///
/// ```dart
/// class UserRepository {
///   UserRepository(this._client);
///   final SupabaseClient _client;
///
///   Future<User> getUser(String id) async {
///     return _client.from('users').select().eq('id', id).single();
///   }
/// }
///
/// final userRepositoryProvider = Provider((ref) {
///   return UserRepository(ref.watch(supabaseClientProvider));
/// });
/// ```
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

// NOTE: currentUserProvider is defined in auth_provider.dart to avoid conflicts
// Use the one from auth_provider.dart for the domain UserModel

/// Riverpod stream provider for authentication state changes.
///
/// Use this provider to reactively rebuild widgets when the auth state changes.
/// This is automatically refreshed when the user signs in, signs out, or
/// their token is refreshed.
///
/// ## Example
///
/// ```dart
/// class AuthWrapper extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authState = ref.watch(authStateChangesProvider);
///
///     return authState.when(
///       data: (state) {
///         if (state.session != null) {
///           return const DashboardScreen();
///         }
///         return const LoginScreen();
///       },
///       loading: () => const LoadingScreen(),
///       error: (e, _) => ErrorScreen(error: e),
///     );
///   }
/// }
/// ```
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

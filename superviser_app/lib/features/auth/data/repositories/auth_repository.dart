/// {@template auth_repository}
/// Repository for handling all authentication operations in the Superviser App.
///
/// This repository provides a clean abstraction layer over Supabase
/// authentication, handling all auth-related API calls and error translation.
///
/// ## Overview
/// [AuthRepository] manages the complete authentication lifecycle including:
/// - Email/password sign-in and sign-up
/// - Google OAuth authentication
/// - Session management and recovery
/// - Password reset functionality
/// - User profile fetching
///
/// ## Architecture
/// This repository follows the repository pattern, abstracting data source
/// complexity from the presentation layer. All Supabase-specific errors are
/// translated to application-specific exceptions.
///
/// ## Usage
/// ```dart
/// // Obtain via Riverpod provider
/// final authRepo = ref.watch(authRepositoryProvider);
///
/// // Sign in with email
/// try {
///   final user = await authRepo.signInWithEmail(
///     email: 'user@example.com',
///     password: 'securePassword123',
///   );
///   print('Welcome, ${user.displayName}!');
/// } on AppAuthException catch (e) {
///   print('Login failed: ${e.message}');
/// }
///
/// // Check authentication status
/// if (authRepo.isAuthenticated()) {
///   final user = authRepo.getCurrentUser();
/// }
/// ```
///
/// ## Error Handling
/// All methods translate Supabase exceptions to [AppAuthException] or
/// [ServerException] for consistent error handling in the UI layer.
///
/// ## See Also
/// - [AuthNotifier] for state management
/// - [UserModel] for the user data model
/// - [AppAuthException] for authentication errors
/// {@endtemplate}
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/user_model.dart';

/// {@macro auth_repository}
class AuthRepository {
  /// Creates an [AuthRepository] with the given Supabase client.
  ///
  /// The [_client] is used for all authentication and database operations.
  /// Typically provided via dependency injection through Riverpod.
  AuthRepository(this._client);

  /// The Supabase client used for all authentication operations.
  final SupabaseClient _client;

  /// Signs in a user with email and password credentials.
  ///
  /// Authenticates the user against Supabase Auth using the provided
  /// [email] and [password]. Returns a [UserModel] on successful
  /// authentication.
  ///
  /// ## Parameters
  /// - [email]: The user's email address
  /// - [password]: The user's password
  ///
  /// ## Returns
  /// A [Future] that completes with a [UserModel] representing the
  /// authenticated user.
  ///
  /// ## Throws
  /// - [AppAuthException] if authentication fails due to:
  ///   - Invalid credentials
  ///   - Unverified email
  ///   - Account locked or disabled
  ///   - Network errors
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   final user = await authRepo.signInWithEmail(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('Logged in as: ${user.email}');
  /// } on AppAuthException catch (e) {
  ///   showError(e.message);
  /// }
  /// ```
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException('Login failed. Please try again.');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Registers a new user with email and password.
  ///
  /// Creates a new user account in Supabase Auth with the provided
  /// credentials. Optionally includes the user's full name in the
  /// user metadata.
  ///
  /// ## Parameters
  /// - [email]: The user's email address (must be unique)
  /// - [password]: The user's chosen password (min 6 characters)
  /// - [fullName]: Optional display name to store in user metadata
  ///
  /// ## Returns
  /// A [Future] that completes with a [UserModel] representing the
  /// newly created user.
  ///
  /// ## Throws
  /// - [AppAuthException] if registration fails due to:
  ///   - Email already in use
  ///   - Weak password
  ///   - Invalid email format
  ///   - Network errors
  ///
  /// ## Note
  /// After successful registration, the user typically needs to verify
  /// their email before they can sign in (depending on Supabase settings).
  ///
  /// ## Example
  /// ```dart
  /// final user = await authRepo.signUpWithEmail(
  ///   email: 'newuser@example.com',
  ///   password: 'securePassword123',
  ///   fullName: 'John Doe',
  /// );
  /// ```
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        throw const AppAuthException('Sign up failed. Please try again.');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Signs out the currently authenticated user.
  ///
  /// Invalidates the current session and clears all stored credentials.
  /// After calling this method, the user will need to authenticate again.
  ///
  /// ## Throws
  /// - [AppAuthException] if sign out fails (rare, usually network-related)
  ///
  /// ## Example
  /// ```dart
  /// await authRepo.signOut();
  /// // Navigate to login screen
  /// ```
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to sign out: $e');
    }
  }

  /// Sends a password reset email to the specified address.
  ///
  /// Triggers Supabase to send a password reset link to the provided
  /// [email]. The link contains a token that allows the user to set
  /// a new password.
  ///
  /// ## Parameters
  /// - [email]: The email address associated with the account
  ///
  /// ## Throws
  /// - [AppAuthException] if the operation fails
  ///
  /// ## Note
  /// For security reasons, this method succeeds even if the email
  /// is not registered (to prevent email enumeration attacks).
  ///
  /// ## Example
  /// ```dart
  /// await authRepo.sendPasswordResetEmail('user@example.com');
  /// showMessage('Check your email for reset instructions');
  /// ```
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to send reset email: $e');
    }
  }

  /// Updates the current user's password.
  ///
  /// Changes the password for the currently authenticated user.
  /// The user must be logged in to use this method.
  ///
  /// ## Parameters
  /// - [newPassword]: The new password (min 6 characters)
  ///
  /// ## Throws
  /// - [AppAuthException] if the update fails or user is not authenticated
  ///
  /// ## Example
  /// ```dart
  /// await authRepo.updatePassword('newSecurePassword123');
  /// ```
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to update password: $e');
    }
  }

  /// Gets the currently authenticated user synchronously.
  ///
  /// Returns the current user from the local session cache without
  /// making a network request. Returns `null` if no user is signed in.
  ///
  /// ## Returns
  /// A [UserModel] if a user is authenticated, `null` otherwise.
  ///
  /// ## Example
  /// ```dart
  /// final user = authRepo.getCurrentUser();
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// }
  /// ```
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  /// Gets the current authentication session.
  ///
  /// Returns the active [Session] object containing access tokens
  /// and refresh tokens. Returns `null` if no active session exists.
  ///
  /// ## Returns
  /// The current [Session] or `null` if not authenticated.
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  /// Recovers and validates the persisted session.
  ///
  /// Attempts to restore the user's session from secure local storage.
  /// If the session is expired, automatically attempts to refresh it
  /// using the stored refresh token.
  ///
  /// This method is critical for session persistence across app restarts.
  ///
  /// ## Returns
  /// A [Future] that completes with:
  /// - A valid [Session] if recovery succeeds
  /// - `null` if no session exists or recovery fails
  ///
  /// ## Note
  /// This method handles all errors gracefully and returns `null`
  /// rather than throwing, as session recovery failure simply means
  /// the user needs to log in again.
  ///
  /// ## Example
  /// ```dart
  /// final session = await authRepo.recoverSession();
  /// if (session != null) {
  ///   // User is still authenticated
  ///   navigateToDashboard();
  /// } else {
  ///   // User needs to log in
  ///   navigateToLogin();
  /// }
  /// ```
  Future<Session?> recoverSession() async {
    try {
      final session = _client.auth.currentSession;

      if (session != null) {
        // Check if session is expired and needs refresh
        if (session.isExpired) {
          // Attempt to refresh the expired session
          final response = await _client.auth.refreshSession();
          return response.session;
        }
        return session;
      }

      return null;
    } on AuthApiException {
      // Session refresh failed - user needs to re-authenticate
      return null;
    } catch (e) {
      // Unexpected error during session recovery
      return null;
    }
  }

  /// Checks if a user is currently authenticated.
  ///
  /// Returns `true` if there is an active session with valid tokens.
  /// This is a synchronous check based on cached session data.
  ///
  /// ## Returns
  /// `true` if authenticated, `false` otherwise.
  ///
  /// ## Example
  /// ```dart
  /// if (authRepo.isAuthenticated()) {
  ///   showDashboard();
  /// } else {
  ///   showLoginScreen();
  /// }
  /// ```
  bool isAuthenticated() {
    return _client.auth.currentSession != null;
  }

  /// Stream of authentication state changes.
  ///
  /// Emits [AuthState] events whenever the user's authentication status
  /// changes, including:
  /// - [AuthChangeEvent.signedIn]: User signed in
  /// - [AuthChangeEvent.signedOut]: User signed out
  /// - [AuthChangeEvent.tokenRefreshed]: Access token was refreshed
  /// - [AuthChangeEvent.userUpdated]: User profile was updated
  ///
  /// ## Usage
  /// ```dart
  /// authRepo.authStateChanges.listen((authState) {
  ///   switch (authState.event) {
  ///     case AuthChangeEvent.signedIn:
  ///       navigateToDashboard();
  ///       break;
  ///     case AuthChangeEvent.signedOut:
  ///       navigateToLogin();
  ///       break;
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Fetches the user's profile from the `profiles` database table.
  ///
  /// Retrieves extended user information that isn't stored in Supabase
  /// Auth, such as role and activation status.
  ///
  /// ## Parameters
  /// - [userId]: The user's UUID (from Supabase Auth)
  ///
  /// ## Returns
  /// A [Future] that completes with:
  /// - A [UserModel] if the profile exists
  /// - `null` if no profile is found
  ///
  /// ## Throws
  /// - [ServerException] if the database query fails
  ///
  /// ## Example
  /// ```dart
  /// final profile = await authRepo.fetchUserProfile(user.id);
  /// if (profile != null) {
  ///   print('Role: ${profile.role}');
  /// }
  /// ```
  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch profile: $e', null);
    }
  }

  /// Fetches supervisor-specific data from the `supervisors` table.
  ///
  /// Retrieves additional data specific to supervisor users, including
  /// their assigned projects and activation status.
  ///
  /// ## Parameters
  /// - [userId]: The user's UUID (profile_id in supervisors table)
  ///
  /// ## Returns
  /// A [Future] that completes with:
  /// - A [Map] containing supervisor data if found
  /// - `null` if no supervisor record exists
  ///
  /// ## Throws
  /// - [ServerException] if the database query fails
  ///
  /// ## Example
  /// ```dart
  /// final supervisorData = await authRepo.fetchSupervisorData(userId);
  /// final isActive = supervisorData?['is_activated'] as bool? ?? false;
  /// ```
  Future<Map<String, dynamic>?> fetchSupervisorData(String userId) async {
    try {
      final response = await _client
          .from('supervisors')
          .select()
          .eq('profile_id', userId)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch supervisor data: $e', null);
    }
  }

  /// Checks if the user is an activated supervisor.
  ///
  /// Queries the `supervisors` table to determine if the user has been
  /// approved for supervisor access. Non-activated supervisors are
  /// restricted from accessing certain features.
  ///
  /// ## Parameters
  /// - [userId]: The user's UUID
  ///
  /// ## Returns
  /// `true` if the user is an activated supervisor, `false` otherwise.
  ///
  /// ## Note
  /// This method returns `false` for all error conditions, treating
  /// any failure as "not activated" for security purposes.
  ///
  /// ## Example
  /// ```dart
  /// final canAccess = await authRepo.isActivatedSupervisor(userId);
  /// if (!canAccess) {
  ///   showActivationPendingScreen();
  /// }
  /// ```
  Future<bool> isActivatedSupervisor(String userId) async {
    try {
      final response = await _client
          .from('supervisors')
          .select('is_activated')
          .eq('profile_id', userId)
          .maybeSingle();

      if (response == null) return false;
      return response['is_activated'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Signs in using Google OAuth with native Google Sign-In.
  ///
  /// Initiates the native Google Sign-In flow, then exchanges the
  /// Google ID token with Supabase for a session.
  ///
  /// ## Returns
  /// A [Future] that completes with:
  /// - `true` if sign-in was successful
  /// - `false` if the user cancelled the sign-in dialog
  ///
  /// ## Throws
  /// - [AppAuthException] if:
  ///   - Google Web Client ID is not configured
  ///   - ID token is missing from Google auth response
  ///   - Supabase token exchange fails
  ///
  /// ## Configuration
  /// Requires `GOOGLE_WEB_CLIENT_ID` to be passed via `--dart-define`
  /// during build.
  ///
  /// ## Example
  /// ```dart
  /// final success = await authRepo.signInWithGoogle();
  /// if (success) {
  ///   // User is signed in, session established via auth listener
  ///   navigateToDashboard();
  /// } else {
  ///   // User cancelled
  ///   showMessage('Sign in cancelled');
  /// }
  /// ```
  Future<bool> signInWithGoogle() async {
    try {
      const webClientId = AppConstants.googleWebClientId;

      if (webClientId.isEmpty) {
        throw const AppAuthException(
          'Google Web Client ID not configured. Pass GOOGLE_WEB_CLIENT_ID as --dart-define',
        );
      }

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AppAuthException('Missing idToken from Google authentication');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.session != null;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Google sign-in failed: $e');
    }
  }

  /// Signs in using Magic Link (passwordless authentication).
  ///
  /// Sends a magic link to the user's email address for passwordless
  /// authentication. When the user clicks the link, they are automatically
  /// signed in to the app.
  ///
  /// ## Parameters
  /// - [email]: The email address to send the magic link to
  /// - [redirectTo]: Optional URL to redirect to after authentication
  ///
  /// ## Returns
  /// A [Future] that completes with `true` if the magic link was sent
  /// successfully, `false` otherwise.
  ///
  /// ## Throws
  /// - [AppAuthException] if the magic link request fails
  ///
  /// ## Example
  /// ```dart
  /// final success = await authRepo.signInWithMagicLink(
  ///   email: 'user@example.com',
  /// );
  /// if (success) {
  ///   showMessage('Check your email for the magic link!');
  /// }
  /// ```
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );

      return true;
    } on AuthApiException catch (e) {
      throw AppAuthException.fromSupabase(e);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to send magic link: $e');
    }
  }
}

/// Riverpod provider for [AuthRepository].
///
/// Provides a singleton instance of [AuthRepository] configured with
/// the Supabase client from [supabaseClientProvider].
///
/// ## Usage
/// ```dart
/// final authRepo = ref.watch(authRepositoryProvider);
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

/// {@template auth_provider}
/// State management for authentication in the Superviser App.
///
/// This file contains the [AuthState] class and [AuthNotifier] state notifier
/// that manage the complete authentication lifecycle, as well as convenient
/// Riverpod providers for accessing auth-related data.
///
/// ## Overview
/// The auth provider system handles:
/// - Session initialization and recovery
/// - Sign in/sign up/sign out operations
/// - Auth state change listening
/// - User data loading and caching
/// - Error state management
///
/// ## Architecture
/// Uses Riverpod's [StateNotifier] pattern for predictable state management.
/// The [AuthNotifier] coordinates with [AuthRepository] for all operations.
///
/// ## Providers
/// - [authProvider]: Main provider for [AuthState]
/// - [currentUserProvider]: Quick access to current [UserModel]
/// - [authLoadingProvider]: Loading state indicator
/// - [authErrorProvider]: Current error message
/// - [isAuthenticatedProvider]: Boolean auth status
/// - [isActivatedProvider]: Supervisor activation status
///
/// ## Usage
/// ```dart
/// // In a widget
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final authState = ref.watch(authProvider);
///
///     if (authState.isLoading) return LoadingIndicator();
///     if (authState.error != null) return ErrorWidget(authState.error!);
///     if (authState.isAuthenticated) return Dashboard();
///     return LoginScreen();
///   }
/// }
///
/// // Performing auth operations
/// ref.read(authProvider.notifier).signIn(email: 'x', password: 'y');
/// ref.read(authProvider.notifier).signOut();
/// ```
///
/// ## See Also
/// - [AuthRepository] for underlying operations
/// - [UserModel] for user data structure
/// {@endtemplate}
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// {@template auth_state}
/// Immutable state class representing the current authentication status.
///
/// Contains all information needed by the UI to render authentication-related
/// views, including the current user, loading state, errors, and activation status.
///
/// ## Properties
/// - [user]: The currently authenticated user, or `null` if not signed in
/// - [isLoading]: Whether an auth operation is in progress
/// - [error]: Error message from the last failed operation
/// - [isActivated]: Whether the user is an activated supervisor
///
/// ## Usage
/// ```dart
/// final state = AuthState(user: myUser, isLoading: false);
///
/// if (state.isAuthenticated) {
///   print('Welcome, ${state.user!.displayName}');
/// }
/// ```
/// {@endtemplate}
class AuthState {
  /// Creates an [AuthState] with the specified properties.
  ///
  /// All parameters are optional with sensible defaults:
  /// - [user]: `null` (not authenticated)
  /// - [isLoading]: `false`
  /// - [error]: `null` (no error)
  /// - [isActivated]: `false`
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isActivated = false,
  });

  /// The currently authenticated user.
  ///
  /// `null` if no user is signed in or if the session has expired.
  final UserModel? user;

  /// Indicates whether an authentication operation is in progress.
  ///
  /// When `true`, UI should show loading indicators and disable
  /// interactive elements to prevent duplicate submissions.
  final bool isLoading;

  /// Error message from the last failed authentication operation.
  ///
  /// `null` if the last operation succeeded or if the error has been
  /// cleared via [AuthNotifier.clearError].
  final String? error;

  /// Indicates whether the user is an activated supervisor.
  ///
  /// Used to control access to supervisor-only features. Users who
  /// are authenticated but not activated are directed to a pending
  /// activation screen.
  final bool isActivated;

  /// Whether a user is currently authenticated.
  ///
  /// Convenience getter that checks if [user] is not `null`.
  bool get isAuthenticated => user != null;

  /// Creates an initial loading state for app startup.
  ///
  /// Used when the app first launches and is checking for an
  /// existing session to recover.
  factory AuthState.initial() => const AuthState(isLoading: true);

  /// Creates a copy of this [AuthState] with the specified fields updated.
  ///
  /// ## Parameters
  /// - [user]: New user value
  /// - [isLoading]: New loading state
  /// - [error]: New error message
  /// - [isActivated]: New activation status
  /// - [clearError]: If `true`, sets [error] to `null`
  /// - [clearUser]: If `true`, sets [user] to `null`
  ///
  /// ## Example
  /// ```dart
  /// // Update loading state
  /// state = state.copyWith(isLoading: true);
  ///
  /// // Clear error
  /// state = state.copyWith(clearError: true);
  ///
  /// // Sign out (clear user)
  /// state = state.copyWith(clearUser: true, isLoading: false);
  /// ```
  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isActivated,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isActivated: isActivated ?? this.isActivated,
    );
  }
}

/// {@template auth_notifier}
/// State notifier that manages authentication state and operations.
///
/// This notifier handles all authentication-related business logic,
/// coordinating between the UI layer and [AuthRepository].
///
/// ## Responsibilities
/// - Initialize auth state on app startup
/// - Listen to auth state changes from Supabase
/// - Perform sign in/sign up/sign out operations
/// - Load and cache user profile data
/// - Manage loading and error states
///
/// ## Lifecycle
/// 1. On creation, attempts to recover existing session
/// 2. Sets up listener for auth state changes
/// 3. Loads user profile data when authenticated
/// 4. Cleans up subscription on dispose
///
/// ## Usage
/// ```dart
/// // Access via ref.read for operations
/// await ref.read(authProvider.notifier).signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// // Sign out
/// await ref.read(authProvider.notifier).signOut();
///
/// // Clear error state
/// ref.read(authProvider.notifier).clearError();
/// ```
/// {@endtemplate}
class AuthNotifier extends StateNotifier<AuthState> {
  /// Creates an [AuthNotifier] with the given repository.
  ///
  /// Immediately begins initialization to recover any existing session.
  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
  }

  /// The repository used for all authentication operations.
  final AuthRepository _repository;

  /// Subscription to Supabase auth state changes.
  StreamSubscription<supabase.AuthState>? _authSubscription;

  /// Initializes authentication state with proper session recovery.
  ///
  /// This method:
  /// 1. Attempts to recover a persisted session
  /// 2. Loads user profile data if a session exists
  /// 3. Sets up a listener for future auth state changes
  ///
  /// Called automatically on construction.
  Future<void> _init() async {
    try {
      // Recover session from secure storage
      // This is critical for session persistence across app restarts
      final session = await _repository.recoverSession();

      if (session != null && session.user != null) {
        await _loadUserData(UserModel.fromSupabaseUser(session.user!));
      } else {
        state = const AuthState();
      }
    } catch (e) {
      // Session recovery failed, user needs to log in again
      state = const AuthState();
    }

    // Listen for auth changes
    _authSubscription = _repository.authStateChanges.listen((authState) {
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        final user = authState.session?.user;
        if (user != null) {
          _loadUserData(UserModel.fromSupabaseUser(user));
        }
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        state = const AuthState();
      } else if (authState.event == supabase.AuthChangeEvent.tokenRefreshed) {
        // Session refreshed successfully, update user data
        final user = authState.session?.user;
        if (user != null) {
          state = state.copyWith(
            user: UserModel.fromSupabaseUser(user),
          );
        }
      } else if (authState.event == supabase.AuthChangeEvent.userUpdated) {
        // User profile was updated, reload full data
        final user = authState.session?.user;
        if (user != null) {
          _loadUserData(UserModel.fromSupabaseUser(user));
        }
      }
    });
  }

  /// Loads complete user data from the database.
  ///
  /// Fetches the user's profile and supervisor status, updating
  /// the state with the complete user information.
  ///
  /// ## Parameters
  /// - [user]: The basic user model from Supabase Auth
  Future<void> _loadUserData(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Check if user is an activated supervisor
      final isActivated = await _repository.isActivatedSupervisor(user.id);

      // Fetch profile data
      final profile = await _repository.fetchUserProfile(user.id);

      state = state.copyWith(
        user: profile ?? user,
        isActivated: isActivated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: 'Failed to load user data',
      );
    }
  }

  /// Signs in a user with email and password.
  ///
  /// Attempts to authenticate the user with the provided credentials.
  /// On success, loads the user's profile and updates the state.
  ///
  /// ## Parameters
  /// - [email]: The user's email address
  /// - [password]: The user's password
  ///
  /// ## Returns
  /// `true` if sign in succeeded, `false` if it failed.
  ///
  /// ## Side Effects
  /// - Sets [AuthState.isLoading] during operation
  /// - Sets [AuthState.user] on success
  /// - Sets [AuthState.error] on failure
  ///
  /// ## Example
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// if (success) {
  ///   context.go('/dashboard');
  /// }
  /// ```
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );

      await _loadUserData(user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Registers a new user with email and password.
  ///
  /// Creates a new user account and optionally includes their full name.
  /// Note: The user may need to verify their email before signing in.
  ///
  /// ## Parameters
  /// - [email]: The user's email address
  /// - [password]: The user's chosen password
  /// - [fullName]: Optional display name
  ///
  /// ## Returns
  /// `true` if registration succeeded, `false` if it failed.
  ///
  /// ## Side Effects
  /// - Sets [AuthState.isLoading] during operation
  /// - Sets [AuthState.error] on failure
  ///
  /// ## Example
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signUp(
  ///   email: 'newuser@example.com',
  ///   password: 'password123',
  ///   fullName: 'John Doe',
  /// );
  /// if (success) {
  ///   showMessage('Check your email to verify your account');
  /// }
  /// ```
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Signs out the current user.
  ///
  /// Clears the session and resets the auth state. After calling this
  /// method, the user will need to sign in again.
  ///
  /// ## Side Effects
  /// - Sets [AuthState.isLoading] during operation
  /// - Clears [AuthState.user] on success
  /// - Sets [AuthState.error] on failure
  ///
  /// ## Example
  /// ```dart
  /// await ref.read(authProvider.notifier).signOut();
  /// context.go('/login');
  /// ```
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sends a password reset email.
  ///
  /// Triggers the password reset flow by sending an email with
  /// a reset link to the specified address.
  ///
  /// ## Parameters
  /// - [email]: The email address to send the reset link to
  ///
  /// ## Returns
  /// `true` if the email was sent, `false` on failure.
  ///
  /// ## Note
  /// Returns `true` even if the email doesn't exist (security best practice).
  ///
  /// ## Example
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).sendPasswordReset(
  ///   'user@example.com',
  /// );
  /// if (success) {
  ///   showMessage('Check your email for reset instructions');
  /// }
  /// ```
  Future<bool> sendPasswordReset(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Signs in using Google OAuth.
  ///
  /// Initiates the native Google Sign-In flow and authenticates
  /// with Supabase using the resulting tokens.
  ///
  /// ## Returns
  /// `true` if sign in succeeded, `false` if cancelled or failed.
  ///
  /// ## Side Effects
  /// - Sets [AuthState.isLoading] during operation
  /// - User data is loaded via auth state listener on success
  /// - Sets [AuthState.error] on failure (not on cancellation)
  ///
  /// ## Example
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signInWithGoogle();
  /// if (success) {
  ///   // Navigation handled by auth state listener
  /// }
  /// ```
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final success = await _repository.signInWithGoogle();

      if (!success) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return false;
      }

      // User data will be loaded via auth state listener
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Signs in using Magic Link (passwordless authentication).
  ///
  /// Sends a magic link to the user's email for passwordless login.
  /// When the user clicks the link, they are automatically signed in.
  ///
  /// ## Parameters
  /// - [email]: The email address to send the magic link to
  ///
  /// ## Returns
  /// `true` if magic link was sent, `false` if it failed.
  ///
  /// ## Side Effects
  /// - Sets [AuthState.isLoading] during operation
  /// - Sets [AuthState.error] on failure
  ///
  /// ## Example
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signInWithMagicLink(
  ///   email: 'user@example.com',
  /// );
  /// if (success) {
  ///   showMessage('Check your email!');
  /// }
  /// ```
  Future<bool> signInWithMagicLink({required String email}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final success = await _repository.signInWithMagicLink(email: email);

      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clears the current error message.
  ///
  /// Call this method before attempting a new operation to reset
  /// the error state, or when the user dismisses an error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refreshes the current user's data from the database.
  ///
  /// Useful after profile updates or when the user returns to
  /// the app and may have updated data.
  ///
  /// ## Example
  /// ```dart
  /// await ref.read(authProvider.notifier).refreshUser();
  /// ```
  Future<void> refreshUser() async {
    final currentUser = _repository.getCurrentUser();
    if (currentUser != null) {
      await _loadUserData(currentUser);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Main provider for authentication state.
///
/// Provides access to the complete [AuthState] and [AuthNotifier] for
/// performing authentication operations.
///
/// ## Usage
/// ```dart
/// // Watch state in a widget
/// final authState = ref.watch(authProvider);
///
/// // Perform operations
/// ref.read(authProvider.notifier).signIn(...);
/// ```
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Provider for the currently authenticated user.
///
/// Returns the [UserModel] if authenticated, `null` otherwise.
/// This is a convenience provider that extracts the user from [authProvider].
///
/// ## Usage
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   Text('Hello, ${user.displayName}');
/// }
/// ```
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for the authentication loading state.
///
/// Returns `true` when an auth operation is in progress.
/// Use this to show loading indicators or disable form inputs.
///
/// ## Usage
/// ```dart
/// final isLoading = ref.watch(authLoadingProvider);
/// PrimaryButton(
///   onPressed: isLoading ? null : handleSubmit,
///   isLoading: isLoading,
/// );
/// ```
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Provider for the current authentication error.
///
/// Returns the error message string if an error occurred,
/// `null` otherwise.
///
/// ## Usage
/// ```dart
/// final error = ref.watch(authErrorProvider);
/// if (error != null) {
///   showSnackBar(error);
/// }
/// ```
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// Provider for checking if a user is authenticated.
///
/// Returns `true` if a user is signed in, `false` otherwise.
///
/// ## Usage
/// ```dart
/// final isAuthenticated = ref.watch(isAuthenticatedProvider);
/// return isAuthenticated ? DashboardScreen() : LoginScreen();
/// ```
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for checking supervisor activation status.
///
/// Returns `true` if the user is an activated supervisor.
/// Non-activated supervisors have restricted access.
///
/// ## Usage
/// ```dart
/// final isActivated = ref.watch(isActivatedProvider);
/// if (!isActivated) {
///   return ActivationPendingScreen();
/// }
/// ```
final isActivatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isActivated;
});

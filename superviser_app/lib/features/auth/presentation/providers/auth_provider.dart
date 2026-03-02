/// {@template auth_provider}
/// State management for authentication in the Superviser App.
///
/// This file contains the [AuthState] class and [AuthNotifier] state notifier
/// that manage the complete authentication lifecycle, as well as convenient
/// Riverpod providers for accessing auth-related data.
///
/// ## Providers
/// - [authProvider]: Main provider for [AuthState]
/// - [currentUserProvider]: Quick access to current [UserModel]
/// - [authLoadingProvider]: Loading state indicator
/// - [authErrorProvider]: Current error message
/// - [isAuthenticatedProvider]: Boolean auth status
/// - [isActivatedProvider]: Supervisor activation status
/// {@endtemplate}
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// {@template auth_state}
/// Immutable state class representing the current authentication status.
/// {@endtemplate}
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isActivated = false,
  });

  /// The currently authenticated user.
  final UserModel? user;

  /// Indicates whether an authentication operation is in progress.
  final bool isLoading;

  /// Error message from the last failed authentication operation.
  final String? error;

  /// Indicates whether the user is an activated supervisor.
  final bool isActivated;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => user != null;

  /// Creates an initial loading state for app startup.
  factory AuthState.initial() => const AuthState(isLoading: true);

  /// Creates a copy of this [AuthState] with the specified fields updated.
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
/// Handles session recovery on startup, sign in/sign up/sign out,
/// and user data loading. Uses token-based session management via
/// TokenStorage and the Express API.
/// {@endtemplate}
class AuthNotifier extends StateNotifier<AuthState> {
  /// Creates an [AuthNotifier] with the given repository.
  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
  }

  /// The repository used for all authentication operations.
  final AuthRepository _repository;

  /// Initializes authentication state with session recovery.
  ///
  /// Checks for stored tokens and validates the session
  /// against the API. If valid, loads user data.
  Future<void> _init() async {
    try {
      // Try to recover session from stored tokens
      final user = await _repository.recoverSession();

      if (user != null) {
        await _loadUserData(user);
      } else {
        state = const AuthState();
      }
    } catch (e) {
      debugPrint('Auth init failed: $e');
      state = const AuthState();
    }
  }

  /// Loads complete user data from the API.
  ///
  /// Fetches the user's profile and supervisor activation status.
  /// Profile fetch failures don't block activation status.
  Future<void> _loadUserData(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Check if user is an activated supervisor
      bool isActivated = false;
      try {
        isActivated = await _repository.isActivatedSupervisor(user.id);
      } catch (e) {
        debugPrint('Activation check failed: $e');
      }

      // Fetch profile data (non-blocking)
      UserModel? profile;
      try {
        profile = await _repository.fetchUserProfile(user.id);
      } catch (e) {
        debugPrint('Profile fetch failed: $e');
      }

      state = state.copyWith(
        user: profile ?? user,
        isActivated: isActivated,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('_loadUserData failed: $e');
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: 'Failed to load user data',
      );
    }
  }

  /// Signs in a user with email and password.
  ///
  /// Returns `true` if sign in succeeded, `false` if it failed.
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
  /// Returns `true` if registration succeeded, `false` if it failed.
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
  /// Returns `true` if the email was sent, `false` on failure.
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
  /// Returns `true` if sign in succeeded, `false` if cancelled or failed.
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final success = await _repository.signInWithGoogle();

      if (!success) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Fetch user data after successful Google sign-in
      final user = await _repository.getCurrentUser();
      if (user != null) {
        await _loadUserData(user);
      } else {
        state = state.copyWith(isLoading: false);
      }

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
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refreshes the current user's data from the API.
  Future<void> refreshUser() async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser != null) {
      await _loadUserData(currentUser);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Main provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Provider for the currently authenticated user.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider for the authentication loading state.
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Provider for the current authentication error.
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// Provider for checking if a user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for checking supervisor activation status.
final isActivatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isActivated;
});

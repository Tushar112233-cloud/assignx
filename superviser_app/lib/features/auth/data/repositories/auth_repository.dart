/// {@template auth_repository}
/// Repository for handling all authentication operations in the Superviser App.
///
/// This repository provides a clean abstraction layer over the Express API
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
/// ## Usage
/// ```dart
/// final authRepo = ref.watch(authRepositoryProvider);
///
/// try {
///   final user = await authRepo.signInWithEmail(
///     email: 'user@example.com',
///     password: 'securePassword123',
///   );
///   print('Welcome, ${user.displayName}!');
/// } on AppAuthException catch (e) {
///   print('Login failed: ${e.message}');
/// }
/// ```
/// {@endtemplate}
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/api/api_client.dart' hide ApiException;
import '../../../../core/config/constants.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

/// {@macro auth_repository}
class AuthRepository {
  /// Creates an [AuthRepository].
  AuthRepository();

  /// Signs in a user with email and password credentials.
  ///
  /// Authenticates the user against the Express API using the provided
  /// [email] and [password]. Returns a [UserModel] on successful
  /// authentication.
  ///
  /// ## Throws
  /// - [AppAuthException] if authentication fails
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response == null) {
        throw const AppAuthException('Login failed. Please try again.');
      }

      // Save tokens
      final accessToken = response['accessToken'] as String? ??
          response['access_token'] as String? ?? '';
      final refreshToken = response['refreshToken'] as String? ??
          response['refresh_token'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await TokenStorage.saveTokens(accessToken, refreshToken);
      }

      // Extract user data from response
      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw const AppAuthException('Login failed. No user data returned.');
      }

      return UserModel.fromJson(userData);
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Registers a new user with email and password.
  ///
  /// ## Throws
  /// - [AppAuthException] if registration fails
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
      };
      if (fullName != null) body['full_name'] = fullName;

      final response = await ApiClient.post('/auth/register', body);

      if (response == null) {
        throw const AppAuthException('Sign up failed. Please try again.');
      }

      // Save tokens if provided
      final accessToken = response['accessToken'] as String? ??
          response['access_token'] as String? ?? '';
      final refreshToken = response['refreshToken'] as String? ??
          response['refresh_token'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await TokenStorage.saveTokens(accessToken, refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw const AppAuthException('Sign up failed. No user data returned.');
      }

      return UserModel.fromJson(userData);
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Signs out the currently authenticated user.
  ///
  /// Clears stored tokens and invalidates the session.
  Future<void> signOut() async {
    try {
      try {
        await ApiClient.post('/auth/logout');
      } catch (_) {
        // Server logout may fail, but we still clear local tokens
      }
      await TokenStorage.clearTokens();
    } catch (e) {
      // Always clear tokens even if API call fails
      await TokenStorage.clearTokens();
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to sign out: $e');
    }
  }

  /// Sends a password reset email to the specified address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await ApiClient.post('/auth/forgot-password', {'email': email});
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to send reset email: $e');
    }
  }

  /// Updates the current user's password.
  Future<void> updatePassword(String newPassword) async {
    try {
      await ApiClient.put('/auth/update-password', {
        'password': newPassword,
      });
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to update password: $e');
    }
  }

  /// Gets the currently authenticated user from the API.
  ///
  /// Makes a network request to validate the token and get current user data.
  /// Returns `null` if not authenticated or token is invalid.
  Future<UserModel?> getCurrentUser() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) return null;

      final response = await ApiClient.get('/auth/me');
      if (response == null) return null;

      // API returns { profile: {...}, roleData: {...} } or { user: {...} }
      final userData = response['user'] as Map<String, dynamic>?
          ?? response['profile'] as Map<String, dynamic>?
          ?? response;
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('getCurrentUser failed: $e');
      return null;
    }
  }

  /// Checks if tokens exist in secure storage.
  ///
  /// This is a fast synchronous-ish check for session existence.
  Future<bool> hasSession() async {
    return TokenStorage.hasTokens();
  }

  /// Recovers and validates the persisted session.
  ///
  /// Checks if tokens exist and validates them against the API.
  /// Returns a [UserModel] if the session is valid, null otherwise.
  Future<UserModel?> recoverSession() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) return null;

      // Validate the token by fetching current user
      return await getCurrentUser();
    } catch (e) {
      debugPrint('Session recovery failed: $e');
      return null;
    }
  }

  /// Checks if the user has valid tokens stored.
  Future<bool> isAuthenticated() async {
    return TokenStorage.hasTokens();
  }

  /// Fetches the user's profile from the API.
  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId');
      if (response == null) return null;

      // API returns { profile: {...} } — unwrap if needed
      final data = response is Map<String, dynamic>
          ? (response['profile'] as Map<String, dynamic>? ?? response)
          : response as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } on ApiException catch (e) {
      throw ServerException(e.message, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch profile: $e', null);
    }
  }

  /// Fetches supervisor-specific data.
  Future<Map<String, dynamic>?> fetchSupervisorData(String userId) async {
    try {
      final response = await ApiClient.get('/supervisors/$userId');
      return response as Map<String, dynamic>?;
    } on ApiException catch (e) {
      throw ServerException(e.message, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch supervisor data: $e', null);
    }
  }

  /// Checks if the user is an activated supervisor.
  Future<bool> isActivatedSupervisor(String userId) async {
    try {
      final response = await ApiClient.get('/supervisors/$userId/activation-status');
      if (response == null) return false;
      return (response['isActivated'] ?? response['is_activated']) as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Signs in using Google OAuth.
  ///
  /// Initiates the native Google Sign-In flow, then exchanges the
  /// Google ID token with the Express API for a session.
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
        return false; // User cancelled
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AppAuthException('Missing idToken from Google authentication');
      }

      // Exchange Google token with Express API
      final response = await ApiClient.post('/auth/google', {
        'idToken': idToken,
        'accessToken': googleAuth.accessToken,
      });

      if (response == null) return false;

      // Save tokens from API response
      final accessToken = response['accessToken'] as String? ??
          response['access_token'] as String? ?? '';
      final refreshToken = response['refreshToken'] as String? ??
          response['refresh_token'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await TokenStorage.saveTokens(accessToken, refreshToken);
      }

      return true;
    } on AppAuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException('Google sign-in failed: $e');
    }
  }

  /// Signs in using Magic Link (passwordless authentication).
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await ApiClient.post('/auth/magic-link', {
        'email': email,
        if (redirectTo != null) 'redirectTo': redirectTo,
      });

      return true;
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to send magic link: $e');
    }
  }
}

/// Riverpod provider for [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

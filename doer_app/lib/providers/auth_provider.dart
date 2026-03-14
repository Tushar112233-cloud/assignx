/// Authentication state management provider for the Dolancer App.
///
/// This file contains the core authentication logic including user sign-up,
/// sign-in, sign-out, profile management, and session handling. It integrates
/// with Supabase for backend authentication services.
///
/// ## Architecture
///
/// The authentication system follows a layered architecture:
/// - **Provider Layer**: [AuthNotifier] manages state and exposes methods
/// - **Repository Layer**: [AuthRepository] handles data operations
/// - **Model Layer**: [UserModel] represents user data
///
/// ## Usage
///
/// ```dart
/// // Watch authentication state in a widget
/// final authState = ref.watch(authProvider);
///
/// // Check if user is authenticated
/// if (authState.isAuthenticated) {
///   // Access user data
///   final user = authState.user;
/// }
///
/// // Perform sign-in
/// final success = await ref.read(authProvider.notifier).signIn(
///   email: 'user@example.com',
///   password: 'password123',
/// );
///
/// // Sign out
/// await ref.read(authProvider.notifier).signOut();
/// ```
///
/// ## State Flow
///
/// ```
/// initial -> loading -> authenticated/unauthenticated -> error
///                           |
///                           v
///                    profile setup -> bank details -> activated
/// ```
///
/// ## Error Handling
///
/// Authentication errors are captured in [AuthState.errorMessage] and the
/// status is set to [AuthStatus.error]. Use [AuthNotifier.clearError] to
/// reset the error state.
///
/// See also:
/// - [AuthRepository] for data layer operations
/// - [UserModel] for the user data structure
/// - [ActivationNotifier] for doer activation flow
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../data/models/doer_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// Re-export for convenience
export '../data/repositories/auth_repository.dart' show ProfileSetupData, BankDetailsFormData;
export '../data/models/doer_model.dart' show SkillModel, SubjectModel;

/// Provides the [AuthRepository] instance for dependency injection.
///
/// This provider creates a singleton instance of [SupabaseAuthRepository]
/// that handles all authentication-related data operations.
///
/// ## Usage
///
/// ```dart
/// final repository = ref.read(authRepositoryProvider);
/// final skills = await repository.getAvailableSkills();
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});

/// Enumeration of possible authentication states.
///
/// Used by [AuthState] to represent the current authentication status
/// of the user in the application.
///
/// ## States
///
/// - [initial]: App just started, auth state unknown
/// - [loading]: Authentication operation in progress
/// - [authenticated]: User is logged in with valid session
/// - [unauthenticated]: No active user session
/// - [error]: Authentication operation failed
enum AuthStatus {
  /// Initial state when the app starts before checking authentication.
  initial,

  /// Loading state during authentication operations.
  loading,

  /// User is authenticated with a valid session.
  authenticated,

  /// User is not authenticated or session expired.
  unauthenticated,

  /// An error occurred during authentication.
  error,
}

/// Immutable state class representing the current authentication state.
///
/// Contains the authentication status, user data, and any error messages.
/// This class is used by [AuthNotifier] to manage and expose auth state.
///
/// ## Properties
///
/// - [status]: Current [AuthStatus] of the user
/// - [user]: The authenticated [UserModel] or null if not logged in
/// - [errorMessage]: Error message if an operation failed
///
/// ## Usage
///
/// ```dart
/// final authState = ref.watch(authProvider);
///
/// if (authState.isLoading) {
///   return LoadingIndicator();
/// }
///
/// if (authState.isAuthenticated) {
///   return HomeScreen(user: authState.user!);
/// }
///
/// return LoginScreen(error: authState.errorMessage);
/// ```
class AuthState {
  /// The current authentication status.
  ///
  /// Defaults to [AuthStatus.initial] when the state is first created.
  final AuthStatus status;

  /// The currently authenticated user, or null if not logged in.
  ///
  /// This contains the full [UserModel] including profile information,
  /// doer details, and activation status when available.
  final UserModel? user;

  /// Error message from the last failed operation, or null if no error.
  ///
  /// This is cleared when a new operation begins or when
  /// [AuthNotifier.clearError] is called.
  final String? errorMessage;

  /// Creates a new [AuthState] instance.
  ///
  /// All parameters are optional with sensible defaults:
  /// - [status] defaults to [AuthStatus.initial]
  /// - [user] defaults to null
  /// - [errorMessage] defaults to null
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Creates a copy of this state with the specified fields replaced.
  ///
  /// This method is used to create new immutable state instances when
  /// the authentication state changes.
  ///
  /// Note: [errorMessage] is always replaced (not merged) to allow clearing.
  ///
  /// ## Parameters
  ///
  /// - [status]: New authentication status
  /// - [user]: New user model
  /// - [errorMessage]: New error message (pass null to clear)
  ///
  /// ## Returns
  ///
  /// A new [AuthState] instance with the specified changes.
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  /// Whether the user is currently authenticated.
  ///
  /// Returns true if [status] is [AuthStatus.authenticated].
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether an authentication operation is in progress.
  ///
  /// Returns true if [status] is [AuthStatus.loading].
  bool get isLoading => status == AuthStatus.loading;
}

/// Notifier class that manages authentication state and operations.
///
/// This class handles all authentication-related operations including:
/// - User registration and sign-in
/// - Session management and auto-refresh
/// - Profile creation and updates
/// - Bank details management
/// - OAuth sign-in (Google)
/// - Phone verification (OTP)
///
/// ## Lifecycle
///
/// The notifier is initialized when first accessed and sets up:
/// 1. Repository dependency injection
/// 2. Auth state change listener for Supabase
/// 3. Initial session check
///
/// ## State Management
///
/// State updates are performed through [state] assignment, triggering
/// reactive updates in all watching widgets.
///
/// ## Usage
///
/// ```dart
/// // Access the notifier for operations
/// final notifier = ref.read(authProvider.notifier);
///
/// // Sign up a new user
/// final success = await notifier.signUp(
///   email: 'user@example.com',
///   password: 'securePassword123',
///   fullName: 'John Doe',
///   phone: '+919876543210',
/// );
///
/// // Set up doer profile
/// await notifier.setupDoerProfile(ProfileSetupData(
///   qualification: 'B.Tech',
///   universityName: 'IIT Delhi',
///   experienceLevel: 'intermediate',
/// ));
/// ```
class AuthNotifier extends Notifier<AuthState> {
  /// The authentication repository for data operations.
  late AuthRepository _repository;

  /// Builds and initializes the authentication state.
  ///
  /// This method is called when the provider is first read. It:
  /// 1. Injects the [AuthRepository] dependency
  /// 2. Checks for an existing token-based session
  ///
  /// ## Returns
  ///
  /// The initial [AuthState] based on current session status:
  /// - [AuthStatus.loading] if tokens exist (profile fetch pending)
  /// - [AuthStatus.unauthenticated] if no tokens exist
  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    // Check for existing session via stored tokens
    Future.microtask(() => _checkExistingSession());

    return const AuthState(status: AuthStatus.loading);
  }

  /// Checks if stored tokens represent a valid session.
  Future<void> _checkExistingSession() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // Try to get the current user ID from the API
      final userId = await _repository.getCurrentUserId();
      if (userId != null) {
        await _fetchUserProfile(userId);
      } else {
        // Tokens are expired or invalid
        await TokenStorage.clearTokens();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      await TokenStorage.clearTokens();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Fetches the user profile from the database.
  ///
  /// Retrieves the complete user profile including doer information
  /// and updates the state accordingly.
  ///
  /// ## Parameters
  ///
  /// - [userId]: The Supabase user ID to fetch profile for
  ///
  /// ## State Updates
  ///
  /// On success: Sets status to [AuthStatus.authenticated] with user data
  /// On profile not found: Creates a basic [UserModel] from auth metadata
  Future<void> _fetchUserProfile(String userId) async {
    final user = await _repository.fetchUserProfile(userId);

    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      // User profile doesn't exist yet (new user) - create basic user model
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: userId,
          email: '',
          fullName: '',
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  /// Registers a new user account.
  ///
  /// Creates a new user in Supabase Auth and creates their profile
  /// in the database.
  ///
  /// ## Parameters
  ///
  /// - [email]: User's email address (must be unique)
  /// - [password]: Password (minimum 6 characters)
  /// - [fullName]: User's full name
  /// - [phone]: User's phone number with country code
  ///
  /// ## Returns
  ///
  /// `true` if registration was successful, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// - Sets status to [AuthStatus.loading] during operation
  /// - On success: [AuthStatus.authenticated] with new user
  /// - On failure: [AuthStatus.error] or [AuthStatus.unauthenticated]
  ///
  /// ## Throws
  ///
  /// Catches [supabase.AuthException] and generic exceptions,
  /// storing error messages in state.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signUp(
  ///   email: 'newuser@example.com',
  ///   password: 'SecurePass123',
  ///   fullName: 'New User',
  ///   phone: '+919876543210',
  /// );
  ///
  /// if (success) {
  ///   // Navigate to profile setup
  /// } else {
  ///   // Show error from authState.errorMessage
  /// }
  /// ```
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (response.hasSession && response.user != null) {
        final userId = (response.user!['_id'] ?? response.user!['id'] ?? '').toString();

        // Create profile in database
        await _repository.createProfile(
          userId: userId,
          email: email,
          fullName: fullName,
          phone: phone,
        );

        await _fetchUserProfile(userId);
        return true;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Registration failed',
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Signs in an existing user with email and password.
  ///
  /// Authenticates the user with Supabase and fetches their profile.
  ///
  /// ## Parameters
  ///
  /// - [email]: User's registered email address
  /// - [password]: User's password
  ///
  /// ## Returns
  ///
  /// `true` if sign-in was successful, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// - Sets status to [AuthStatus.loading] during operation
  /// - On success: [AuthStatus.authenticated] with user data
  /// - On failure: [AuthStatus.error] with error message
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signIn(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _repository.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.hasSession && response.user != null) {
        await _fetchUserProfile((response.user!['_id'] ?? response.user!['id'] ?? '').toString());
        return true;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign in failed',
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Signs out the current user.
  ///
  /// Ends the user's session and clears all authentication state.
  /// For security, local state is cleared even if the server request fails.
  ///
  /// ## State Updates
  ///
  /// Always sets status to [AuthStatus.unauthenticated] after completion.
  /// May include an error message if server sign-out failed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await ref.read(authProvider.notifier).signOut();
  /// // Navigate to login screen
  /// ```
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Force local logout even on error for security
      // User data should not persist if sign-out was attempted
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Sign out had issues. Please restart the app if problems persist.',
      );
    }
  }

  /// Creates a doer profile with qualifications, skills, and subjects.
  ///
  /// This method is called during the activation flow to set up the user
  /// as a doer with their professional information.
  ///
  /// ## Parameters
  ///
  /// - [data]: [ProfileSetupData] containing qualification details
  ///
  /// ## Returns
  ///
  /// `true` if profile setup was successful, `false` otherwise.
  ///
  /// ## Prerequisites
  ///
  /// User must be authenticated ([state.user] must not be null).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).setupDoerProfile(
  ///   ProfileSetupData(
  ///     qualification: 'M.Tech',
  ///     universityName: 'IIT Bombay',
  ///     experienceLevel: 'advanced',
  ///     yearsOfExperience: 5,
  ///     bio: 'Expert in machine learning and data science',
  ///     skills: ['Python', 'TensorFlow'],
  ///     subjects: ['Computer Science', 'Mathematics'],
  ///   ),
  /// );
  /// ```
  Future<bool> setupDoerProfile(ProfileSetupData data) async {
    if (state.user == null) return false;

    try {
      final doerId = await _repository.createDoerProfile(
        profileId: state.user!.id,
        data: data,
      );

      // Refresh user profile
      await _fetchUserProfile(state.user!.id);

      // Update local state with new doer info
      if (state.user != null) {
        state = state.copyWith(
          user: state.user!.copyWith(
            doerId: doerId,
            qualification: data.qualification,
            universityName: data.universityName,
            experienceLevel: data.experienceLevel,
            yearsOfExperience: data.yearsOfExperience,
            bio: data.bio,
          ),
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier.setupDoerProfile error: $e');
      }
      return false;
    }
  }

  /// Updates an existing doer profile.
  ///
  /// Modifies the doer's qualification, skills, and other professional
  /// information.
  ///
  /// ## Parameters
  ///
  /// - [data]: [ProfileSetupData] with updated information
  ///
  /// ## Returns
  ///
  /// `true` if update was successful, `false` otherwise.
  ///
  /// ## Prerequisites
  ///
  /// User must have an existing doer profile ([state.user?.doerId] must not be null).
  Future<bool> updateDoerProfile(ProfileSetupData data) async {
    if (state.user?.doerId == null) return false;

    try {
      await _repository.updateDoerProfile(state.user!.doerId!, data);

      // Refresh user profile
      await _fetchUserProfile(state.user!.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier.updateDoerProfile error: $e');
      }
      return false;
    }
  }

  /// Updates the user's bank account details.
  ///
  /// Saves bank information required for payment disbursement.
  ///
  /// ## Parameters
  ///
  /// - [data]: [BankDetailsFormData] containing bank account information
  ///
  /// ## Returns
  ///
  /// `true` if update was successful, `false` otherwise.
  ///
  /// ## Prerequisites
  ///
  /// User must have an existing doer profile.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).updateBankDetails(
  ///   BankDetailsFormData(
  ///     accountHolderName: 'John Doe',
  ///     accountNumber: '1234567890',
  ///     ifscCode: 'SBIN0001234',
  ///     bankName: 'State Bank of India',
  ///     upiId: 'john@upi',
  ///   ),
  /// );
  /// ```
  Future<bool> updateBankDetails(BankDetailsFormData data) async {
    if (state.user?.doerId == null) return false;

    try {
      await _repository.updateBankDetails(state.user!.doerId!, data);

      // Update local state
      state = state.copyWith(
        user: state.user!.copyWith(
          bankAccountName: data.accountHolderName,
          bankAccountNumber: data.accountNumber,
          bankIfscCode: data.ifscCode,
          bankName: data.bankName,
          upiId: data.upiId,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves all available skills from the database.
  ///
  /// Used during profile setup to let users select their skills.
  ///
  /// ## Returns
  ///
  /// A list of [SkillModel] objects representing available skills.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final skills = await ref.read(authProvider.notifier).getAvailableSkills();
  /// // Display skills in a multi-select widget
  /// ```
  Future<List<SkillModel>> getAvailableSkills() async {
    return await _repository.getAvailableSkills();
  }

  /// Retrieves all available subjects from the database.
  ///
  /// Used during profile setup to let users select their expertise areas.
  ///
  /// ## Returns
  ///
  /// A list of [SubjectModel] objects representing available subjects.
  Future<List<SubjectModel>> getAvailableSubjects() async {
    return await _repository.getAvailableSubjects();
  }

  /// Sends an OTP to the specified email address.
  ///
  /// ## Parameters
  ///
  /// - [email]: Email address to send OTP to
  /// - [purpose]: Either 'login' or 'signup'
  ///
  /// ## Returns
  ///
  /// `true` if OTP was sent successfully, `false` otherwise.
  Future<bool> sendOtp(String email, {String purpose = 'login'}) async {
    try {
      await _repository.sendOtp(email, purpose: purpose);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier.sendOtp error: $e');
      }
      state = state.copyWith(errorMessage: 'Connection error. Please check your network.');
      return false;
    }
  }

  /// Verifies the OTP entered by the user.
  ///
  /// ## Parameters
  ///
  /// - [email]: The email address the OTP was sent to
  /// - [otp]: The OTP entered by the user
  /// - [purpose]: Either 'login' or 'signup'
  ///
  /// ## Returns
  ///
  /// `true` if OTP verification was successful, `false` otherwise.
  Future<bool> verifyOtp(String email, String otp, {String purpose = 'login'}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _repository.verifyOtp(email, otp, purpose: purpose);
      if (response.hasSession && response.user != null) {
        final userId = (response.user!['_id'] ?? response.user!['id'] ?? '').toString();
        await _fetchUserProfile(userId);
        return true;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'OTP verification failed',
      );
      return false;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier.verifyOtp error: $e');
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'OTP verification failed. Please try again.',
      );
      return false;
    }
  }

  /// Clears any error message from the state.
  ///
  /// Use this method to reset the error state after displaying
  /// an error message to the user.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // After showing error snackbar
  /// ref.read(authProvider.notifier).clearError();
  /// ```
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Signs in using Google OAuth.
  ///
  /// Opens Google sign-in flow and authenticates the user.
  /// The auth state listener handles session updates.
  ///
  /// ## Returns
  ///
  /// `true` if sign-in was initiated successfully, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// - Sets status to [AuthStatus.loading] during operation
  /// - On cancellation: [AuthStatus.unauthenticated] with message
  /// - On error: [AuthStatus.error] with descriptive message
  ///
  /// ## Notes
  ///
  /// Requires proper configuration of:
  /// - Google Cloud Console OAuth credentials
  /// - SHA-1 fingerprint in Firebase/Google Console
  /// - Supabase Google OAuth provider settings
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signInWithGoogle();
  /// ```
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final success = await _repository.signInWithGoogle();
      if (!success) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Google sign-in was cancelled',
        );
      }
      // Auth state listener will handle the session update
      return success;
    } catch (e) {
      String errorMessage = 'Google sign-in failed';
      if (e.toString().contains('GOOGLE_WEB_CLIENT_ID')) {
        errorMessage = 'Google Sign-In not configured. Please contact support.';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Google sign-in configuration error. Check SHA-1 fingerprint.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  /// Signs in with magic link (passwordless email authentication).
  ///
  /// Sends a magic link to the provided email address. The user clicks
  /// the link in their email to complete authentication without a password.
  ///
  /// ## Parameters
  ///
  /// - [email]: Email address to send the magic link to
  ///
  /// ## Returns
  ///
  /// `true` if the magic link was sent successfully, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// - Sets status to [AuthStatus.loading] during operation
  /// - On success: [AuthStatus.unauthenticated] (waiting for link click)
  /// - On error: [AuthStatus.error] with descriptive message
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).signInWithMagicLink(
  ///   email: 'user@example.com',
  /// );
  /// if (success) {
  ///   // Show message to check email
  /// }
  /// ```
  Future<bool> signInWithMagicLink({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final success = await _repository.signInWithMagicLink(email: email);

      // After sending, keep state as unauthenticated (user needs to click link)
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      );

      return success;
    } catch (e) {
      String errorMessage = 'Failed to send magic link';
      if (e.toString().contains('rate limit')) {
        errorMessage = 'Too many attempts. Please try again later.';
      } else if (e.toString().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  /// Refreshes the current user's profile from the database.
  ///
  /// Use this method to sync local state with server after external changes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // After profile update on another device
  /// await ref.read(authProvider.notifier).refreshProfile();
  /// ```
  Future<void> refreshProfile() async {
    if (state.user != null) {
      await _fetchUserProfile(state.user!.id);
    }
  }

  /// Sends a password reset email to the specified address.
  ///
  /// Initiates the password reset flow by sending a reset link via email.
  /// The user will receive an email with a link to reset their password.
  ///
  /// ## Parameters
  ///
  /// - [email]: Email address to send the reset link to
  ///
  /// ## Returns
  ///
  /// `true` if the reset email was sent successfully, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// - Does not change authentication state (user remains unauthenticated)
  /// - On error: Sets [AuthState.errorMessage] with descriptive message
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(authProvider.notifier).resetPassword(
  ///   email: 'user@example.com',
  /// );
  /// if (success) {
  ///   // Show success message to check email
  /// } else {
  ///   // Show error from authState.errorMessage
  /// }
  /// ```
  Future<bool> resetPassword({required String email}) async {
    try {
      await _repository.resetPasswordForEmail(email);
      // Clear any previous error messages
      state = state.copyWith(errorMessage: null);
      return true;
    } on ApiException catch (e) {
      String errorMessage = 'Failed to send reset email';
      if (e.message.toLowerCase().contains('rate limit')) {
        errorMessage = 'Too many attempts. Please try again later.';
      } else if (e.message.toLowerCase().contains('invalid')) {
        errorMessage = 'Please enter a valid email address.';
      } else {
        errorMessage = e.message;
      }
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      return false;
    }
  }
}

/// The main authentication provider.
///
/// Use this provider to access authentication state and perform auth operations.
///
/// ## Watching State
///
/// ```dart
/// // In a widget
/// final authState = ref.watch(authProvider);
///
/// return switch (authState.status) {
///   AuthStatus.loading => LoadingScreen(),
///   AuthStatus.authenticated => HomeScreen(),
///   AuthStatus.unauthenticated => LoginScreen(),
///   _ => ErrorScreen(authState.errorMessage),
/// };
/// ```
///
/// ## Performing Operations
///
/// ```dart
/// // Access notifier for operations
/// await ref.read(authProvider.notifier).signIn(
///   email: email,
///   password: password,
/// );
/// ```
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Convenience provider for accessing the current user.
///
/// Returns the [UserModel] if authenticated, null otherwise.
///
/// ## Usage
///
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   Text('Welcome, ${user.fullName}');
/// }
/// ```
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience provider for accessing the current authentication status.
///
/// ## Usage
///
/// ```dart
/// final status = ref.watch(authStatusProvider);
/// if (status == AuthStatus.loading) {
///   return CircularProgressIndicator();
/// }
/// ```
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

/// Convenience provider for checking if the user is authenticated.
///
/// Returns `true` if the user has an active session, `false` otherwise.
///
/// ## Usage
///
/// ```dart
/// final isLoggedIn = ref.watch(isAuthenticatedProvider);
/// return isLoggedIn ? HomeScreen() : LoginScreen();
/// ```
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider for fetching available skills asynchronously.
///
/// Returns a [Future] that resolves to a list of [SkillModel].
/// The result is cached until invalidated.
///
/// ## Usage
///
/// ```dart
/// final skillsAsync = ref.watch(availableSkillsProvider);
///
/// return skillsAsync.when(
///   data: (skills) => SkillsList(skills: skills),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => ErrorWidget(e.toString()),
/// );
/// ```
final availableSkillsProvider = FutureProvider<List<SkillModel>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getAvailableSkills();
});

/// Provider for fetching available subjects asynchronously.
///
/// Returns a [Future] that resolves to a list of [SubjectModel].
/// The result is cached until invalidated.
///
/// ## Usage
///
/// ```dart
/// final subjectsAsync = ref.watch(availableSubjectsProvider);
///
/// return subjectsAsync.when(
///   data: (subjects) => SubjectsList(subjects: subjects),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => ErrorWidget(e.toString()),
/// );
/// ```
final availableSubjectsProvider = FutureProvider<List<SubjectModel>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getAvailableSubjects();
});

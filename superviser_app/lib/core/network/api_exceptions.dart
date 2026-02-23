/// API exception classes for the Superviser App.
///
/// This file provides a comprehensive exception hierarchy for handling
/// various error scenarios in network operations. All exceptions extend
/// from [ApiException] and provide user-friendly error messages.
///
/// ## Exception Hierarchy
///
/// ```
/// ApiException (sealed base class)
///     |
///     +-- AppAuthException (authentication errors)
///     +-- NetworkException (connectivity issues)
///     +-- ServerException (backend errors)
///     +-- NotFoundException (missing resources)
///     +-- ValidationException (input validation)
///     +-- StorageException (file storage errors)
///     +-- CancelledException (user cancellation)
/// ```
///
/// ## Usage
///
/// ```dart
/// try {
///   await authRepository.signIn(email, password);
/// } on AppAuthException catch (e) {
///   showSnackBar(e.userMessage);
/// } on NetworkException catch (e) {
///   showOfflineDialog();
/// } on ApiException catch (e) {
///   // Catch-all for other API errors
///   showErrorDialog(e.userMessage);
/// }
/// ```
///
/// ## Error Mapping
///
/// Supabase-specific errors are automatically mapped to user-friendly
/// messages using factory constructors like [AppAuthException.fromSupabase]
/// and [ServerException.fromPostgrest].
///
/// See also:
/// - [SupabaseService] for the Supabase client
/// - [handleSupabaseError] for convenient error handling
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all API exceptions in the application.
///
/// This is a sealed class, meaning all subclasses are defined in this file.
/// This allows exhaustive pattern matching in `switch` statements.
///
/// ## Properties
///
/// - [message]: Technical error message for debugging
/// - [originalError]: The original error object that caused this exception
/// - [userMessage]: User-friendly message suitable for display in UI
///
/// ## Example
///
/// ```dart
/// void handleError(ApiException e) {
///   switch (e) {
///     case AppAuthException():
///       // Handle auth error
///       break;
///     case NetworkException():
///       // Handle network error
///       break;
///     case ServerException():
///       // Handle server error
///       break;
///     // ... other cases
///   }
/// }
/// ```
sealed class ApiException implements Exception {
  /// Creates an API exception with the given message.
  ///
  /// - [message]: A description of the error
  /// - [originalError]: Optional original error that caused this exception
  const ApiException(this.message, [this.originalError]);

  /// The error message describing what went wrong.
  final String message;

  /// The original error object that caused this exception.
  ///
  /// This is useful for debugging and logging the root cause of errors.
  final Object? originalError;

  /// Returns a user-friendly error message suitable for display in the UI.
  ///
  /// By default, this returns [message]. Subclasses may override this to
  /// provide more context-appropriate messages.
  String get userMessage => message;

  @override
  String toString() => message;
}

/// Exception thrown when authentication operations fail.
///
/// This exception handles errors from Supabase Auth, including:
/// - Invalid credentials
/// - Email not verified
/// - User already exists
/// - Rate limiting
///
/// ## Factory Constructor
///
/// Use [AppAuthException.fromSupabase] to automatically map Supabase
/// auth errors to user-friendly messages.
///
/// ## Example
///
/// ```dart
/// try {
///   await supabase.auth.signInWithPassword(email: email, password: password);
/// } on AuthApiException catch (e) {
///   throw AppAuthException.fromSupabase(e);
/// }
/// ```
class AppAuthException extends ApiException {
  /// Creates an authentication exception with the given message.
  const AppAuthException(super.message, [super.originalError]);

  /// Creates an authentication exception from a Supabase [AuthApiException].
  ///
  /// This factory maps common Supabase auth error messages to user-friendly
  /// alternatives that are suitable for display in the UI.
  ///
  /// ## Mapped Errors
  ///
  /// | Supabase Error | User Message |
  /// |---------------|--------------|
  /// | Invalid login credentials | Invalid email or password. Please try again. |
  /// | Email not confirmed | Please verify your email address to continue. |
  /// | User already registered | An account with this email already exists. |
  /// | Password should be... | Password must be at least 8 characters long. |
  /// | rate limit | Too many attempts. Please wait and try again. |
  factory AppAuthException.fromSupabase(AuthApiException e) {
    return AppAuthException(_mapAuthError(e.message), e);
  }

  /// Maps Supabase auth error messages to user-friendly alternatives.
  static String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email address to continue.';
    }
    if (message.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('Password should be')) {
      return 'Password must be at least 8 characters long.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return message;
  }
}

/// Exception thrown when network connectivity fails.
///
/// This exception represents errors related to network connectivity,
/// including no internet connection and request timeouts.
///
/// ## Factory Constructors
///
/// - [NetworkException.noConnection]: No internet connectivity
/// - [NetworkException.timeout]: Request timed out
///
/// ## Example
///
/// ```dart
/// try {
///   await fetchData();
/// } on SocketException {
///   throw NetworkException.noConnection();
/// } on TimeoutException {
///   throw NetworkException.timeout();
/// }
/// ```
class NetworkException extends ApiException {
  /// Creates a network exception with the given message.
  const NetworkException(super.message, [super.originalError]);

  /// Creates a network exception indicating no internet connection.
  ///
  /// Use this when the device cannot reach the network.
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection. Please check your network.',
    );
  }

  /// Creates a network exception indicating a request timeout.
  ///
  /// Use this when a request takes too long to complete.
  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out. Please try again.',
    );
  }
}

/// Exception thrown when the server returns an error response.
///
/// This exception represents errors from the Supabase backend, including
/// database errors, permission issues, and constraint violations.
///
/// ## Properties
///
/// - [statusCode]: HTTP status code, if available
///
/// ## Factory Constructor
///
/// Use [ServerException.fromPostgrest] to automatically map Postgrest
/// database errors to user-friendly messages.
///
/// ## Example
///
/// ```dart
/// try {
///   await supabase.from('users').insert(data);
/// } on PostgrestException catch (e) {
///   throw ServerException.fromPostgrest(e);
/// }
/// ```
class ServerException extends ApiException {
  /// Creates a server exception with the given message and status code.
  const ServerException(super.message, this.statusCode, [super.originalError]);

  /// The HTTP status code returned by the server, if available.
  final int? statusCode;

  /// Creates a server exception from a Supabase [PostgrestException].
  ///
  /// This factory maps common Postgrest database error messages to
  /// user-friendly alternatives.
  ///
  /// ## Mapped Errors
  ///
  /// | Postgrest Error | User Message |
  /// |-----------------|--------------|
  /// | duplicate key | This record already exists. |
  /// | violates foreign key | Referenced record not found. |
  /// | permission denied | You do not have permission to perform this action. |
  factory ServerException.fromPostgrest(PostgrestException e) {
    return ServerException(
      _mapPostgrestError(e.message),
      int.tryParse(e.code ?? ''),
      e,
    );
  }

  /// Maps Postgrest error messages to user-friendly alternatives.
  static String _mapPostgrestError(String message) {
    if (message.contains('duplicate key')) {
      return 'This record already exists.';
    }
    if (message.contains('violates foreign key')) {
      return 'Referenced record not found.';
    }
    if (message.contains('permission denied')) {
      return 'You do not have permission to perform this action.';
    }
    return message;
  }
}

/// Exception thrown when a requested resource is not found.
///
/// This exception represents 404-style errors where the requested
/// data does not exist in the database.
///
/// ## Example
///
/// ```dart
/// final user = await supabase.from('users').select().eq('id', id).maybeSingle();
/// if (user == null) {
///   throw const NotFoundException('User not found');
/// }
/// ```
class NotFoundException extends ApiException {
  /// Creates a not found exception with an optional custom message.
  ///
  /// Defaults to 'Resource not found' if no message is provided.
  const NotFoundException([String message = 'Resource not found'])
      : super(message);
}

/// Exception thrown when input validation fails.
///
/// This exception represents client-side validation errors and can
/// include field-specific error messages for form validation.
///
/// ## Properties
///
/// - [errors]: Map of field names to error messages
///
/// ## Example
///
/// ```dart
/// if (!isValidEmail(email)) {
///   throw ValidationException(
///     'Invalid input',
///     {'email': 'Please enter a valid email address'},
///   );
/// }
/// ```
class ValidationException extends ApiException {
  /// Creates a validation exception with the given message and optional field errors.
  const ValidationException(super.message, [this.errors = const {}]);

  /// A map of field names to their validation error messages.
  ///
  /// This is useful for displaying inline validation errors in forms.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final exception = ValidationException('Validation failed', {
  ///   'email': 'Invalid email format',
  ///   'password': 'Password too short',
  /// });
  ///
  /// for (final entry in exception.errors.entries) {
  ///   print('${entry.key}: ${entry.value}');
  /// }
  /// ```
  final Map<String, String> errors;
}

/// Exception thrown when storage operations fail.
///
/// This exception handles errors from Supabase Storage, including
/// upload failures, download errors, and permission issues.
///
/// ## Factory Constructor
///
/// Use [StorageException.fromSupabase] to create an exception from
/// any Supabase storage error.
///
/// ## Example
///
/// ```dart
/// try {
///   await supabase.storage.from('avatars').upload(path, file);
/// } catch (e) {
///   throw StorageException.fromSupabase(e);
/// }
/// ```
class StorageException extends ApiException {
  /// Creates a storage exception with the given message.
  const StorageException(super.message, [super.originalError]);

  /// Creates a storage exception from a Supabase storage error.
  ///
  /// This factory handles various storage error types and extracts
  /// meaningful error messages.
  factory StorageException.fromSupabase(Object e) {
    if (e is StorageException) {
      return StorageException(e.message, e);
    }
    return StorageException(e.toString(), e);
  }
}

/// Exception thrown when an operation is cancelled by the user.
///
/// This exception represents intentional cancellation of an operation,
/// such as dismissing a dialog or navigating away during a request.
///
/// ## Example
///
/// ```dart
/// try {
///   await longRunningOperation(onCancel: () {
///     throw const CancelledException();
///   });
/// } on CancelledException {
///   // User cancelled, no error message needed
///   return;
/// }
/// ```
class CancelledException extends ApiException {
  /// Creates a cancellation exception with an optional custom message.
  ///
  /// Defaults to 'Operation cancelled' if no message is provided.
  const CancelledException([String message = 'Operation cancelled'])
      : super(message);
}

/// Handles common Supabase errors and throws appropriate [ApiException] subclasses.
///
/// This helper function simplifies error handling in repositories by
/// automatically mapping Supabase-specific exceptions to app exceptions.
///
/// ## Type Parameter
///
/// - [T]: The return type when using the [fallback] function
///
/// ## Parameters
///
/// - [error]: The caught error object to handle
/// - [fallback]: Optional function to call if the error is not a known Supabase error
///
/// ## Throws
///
/// - [AppAuthException] for [AuthApiException]
/// - [ServerException] for [PostgrestException]
/// - [ServerException] with generic message for unknown errors (if no fallback)
///
/// ## Example
///
/// ```dart
/// Future<User> getUser(String id) async {
///   try {
///     return await supabase.from('users').select().eq('id', id).single();
///   } catch (e) {
///     handleSupabaseError(e);
///   }
/// }
///
/// // With fallback
/// Future<User?> getUserOrNull(String id) async {
///   try {
///     return await supabase.from('users').select().eq('id', id).single();
///   } catch (e) {
///     return handleSupabaseError(e, fallback: () => null);
///   }
/// }
/// ```
T handleSupabaseError<T>(Object error, {T Function()? fallback}) {
  if (error is AuthApiException) {
    throw AppAuthException.fromSupabase(error);
  }
  if (error is PostgrestException) {
    throw ServerException.fromPostgrest(error);
  }
  if (fallback != null) {
    return fallback();
  }
  throw ServerException('An unexpected error occurred', null, error);
}

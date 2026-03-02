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
library;

/// Base class for all API exceptions in the application.
///
/// This is a sealed class, meaning all subclasses are defined in this file.
/// This allows exhaustive pattern matching in `switch` statements.
sealed class ApiException implements Exception {
  /// Creates an API exception with the given message.
  const ApiException(this.message, [this.originalError]);

  /// The error message describing what went wrong.
  final String message;

  /// The original error object that caused this exception.
  final Object? originalError;

  /// Returns a user-friendly error message suitable for display in the UI.
  String get userMessage => message;

  @override
  String toString() => message;
}

/// Exception thrown when authentication operations fail.
///
/// This exception handles errors from the Express API auth endpoints.
class AppAuthException extends ApiException {
  /// Creates an authentication exception with the given message.
  const AppAuthException(super.message, [super.originalError]);

  /// Creates an authentication exception from an API error message.
  ///
  /// Maps common auth error messages to user-friendly alternatives.
  factory AppAuthException.fromApiError(String message) {
    return AppAuthException(_mapAuthError(message));
  }

  /// Maps auth error messages to user-friendly alternatives.
  static String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid email or password') ||
        lower.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed') ||
        lower.contains('email not verified')) {
      return 'Please verify your email address to continue.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('email already exists') ||
        lower.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password should be') ||
        lower.contains('weak password') ||
        lower.contains('password too short')) {
      return 'Password must be at least 8 characters long.';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Too many attempts. Please wait and try again.';
    }
    if (lower.contains('session expired') || lower.contains('token expired')) {
      return 'Your session has expired. Please sign in again.';
    }
    return message;
  }
}

/// Exception thrown when network connectivity fails.
class NetworkException extends ApiException {
  /// Creates a network exception with the given message.
  const NetworkException(super.message, [super.originalError]);

  /// Creates a network exception indicating no internet connection.
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection. Please check your network.',
    );
  }

  /// Creates a network exception indicating a request timeout.
  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out. Please try again.',
    );
  }
}

/// Exception thrown when the server returns an error response.
class ServerException extends ApiException {
  /// Creates a server exception with the given message and status code.
  const ServerException(super.message, this.statusCode, [super.originalError]);

  /// The HTTP status code returned by the server, if available.
  final int? statusCode;

  /// Creates a server exception from an API error response.
  ///
  /// Maps common error codes and messages to user-friendly alternatives.
  factory ServerException.fromApiError(String message, int? statusCode) {
    return ServerException(
      _mapServerError(message, statusCode),
      statusCode,
    );
  }

  /// Maps server error messages to user-friendly alternatives.
  static String _mapServerError(String message, int? statusCode) {
    final lower = message.toLowerCase();
    if (lower.contains('duplicate key') || lower.contains('already exists')) {
      return 'This record already exists.';
    }
    if (lower.contains('foreign key') || lower.contains('referenced')) {
      return 'Referenced record not found.';
    }
    if (lower.contains('permission denied') || lower.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }
    if (lower.contains('not found')) {
      return 'The requested resource was not found.';
    }
    if (statusCode == 404) {
      return 'The requested resource was not found.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    if (statusCode == 409) {
      return 'This record already exists.';
    }
    return message;
  }
}

/// Exception thrown when a requested resource is not found.
class NotFoundException extends ApiException {
  /// Creates a not found exception with an optional custom message.
  const NotFoundException([String message = 'Resource not found'])
      : super(message);
}

/// Exception thrown when input validation fails.
class ValidationException extends ApiException {
  /// Creates a validation exception with the given message and optional field errors.
  const ValidationException(super.message, [this.errors = const {}]);

  /// A map of field names to their validation error messages.
  final Map<String, String> errors;
}

/// Exception thrown when storage/upload operations fail.
class StorageException extends ApiException {
  /// Creates a storage exception with the given message.
  const StorageException(super.message, [super.originalError]);

  /// Creates a storage exception from a generic error.
  factory StorageException.fromError(Object e) {
    if (e is StorageException) {
      return e;
    }
    return StorageException(e.toString(), e);
  }
}

/// Exception thrown when an operation is cancelled by the user.
class CancelledException extends ApiException {
  /// Creates a cancellation exception with an optional custom message.
  const CancelledException([String message = 'Operation cancelled'])
      : super(message);
}

/// Handles common API errors and throws appropriate [ApiException] subclasses.
///
/// This helper function simplifies error handling in repositories.
T handleApiError<T>(Object error, {T Function()? fallback}) {
  if (error is ApiException) {
    throw error;
  }
  if (fallback != null) {
    return fallback();
  }
  throw ServerException('An unexpected error occurred', null, error);
}

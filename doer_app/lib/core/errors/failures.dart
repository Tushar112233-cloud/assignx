/// Failure classes for functional error handling.
///
/// This file defines a hierarchy of failure classes used for
/// representing error states in a functional programming style.
/// Unlike exceptions which are thrown, failures are returned as
/// values, making error handling more explicit and type-safe.
///
/// ## Failure vs Exception
/// - **Exceptions**: Thrown for unexpected errors, caught in try-catch
/// - **Failures**: Returned as values, handled via Either/Result patterns
///
/// ## Failure Hierarchy
/// ```
/// Failure (base)
/// |-- ServerFailure
/// |-- NetworkFailure
/// |-- AuthFailure
/// |-- CacheFailure
/// |-- ValidationFailure
/// |-- PermissionFailure
/// |-- UnknownFailure
/// ```
///
/// ## Usage Pattern
/// Failures are typically used with the Either pattern for returning
/// success or failure from use cases and repositories.
///
/// ## Example
/// ```dart
/// Future<Either<Failure, User>> getUser(String id) async {
///   try {
///     final user = await dataSource.getUser(id);
///     return Right(user);
///   } on ServerException catch (e) {
///     return Left(ServerFailure(message: e.message));
///   } on NetworkException {
///     return Left(const NetworkFailure());
///   }
/// }
/// ```
library;

/// Base class for all failure types.
///
/// Provides a common interface for error representation with
/// a human-readable message and optional error code.
///
/// ## Properties
/// - [message]: User-friendly error message for display
/// - [code]: Optional machine-readable code for handling
///
/// ## Usage
/// Extend this class to create specific failure types:
/// ```dart
/// class CustomFailure extends Failure {
///   const CustomFailure({required super.message, super.code});
/// }
/// ```
abstract class Failure {
  /// Human-readable error message.
  ///
  /// This message should be suitable for display to users.
  final String message;

  /// Optional machine-readable error code.
  ///
  /// Used for programmatic error handling and analytics.
  final String? code;

  /// Creates a [Failure] with required message and optional code.
  ///
  /// @param message User-friendly error description
  /// @param code Optional error code for categorization
  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure: $message';
}

/// Failure representing server-side errors.
///
/// Used when the backend server returns an error or the
/// API request fails due to server issues.
///
/// ## Common Scenarios
/// - HTTP 4xx/5xx responses
/// - Backend service unavailable
/// - Database errors from server
///
/// ## Example
/// ```dart
/// return Left(ServerFailure(
///   message: 'Unable to process your request',
///   code: 'SERVER_500',
/// ));
/// ```
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with the given details.
  ///
  /// @param message Description of the server error
  /// @param code HTTP status code or custom error code
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing network connectivity issues.
///
/// Used when the device cannot connect to the network
/// or when requests timeout.
///
/// ## Common Scenarios
/// - No internet connection
/// - WiFi/mobile data disabled
/// - Request timeout
/// - DNS resolution failure
///
/// ## Example
/// ```dart
/// on SocketException {
///   return Left(const NetworkFailure());
/// }
/// ```
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with optional custom message.
  ///
  /// Defaults to a user-friendly connectivity message.
  ///
  /// @param message Custom error message
  /// @param code Error code (defaults to 'NETWORK_FAILURE')
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_FAILURE',
  });
}

/// Failure representing authentication errors.
///
/// Used when authentication fails, sessions expire, or
/// users lack authorization for an action.
///
/// ## Common Scenarios
/// - Invalid login credentials
/// - Session/token expired
/// - Account locked or disabled
/// - Insufficient permissions
///
/// ## Example
/// ```dart
/// return Left(AuthFailure(
///   message: 'Your session has expired. Please log in again.',
///   code: 'SESSION_EXPIRED',
/// ));
/// ```
class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with the given details.
  ///
  /// @param message Description of the auth error
  /// @param code Auth error code (e.g., 'INVALID_CREDENTIALS')
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Failure representing local cache errors.
///
/// Used when reading from or writing to local storage fails.
///
/// ## Common Scenarios
/// - Cache miss when offline
/// - Corrupted cache data
/// - Storage quota exceeded
/// - Cache read/write errors
///
/// ## Example
/// ```dart
/// catch (e) {
///   return Left(const CacheFailure());
/// }
/// ```
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with optional custom message.
  ///
  /// Defaults to a generic cache error message.
  ///
  /// @param message Custom error message
  /// @param code Error code (defaults to 'CACHE_FAILURE')
  const CacheFailure({
    super.message = 'Unable to access cached data',
    super.code = 'CACHE_FAILURE',
  });
}

/// Failure representing input validation errors.
///
/// Used when user input fails validation, either locally
/// or from server-side validation.
///
/// ## Properties
/// - [fieldErrors]: Map of field-specific error messages
///
/// ## Common Scenarios
/// - Form validation failure
/// - Business rule violations
/// - Server-side validation rejection
///
/// ## Example
/// ```dart
/// return Left(ValidationFailure(
///   message: 'Please correct the errors in the form',
///   fieldErrors: {
///     'email': 'Email is already registered',
///   },
/// ));
/// ```
class ValidationFailure extends Failure {
  /// Map of field names to their specific validation errors.
  ///
  /// Enables UI to display errors next to relevant form fields.
  final Map<String, String>? fieldErrors;

  /// Creates a [ValidationFailure] with message and optional field errors.
  ///
  /// @param message General validation error message
  /// @param code Validation error code
  /// @param fieldErrors Map of field-specific error messages
  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

/// Failure representing permission issues.
///
/// Used when required device permissions are denied
/// or user access rights are insufficient.
///
/// ## Common Scenarios
/// - Camera permission denied
/// - Location access blocked
/// - Storage permission required
/// - Feature restricted by role
///
/// ## Example
/// ```dart
/// return Left(PermissionFailure(
///   message: 'Please grant camera access in Settings',
/// ));
/// ```
class PermissionFailure extends Failure {
  /// Creates a [PermissionFailure] with the given message.
  ///
  /// Defaults to 'PERMISSION_FAILURE' code.
  ///
  /// @param message Description of the required permission
  /// @param code Permission error code
  const PermissionFailure({
    required super.message,
    super.code = 'PERMISSION_FAILURE',
  });
}

/// Failure representing unexpected or unhandled errors.
///
/// Used as a fallback when an error doesn't match any
/// specific failure type.
///
/// ## Common Scenarios
/// - Unhandled exceptions
/// - Unexpected error states
/// - Generic catch-all errors
///
/// ## Example
/// ```dart
/// catch (e) {
///   return Left(const UnknownFailure());
/// }
/// ```
class UnknownFailure extends Failure {
  /// Creates an [UnknownFailure] with optional custom message.
  ///
  /// Defaults to a generic error message.
  ///
  /// @param message Custom error message
  /// @param code Error code (defaults to 'UNKNOWN_FAILURE')
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'UNKNOWN_FAILURE',
  });
}

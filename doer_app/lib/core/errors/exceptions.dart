/// Custom exception classes for error handling.
///
/// This file defines a hierarchy of exception classes used throughout
/// the DOER app for type-safe error handling and specific error recovery.
///
/// ## Exception Hierarchy
/// ```
/// AppException (base)
/// |-- ServerException
/// |-- NetworkException
/// |-- AuthException
/// |-- ValidationException
/// |-- CacheException
/// |-- PermissionException
/// |-- FileException
/// ```
///
/// ## Usage Pattern
/// Exceptions are typically thrown in repositories and data sources,
/// then caught and converted to [Failure] objects for presentation.
///
/// ## Example
/// ```dart
/// try {
///   final response = await api.getUser(id);
///   return response;
/// } on SocketException {
///   throw const NetworkException();
/// } on ApiException catch (e) {
///   throw ServerException(message: e.message, code: e.code);
/// }
/// ```
library;

/// Base exception class for all app-specific exceptions.
///
/// Provides a common structure for exceptions with a message,
/// optional error code, and optional original error for debugging.
///
/// ## Properties
/// - [message]: Human-readable error description
/// - [code]: Optional machine-readable error code for handling
/// - [originalError]: Original exception for debugging (not shown to users)
///
/// ## Example
/// ```dart
/// throw AppException(
///   message: 'Failed to load data',
///   code: 'DATA_LOAD_ERROR',
///   originalError: e,
/// );
/// ```
class AppException implements Exception {
  /// Human-readable error message.
  ///
  /// This message may be displayed to users or used for logging.
  final String message;

  /// Optional machine-readable error code.
  ///
  /// Used for programmatic error handling and categorization.
  final String? code;

  /// The original error that caused this exception.
  ///
  /// Useful for debugging and logging; should not be exposed to users.
  final dynamic originalError;

  /// Creates an [AppException] with required message and optional details.
  ///
  /// @param message Human-readable error description
  /// @param code Optional error code for programmatic handling
  /// @param originalError Original exception for debugging
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception for server-side errors.
///
/// Thrown when the backend server returns an error response,
/// such as 4xx or 5xx HTTP status codes.
///
/// ## Common Use Cases
/// - API returns error status
/// - Backend validation failures
/// - Database errors from server
///
/// ## Example
/// ```dart
/// if (response.statusCode >= 500) {
///   throw ServerException(
///     message: 'Server is temporarily unavailable',
///     code: 'SERVER_ERROR',
///   );
/// }
/// ```
class ServerException extends AppException {
  /// Creates a [ServerException] with the given details.
  ///
  /// @param message Description of the server error
  /// @param code HTTP status code or custom error code
  /// @param originalError The original HTTP or API exception
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for network connectivity issues.
///
/// Thrown when the device cannot establish a network connection
/// or when a request times out.
///
/// ## Common Use Cases
/// - No internet connection
/// - DNS resolution failure
/// - Connection timeout
/// - Socket exceptions
///
/// ## Example
/// ```dart
/// on SocketException {
///   throw const NetworkException();
/// }
/// ```
class NetworkException extends AppException {
  /// Creates a [NetworkException] with optional custom message.
  ///
  /// Defaults to 'No internet connection' message and 'NETWORK_ERROR' code.
  ///
  /// @param message Custom error message (defaults to standard message)
  /// @param code Error code (defaults to 'NETWORK_ERROR')
  /// @param originalError Original network exception
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Exception for authentication and authorization errors.
///
/// Thrown when authentication fails, tokens expire, or user
/// lacks permission for an action.
///
/// ## Common Use Cases
/// - Invalid credentials
/// - Expired session/token
/// - Unauthorized access attempt
/// - Account locked or disabled
///
/// ## Example
/// ```dart
/// if (response.statusCode == 401) {
///   throw AuthException(
///     message: 'Session expired. Please log in again.',
///     code: 'SESSION_EXPIRED',
///   );
/// }
/// ```
class AuthException extends AppException {
  /// Creates an [AuthException] with the given details.
  ///
  /// @param message Description of the authentication error
  /// @param code Auth error code (e.g., 'INVALID_CREDENTIALS')
  /// @param originalError Original auth exception
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for input validation errors.
///
/// Thrown when user input fails validation rules, either locally
/// or from server-side validation.
///
/// ## Properties
/// - [fieldErrors]: Map of field names to specific error messages
///
/// ## Common Use Cases
/// - Form field validation failure
/// - Server-side validation rejection
/// - Business rule violations
///
/// ## Example
/// ```dart
/// throw ValidationException(
///   message: 'Please fix the errors below',
///   fieldErrors: {
///     'email': 'Invalid email format',
///     'password': 'Password too short',
///   },
/// );
/// ```
class ValidationException extends AppException {
  /// Map of field names to their specific validation errors.
  ///
  /// Allows UI to display errors next to specific form fields.
  final Map<String, String>? fieldErrors;

  /// Creates a [ValidationException] with message and optional field errors.
  ///
  /// @param message General validation error message
  /// @param code Validation error code
  /// @param originalError Original validation exception
  /// @param fieldErrors Map of field-specific error messages
  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception for cache-related errors.
///
/// Thrown when reading from or writing to local cache fails.
///
/// ## Common Use Cases
/// - Cache read failure
/// - Cache write failure
/// - Cache corruption
/// - Storage full
///
/// ## Example
/// ```dart
/// try {
///   return await cache.read(key);
/// } catch (e) {
///   throw CacheException(originalError: e);
/// }
/// ```
class CacheException extends AppException {
  /// Creates a [CacheException] with optional details.
  ///
  /// Defaults to 'Cache error occurred' message and 'CACHE_ERROR' code.
  ///
  /// @param message Custom error message
  /// @param code Error code
  /// @param originalError Original cache exception
  const CacheException({
    super.message = 'Cache error occurred',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Exception for permission-related errors.
///
/// Thrown when the app lacks required device permissions
/// or user access rights.
///
/// ## Common Use Cases
/// - Camera permission denied
/// - Storage permission denied
/// - Location permission denied
/// - Feature access restricted
///
/// ## Example
/// ```dart
/// if (!await Permission.camera.isGranted) {
///   throw PermissionException(
///     message: 'Camera permission is required to take photos',
///   );
/// }
/// ```
class PermissionException extends AppException {
  /// Creates a [PermissionException] with the given message.
  ///
  /// Defaults to 'PERMISSION_DENIED' code.
  ///
  /// @param message Description of the required permission
  /// @param code Permission error code
  /// @param originalError Original permission exception
  const PermissionException({
    required super.message,
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// Exception for file operation errors.
///
/// Thrown when file read, write, upload, or download operations fail.
///
/// ## Common Use Cases
/// - File not found
/// - File too large
/// - Unsupported file type
/// - Upload/download failure
/// - Insufficient storage
///
/// ## Example
/// ```dart
/// if (file.lengthSync() > maxSize) {
///   throw FileException(
///     message: 'File exceeds maximum size of 50MB',
///     code: 'FILE_TOO_LARGE',
///   );
/// }
/// ```
class FileException extends AppException {
  /// Creates a [FileException] with the given details.
  ///
  /// Defaults to 'FILE_ERROR' code.
  ///
  /// @param message Description of the file error
  /// @param code File error code
  /// @param originalError Original file exception
  const FileException({
    required super.message,
    super.code = 'FILE_ERROR',
    super.originalError,
  });
}

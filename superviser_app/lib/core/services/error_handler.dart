import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import '../network/api_exceptions.dart';
import 'snackbar_service.dart';

/// Global error handler for the application.
class ErrorHandler {
  ErrorHandler._();

  static final ErrorHandler _instance = ErrorHandler._();
  static ErrorHandler get instance => _instance;

  SnackbarService? _snackbarService;

  /// Initialize the error handler.
  void initialize({SnackbarService? snackbarService}) {
    _snackbarService = snackbarService ?? SnackbarService.instance;
    _setupGlobalErrorHandlers();
  }

  void _setupGlobalErrorHandlers() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };
  }

  /// Handle an error and optionally show a user-friendly message.
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    bool showSnackbar = true,
    String? customMessage,
  }) {
    _logError(error, stackTrace);

    if (showSnackbar) {
      final message = customMessage ?? _getUserFriendlyMessage(error);
      _snackbarService?.showError(message);
    }
  }

  /// Handle an async error with retry capability.
  Future<T?> handleAsyncError<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    int maxRetries = 0,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;

    while (attempts <= maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempts++;
        _logError(error, stackTrace);

        if (attempts > maxRetries) {
          final message = errorMessage ?? _getUserFriendlyMessage(error);
          _snackbarService?.showError(
            message,
            actionLabel: maxRetries > 0 ? 'Retry' : null,
            onAction: maxRetries > 0
                ? () => handleAsyncError(
                      operation,
                      errorMessage: errorMessage,
                      maxRetries: maxRetries,
                      retryDelay: retryDelay,
                    )
                : null,
          );
          return null;
        }

        await Future.delayed(retryDelay * attempts);
      }
    }

    return null;
  }

  /// Run zone guarded to catch all errors.
  void runGuarded(void Function() body) {
    runZonedGuarded(
      body,
      (error, stack) {
        handleError(error, stackTrace: stack);
      },
    );
  }

  /// Get a user-friendly error message.
  String _getUserFriendlyMessage(dynamic error) {
    if (error is ApiException) {
      return error.userMessage;
    }

    if (error is AuthException) {
      return _getAuthErrorMessage(error);
    }

    if (error is PostgrestException) {
      return _getPostgrestErrorMessage(error);
    }

    if (error is StorageException) {
      return 'Failed to upload or download file. Please try again.';
    }

    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please check your connection.';
    }

    if (error.toString().contains('FormatException')) {
      return 'Invalid data format received.';
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    if (error.toString().contains('HandshakeException')) {
      return 'Secure connection failed. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }

  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }

    if (message.contains('user not found')) {
      return 'No account found with this email.';
    }

    if (message.contains('email already registered')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (message.contains('session expired') ||
        message.contains('token expired')) {
      return 'Your session has expired. Please sign in again.';
    }

    if (message.contains('weak password')) {
      return 'Password is too weak. Please use a stronger password.';
    }

    return 'Authentication failed. Please try again.';
  }

  String _getPostgrestErrorMessage(PostgrestException error) {
    final code = error.code;

    switch (code) {
      case '23505':
        return 'This record already exists.';
      case '23503':
        return 'Cannot delete this record because it is referenced elsewhere.';
      case '42501':
        return 'You do not have permission to perform this action.';
      case '42P01':
        return 'The requested resource was not found.';
      case 'PGRST116':
        return 'The requested resource was not found.';
      default:
        return 'Database operation failed. Please try again.';
    }
  }

  void _logError(dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();

    developer.log(
      'Error occurred at $timestamp',
      name: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint('╔══════════════════════════════════════════════════════════');
      debugPrint('║ ERROR: $error');
      debugPrint('║ TIME: $timestamp');
      if (stackTrace != null) {
        debugPrint('║ STACK:');
        for (final line in stackTrace.toString().split('\n').take(10)) {
          debugPrint('║   $line');
        }
      }
      debugPrint('╚══════════════════════════════════════════════════════════');
    }
  }
}

/// Provider for error handler.
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final handler = ErrorHandler.instance;
  handler.initialize(snackbarService: ref.read(snackbarServiceProvider));
  return handler;
});

/// Extension for error handling on AsyncValue.
extension AsyncValueErrorExtension<T> on AsyncValue<T> {
  /// Show error snackbar if this value has an error.
  void showErrorIfNeeded(SnackbarService snackbar) {
    whenOrNull(
      error: (error, _) {
        snackbar.showError(ErrorHandler.instance._getUserFriendlyMessage(error));
      },
    );
  }
}

/// Error boundary widget that catches errors in the widget tree.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.errorWidget,
  });

  final Widget child;
  final void Function(Object error, StackTrace? stack)? onError;
  final Widget Function(Object error)? errorWidget;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget?.call(_error!) ?? _DefaultErrorWidget(error: _error!);
    }

    return widget.child;
  }
}

/// Default error widget shown when an error occurs.
class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              ErrorHandler.instance._getUserFriendlyMessage(error),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // Trigger a rebuild by navigating or refreshing
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

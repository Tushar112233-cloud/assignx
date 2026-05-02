/// Centralized logging service for the application.
///
/// This file provides a comprehensive logging system with different
/// severity levels, automatic environment detection, sensitive data
/// redaction, and preparation for crash reporting integration.
///
/// ## Features
/// - Multiple log levels (debug, info, warning, error, fatal)
/// - Automatic production mode detection
/// - Sensitive data redaction (passwords, tokens, phone numbers, etc.)
/// - Network request logging
/// - Performance metric logging
/// - User action logging for analytics
/// - Extension for easy error logging
///
/// ## Log Levels
/// - **debug**: Development-only verbose logging
/// - **info**: General informational messages
/// - **warning**: Potential issues that don't require immediate action
/// - **error**: Recoverable errors that need attention
/// - **fatal**: Critical errors that may crash the app
///
/// ## Usage
/// ```dart
/// // Initialize in main()
/// LoggerService.init();
///
/// // Log messages
/// LoggerService.debug('Loading user data', tag: 'UserRepo');
/// LoggerService.info('User logged in', tag: 'Auth');
/// LoggerService.error('Failed to save', error, tag: 'Storage');
/// ```
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized logging service for the application.
///
/// Provides structured logging with different severity levels,
/// automatic environment detection, and preparation for crash
/// reporting integration.
///
/// ## Initialization
/// Call [init] in `main()` before `runApp()`:
/// ```dart
/// void main() async {
///   LoggerService.init();
///   // ... rest of initialization
/// }
/// ```
///
/// ## Thread Safety
/// This class uses a private constructor pattern and all members
/// are static. It is safe to use from any context.
///
/// ## Production Behavior
/// In release mode ([kReleaseMode] = true):
/// - Debug logs are suppressed
/// - Other logs are prepared for crash reporting (TODO)
/// - Sensitive data is still redacted
class LoggerService {
  /// Private constructor to prevent instantiation.
  LoggerService._();

  /// Whether the app is running in production mode.
  ///
  /// Defaults to [kReleaseMode] but can be overridden in [init].
  static bool _isProduction = kReleaseMode;

  /// Whether the logger has been initialized.
  static bool _isInitialized = false;

  /// Patterns for detecting sensitive data in log messages.
  ///
  /// These patterns are used to redact potentially sensitive information
  /// before logging to prevent accidental exposure.
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'password[\s:=]+\S+', caseSensitive: false),
    RegExp(r'token[\s:=]+\S+', caseSensitive: false),
    RegExp(r'key[\s:=]+\S+', caseSensitive: false),
    RegExp(r'\b\d{9,18}\b'), // Account numbers
    RegExp(r'\b[A-Z]{4}0[A-Z0-9]{6}\b'), // IFSC codes
    RegExp(r'\b[6-9]\d{9}\b'), // Phone numbers
  ];

  /// Initialize the logger service.
  ///
  /// Call this in `main()` before `runApp()`. Safe to call multiple
  /// times; subsequent calls are ignored.
  ///
  /// @param isProduction Override production mode detection.
  ///   Defaults to [kReleaseMode].
  ///
  /// ## Example
  /// ```dart
  /// void main() async {
  ///   LoggerService.init();
  ///   // or with override
  ///   LoggerService.init(isProduction: false);
  ///   runApp(MyApp());
  /// }
  /// ```
  static void init({bool? isProduction}) {
    if (_isInitialized) return;

    if (isProduction != null) {
      _isProduction = isProduction;
    }

    _isInitialized = true;
    info('LoggerService initialized', tag: 'Logger');
  }

  /// Log a debug message.
  ///
  /// Only logged in debug/development mode. Use for verbose
  /// debugging information that shouldn't appear in production.
  ///
  /// @param message The message to log
  /// @param tag Optional category tag for filtering
  /// @param data Optional additional data to log
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.debug(
  ///   'Fetching user profile',
  ///   tag: 'UserRepo',
  ///   data: {'userId': '123'},
  /// );
  /// ```
  static void debug(
    String message, {
    String? tag,
    dynamic data,
  }) {
    if (_isProduction) return;

    final formattedMessage = _formatMessage('DEBUG', message, tag);
    final sanitizedData = data != null ? _sanitize(data.toString()) : null;

    developer.log(
      formattedMessage,
      name: tag ?? 'App',
      level: 500, // FINE
    );

    if (sanitizedData != null) {
      developer.log('  Data: $sanitizedData', name: tag ?? 'App', level: 500);
    }
  }

  /// Log an info message.
  ///
  /// Use for general informational messages about app state
  /// and significant events.
  ///
  /// @param message The message to log
  /// @param tag Optional category tag for filtering
  /// @param data Optional additional data to log
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.info('User logged in successfully', tag: 'Auth');
  /// ```
  static void info(
    String message, {
    String? tag,
    dynamic data,
  }) {
    final formattedMessage = _formatMessage('INFO', message, tag);
    final sanitizedData = data != null ? _sanitize(data.toString()) : null;

    if (!_isProduction) {
      developer.log(
        formattedMessage,
        name: tag ?? 'App',
        level: 800, // INFO
      );

      if (sanitizedData != null) {
        developer.log('  Data: $sanitizedData', name: tag ?? 'App', level: 800);
      }
    }

    // TODO: In production, send to analytics/monitoring service
    // Analytics.logEvent(name: 'info', parameters: {...});
  }

  /// Log a warning message.
  ///
  /// Use for potential issues that don't require immediate action
  /// but should be monitored.
  ///
  /// @param message The message to log
  /// @param tag Optional category tag for filtering
  /// @param data Optional additional data to log
  /// @param stackTrace Optional stack trace for context
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.warning(
  ///   'Cache expired, fetching fresh data',
  ///   tag: 'Cache',
  /// );
  /// ```
  static void warning(
    String message, {
    String? tag,
    dynamic data,
    StackTrace? stackTrace,
  }) {
    final formattedMessage = _formatMessage('WARNING', message, tag);
    final sanitizedData = data != null ? _sanitize(data.toString()) : null;

    if (!_isProduction) {
      developer.log(
        formattedMessage,
        name: tag ?? 'App',
        level: 900, // WARNING
      );

      if (sanitizedData != null) {
        developer.log('  Data: $sanitizedData', name: tag ?? 'App', level: 900);
      }

      if (stackTrace != null) {
        developer.log('  Stack: $stackTrace', name: tag ?? 'App', level: 900);
      }
    }

    // TODO: In production, send to monitoring service
    // Crashlytics.recordError(...);
  }

  /// Log an error message.
  ///
  /// This should be used for recoverable errors. For critical
  /// errors that may crash the app, use [fatal] instead.
  ///
  /// @param message Description of what went wrong
  /// @param error The error object
  /// @param tag Optional category tag for filtering
  /// @param stackTrace Optional stack trace
  /// @param context Optional additional context data
  ///
  /// ## Example
  /// ```dart
  /// try {
  ///   await fetchData();
  /// } catch (e, s) {
  ///   LoggerService.error(
  ///     'Failed to fetch user data',
  ///     e,
  ///     tag: 'UserRepo',
  ///     stackTrace: s,
  ///   );
  /// }
  /// ```
  static void error(
    String message,
    dynamic error, {
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final formattedMessage = _formatMessage('ERROR', message, tag);
    final errorString = error?.toString() ?? 'Unknown error';

    if (!_isProduction) {
      developer.log(
        formattedMessage,
        name: tag ?? 'App',
        level: 1000, // SEVERE
        error: error,
        stackTrace: stackTrace,
      );

      developer.log('  Error: $errorString', name: tag ?? 'App', level: 1000);

      if (context != null) {
        final sanitizedContext = _sanitizeMap(context);
        developer.log(
          '  Context: $sanitizedContext',
          name: tag ?? 'App',
          level: 1000,
        );
      }
    }

    // TODO: In production, send to crash reporting
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: message,
    //   information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    // );
  }

  /// Log a fatal error.
  ///
  /// Use for critical errors that should trigger crash reporting.
  /// These are errors that the app cannot recover from gracefully.
  ///
  /// @param message Description of the fatal error
  /// @param error The error object
  /// @param tag Optional category tag for filtering
  /// @param stackTrace Optional stack trace
  /// @param context Optional additional context data
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.fatal(
  ///   'Database corruption detected',
  ///   error,
  ///   tag: 'Database',
  ///   stackTrace: stackTrace,
  /// );
  /// ```
  static void fatal(
    String message,
    dynamic error, {
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final formattedMessage = _formatMessage('FATAL', message, tag);

    if (!_isProduction) {
      developer.log(
        formattedMessage,
        name: tag ?? 'App',
        level: 1200, // SHOUT
        error: error,
        stackTrace: stackTrace,
      );

      debugPrint('FATAL ERROR: $message');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack: $stackTrace');
      }
    }

    // TODO: In production, send fatal error to crash reporting
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: message,
    //   fatal: true,
    // );
  }

  /// Log a user action for analytics.
  ///
  /// Use to track user interactions for analytics and behavior analysis.
  ///
  /// @param action The action name/identifier
  /// @param screen Optional screen where the action occurred
  /// @param params Optional parameters for the action
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.logUserAction(
  ///   'button_tap',
  ///   screen: 'Dashboard',
  ///   params: {'button': 'submit'},
  /// );
  /// ```
  static void logUserAction(
    String action, {
    String? screen,
    Map<String, dynamic>? params,
  }) {
    final sanitizedParams = params != null ? _sanitizeMap(params) : null;

    if (!_isProduction) {
      final screenInfo = screen != null ? ' [Screen: $screen]' : '';
      developer.log(
        'ACTION: $action$screenInfo',
        name: 'UserAction',
        level: 800,
      );

      if (sanitizedParams != null) {
        developer.log('  Params: $sanitizedParams', name: 'UserAction', level: 800);
      }
    }

    // TODO: Send to analytics in production
    // Analytics.logEvent(name: action, parameters: sanitizedParams);
  }

  /// Log a network request.
  ///
  /// Use to track API calls for debugging and performance monitoring.
  ///
  /// @param method HTTP method (GET, POST, etc.)
  /// @param url The request URL
  /// @param statusCode Optional response status code
  /// @param durationMs Optional request duration in milliseconds
  /// @param error Optional error message if request failed
  ///
  /// ## Example
  /// ```dart
  /// final stopwatch = Stopwatch()..start();
  /// final response = await http.get(url);
  /// stopwatch.stop();
  ///
  /// LoggerService.logNetwork(
  ///   'GET',
  ///   url.toString(),
  ///   statusCode: response.statusCode,
  ///   durationMs: stopwatch.elapsedMilliseconds,
  /// );
  /// ```
  static void logNetwork(
    String method,
    String url, {
    int? statusCode,
    int? durationMs,
    String? error,
  }) {
    if (_isProduction) return;

    final status = statusCode != null ? ' [$statusCode]' : '';
    final duration = durationMs != null ? ' (${durationMs}ms)' : '';

    developer.log(
      'NETWORK: $method $url$status$duration',
      name: 'Network',
      level: 800,
    );

    if (error != null) {
      developer.log('  Error: $error', name: 'Network', level: 1000);
    }
  }

  /// Log performance metrics.
  ///
  /// Use to track operation timing for performance optimization.
  ///
  /// @param operation Name of the operation being measured
  /// @param durationMs Duration in milliseconds
  /// @param metadata Optional additional metadata
  ///
  /// ## Example
  /// ```dart
  /// final stopwatch = Stopwatch()..start();
  /// await heavyOperation();
  /// stopwatch.stop();
  ///
  /// LoggerService.logPerformance(
  ///   'heavyOperation',
  ///   durationMs: stopwatch.elapsedMilliseconds,
  ///   metadata: {'itemCount': 100},
  /// );
  /// ```
  static void logPerformance(
    String operation, {
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) {
    if (_isProduction) return;

    developer.log(
      'PERF: $operation took ${durationMs}ms',
      name: 'Performance',
      level: 800,
    );

    if (metadata != null) {
      developer.log('  Metadata: $metadata', name: 'Performance', level: 800);
    }

    // TODO: Send performance metrics in production
    // FirebasePerformance.instance.newTrace(operation)...
  }

  /// Set user identifier for crash reporting.
  ///
  /// Call this after user authentication to associate logs
  /// and crash reports with a specific user.
  ///
  /// @param userId The user's unique identifier, or null to clear
  ///
  /// ## Example
  /// ```dart
  /// // After login
  /// LoggerService.setUserId(user.id);
  ///
  /// // After logout
  /// LoggerService.setUserId(null);
  /// ```
  static void setUserId(String? userId) {
    if (userId != null) {
      debug('User ID set', tag: 'Auth', data: 'user_${userId.substring(0, 4)}...');
    } else {
      debug('User ID cleared', tag: 'Auth');
    }

    // TODO: Set user ID in crash reporting
    // FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  /// Add custom key-value for crash reports.
  ///
  /// Use to add contextual information that will be included
  /// in crash reports.
  ///
  /// @param key The key name
  /// @param value The value to associate
  ///
  /// ## Example
  /// ```dart
  /// LoggerService.setCustomKey('subscription_tier', 'premium');
  /// ```
  static void setCustomKey(String key, dynamic value) {
    debug('Custom key set: $key', tag: 'Logger');

    // TODO: Set custom key in crash reporting
    // FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Formats a log message with timestamp, level, and optional tag.
  static String _formatMessage(String level, String message, String? tag) {
    final timestamp = DateTime.now().toIso8601String();
    final tagPart = tag != null ? '[$tag] ' : '';
    return '[$timestamp] $level: $tagPart$message';
  }

  /// Sanitizes text by redacting sensitive patterns.
  static String _sanitize(String text) {
    var result = text;
    for (final pattern in _sensitivePatterns) {
      result = result.replaceAll(pattern, '[REDACTED]');
    }
    return result;
  }

  /// Sanitizes a map by redacting sensitive keys and values.
  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    const sensitiveKeys = [
      'password',
      'token',
      'key',
      'secret',
      'account_number',
      'accountNumber',
      'ifsc',
      'ifsc_code',
      'phone',
      'email',
    ];

    return map.map((key, value) {
      if (sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
        return MapEntry(key, '[REDACTED]');
      }
      if (value is String) {
        return MapEntry(key, _sanitize(value));
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeMap(value));
      }
      return MapEntry(key, value);
    });
  }
}

/// Extension to easily log provider errors.
///
/// Provides a convenient method on any object to log it as an error
/// with the object's runtime type as the tag.
///
/// ## Usage
/// ```dart
/// try {
///   await operation();
/// } catch (e, s) {
///   e.logError('Operation failed', stackTrace: s);
/// }
/// ```
extension LoggerProviderExtension on Object {
  /// Logs this object as an error.
  ///
  /// @param message Description of what went wrong
  /// @param stackTrace Optional stack trace
  void logError(String message, {StackTrace? stackTrace}) {
    LoggerService.error(
      message,
      this,
      tag: runtimeType.toString(),
      stackTrace: stackTrace,
    );
  }
}

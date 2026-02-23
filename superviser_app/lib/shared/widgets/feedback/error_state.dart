import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';

/// {@template error_state}
/// A widget for displaying error states with retry functionality.
///
/// Provides a consistent error UI pattern across the app with an icon,
/// error message, and optional retry button.
///
/// ## Appearance
/// - Centered content with generous padding (32px)
/// - Large error icon (80px by default) in error color
/// - Optional title in titleLarge style
/// - Error message in bodyMedium with muted color
/// - Optional retry button with refresh icon
///
/// ## Usage
///
/// Basic error:
/// ```dart
/// ErrorState(
///   message: 'Failed to load data',
///   onRetry: () => reloadData(),
/// )
/// ```
///
/// With title and custom icon:
/// ```dart
/// ErrorState(
///   title: 'Access Denied',
///   message: 'You do not have permission to view this content.',
///   icon: Icons.lock_outline,
/// )
/// ```
///
/// Without retry:
/// ```dart
/// ErrorState(
///   message: 'This feature is not available.',
/// )
/// ```
///
/// See also:
/// - [NetworkErrorState] for network-specific errors
/// - [ServerErrorState] for server/API errors
/// - [EmptyState] for empty data states
/// {@endtemplate}
class ErrorState extends StatelessWidget {
  /// Creates an error state widget.
  ///
  /// The [message] parameter is required.
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.iconSize = 80,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  /// The error message to display.
  ///
  /// Displayed below the title (if present) in bodyMedium style
  /// with muted color.
  final String message;

  /// Optional title for the error.
  ///
  /// Displayed above the message in titleLarge style.
  final String? title;

  /// Icon to display above the text.
  ///
  /// Defaults to [Icons.error_outline] if not specified.
  /// Displayed in the theme's error color at 70% opacity.
  final IconData? icon;

  /// The size of the [icon].
  ///
  /// Defaults to 80 pixels.
  final double iconSize;

  /// Callback when the retry button is pressed.
  ///
  /// If null, no retry button is displayed.
  final VoidCallback? onRetry;

  /// Label for the retry button.
  ///
  /// Defaults to 'Try Again'.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: iconSize,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: retryLabel,
                onPressed: onRetry,
                width: 150,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// {@template network_error_state}
/// A pre-configured error state for network connectivity issues.
///
/// Displays a WiFi-off icon with a friendly message about
/// checking internet connection.
///
/// ## Appearance
/// - WiFi-off icon
/// - "No Connection" title
/// - Message prompting to check internet connection
/// - Optional retry button
///
/// ## Usage
/// ```dart
/// // When a network request fails due to connectivity
/// if (error is SocketException) {
///   return NetworkErrorState(
///     onRetry: () => retryRequest(),
///   );
/// }
/// ```
///
/// See also:
/// - [ErrorState] for general errors
/// - [ServerErrorState] for server-side errors
/// {@endtemplate}
class NetworkErrorState extends StatelessWidget {
  /// Creates a network error state.
  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  /// Callback when the retry button is pressed.
  ///
  /// If null, no retry button is displayed.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      title: 'No Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
    );
  }
}

/// {@template server_error_state}
/// A pre-configured error state for server-side errors.
///
/// Displays a cloud-off icon with a generic message about
/// something going wrong on the server.
///
/// ## Appearance
/// - Cloud-off icon
/// - "Something Went Wrong" title
/// - Generic error message
/// - Optional retry button
///
/// ## Usage
/// ```dart
/// // When a server request returns a 5xx error
/// if (response.statusCode >= 500) {
///   return ServerErrorState(
///     onRetry: () => retryRequest(),
///   );
/// }
/// ```
///
/// See also:
/// - [ErrorState] for general errors
/// - [NetworkErrorState] for connectivity issues
/// {@endtemplate}
class ServerErrorState extends StatelessWidget {
  /// Creates a server error state.
  const ServerErrorState({
    super.key,
    this.onRetry,
  });

  /// Callback when the retry button is pressed.
  ///
  /// If null, no retry button is displayed.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      title: 'Something Went Wrong',
      message: 'We encountered an error. Please try again later.',
      icon: Icons.cloud_off_outlined,
      onRetry: onRetry,
    );
  }
}

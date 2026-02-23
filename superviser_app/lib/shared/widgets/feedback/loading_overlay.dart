import 'package:flutter/material.dart';

/// {@template loading_overlay}
/// A full-screen loading overlay with a semi-transparent backdrop.
///
/// Displays a centered loading indicator with an optional message.
/// Commonly used during async operations like API calls, form submissions,
/// or data processing to indicate progress and prevent user interaction.
///
/// ## Appearance
/// - Semi-transparent black backdrop (Colors.black54)
/// - Centered card with rounded corners
/// - Circular progress indicator
/// - Optional message text below the indicator
///
/// ## Usage
///
/// As a widget in a Stack:
/// ```dart
/// Stack(
///   children: [
///     MyContent(),
///     if (isLoading)
///       const LoadingOverlay(message: 'Please wait...'),
///   ],
/// )
/// ```
///
/// Using the static [show] method as a dialog:
/// ```dart
/// // Show the overlay
/// LoadingOverlay.show(context, message: 'Saving...');
///
/// try {
///   await saveData();
/// } finally {
///   // Hide the overlay
///   LoadingOverlay.hide(context);
/// }
/// ```
///
/// See also:
/// - [LoadingIndicator] for an inline loading spinner
/// - [LoadingScreen] for a full-screen loading scaffold
/// {@endtemplate}
class LoadingOverlay extends StatelessWidget {
  /// Creates a full-screen loading overlay.
  const LoadingOverlay({
    super.key,
    this.message,
    this.color,
  });

  /// Optional message to display below the loading indicator.
  ///
  /// Displayed with centered alignment using bodyMedium text style.
  final String? message;

  /// Color of the loading indicator.
  ///
  /// If null, uses the theme's primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: color ?? theme.colorScheme.primary,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the loading overlay as a non-dismissible dialog.
  ///
  /// The overlay cannot be dismissed by tapping outside or pressing back.
  /// Use [hide] to programmatically close the overlay.
  ///
  /// Example:
  /// ```dart
  /// LoadingOverlay.show(context, message: 'Processing...');
  /// await doSomethingAsync();
  /// LoadingOverlay.hide(context);
  /// ```
  static Future<void> show(
    BuildContext context, {
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: LoadingOverlay(message: message),
      ),
    );
  }

  /// Hides the currently displayed loading overlay.
  ///
  /// Call this after [show] to dismiss the overlay.
  /// Typically called in a finally block to ensure cleanup.
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// {@template loading_indicator}
/// A simple inline circular loading indicator.
///
/// Use for inline loading states within layouts, buttons, or other
/// components where a full overlay is not needed.
///
/// ## Appearance
/// - Circular progress indicator with customizable size
/// - Customizable stroke width and color
///
/// ## Usage
/// ```dart
/// Center(
///   child: LoadingIndicator(
///     size: 32,
///     strokeWidth: 3,
///     color: Colors.blue,
///   ),
/// )
/// ```
///
/// See also:
/// - [LoadingOverlay] for full-screen loading states
/// - [LoadingScreen] for scaffold-based loading screens
/// {@endtemplate}
class LoadingIndicator extends StatelessWidget {
  /// Creates an inline loading indicator.
  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 2,
    this.color,
  });

  /// The diameter of the loading indicator.
  ///
  /// Defaults to 24 pixels.
  final double size;

  /// The width of the circular stroke.
  ///
  /// Defaults to 2 pixels.
  final double strokeWidth;

  /// The color of the indicator.
  ///
  /// If null, uses the theme's primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// {@template loading_screen}
/// A full-screen scaffold with a centered loading indicator.
///
/// Use when the entire screen content is loading and you need
/// a proper scaffold structure (for theming, safe areas, etc.).
///
/// ## Appearance
/// - Full scaffold with centered content
/// - Circular progress indicator in the center
/// - Optional message below the indicator
///
/// ## Usage
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   if (isLoading) {
///     return const LoadingScreen(message: 'Loading data...');
///   }
///   return MyActualScreen();
/// }
/// ```
///
/// See also:
/// - [LoadingOverlay] for overlay on top of existing content
/// - [LoadingIndicator] for inline loading spinners
/// {@endtemplate}
class LoadingScreen extends StatelessWidget {
  /// Creates a full-screen loading scaffold.
  const LoadingScreen({
    super.key,
    this.message,
  });

  /// Optional message to display below the loading indicator.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

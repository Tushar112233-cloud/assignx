/// A loading overlay wrapper widget.
///
/// This file provides a wrapper component that shows a loading indicator
/// over its child content when loading is in progress.
///
/// ## Features
/// - Semi-transparent backdrop
/// - Centered loading indicator
/// - Optional message text
/// - Customizable overlay color
/// - Prevents user interaction while visible
///
/// ## Example
/// ```dart
/// LoadingOverlay(
///   isLoading: isSubmitting,
///   child: FormContent(),
///   message: 'Saving changes...',
/// )
/// ```
///
/// See also:
/// - [LoadingIndicator] for inline loading states
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'loading_indicator.dart';

/// A loading overlay that shows a loading indicator over content.
///
/// Wraps content and shows a semi-transparent overlay with a loading
/// indicator when [isLoading] is true. Blocks user interaction with
/// the content beneath.
///
/// ## Usage
/// ```dart
/// LoadingOverlay(
///   isLoading: isSubmitting,
///   child: FormContent(),
///   message: 'Saving changes...',
/// )
/// ```
///
/// ## Customization
/// - [overlayColor]: Background color of the overlay
/// - [message]: Optional text displayed below the indicator
///
/// See also:
/// - [LoadingIndicator] for the spinner widget
class LoadingOverlay extends StatelessWidget {
  /// Creates a loading overlay wrapper.
  ///
  /// [isLoading] and [child] are required.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.overlayColor,
    this.message,
  });

  /// Whether to show the loading overlay.
  ///
  /// When true, the overlay is visible and blocks interaction.
  final bool isLoading;

  /// The content to display beneath the overlay.
  final Widget child;

  /// The color of the semi-transparent overlay.
  ///
  /// Defaults to white with 80% opacity.
  final Color? overlayColor;

  /// Optional message to display below the loading indicator.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

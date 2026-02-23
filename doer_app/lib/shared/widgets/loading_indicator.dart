/// Loading indicator widgets for displaying progress states.
///
/// This file provides reusable loading components with various sizes
/// for indicating background operations or data fetching.
///
/// ## Features
/// - Three size options (small, medium, large)
/// - Optional message text
/// - Centered layout for overlay use
/// - Full-screen loading overlay variant
/// - Shimmer placeholder for skeleton loading
///
/// ## Example
/// ```dart
/// LoadingIndicator(
///   size: LoadingIndicatorSize.medium,
///   message: 'Loading projects...',
/// )
/// ```
///
/// See also:
/// - [LoadingOverlay] for full-screen loading states
/// - [ShimmerLoading] for skeleton loading
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Available loading indicator size options.
///
/// Each size provides different dimensions and stroke width:
/// - [small]: 20px diameter, 2px stroke
/// - [medium]: 36px diameter, 3px stroke (default)
/// - [large]: 48px diameter, 4px stroke
enum LoadingIndicatorSize { small, medium, large }

/// A reusable loading indicator widget with optional message.
///
/// Use when content is being loaded or an operation is in progress.
/// Displays a circular progress indicator with optional descriptive text.
///
/// ## Usage
/// ```dart
/// LoadingIndicator(
///   size: LoadingIndicatorSize.medium,
///   message: 'Loading projects...',
/// )
/// ```
///
/// ## Customization
/// - [size]: Predefined size option
/// - [color]: Progress indicator color
/// - [message]: Optional text below the indicator
///
/// See also:
/// - [LoadingIndicatorSize] for available sizes
/// - [LoadingOverlay] for full-screen loading
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator with the specified properties.
  const LoadingIndicator({
    super.key,
    this.size = LoadingIndicatorSize.medium,
    this.color,
    this.message,
  });

  /// The size of the loading indicator.
  ///
  /// Defaults to [LoadingIndicatorSize.medium].
  final LoadingIndicatorSize size;

  /// The color of the progress indicator.
  ///
  /// Defaults to [AppColors.primary].
  final Color? color;

  /// Optional message text displayed below the indicator.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getSize(),
            height: _getSize(),
            child: CircularProgressIndicator(
              strokeWidth: _getStrokeWidth(),
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Returns the indicator diameter based on [size].
  double _getSize() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 20;
      case LoadingIndicatorSize.medium:
        return 36;
      case LoadingIndicatorSize.large:
        return 48;
    }
  }

  /// Returns the stroke width based on [size].
  double _getStrokeWidth() {
    switch (size) {
      case LoadingIndicatorSize.small:
        return 2;
      case LoadingIndicatorSize.medium:
        return 3;
      case LoadingIndicatorSize.large:
        return 4;
    }
  }
}

/// A full-screen loading overlay widget.
///
/// Displays a modal loading state that blocks user interaction
/// and covers the content beneath. Use for operations that require
/// the user to wait before continuing.
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
/// ## Visibility
/// The overlay only appears when [isLoading] is true.
///
/// See also:
/// - [LoadingIndicator] for inline loading states
class LoadingOverlay extends StatelessWidget {
  /// Creates a loading overlay wrapper.
  ///
  /// [isLoading] and [child] are required.
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  /// Whether to show the loading overlay.
  ///
  /// When true, the overlay is visible and blocks interaction.
  final bool isLoading;

  /// The content to display beneath the overlay.
  final Widget child;

  /// Optional message to display in the loading overlay.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: LoadingIndicator(
              size: LoadingIndicatorSize.large,
              color: Colors.white,
              message: message,
            ),
          ),
      ],
    );
  }
}

/// A shimmer loading placeholder for skeleton loading effects.
///
/// Displays a gray placeholder box to indicate where content will appear.
/// Use in lists or grids while content is loading.
///
/// ## Usage
/// ```dart
/// ShimmerLoading(
///   width: 200,
///   height: 100,
///   borderRadius: BorderRadius.circular(8),
/// )
/// ```
///
/// See also:
/// - [LoadingIndicator] for spinner-style loading
class ShimmerLoading extends StatelessWidget {
  /// Creates a shimmer placeholder with the specified dimensions.
  ///
  /// [width] and [height] are required.
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// The width of the placeholder.
  final double width;

  /// The height of the placeholder.
  final double height;

  /// Corner radius for the placeholder.
  ///
  /// Defaults to 4px radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

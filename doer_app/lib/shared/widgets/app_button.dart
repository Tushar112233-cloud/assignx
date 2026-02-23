/// A customizable button widget following the app design system.
///
/// This file provides a reusable button component with multiple variants,
/// sizes, and states for consistent UI across the application.
///
/// ## Features
/// - Multiple button variants (primary, secondary, outline, text)
/// - Three size options (small, medium, large)
/// - Loading state with spinner indicator
/// - Optional leading and trailing icons
/// - Full-width option for form buttons
///
/// ## Example
/// ```dart
/// AppButton(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
///   variant: AppButtonVariant.primary,
///   isLoading: isSubmitting,
/// )
/// ```
///
/// See also:
/// - [AppColors] for the color scheme used
/// - [AppSpacing] for spacing and border radius constants
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Available button style variants.
///
/// Each variant provides a different visual appearance:
/// - [primary]: Solid background with primary color, white text
/// - [secondary]: Solid background with accent color, white text
/// - [outline]: Transparent with primary-colored border and text
/// - [text]: Text only, no background or border
enum AppButtonVariant { primary, secondary, outline, text }

/// Available button size options.
///
/// Each size affects height, padding, and font size:
/// - [small]: Height 36px, compact padding
/// - [medium]: Height 48px, standard padding (default)
/// - [large]: Height 56px, generous padding
enum AppButtonSize { small, medium, large }

/// A customizable button widget following the app design system.
///
/// Supports multiple variants (primary, secondary, outline, text) and states
/// (loading, disabled) with consistent styling.
///
/// ## Usage
/// ```dart
/// AppButton(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
///   variant: AppButtonVariant.primary,
///   isLoading: isSubmitting,
/// )
/// ```
///
/// ## Variants
/// - [AppButtonVariant.primary]: Solid background, primary color
/// - [AppButtonVariant.secondary]: Solid background, accent color
/// - [AppButtonVariant.outline]: Outlined, transparent background
/// - [AppButtonVariant.text]: Text only, no background
///
/// See also:
/// - [AppColors] for the color scheme
/// - [AppSpacing] for sizing constants
class AppButton extends StatelessWidget {
  /// Creates a button with the specified properties.
  ///
  /// The [text] parameter is required and defines the button label.
  /// When [isLoading] is true, a loading indicator replaces the text.
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
  });

  /// The button label text.
  final String text;

  /// Callback invoked when the button is pressed.
  ///
  /// If null, the button will be in a disabled state.
  /// When [isLoading] is true, this callback is also disabled.
  final VoidCallback? onPressed;

  /// The visual style variant of the button.
  ///
  /// Defaults to [AppButtonVariant.primary].
  final AppButtonVariant variant;

  /// The size of the button affecting height and padding.
  ///
  /// Defaults to [AppButtonSize.medium].
  final AppButtonSize size;

  /// Whether to show a loading indicator instead of the text.
  ///
  /// When true, the button is automatically disabled.
  final bool isLoading;

  /// Whether the button should expand to fill available width.
  ///
  /// Useful for form submit buttons.
  final bool isFullWidth;

  /// Optional icon displayed before the text.
  final IconData? icon;

  /// Optional icon displayed after the text.
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(),
    );
  }

  /// Returns the button height based on the selected size.
  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  /// Returns the horizontal padding based on the selected size.
  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
  }

  /// Returns the font size based on the selected size.
  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.large:
        return 16;
    }
  }

  /// Builds the appropriate button widget based on variant.
  Widget _buildButton() {
    final child = _buildChild();

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: _getPadding(),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            textStyle: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        );

      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: _getPadding(),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            textStyle: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        );

      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            side: const BorderSide(color: AppColors.primary),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            textStyle: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: _getPadding(),
            textStyle: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        );
    }
  }

  /// Builds the button content (loading indicator, icon+text, or text only).
  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.outline || variant == AppButtonVariant.text
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    }

    if (icon != null && suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getFontSize() + 4),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
          const SizedBox(width: AppSpacing.sm),
          Icon(suffixIcon, size: _getFontSize() + 4),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getFontSize() + 4),
          const SizedBox(width: AppSpacing.sm),
          Text(text),
        ],
      );
    }

    if (suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          const SizedBox(width: AppSpacing.sm),
          Icon(suffixIcon, size: _getFontSize() + 4),
        ],
      );
    }

    return Text(text);
  }
}

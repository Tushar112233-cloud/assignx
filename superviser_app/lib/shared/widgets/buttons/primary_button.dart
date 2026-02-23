import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

/// {@template primary_button}
/// A filled button with the app's primary color scheme.
///
/// This is the main call-to-action button used throughout the app for
/// primary actions like "Login", "Submit", "Continue", and other important
/// user interactions.
///
/// ## Appearance
/// - Filled background with primary color from theme
/// - White/onPrimary text color
/// - Rounded corners matching the app's elevated button theme
/// - Full width by default (can be customized via [width])
/// - Fixed height of 52px by default (can be customized via [height])
/// - Loading spinner replaces text when [isLoading] is true
///
/// ## States
/// - **Enabled**: Normal interactive state
/// - **Disabled**: When [isEnabled] is false or [onPressed] is null
/// - **Loading**: When [isLoading] is true, shows a circular progress indicator
///
/// ## Usage
/// ```dart
/// PrimaryButton(
///   text: 'Submit',
///   onPressed: () => handleSubmit(),
///   isLoading: isSubmitting,
/// )
/// ```
///
/// With an icon:
/// ```dart
/// PrimaryButton(
///   text: 'Continue',
///   icon: Icons.arrow_forward,
///   iconPosition: IconPosition.right,
///   onPressed: () => navigateNext(),
/// )
/// ```
///
/// See also:
/// - [SecondaryButton] for outlined/secondary actions
/// - [TertiaryButton] for text-only/link-style buttons
/// {@endtemplate}
class PrimaryButton extends StatelessWidget {
  /// Creates a primary button.
  ///
  /// The [text] parameter is required and specifies the button label.
  /// The [onPressed] callback is called when the button is tapped.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 52,
    this.icon,
    this.iconPosition = IconPosition.left,
  });

  /// The button label text.
  ///
  /// Displayed in the center of the button using [AppTypography.buttonMedium].
  final String text;

  /// Callback fired when the button is pressed.
  ///
  /// Set to null to disable the button. The button is also disabled
  /// when [isLoading] or [isEnabled] is false.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of text.
  ///
  /// When true, a [CircularProgressIndicator] is displayed and the button
  /// is automatically disabled.
  ///
  /// Defaults to false.
  final bool isLoading;

  /// Whether the button is enabled.
  ///
  /// When false, the button is disabled and appears with reduced opacity.
  ///
  /// Defaults to true.
  final bool isEnabled;

  /// The button width.
  ///
  /// If null, the button expands to fill its parent width.
  /// Specify a fixed width to constrain the button size.
  final double? width;

  /// The button height.
  ///
  /// Defaults to 52.0 pixels.
  final double height;

  /// An optional icon to display alongside the text.
  ///
  /// The icon is displayed at the position specified by [iconPosition].
  /// Icon size is fixed at 20 pixels.
  final IconData? icon;

  /// The position of the [icon] relative to the [text].
  ///
  /// Defaults to [IconPosition.left].
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(text, style: AppTypography.buttonMedium);
    }

    final iconWidget = Icon(icon, size: 20);
    final textWidget = Text(text, style: AppTypography.buttonMedium);
    const gap = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, gap, textWidget]
          : [textWidget, gap, iconWidget],
    );
  }
}

/// {@template secondary_button}
/// An outlined button for secondary actions.
///
/// Use for less prominent actions like "Cancel", "Back", "Skip", or
/// alternative options that don't require primary emphasis.
///
/// ## Appearance
/// - Transparent background with outlined border
/// - Primary color text and border
/// - Rounded corners matching the app's outlined button theme
/// - Full width by default (can be customized via [width])
/// - Fixed height of 52px by default (can be customized via [height])
/// - Loading spinner when [isLoading] is true
///
/// ## States
/// - **Enabled**: Normal interactive state with primary color outline
/// - **Disabled**: Reduced opacity when [isEnabled] is false
/// - **Loading**: Shows circular progress indicator
///
/// ## Usage
/// ```dart
/// SecondaryButton(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
///
/// See also:
/// - [PrimaryButton] for primary/main actions
/// - [TertiaryButton] for text-only/link-style buttons
/// {@endtemplate}
class SecondaryButton extends StatelessWidget {
  /// Creates a secondary outlined button.
  ///
  /// The [text] parameter is required and specifies the button label.
  /// The [onPressed] callback is called when the button is tapped.
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 52,
    this.icon,
    this.iconPosition = IconPosition.left,
  });

  /// The button label text.
  final String text;

  /// Callback fired when the button is pressed.
  ///
  /// Set to null to disable the button.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of text.
  ///
  /// When true, the button is also disabled.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// The button width.
  ///
  /// If null, the button expands to fill its parent width.
  final double? width;

  /// The button height.
  ///
  /// Defaults to 52.0 pixels.
  final double height;

  /// An optional icon to display alongside the text.
  final IconData? icon;

  /// The position of the [icon] relative to the [text].
  ///
  /// Defaults to [IconPosition.left].
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(text, style: AppTypography.buttonMedium);
    }

    final iconWidget = Icon(icon, size: 20);
    final textWidget = Text(text, style: AppTypography.buttonMedium);
    const gap = SizedBox(width: 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, gap, textWidget]
          : [textWidget, gap, iconWidget],
    );
  }
}

/// {@template tertiary_button}
/// A text-only button for tertiary actions.
///
/// Use for link-style actions like "Forgot password?", "Learn more",
/// "Skip for now", or other low-emphasis interactive text.
///
/// ## Appearance
/// - No background or border
/// - Primary color text
/// - Compact sizing that fits the content
/// - Smaller loading indicator (16px) when [isLoading] is true
///
/// ## States
/// - **Enabled**: Normal interactive state
/// - **Disabled**: Reduced opacity when [isEnabled] is false
/// - **Loading**: Shows small circular progress indicator
///
/// ## Usage
/// ```dart
/// TertiaryButton(
///   text: 'Forgot password?',
///   onPressed: () => navigateToForgotPassword(),
/// )
/// ```
///
/// With trailing icon:
/// ```dart
/// TertiaryButton(
///   text: 'Learn more',
///   icon: Icons.open_in_new,
///   iconPosition: IconPosition.right,
///   onPressed: () => openExternalLink(),
/// )
/// ```
///
/// See also:
/// - [PrimaryButton] for primary/main actions
/// - [SecondaryButton] for outlined/secondary actions
/// {@endtemplate}
class TertiaryButton extends StatelessWidget {
  /// Creates a tertiary text button.
  ///
  /// The [text] parameter is required and specifies the button label.
  /// The [onPressed] callback is called when the button is tapped.
  const TertiaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.iconPosition = IconPosition.left,
  });

  /// The button label text.
  final String text;

  /// Callback fired when the button is pressed.
  ///
  /// Set to null to disable the button.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of text.
  ///
  /// When true, the button is also disabled.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// An optional icon to display alongside the text.
  ///
  /// Icon size is 18 pixels (slightly smaller than other button types).
  final IconData? icon;

  /// The position of the [icon] relative to the [text].
  ///
  /// Defaults to [IconPosition.left].
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (icon == null) {
      return Text(text, style: AppTypography.buttonMedium);
    }

    final iconWidget = Icon(icon, size: 18);
    final textWidget = Text(text, style: AppTypography.buttonMedium);
    const gap = SizedBox(width: 6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: iconPosition == IconPosition.left
          ? [iconWidget, gap, textWidget]
          : [textWidget, gap, iconWidget],
    );
  }
}

/// {@template icon_position}
/// Specifies the position of an icon relative to button text.
///
/// Used by [PrimaryButton], [SecondaryButton], and [TertiaryButton]
/// to control icon placement.
/// {@endtemplate}
enum IconPosition {
  /// Icon appears before (to the left of) the text.
  left,

  /// Icon appears after (to the right of) the text.
  right,
}

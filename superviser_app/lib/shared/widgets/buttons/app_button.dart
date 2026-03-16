/// A customizable button widget following the supervisor app design system.
///
/// This file provides a reusable button component with multiple variants,
/// gradient fills, glass effects, press animations, and loading states
/// for consistent UI across the application.
///
/// ## Features
/// - Multiple button variants (primary, secondary, text)
/// - Gradient-filled primary buttons with charcoal-to-orange gradient
/// - Glass-style secondary buttons with orange border
/// - Press scale animation (0.97) on all variants
/// - Loading state with circular progress indicator
/// - Optional leading and trailing icons with proper spacing
/// - Full-width option for form buttons
/// - Three size options (small, medium, large)
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
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Available button style variants.
///
/// Each variant provides a different visual appearance:
/// - [primary]: Charcoal-to-orange gradient fill (#1C1C1C -> #F97316), white text, pill shape
/// - [secondary]: Glass container with orange border, orange text
/// - [text]: Text-only with orange color, no background or border
enum AppButtonVariant { primary, secondary, text }

/// Available button size options.
///
/// Each size affects height, padding, and font size:
/// - [small]: Height 40px, compact padding
/// - [medium]: Height 52px, standard padding (default)
/// - [large]: Height 56px, generous padding
enum AppButtonSize { small, medium, large }

/// A customizable button widget following the supervisor app design system.
///
/// Supports gradient-filled primary buttons, glass-style secondary buttons,
/// text-only tertiary buttons, press scale animations, and loading states.
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
/// - [AppButtonVariant.primary]: Charcoal-to-orange gradient fill, white text, pill shape
/// - [AppButtonVariant.secondary]: Glass container, orange border, orange text
/// - [AppButtonVariant.text]: Text only, orange color, no background
///
/// See also:
/// - [AppColors] for the color scheme
/// - [AppSpacing] for sizing constants
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  /// Whether the button is currently disabled (null callback or loading).
  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isDisabled) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _isDisabled ? null : widget.onPressed,
        child: _wrapDisabled(
          SizedBox(
            width: widget.isFullWidth ? double.infinity : null,
            height: _getHeight(),
            child: _buildButton(),
          ),
        ),
      ),
    );
  }

  /// Wraps child with Opacity only when disabled (avoids unnecessary Opacity layer).
  Widget _wrapDisabled(Widget child) {
    return _isDisabled ? Opacity(opacity: 0.5, child: child) : child;
  }

  /// Returns the button height based on the selected size.
  double _getHeight() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 56;
    }
  }

  /// Returns the horizontal padding based on the selected size.
  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    }
  }

  /// Returns the font size based on the selected size.
  double _getFontSize() {
    switch (widget.size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  /// Pill-shaped border radius (14px) for primary buttons.
  static const BorderRadius _pillRadius =
      BorderRadius.all(Radius.circular(14));

  /// Builds the appropriate button widget based on variant.
  Widget _buildButton() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _buildPrimaryButton();
      case AppButtonVariant.secondary:
        return _buildSecondaryButton();
      case AppButtonVariant.text:
        return _buildTextButton();
    }
  }

  /// Builds the gradient-filled primary button.
  ///
  /// Uses a charcoal-to-orange gradient (#1C1C1C -> #F97316) with white text
  /// and a pill shape (radius 14).
  Widget _buildPrimaryButton() {
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        borderRadius: _pillRadius,
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientEnd.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: _buildChild(Colors.white)),
    );
  }

  /// Builds the glass-style secondary button.
  ///
  /// Uses a glass morphism background with an orange border and orange text.
  Widget _buildSecondaryButton() {
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: _pillRadius,
        border: Border.all(
          color: AppColors.accent.withAlpha(128),
          width: 1.5,
        ),
      ),
      child: Center(child: _buildChild(AppColors.accent)),
    );
  }

  /// Builds the text-only button.
  ///
  /// Renders text (and optional icons) in orange with no background.
  Widget _buildTextButton() {
    return Container(
      padding: _getPadding(),
      child: Center(child: _buildChild(AppColors.accent)),
    );
  }

  /// Builds the button content (loading indicator, icon+text, or text only).
  ///
  /// The [color] parameter determines the foreground color for text, icons,
  /// and the loading indicator.
  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      ),
    );

    final iconSize = _getFontSize() + 4;

    if (widget.icon != null && widget.suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: iconSize, color: color),
          const SizedBox(width: AppSpacing.sm),
          textWidget,
          const SizedBox(width: AppSpacing.sm),
          Icon(widget.suffixIcon, size: iconSize, color: color),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: iconSize, color: color),
          const SizedBox(width: AppSpacing.sm),
          textWidget,
        ],
      );
    }

    if (widget.suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          const SizedBox(width: AppSpacing.sm),
          Icon(widget.suffixIcon, size: iconSize, color: color),
        ],
      );
    }

    return textWidget;
  }
}

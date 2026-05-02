/// A customizable text field widget following the app design system.
///
/// This file provides reusable text input components with consistent styling,
/// validation support, and special variants for common input types.
///
/// ## Features
/// - Label and helper text support
/// - Error state handling
/// - Password visibility toggle
/// - Prefix and suffix icons
/// - Input formatters and keyboard types
/// - Phone number variant with country code
///
/// ## Example
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => validateEmail(value),
/// )
/// ```
///
/// See also:
/// - [AppPhoneField] for phone number input
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A customizable text field widget following the app design system.
///
/// Provides consistent text input styling with support for labels, hints,
/// validation, icons, and various input types.
///
/// ## Usage
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => validateEmail(value),
/// )
/// ```
///
/// ## Password Fields
/// When [obscureText] is true, automatically adds a visibility toggle button.
///
/// See also:
/// - [AppPhoneField] for phone number input with country code
class AppTextField extends StatefulWidget {
  /// Creates a text field with the specified properties.
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  /// The label text displayed above the field.
  final String? label;

  /// The hint text displayed when the field is empty.
  final String? hint;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Error text that overrides helper text and shows error styling.
  final String? errorText;

  /// Controller for managing the text field value.
  final TextEditingController? controller;

  /// Validation function called on form validation.
  ///
  /// Returns an error message string if invalid, null if valid.
  final String? Function(String?)? validator;

  /// Callback invoked when the text value changes.
  final void Function(String)? onChanged;

  /// Callback invoked when the user submits (e.g., presses enter).
  final void Function(String)? onSubmitted;

  /// The keyboard type to display.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  /// The action button on the keyboard.
  ///
  /// Defaults to [TextInputAction.next].
  final TextInputAction textInputAction;

  /// Whether to obscure the text (for passwords).
  ///
  /// When true, automatically adds a visibility toggle button.
  final bool obscureText;

  /// Whether the field is enabled for input.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Maximum number of lines for multi-line input.
  ///
  /// Ignored when [obscureText] is true.
  final int maxLines;

  /// Maximum character length.
  final int? maxLength;

  /// Widget displayed before the input area.
  final Widget? prefix;

  /// Widget displayed after the input area.
  final Widget? suffix;

  /// Icon displayed as a prefix.
  final IconData? prefixIcon;

  /// Icon displayed as a suffix.
  ///
  /// Tappable when [onSuffixTap] is provided.
  final IconData? suffixIcon;

  /// Callback invoked when the suffix icon is tapped.
  final VoidCallback? onSuffixTap;

  /// Input formatters to restrict or format input.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node for managing focus state.
  final FocusNode? focusNode;

  /// Whether to auto-focus this field.
  final bool autofocus;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            prefix: widget.prefix,
            suffix: widget.suffix,
            suffixIcon: _buildSuffixIcon(),
            counterText: '',
          ),
        ),
      ],
    );
  }

  /// Builds the suffix icon widget.
  ///
  /// For password fields, returns a visibility toggle.
  /// For other fields with [suffixIcon], returns a tappable icon button.
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, size: 20, color: AppColors.textSecondary),
        onPressed: widget.onSuffixTap,
      );
    }

    return null;
  }
}

/// A phone number text field with country code prefix.
///
/// Provides a specialized text field for phone number input with:
/// - Country code prefix display
/// - Digit-only input filtering
/// - 10-digit length limit (configurable)
///
/// ## Usage
/// ```dart
/// AppPhoneField(
///   label: 'Phone Number',
///   controller: phoneController,
///   validator: (value) => validatePhone(value),
/// )
/// ```
///
/// See also:
/// - [AppTextField] for general text input
class AppPhoneField extends StatelessWidget {
  /// Creates a phone number field with the specified properties.
  const AppPhoneField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.countryCode = '+91',
  });

  /// The label text displayed above the field.
  final String? label;

  /// Controller for managing the phone number value.
  final TextEditingController? controller;

  /// Validation function called on form validation.
  final String? Function(String?)? validator;

  /// Callback invoked when the phone number changes.
  final void Function(String)? onChanged;

  /// Whether the field is enabled for input.
  final bool enabled;

  /// The country code prefix to display.
  ///
  /// Defaults to '+91' (India).
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: 'Enter phone number',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      prefix: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: Text(
          countryCode,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }
}

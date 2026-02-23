import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template app_text_field}
/// A customizable text field widget with consistent styling across the app.
///
/// This is the base text field component that supports various configurations
/// including password visibility toggle, prefix/suffix icons, validation,
/// multiline input, and more.
///
/// ## Appearance
/// - Filled background with rounded corners
/// - Optional label displayed above the field
/// - Hint text when the field is empty
/// - Helper text or error text displayed below
/// - Prefix and suffix icons with consistent sizing (20px)
///
/// ## Features
/// - Password visibility toggle when [showPasswordToggle] is true
/// - Form validation via [validator]
/// - Input formatting via [inputFormatters]
/// - Multiline support with [maxLines] and [minLines]
/// - Character limit with [maxLength]
///
/// ## Usage
/// Basic text field:
/// ```dart
/// AppTextField(
///   controller: _nameController,
///   label: 'Full Name',
///   hint: 'Enter your full name',
///   prefixIcon: Icons.person_outline,
/// )
/// ```
///
/// Password field with visibility toggle:
/// ```dart
/// AppTextField(
///   controller: _passwordController,
///   label: 'Password',
///   hint: 'Enter your password',
///   obscureText: true,
///   showPasswordToggle: true,
///   prefixIcon: Icons.lock_outline,
/// )
/// ```
///
/// Multiline text area:
/// ```dart
/// AppTextField(
///   controller: _bioController,
///   label: 'Bio',
///   hint: 'Tell us about yourself',
///   maxLines: 5,
///   minLines: 3,
/// )
/// ```
///
/// See also:
/// - [EmailTextField] for email-specific input
/// - [PasswordTextField] for password-specific input with visibility toggle
/// {@endtemplate}
class AppTextField extends StatefulWidget {
  /// Creates a customizable text field.
  ///
  /// All parameters are optional except when specific functionality is needed.
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.onTap,
    this.fillColor,
  });

  /// Controls the text being edited.
  ///
  /// If null, the field creates its own internal controller.
  final TextEditingController? controller;

  /// Label text displayed above the text field.
  ///
  /// Displayed with [FontWeight.w500] styling.
  final String? label;

  /// Hint text displayed when the field is empty.
  ///
  /// Appears in a lighter color inside the field.
  final String? hint;

  /// Helper text displayed below the field.
  ///
  /// Provides additional context or instructions.
  /// Overridden by [errorText] when present.
  final String? helperText;

  /// Error text displayed below the field.
  ///
  /// Displayed in the error color and takes precedence over [helperText].
  final String? errorText;

  /// Icon displayed at the start (left) of the field.
  ///
  /// Size is fixed at 20 pixels.
  final IconData? prefixIcon;

  /// Icon displayed at the end (right) of the field.
  ///
  /// When [showPasswordToggle] is true and [obscureText] is true,
  /// this is overridden by the visibility toggle icon.
  final IconData? suffixIcon;

  /// Callback when the suffix icon is tapped.
  ///
  /// Only called when [suffixIcon] is provided and
  /// [showPasswordToggle] is false.
  final VoidCallback? onSuffixTap;

  /// Whether to hide the text being edited.
  ///
  /// When true, text is replaced with dots.
  /// Commonly used for password fields.
  final bool obscureText;

  /// Whether to show a password visibility toggle button.
  ///
  /// Only effective when [obscureText] is true.
  /// Displays an eye icon that toggles text visibility.
  final bool showPasswordToggle;

  /// The type of keyboard to use for editing the text.
  ///
  /// Examples: [TextInputType.emailAddress], [TextInputType.number].
  final TextInputType? keyboardType;

  /// The action button to use for the keyboard.
  ///
  /// Examples: [TextInputAction.next], [TextInputAction.done].
  final TextInputAction? textInputAction;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates they are done editing the text.
  final ValueChanged<String>? onSubmitted;

  /// Form validation function.
  ///
  /// Returns an error string if validation fails, null otherwise.
  final String? Function(String?)? validator;

  /// Optional input formatters that restrict/format input.
  ///
  /// Examples: [FilteringTextInputFormatter], [LengthLimitingTextInputFormatter].
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of lines for the text field.
  ///
  /// Set to null for unlimited lines. Forced to 1 when [obscureText] is true.
  final int? maxLines;

  /// Minimum number of lines for the text field.
  ///
  /// Useful for text areas that should start with a certain height.
  final int? minLines;

  /// Maximum character length for the input.
  ///
  /// The character counter is hidden via [InputDecoration.counterText].
  final int? maxLength;

  /// Whether the text field is enabled.
  ///
  /// When false, the field is not editable and appears grayed out.
  final bool enabled;

  /// Whether the text field is read-only.
  ///
  /// When true, the field can be focused but not edited.
  final bool readOnly;

  /// Whether to focus this field automatically.
  final bool autofocus;

  /// Whether to enable autocorrect.
  ///
  /// Disabled by default for email and password fields.
  final bool autocorrect;

  /// Whether to enable input suggestions.
  ///
  /// Disabled by default for email and password fields.
  final bool enableSuggestions;

  /// How to capitalize text input.
  ///
  /// Defaults to [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  /// Focus node for controlling focus programmatically.
  final FocusNode? focusNode;

  /// Callback when the field is tapped.
  ///
  /// Useful for showing date pickers or other overlays.
  final VoidCallback? onTap;

  /// Custom fill color for the text field background.
  ///
  /// If null, uses the theme's default input decoration fill color.
  final Color? fillColor;

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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          textCapitalization: widget.textCapitalization,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.fillColor,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
            suffixIcon: _buildSuffixIcon(),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
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
        icon: Icon(widget.suffixIcon, size: 20),
        onPressed: widget.onSuffixTap,
      );
    }

    return null;
  }
}

/// {@template email_text_field}
/// A pre-configured text field optimized for email input.
///
/// This widget wraps [AppTextField] with email-specific settings:
/// - Email keyboard type
/// - Email icon prefix
/// - Autocorrect and suggestions disabled
///
/// ## Appearance
/// - Email icon (envelope) as prefix
/// - Default label "Email"
/// - Default hint "Enter your email"
///
/// ## Usage
/// ```dart
/// EmailTextField(
///   controller: _emailController,
///   onChanged: (value) => validateEmail(value),
///   validator: (value) {
///     if (value == null || !value.contains('@')) {
///       return 'Please enter a valid email';
///     }
///     return null;
///   },
/// )
/// ```
///
/// See also:
/// - [AppTextField] for a fully customizable text field
/// - [PasswordTextField] for password input
/// {@endtemplate}
class EmailTextField extends StatelessWidget {
  /// Creates an email text field with optimized settings.
  const EmailTextField({
    super.key,
    this.controller,
    this.label = 'Email',
    this.hint = 'Enter your email',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.focusNode,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label text displayed above the field.
  ///
  /// Defaults to 'Email'.
  final String? label;

  /// Hint text displayed when the field is empty.
  ///
  /// Defaults to 'Enter your email'.
  final String? hint;

  /// Error text displayed below the field.
  final String? errorText;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates they are done editing.
  final ValueChanged<String>? onSubmitted;

  /// Form validation function.
  final String? Function(String?)? validator;

  /// The action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.next].
  final TextInputAction textInputAction;

  /// Whether to focus this field automatically.
  final bool autofocus;

  /// Focus node for controlling focus programmatically.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      autofocus: autofocus,
      focusNode: focusNode,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

/// {@template password_text_field}
/// A pre-configured text field optimized for password input.
///
/// This widget wraps [AppTextField] with password-specific settings:
/// - Obscured text (dots instead of characters)
/// - Password visibility toggle button
/// - Lock icon prefix
/// - Autocorrect and suggestions disabled
///
/// ## Appearance
/// - Lock icon as prefix
/// - Eye icon toggle for visibility
/// - Default label "Password"
/// - Default hint "Enter your password"
/// - Text obscured by default
///
/// ## Usage
/// ```dart
/// PasswordTextField(
///   controller: _passwordController,
///   validator: (value) {
///     if (value == null || value.length < 8) {
///       return 'Password must be at least 8 characters';
///     }
///     return null;
///   },
/// )
/// ```
///
/// See also:
/// - [AppTextField] for a fully customizable text field
/// - [EmailTextField] for email input
/// {@endtemplate}
class PasswordTextField extends StatelessWidget {
  /// Creates a password text field with visibility toggle.
  const PasswordTextField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Label text displayed above the field.
  ///
  /// Defaults to 'Password'.
  final String? label;

  /// Hint text displayed when the field is empty.
  ///
  /// Defaults to 'Enter your password'.
  final String? hint;

  /// Error text displayed below the field.
  final String? errorText;

  /// Called when the text being edited changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates they are done editing.
  final ValueChanged<String>? onSubmitted;

  /// Form validation function.
  final String? Function(String?)? validator;

  /// The action button to use for the keyboard.
  ///
  /// Defaults to [TextInputAction.done].
  final TextInputAction textInputAction;

  /// Focus node for controlling focus programmatically.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      prefixIcon: Icons.lock_outlined,
      obscureText: true,
      showPasswordToggle: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

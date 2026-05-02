import 'package:flutter/material.dart';

/// {@template context_extensions}
/// Extension methods on [BuildContext] for convenient access to theme,
/// media query, navigation, and other commonly used Flutter APIs.
///
/// These extensions reduce boilerplate and improve code readability by
/// providing direct access to frequently used context-based properties.
///
/// ## Categories
/// - **Theme**: Access to colors, text styles, and theme mode
/// - **Media Query**: Screen dimensions, safe areas, and keyboard state
/// - **Responsive Breakpoints**: Device size detection
/// - **Navigation**: Pop operations and route checking
/// - **Focus**: Keyboard dismissal and focus management
/// - **Snackbar**: Quick display of feedback messages
///
/// ## Usage
/// ```dart
/// // Instead of: Theme.of(context).colorScheme.primary
/// final primaryColor = context.colorScheme.primary;
///
/// // Instead of: MediaQuery.of(context).size.width
/// final width = context.screenWidth;
///
/// // Instead of: Navigator.of(context).pop()
/// context.pop();
///
/// // Quick snackbar
/// context.showSnackBar('Item saved successfully');
/// ```
/// {@endtemplate}
extension ContextExtensions on BuildContext {
  // ============ Theme ============

  /// Returns the current [ThemeData].
  ///
  /// Shorthand for `Theme.of(context)`.
  ///
  /// Example:
  /// ```dart
  /// final theme = context.theme;
  /// final buttonStyle = theme.elevatedButtonTheme;
  /// ```
  ThemeData get theme => Theme.of(this);

  /// Returns the current [ColorScheme].
  ///
  /// Shorthand for `Theme.of(context).colorScheme`.
  ///
  /// Example:
  /// ```dart
  /// Container(color: context.colorScheme.primary)
  /// ```
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current [TextTheme].
  ///
  /// Shorthand for `Theme.of(context).textTheme`.
  ///
  /// Example:
  /// ```dart
  /// Text('Title', style: context.textTheme.headlineMedium)
  /// ```
  TextTheme get textTheme => theme.textTheme;

  /// Returns true if dark mode is enabled.
  ///
  /// Example:
  /// ```dart
  /// final iconColor = context.isDarkMode ? Colors.white : Colors.black;
  /// ```
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ============ Media Query ============

  /// Returns the [MediaQueryData] for this context.
  ///
  /// Provides access to device information like screen size,
  /// orientation, and platform brightness.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the screen size.
  ///
  /// Shorthand for `MediaQuery.of(context).size`.
  Size get screenSize => mediaQuery.size;

  /// Returns the screen width in logical pixels.
  ///
  /// Example:
  /// ```dart
  /// Container(width: context.screenWidth * 0.8)
  /// ```
  double get screenWidth => screenSize.width;

  /// Returns the screen height in logical pixels.
  ///
  /// Example:
  /// ```dart
  /// Container(height: context.screenHeight / 2)
  /// ```
  double get screenHeight => screenSize.height;

  /// Returns the padding for safe areas (notch, status bar, etc.).
  ///
  /// Use to position content that should avoid system UI.
  ///
  /// Example:
  /// ```dart
  /// Padding(padding: EdgeInsets.only(top: context.padding.top))
  /// ```
  EdgeInsets get padding => mediaQuery.padding;

  /// Returns the view insets (typically keyboard height).
  ///
  /// Example:
  /// ```dart
  /// final bottomPadding = context.viewInsets.bottom;
  /// ```
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Returns true if the keyboard is currently visible.
  ///
  /// Useful for adjusting layout when keyboard appears.
  ///
  /// Example:
  /// ```dart
  /// if (!context.isKeyboardVisible) {
  ///   showBottomNavigation();
  /// }
  /// ```
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Returns the device pixel ratio.
  ///
  /// Useful for calculations involving actual device pixels.
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  // ============ Responsive Breakpoints ============

  /// Returns true if the screen width is less than 600 pixels.
  ///
  /// Indicates a mobile phone form factor.
  ///
  /// Example:
  /// ```dart
  /// if (context.isMobile) {
  ///   return MobileLayout();
  /// }
  /// ```
  bool get isMobile => screenWidth < 600;

  /// Returns true if the screen width is between 600 and 900 pixels.
  ///
  /// Indicates a tablet form factor.
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Returns true if the screen width is 900 pixels or greater.
  ///
  /// Indicates a desktop/large screen form factor.
  bool get isDesktop => screenWidth >= 900;

  // ============ Navigation ============

  /// Pops the current route from the navigation stack.
  ///
  /// Optionally returns a [result] to the previous route.
  ///
  /// Example:
  /// ```dart
  /// // Simple pop
  /// context.pop();
  ///
  /// // Pop with result
  /// context.pop(selectedItem);
  /// ```
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Returns true if the current route can be popped.
  ///
  /// Useful for conditionally showing back buttons.
  ///
  /// Example:
  /// ```dart
  /// if (context.canPop) {
  ///   IconButton(onPressed: context.pop, icon: Icon(Icons.arrow_back))
  /// }
  /// ```
  bool get canPop => Navigator.of(this).canPop();

  // ============ Focus ============

  /// Unfocuses the current focus node, typically hiding the keyboard.
  ///
  /// Example:
  /// ```dart
  /// GestureDetector(
  ///   onTap: () => context.unfocus(),
  ///   child: child,
  /// )
  /// ```
  void unfocus() => FocusScope.of(this).unfocus();

  /// Requests focus on a specific [FocusNode].
  ///
  /// Example:
  /// ```dart
  /// context.requestFocus(passwordFocusNode);
  /// ```
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // ============ Snackbar ============

  /// Shows a snackbar with the given [message].
  ///
  /// Returns a controller that can be used to hide or interact
  /// with the snackbar.
  ///
  /// Example:
  /// ```dart
  /// context.showSnackBar('Item saved');
  ///
  /// // With action
  /// context.showSnackBar(
  ///   'Item deleted',
  ///   action: SnackBarAction(label: 'Undo', onPressed: undoDelete),
  /// );
  /// ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
      ),
    );
  }

  /// Shows an error snackbar with the given [message].
  ///
  /// Displays with error color background for visual distinction.
  ///
  /// Example:
  /// ```dart
  /// context.showErrorSnackBar('Failed to save changes');
  /// ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: duration,
      ),
    );
  }

  /// Shows a success snackbar with the given [message].
  ///
  /// Displays with green background for positive feedback.
  ///
  /// Example:
  /// ```dart
  /// context.showSuccessSnackBar('Profile updated successfully');
  /// ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration,
      ),
    );
  }

  /// Hides the currently displayed snackbar.
  ///
  /// Example:
  /// ```dart
  /// context.hideSnackBar();
  /// ```
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}

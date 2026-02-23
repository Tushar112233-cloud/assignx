import 'package:flutter/material.dart';

/// String extensions for common operations.
extension StringExtensions on String {
  /// Capitalize first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is valid email.
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is valid phone number.
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'\s|-'), ''));
  }

  /// Get initials from name.
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

/// DateTime extensions.
extension DateTimeExtensions on DateTime {
  /// Format as readable date (e.g., "Dec 27, 2025").
  String get formatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Format as short date (e.g., "27/12/2025").
  String get shortFormatted => '$day/$month/$year';

  /// Check if date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Get time until this date.
  Duration get timeUntil => difference(DateTime.now());

  /// Get time since this date.
  Duration get timeSince => DateTime.now().difference(this);
}

/// BuildContext extensions.
extension ContextExtensions on BuildContext {
  /// Get theme data.
  ThemeData get theme => Theme.of(this);

  /// Get color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Get screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width.
  double get screenWidth => screenSize.width;

  /// Get screen height.
  double get screenHeight => screenSize.height;

  /// Get view padding.
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Get bottom padding (safe area).
  double get bottomPadding => viewPadding.bottom;

  /// Get top padding (status bar).
  double get topPadding => viewPadding.top;

  /// Check if keyboard is visible.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  /// Show snackbar.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Show loading dialog.
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog.
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}

/// Widget extensions.
extension WidgetExtensions on Widget {
  /// Wrap with padding.
  Widget padAll(double padding) => Padding(
        padding: EdgeInsets.all(padding),
        child: this,
      );

  /// Wrap with horizontal padding.
  Widget padHorizontal(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );

  /// Wrap with vertical padding.
  Widget padVertical(double padding) => Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: this,
      );

  /// Center the widget.
  Widget get centered => Center(child: this);

  /// Make widget expanded.
  Widget get expanded => Expanded(child: this);
}

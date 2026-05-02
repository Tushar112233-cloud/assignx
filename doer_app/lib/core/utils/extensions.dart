/// Dart extension methods for common types.
///
/// This file provides extension methods on built-in Dart types and
/// Flutter classes to add convenient functionality throughout the app.
///
/// ## Extensions
/// - [StringExtensions]: String manipulation and validation
/// - [DateTimeExtensions]: Date formatting and comparison
/// - [NumberExtensions]: Number formatting (currency, compact, percentage)
/// - [ContextExtensions]: BuildContext conveniences
/// - [ListExtensions]: Safe list access
///
/// ## Usage
/// Extensions are automatically available when this file is imported:
/// ```dart
/// import 'package:doer_app/core/utils/extensions.dart';
///
/// 'hello world'.capitalizeWords(); // "Hello World"
/// DateTime.now().formattedDate;    // "Dec 27, 2025"
/// 1500.toCurrency;                 // "Rs.1,500"
/// context.screenWidth;             // 375.0
/// ```
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions.
///
/// Provides common string manipulation and validation methods.
extension StringExtensions on String {
  /// Capitalizes the first letter.
  ///
  /// Returns the string with first character uppercase, rest unchanged.
  ///
  /// ## Example
  /// ```dart
  /// 'hello'.capitalize(); // "Hello"
  /// 'WORLD'.capitalize(); // "WORLD"
  /// ''.capitalize();      // ""
  /// ```
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word.
  ///
  /// Splits by spaces and capitalizes the first letter of each word.
  ///
  /// ## Example
  /// ```dart
  /// 'hello world'.capitalizeWords(); // "Hello World"
  /// 'the quick brown fox'.capitalizeWords(); // "The Quick Brown Fox"
  /// ```
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Checks if string is a valid email.
  ///
  /// Uses a standard email regex pattern.
  ///
  /// ## Example
  /// ```dart
  /// 'user@example.com'.isValidEmail; // true
  /// 'invalid-email'.isValidEmail;    // false
  /// ```
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Checks if string is a valid phone number (Indian).
  ///
  /// Validates 10-digit Indian mobile numbers starting with 6-9.
  ///
  /// ## Example
  /// ```dart
  /// '9876543210'.isValidPhone; // true
  /// '1234567890'.isValidPhone; // false
  /// ```
  bool get isValidPhone {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(this);
  }

  /// Truncates string to specified length.
  ///
  /// If the string is longer than [maxLength], it is truncated and
  /// [suffix] is appended.
  ///
  /// @param maxLength Maximum length including suffix
  /// @param suffix String to append when truncated (default: '...')
  ///
  /// ## Example
  /// ```dart
  /// 'Hello World'.truncate(8);        // "Hello..."
  /// 'Hi'.truncate(10);                // "Hi"
  /// 'Long text'.truncate(7, suffix: '-'); // "Long t-"
  /// ```
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
}

/// DateTime extensions.
///
/// Provides date/time formatting and comparison methods.
extension DateTimeExtensions on DateTime {
  /// Formats date as "Dec 27, 2025".
  ///
  /// Uses abbreviated month name with day and full year.
  String get formattedDate => DateFormat('MMM d, y').format(this);

  /// Formats time as "10:30 AM".
  ///
  /// Uses 12-hour format with AM/PM indicator.
  String get formattedTime => DateFormat('h:mm a').format(this);

  /// Formats as "Dec 27, 2025 at 10:30 AM".
  ///
  /// Combines date and time with "at" separator.
  String get formattedDateTime => DateFormat('MMM d, y \'at\' h:mm a').format(this);

  /// Formats as relative time (e.g., "2 hours ago").
  ///
  /// Returns human-readable time difference from now.
  ///
  /// ## Example
  /// ```dart
  /// DateTime.now().subtract(Duration(hours: 2)).timeAgo; // "2 hours ago"
  /// DateTime.now().subtract(Duration(days: 1)).timeAgo;  // "1 day ago"
  /// DateTime.now().timeAgo;                               // "Just now"
  /// ```
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns countdown string (e.g., "2h 30m left").
  ///
  /// Calculates time remaining until [target] date.
  /// Returns "Overdue" if target is in the past.
  ///
  /// @param target The target datetime to count down to
  ///
  /// ## Example
  /// ```dart
  /// final now = DateTime.now();
  /// final deadline = now.add(Duration(hours: 5, minutes: 30));
  /// now.countdownTo(deadline); // "5h 30m left"
  /// ```
  String countdownTo(DateTime target) {
    final difference = target.difference(this);
    if (difference.isNegative) return 'Overdue';

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else {
      return '${difference.inMinutes}m left';
    }
  }

  /// Checks if date is today.
  ///
  /// Compares year, month, and day with current date.
  ///
  /// ## Example
  /// ```dart
  /// DateTime.now().isToday;                                // true
  /// DateTime.now().add(Duration(days: 1)).isToday;         // false
  /// ```
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if date is within 6 hours (urgent).
  ///
  /// Used for deadline urgency indicators. Returns true if the date
  /// is in the future but less than 6 hours away.
  ///
  /// ## Example
  /// ```dart
  /// DateTime.now().add(Duration(hours: 3)).isUrgent; // true
  /// DateTime.now().add(Duration(hours: 8)).isUrgent; // false
  /// ```
  bool get isUrgent {
    final now = DateTime.now();
    return difference(now).inHours <= 6 && difference(now).inHours >= 0;
  }
}

/// Number extensions.
///
/// Provides number formatting methods for display.
extension NumberExtensions on num {
  /// Formats number as currency (Indian Rupee).
  ///
  /// Uses Indian locale formatting with Rupee symbol.
  ///
  /// ## Example
  /// ```dart
  /// 1500.toCurrency;    // "Rs.1,500"
  /// 1000000.toCurrency; // "Rs.10,00,000"
  /// ```
  String get toCurrency => NumberFormat.currency(
        locale: 'en_IN',
        symbol: '\u20B9',
        decimalDigits: 0,
      ).format(this);

  /// Formats as compact number (e.g., 1.5K).
  ///
  /// Uses compact notation for large numbers.
  ///
  /// ## Example
  /// ```dart
  /// 1500.toCompact;    // "1.5K"
  /// 1000000.toCompact; // "1M"
  /// ```
  String get toCompact => NumberFormat.compact().format(this);

  /// Formats as percentage.
  ///
  /// Appends '%' symbol to the number.
  ///
  /// @param decimals Number of decimal places (default: 0)
  ///
  /// ## Example
  /// ```dart
  /// 75.toPercent();   // "75%"
  /// 75.5.toPercent(1); // "75.5%"
  /// ```
  String toPercent([int decimals = 0]) =>
      '${toStringAsFixed(decimals)}%';
}

/// BuildContext extensions.
///
/// Provides convenient accessors for common BuildContext properties.
extension ContextExtensions on BuildContext {
  /// Returns screen width.
  ///
  /// Shorthand for `MediaQuery.of(context).size.width`.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Returns screen height.
  ///
  /// Shorthand for `MediaQuery.of(context).size.height`.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns current theme.
  ///
  /// Shorthand for `Theme.of(context)`.
  ThemeData get theme => Theme.of(this);

  /// Returns text theme.
  ///
  /// Shorthand for `Theme.of(context).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns color scheme.
  ///
  /// Shorthand for `Theme.of(context).colorScheme`.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shows a snackbar.
  ///
  /// Displays a snackbar with the given message. Optionally styled
  /// as an error snackbar.
  ///
  /// @param message The message to display
  /// @param isError Whether to style as error (red background)
  ///
  /// ## Example
  /// ```dart
  /// context.showSnackBar('Saved successfully');
  /// context.showSnackBar('Failed to save', isError: true);
  /// ```
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Shows a loading dialog.
  ///
  /// Displays a centered circular progress indicator that blocks
  /// user interaction. Call [hideLoadingDialog] to dismiss.
  ///
  /// ## Example
  /// ```dart
  /// context.showLoadingDialog();
  /// await performOperation();
  /// context.hideLoadingDialog();
  /// ```
  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hides loading dialog.
  ///
  /// Pops the current dialog route. Should be called after
  /// [showLoadingDialog].
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}

/// List extensions.
///
/// Provides safe access methods for lists.
extension ListExtensions<T> on List<T> {
  /// Safely gets element at index or returns null.
  ///
  /// Returns `null` if index is out of bounds, preventing
  /// RangeError exceptions.
  ///
  /// @param index The index to access
  /// @returns The element at index, or null if out of bounds
  ///
  /// ## Example
  /// ```dart
  /// final list = ['a', 'b', 'c'];
  /// list.safeGet(1);  // 'b'
  /// list.safeGet(5);  // null
  /// list.safeGet(-1); // null
  /// ```
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

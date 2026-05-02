/// Formatting utilities for the Superviser App.
///
/// This file provides reusable formatting functions for common data types
/// including dates, times, numbers, currencies, and text. All formatters
/// handle null values gracefully with configurable fallback text.
///
/// ## Formatting Categories
///
/// - **Date/Time**: Format dates, times, relative times
/// - **Duration**: Human-readable duration strings
/// - **Numbers**: Currency, decimals, percentages
/// - **Text**: Truncation, title case, initials
/// - **Phone**: Phone number formatting
/// - **File Size**: Human-readable file sizes
///
/// ## Null Safety
///
/// All formatters accept nullable input and return a fallback value
/// (default: '-') when the input is null:
///
/// ```dart
/// Formatters.date(null);  // Returns '-'
/// Formatters.date(null, fallback: 'N/A');  // Returns 'N/A'
/// ```
///
/// ## Dependencies
///
/// - `intl` package for date and number formatting
/// - `timeago` package for relative time formatting
///
/// See also:
/// - [Validators] for input validation
/// - [AppConstants] for app-wide constants
library;

import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Provides static formatting functions for various data types.
///
/// This abstract class serves as a namespace for formatter functions.
/// All formatters are static methods that handle null values gracefully.
///
/// ## Example
///
/// ```dart
/// // Date formatting
/// Text(Formatters.date(DateTime.now()));  // 'Dec 28, 2024'
///
/// // Currency formatting
/// Text(Formatters.currency(1234.56));  // '₹1,234.56'
///
/// // Relative time
/// Text(Formatters.timeAgo(someDateTime));  // '2 hours ago'
/// ```
abstract class Formatters {
  /// Formats a [DateTime] to a readable date string.
  ///
  /// Format: 'MMM d, yyyy' (e.g., 'Dec 28, 2024')
  ///
  /// ## Parameters
  ///
  /// - [date]: The date to format
  /// - [fallback]: Value to return if date is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted date string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.date(DateTime(2024, 12, 28));  // 'Dec 28, 2024'
  /// Formatters.date(null);                     // '-'
  /// Formatters.date(null, fallback: 'TBD');   // 'TBD'
  /// ```
  static String date(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Formats a [DateTime] to a readable time string.
  ///
  /// Format: 'h:mm a' (e.g., '2:30 PM')
  ///
  /// ## Parameters
  ///
  /// - [date]: The datetime to extract time from
  /// - [fallback]: Value to return if date is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted time string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.time(DateTime(2024, 12, 28, 14, 30));  // '2:30 PM'
  /// ```
  static String time(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('h:mm a').format(date);
  }

  /// Formats a [DateTime] to a combined date and time string.
  ///
  /// Format: 'MMM d, yyyy h:mm a' (e.g., 'Dec 28, 2024 2:30 PM')
  ///
  /// ## Parameters
  ///
  /// - [date]: The datetime to format
  /// - [fallback]: Value to return if date is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted datetime string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.dateTime(DateTime(2024, 12, 28, 14, 30));
  /// // 'Dec 28, 2024 2:30 PM'
  /// ```
  static String dateTime(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }

  /// Formats a [DateTime] to a short date string.
  ///
  /// Format: 'MM/dd/yy' (e.g., '12/28/24')
  ///
  /// ## Parameters
  ///
  /// - [date]: The date to format
  /// - [fallback]: Value to return if date is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A short formatted date string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.shortDate(DateTime(2024, 12, 28));  // '12/28/24'
  /// ```
  static String shortDate(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return DateFormat('MM/dd/yy').format(date);
  }

  /// Formats a [DateTime] to a relative time string.
  ///
  /// Uses the `timeago` package to produce human-readable relative times
  /// like '2 hours ago', 'yesterday', '3 days ago'.
  ///
  /// ## Parameters
  ///
  /// - [date]: The datetime to format relative to now
  /// - [fallback]: Value to return if date is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A relative time string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final twoHoursAgo = DateTime.now().subtract(Duration(hours: 2));
  /// Formatters.timeAgo(twoHoursAgo);  // '2 hours ago'
  /// ```
  static String timeAgo(DateTime? date, {String fallback = '-'}) {
    if (date == null) return fallback;
    return timeago.format(date);
  }

  /// Formats a [Duration] to a human-readable string.
  ///
  /// Automatically selects the appropriate unit based on duration:
  /// - Days and hours if >= 1 day
  /// - Hours and minutes if >= 1 hour
  /// - Minutes if >= 1 minute
  /// - Seconds otherwise
  ///
  /// ## Parameters
  ///
  /// - [duration]: The duration to format
  /// - [fallback]: Value to return if duration is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted duration string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.duration(Duration(days: 2, hours: 5));   // '2d 5h'
  /// Formatters.duration(Duration(hours: 3, minutes: 30)); // '3h 30m'
  /// Formatters.duration(Duration(minutes: 45));          // '45m'
  /// Formatters.duration(Duration(seconds: 30));          // '30s'
  /// ```
  static String duration(Duration? duration, {String fallback = '-'}) {
    if (duration == null) return fallback;

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  /// Formats a number as currency.
  ///
  /// ## Parameters
  ///
  /// - [amount]: The amount to format
  /// - [symbol]: Currency symbol (default: '₹')
  /// - [decimalDigits]: Number of decimal places (default: 2)
  /// - [fallback]: Value to return if amount is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted currency string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.currency(1234.56);                    // '₹1,234.56'
  /// Formatters.currency(1234.56, symbol: '€');      // '€1,234.56'
  /// Formatters.currency(1234, decimalDigits: 0);    // '₹1,234'
  /// ```
  static String currency(
    num? amount, {
    String symbol = '₹',
    int decimalDigits = 2,
    String fallback = '-',
  }) {
    if (amount == null) return fallback;
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  /// Formats a number as Indian Rupee currency.
  ///
  /// Uses Indian numbering system (lakhs, crores) and Rupee symbol.
  ///
  /// ## Parameters
  ///
  /// - [amount]: The amount to format
  /// - [fallback]: Value to return if amount is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted Rupee string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.rupee(100000);   // '₹1,00,000'
  /// Formatters.rupee(1234567);  // '₹12,34,567'
  /// ```
  static String rupee(num? amount, {String fallback = '-'}) {
    if (amount == null) return fallback;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Formats a number with thousand separators.
  ///
  /// ## Parameters
  ///
  /// - [value]: The number to format
  /// - [fallback]: Value to return if value is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted number string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.number(1234567);  // '1,234,567'
  /// Formatters.number(1000);     // '1,000'
  /// ```
  static String number(num? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    return NumberFormat('#,###').format(value);
  }

  /// Formats a decimal number with specified precision.
  ///
  /// ## Parameters
  ///
  /// - [value]: The number to format
  /// - [decimalDigits]: Number of decimal places (default: 2)
  /// - [fallback]: Value to return if value is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted decimal string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.decimal(3.14159);                  // '3.14'
  /// Formatters.decimal(3.14159, decimalDigits: 4);  // '3.1416'
  /// ```
  static String decimal(
    num? value, {
    int decimalDigits = 2,
    String fallback = '-',
  }) {
    if (value == null) return fallback;
    return value.toStringAsFixed(decimalDigits);
  }

  /// Formats a number as a percentage.
  ///
  /// ## Parameters
  ///
  /// - [value]: The percentage value (e.g., 75 for 75%)
  /// - [decimalDigits]: Number of decimal places (default: 0)
  /// - [fallback]: Value to return if value is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted percentage string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.percentage(75);                     // '75%'
  /// Formatters.percentage(75.5, decimalDigits: 1); // '75.5%'
  /// ```
  static String percentage(
    num? value, {
    int decimalDigits = 0,
    String fallback = '-',
  }) {
    if (value == null) return fallback;
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Formats file size in human-readable format.
  ///
  /// Automatically selects the appropriate unit (B, KB, MB, GB, TB).
  ///
  /// ## Parameters
  ///
  /// - [bytes]: The file size in bytes
  /// - [fallback]: Value to return if bytes is null (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted file size string or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.fileSize(500);        // '500 B'
  /// Formatters.fileSize(1024);       // '1.0 KB'
  /// Formatters.fileSize(1048576);    // '1.0 MB'
  /// Formatters.fileSize(1073741824); // '1.0 GB'
  /// ```
  static String fileSize(int? bytes, {String fallback = '-'}) {
    if (bytes == null) return fallback;

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Truncates text with ellipsis.
  ///
  /// If the text exceeds [maxLength], it is truncated and '...' is appended.
  ///
  /// ## Parameters
  ///
  /// - [text]: The text to truncate
  /// - [maxLength]: Maximum length before truncation
  /// - [fallback]: Value to return if text is null or empty (default: '-')
  ///
  /// ## Returns
  ///
  /// The original text if within limit, truncated text, or fallback.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.truncate('Hello World', 8);  // 'Hello Wo...'
  /// Formatters.truncate('Hello', 10);       // 'Hello'
  /// ```
  static String truncate(String? text, int maxLength, {String fallback = '-'}) {
    if (text == null || text.isEmpty) return fallback;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalizes the first letter of each word.
  ///
  /// ## Parameters
  ///
  /// - [text]: The text to convert to title case
  /// - [fallback]: Value to return if text is null or empty (default: '-')
  ///
  /// ## Returns
  ///
  /// The text in title case or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.titleCase('hello world');  // 'Hello World'
  /// Formatters.titleCase('HELLO WORLD');  // 'Hello World'
  /// ```
  static String titleCase(String? text, {String fallback = '-'}) {
    if (text == null || text.isEmpty) return fallback;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats a phone number for display.
  ///
  /// Formats 10-digit numbers as '(XXX) XXX-XXXX'.
  /// Other formats are returned as-is.
  ///
  /// ## Parameters
  ///
  /// - [phone]: The phone number to format
  /// - [fallback]: Value to return if phone is null or empty (default: '-')
  ///
  /// ## Returns
  ///
  /// A formatted phone number or the fallback value.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.phone('1234567890');  // '(123) 456-7890'
  /// Formatters.phone('+1234567890'); // '+1234567890' (returned as-is)
  /// ```
  static String phone(String? phone, {String fallback = '-'}) {
    if (phone == null || phone.isEmpty) return fallback;

    // Remove non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    return phone;
  }

  /// Gets initials from a name.
  ///
  /// Extracts the first letter of each word (up to [count] letters).
  ///
  /// ## Parameters
  ///
  /// - [name]: The name to extract initials from
  /// - [count]: Maximum number of initials (default: 2)
  ///
  /// ## Returns
  ///
  /// The initials in uppercase, or an empty string if name is null/empty.
  ///
  /// ## Example
  ///
  /// ```dart
  /// Formatters.initials('John Doe');          // 'JD'
  /// Formatters.initials('John Michael Doe');  // 'JM'
  /// Formatters.initials('John Michael Doe', count: 3);  // 'JMD'
  /// Formatters.initials('John');              // 'J'
  /// ```
  static String initials(String? name, {int count = 2}) {
    if (name == null || name.isEmpty) return '';

    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((part) => part.isNotEmpty)
        .take(count)
        .map((part) => part[0].toUpperCase())
        .join();

    return initials;
  }
}

/// Utility classes for formatting dates, times, currency, and numbers.
///
/// This file provides static utility classes for consistent data formatting
/// across the application, with special support for Indian locale formats.
///
/// ## Features
/// - Date and time formatting with multiple styles
/// - Relative time formatting (e.g., "2 hours ago")
/// - Indian Rupee currency formatting with lakh/crore notation
/// - Number formatting with ordinals and file sizes
///
/// ## Example
/// ```dart
/// // Date formatting
/// DateFormatter.mediumDate(DateTime.now()); // "Jan 15, 2024"
/// DateFormatter.timeAgo(someDate); // "2h ago"
///
/// // Currency formatting
/// CurrencyFormatter.formatINR(150000); // "Rs1,50,000"
/// CurrencyFormatter.formatCompactINR(1500000); // "Rs15L"
///
/// // Number formatting
/// NumberFormatter.fileSize(1024000); // "1000.0 KB"
/// NumberFormatter.ordinal(3); // "3rd"
/// ```
///
/// See also:
/// - [MaskingUtils] for sensitive data masking
library;

/// Utility class for formatting dates and times.
///
/// Provides static methods for formatting DateTime objects in various styles,
/// from short dates to relative time expressions.
///
/// ## Usage
/// ```dart
/// DateFormatter.timeAgo(DateTime.now().subtract(Duration(hours: 2))); // "2h ago"
/// DateFormatter.mediumDate(DateTime(2024, 1, 15)); // "Jan 15, 2024"
/// DateFormatter.deadline(futureDate); // "Due in 3 days"
/// ```
class DateFormatter {
  /// Private constructor to prevent instantiation.
  DateFormatter._();

  /// Formats a date as a relative time string.
  ///
  /// Returns human-readable relative time based on the difference from now.
  ///
  /// ## Examples
  /// - 'Just now' (< 1 minute ago)
  /// - '5m ago' (5 minutes ago)
  /// - '2h ago' (2 hours ago)
  /// - '3d ago' (3 days ago)
  /// - '15/1/2024' (> 7 days ago)
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return shortDate(date);
  }

  /// Formats a date as a short date string (dd/mm/yyyy).
  ///
  /// Example: DateTime(2024, 1, 15) -> "15/1/2024"
  static String shortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Formats a date as a medium date string.
  ///
  /// Example: DateTime(2024, 1, 15) -> "Jan 15, 2024"
  static String mediumDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a date as a long date string.
  ///
  /// Example: DateTime(2024, 1, 15) -> "January 15, 2024"
  static String longDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a time as HH:MM (24-hour format).
  ///
  /// Example: DateTime with hour 14, minute 30 -> "14:30"
  static String time24(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Formats a time as HH:MM AM/PM (12-hour format).
  ///
  /// Example: DateTime with hour 14, minute 30 -> "02:30 PM"
  static String time12(DateTime date) {
    final hour = date.hour % 12;
    final displayHour = hour == 0 ? 12 : hour;
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${displayHour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  /// Formats a date and time combination.
  ///
  /// Combines [shortDate] and [time12] into a single string.
  ///
  /// Example: "15/1/2024 02:30 PM"
  static String dateTime(DateTime date) {
    return '${shortDate(date)} ${time12(date)}';
  }

  /// Formats a date relative to today (Today, Yesterday, or date).
  ///
  /// Returns user-friendly relative date expressions.
  ///
  /// ## Examples
  /// - "Today" (same day)
  /// - "Yesterday" (previous day)
  /// - "3d ago" (within a week)
  /// - "15/1/2024" (older dates)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';

    return shortDate(date);
  }

  /// Formats a Duration in human-readable format.
  ///
  /// Returns the most appropriate time unit combination.
  ///
  /// ## Examples
  /// - Duration(days: 2, hours: 5) -> "2d 5h"
  /// - Duration(hours: 3, minutes: 30) -> "3h 30m"
  /// - Duration(minutes: 45) -> "45m"
  /// - Duration(seconds: 30) -> "30s"
  static String duration(Duration duration) {
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

  /// Formats a deadline with days remaining.
  ///
  /// Returns context-aware deadline messages based on time remaining.
  ///
  /// ## Examples
  /// - "Overdue by 2d 5h" (past deadline)
  /// - "Due in 2h 30m" (within 6 hours)
  /// - "Due today" (same day, more than 6 hours)
  /// - "Due tomorrow" (next day)
  /// - "Due in 3 days" (within a week)
  /// - "Due 15/1/2024" (more than a week)
  static String deadline(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      return 'Overdue by ${duration(diff.abs())}';
    }

    if (diff.inDays == 0) {
      if (diff.inHours <= 6) {
        return 'Due in ${diff.inHours}h ${diff.inMinutes % 60}m';
      }
      return 'Due today';
    }

    if (diff.inDays == 1) return 'Due tomorrow';
    if (diff.inDays < 7) return 'Due in ${diff.inDays} days';

    return 'Due ${shortDate(deadline)}';
  }
}

/// Utility class for formatting currency values.
///
/// Provides static methods for formatting numbers as Indian Rupees
/// with proper lakh/crore notation and comma placement.
///
/// ## Usage
/// ```dart
/// CurrencyFormatter.formatINR(150000); // "Rs1,50,000"
/// CurrencyFormatter.formatCompactINR(1500000); // "Rs15L"
/// CurrencyFormatter.percentage(75.5, decimals: 1); // "75.5%"
/// ```
class CurrencyFormatter {
  /// Private constructor to prevent instantiation.
  CurrencyFormatter._();

  /// Formats a number as Indian Rupees with Indian comma notation.
  ///
  /// Uses the Indian numbering system (1,00,000 instead of 100,000).
  /// Large numbers are displayed with Cr (crore) and L (lakh) suffixes.
  ///
  /// ## Examples
  /// - 1000 -> "Rs1,000"
  /// - 50000 -> "Rs50,000"
  /// - 150000 -> "Rs1,50,000"
  /// - 15000000 -> "Rs1.50 Cr"
  static String formatINR(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Indian number format: 1,00,000 instead of 100,000
    String formatted;
    if (absAmount >= 10000000) {
      formatted = _formatWithLakhCrore(absAmount);
    } else {
      formatted = absAmount.toStringAsFixed(0);
      formatted = _addIndianCommas(formatted);
    }

    return '${isNegative ? '-' : ''}₹$formatted';
  }

  /// Formats a number as compact Indian currency.
  ///
  /// Uses K, L (lakh), and Cr (crore) suffixes for large numbers.
  ///
  /// ## Examples
  /// - 1500 -> "Rs1.5K"
  /// - 150000 -> "Rs1.5L"
  /// - 15000000 -> "Rs1.5Cr"
  static String formatCompactINR(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted;
    if (absAmount >= 10000000) {
      formatted = '${(absAmount / 10000000).toStringAsFixed(1)}Cr';
    } else if (absAmount >= 100000) {
      formatted = '${(absAmount / 100000).toStringAsFixed(1)}L';
    } else if (absAmount >= 1000) {
      formatted = '${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = absAmount.toStringAsFixed(0);
    }

    return '${isNegative ? '-' : ''}₹$formatted';
  }

  /// Formats a number as compact currency without the rupee symbol.
  ///
  /// Useful when the currency symbol is displayed separately.
  ///
  /// ## Examples
  /// - 1500 -> "1.5K"
  /// - 150000 -> "1.5L"
  /// - 15000000 -> "1.5Cr"
  static String formatCompact(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formatted;
    if (absAmount >= 10000000) {
      formatted = '${(absAmount / 10000000).toStringAsFixed(1)}Cr';
    } else if (absAmount >= 100000) {
      formatted = '${(absAmount / 100000).toStringAsFixed(1)}L';
    } else if (absAmount >= 1000) {
      formatted = '${(absAmount / 1000).toStringAsFixed(1)}K';
    } else {
      formatted = absAmount.toStringAsFixed(0);
    }

    return '${isNegative ? '-' : ''}$formatted';
  }

  /// Adds Indian-style comma formatting to a number string.
  ///
  /// Indian format: 1,00,000 (last 3 digits, then groups of 2).
  static String _addIndianCommas(String number) {
    if (number.length <= 3) return number;

    final lastThree = number.substring(number.length - 3);
    final remaining = number.substring(0, number.length - 3);

    final buffer = StringBuffer();
    for (var i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return buffer.toString();
  }

  /// Formats large amounts with lakh/crore suffixes.
  static String _formatWithLakhCrore(num amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} L';
    }
    return amount.toStringAsFixed(0);
  }

  /// Formats a number as a percentage string.
  ///
  /// [decimals] controls the number of decimal places (default: 0).
  ///
  /// ## Examples
  /// - percentage(75) -> "75%"
  /// - percentage(75.5, decimals: 1) -> "75.5%"
  static String percentage(num value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
}

/// Utility class for formatting numbers.
///
/// Provides static methods for common number formatting needs
/// including thousand separators, ordinals, and file sizes.
///
/// ## Usage
/// ```dart
/// NumberFormatter.withSeparators(1000000); // "1,000,000"
/// NumberFormatter.ordinal(3); // "3rd"
/// NumberFormatter.fileSize(1024000); // "1000.0 KB"
/// ```
class NumberFormatter {
  /// Private constructor to prevent instantiation.
  NumberFormatter._();

  /// Formats a number with thousand separators (Western format).
  ///
  /// Example: 1000000 -> "1,000,000"
  static String withSeparators(num number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Formats a number with ordinal suffix (1st, 2nd, 3rd, etc.).
  ///
  /// Handles special cases for 11th, 12th, 13th.
  ///
  /// ## Examples
  /// - 1 -> "1st"
  /// - 2 -> "2nd"
  /// - 3 -> "3rd"
  /// - 11 -> "11th"
  /// - 21 -> "21st"
  static String ordinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Formats bytes to human-readable file size.
  ///
  /// Automatically selects the appropriate unit (B, KB, MB, GB).
  ///
  /// ## Examples
  /// - 500 -> "500 B"
  /// - 1024 -> "1.0 KB"
  /// - 1048576 -> "1.0 MB"
  /// - 1073741824 -> "1.0 GB"
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formats a word count with proper singular/plural form.
  ///
  /// ## Examples
  /// - 1 -> "1 word"
  /// - 500 -> "500 words"
  static String wordCount(int count) {
    if (count == 1) return '1 word';
    return '$count words';
  }
}

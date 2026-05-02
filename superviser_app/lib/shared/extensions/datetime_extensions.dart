/// {@template datetime_extensions}
/// Extension methods on [DateTime] for common date/time operations.
///
/// Provides utilities for date comparisons, range calculations,
/// and human-readable formatting.
///
/// ## Categories
/// - **Comparisons**: isToday, isYesterday, isTomorrow, isPast, isFuture
/// - **Week/Month/Year**: isThisWeek, isThisMonth, isThisYear, isWeekend
/// - **Boundaries**: startOfDay, endOfDay, startOfWeek, endOfWeek
/// - **Calculations**: daysFromNow, hoursFromNow, addBusinessDays
/// - **Formatting**: relativeDate
///
/// ## Usage
/// ```dart
/// final date = DateTime.now();
///
/// date.isToday; // true
/// date.startOfDay; // Today at 00:00:00
/// date.addBusinessDays(5); // Skip weekends
/// date.relativeDate; // 'Today'
/// ```
/// {@endtemplate}
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today.
  ///
  /// Compares year, month, and day only (ignores time).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().isToday; // true
  /// DateTime(2020, 1, 1).isToday; // false
  /// ```
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().subtract(Duration(days: 1)).isYesterday; // true
  /// ```
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is tomorrow.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().add(Duration(days: 1)).isTomorrow; // true
  /// ```
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns true if this date is in the past.
  ///
  /// Compares the full timestamp including time.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2020, 1, 1).isPast; // true
  /// DateTime.now().add(Duration(hours: 1)).isPast; // false
  /// ```
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if this date is in the future.
  ///
  /// Compares the full timestamp including time.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2030, 1, 1).isFuture; // true
  /// DateTime.now().subtract(Duration(hours: 1)).isFuture; // false
  /// ```
  bool get isFuture => isAfter(DateTime.now());

  /// Returns true if this date is within the current week.
  ///
  /// Week starts on Monday and ends on Sunday.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().isThisWeek; // true
  /// ```
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Returns true if this date is within the current month.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().isThisMonth; // true
  /// DateTime(2020, 1, 1).isThisMonth; // false (unless it's January 2020)
  /// ```
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Returns true if this date is within the current year.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().isThisYear; // true
  /// ```
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// Returns the start of the day (00:00:00.000).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 15, 14, 30).startOfDay;
  /// // DateTime(2023, 6, 15, 0, 0, 0, 0)
  /// ```
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 15, 14, 30).endOfDay;
  /// // DateTime(2023, 6, 15, 23, 59, 59, 999)
  /// ```
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the start of the week (Monday 00:00:00).
  ///
  /// Example:
  /// ```dart
  /// // If today is Wednesday June 14, 2023
  /// DateTime.now().startOfWeek;
  /// // Returns Monday June 12, 2023 at 00:00:00
  /// ```
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Returns the end of the week (Sunday 23:59:59.999).
  ///
  /// Example:
  /// ```dart
  /// // If today is Wednesday June 14, 2023
  /// DateTime.now().endOfWeek;
  /// // Returns Sunday June 18, 2023 at 23:59:59.999
  /// ```
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// Returns the start of the month (1st day 00:00:00).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 15).startOfMonth;
  /// // DateTime(2023, 6, 1, 0, 0, 0)
  /// ```
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Returns the end of the month (last day 23:59:59.999).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 15).endOfMonth;
  /// // DateTime(2023, 6, 30, 23, 59, 59, 999)
  /// ```
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Returns the difference in days from now.
  ///
  /// Positive values indicate future dates, negative indicate past.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().add(Duration(days: 3)).daysFromNow; // 3
  /// DateTime.now().subtract(Duration(days: 2)).daysFromNow; // -2
  /// ```
  int get daysFromNow {
    final now = DateTime.now().startOfDay;
    return startOfDay.difference(now).inDays;
  }

  /// Returns the difference in hours from now.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().add(Duration(hours: 5)).hoursFromNow; // 5
  /// ```
  int get hoursFromNow {
    return difference(DateTime.now()).inHours;
  }

  /// Returns the difference in minutes from now.
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().add(Duration(minutes: 30)).minutesFromNow; // 30
  /// ```
  int get minutesFromNow {
    return difference(DateTime.now()).inMinutes;
  }

  /// Adds business days (skipping weekends).
  ///
  /// Supports both positive and negative values.
  ///
  /// Example:
  /// ```dart
  /// // If today is Friday
  /// DateTime.now().addBusinessDays(1); // Returns Monday
  /// DateTime.now().addBusinessDays(3); // Returns Wednesday
  /// DateTime.now().addBusinessDays(-1); // Returns Thursday
  /// ```
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days.abs();
    final increment = days >= 0 ? 1 : -1;

    while (remaining > 0) {
      result = result.add(Duration(days: increment));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }

    return result;
  }

  /// Returns true if this date is a weekend (Saturday or Sunday).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 17).isWeekend; // true (Saturday)
  /// DateTime(2023, 6, 14).isWeekend; // false (Wednesday)
  /// ```
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Returns true if this date is a weekday (Monday-Friday).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2023, 6, 14).isWeekday; // true (Wednesday)
  /// DateTime(2023, 6, 17).isWeekday; // false (Saturday)
  /// ```
  bool get isWeekday => !isWeekend;

  /// Returns a human-readable relative date string.
  ///
  /// Returns:
  /// - "Today" for today's date
  /// - "Yesterday" for yesterday
  /// - "Tomorrow" for tomorrow
  /// - "In X days" for near future dates
  /// - "X days ago" for near past dates
  /// - ISO date string (YYYY-MM-DD) for other dates
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().relativeDate; // 'Today'
  /// DateTime.now().add(Duration(days: 1)).relativeDate; // 'Tomorrow'
  /// DateTime.now().add(Duration(days: 3)).relativeDate; // 'In 3 days'
  /// DateTime.now().subtract(Duration(days: 2)).relativeDate; // '2 days ago'
  /// ```
  String get relativeDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    if (daysFromNow > 0 && daysFromNow < 7) {
      return 'In $daysFromNow days';
    }
    if (daysFromNow < 0 && daysFromNow > -7) {
      return '${-daysFromNow} days ago';
    }
    return toString().substring(0, 10);
  }
}

/// {@template nullable_datetime_extensions}
/// Extension methods on nullable [DateTime] for null-safe operations.
///
/// Provides utilities for working with optional date/time values
/// without explicit null checks.
///
/// ## Usage
/// ```dart
/// DateTime? date;
///
/// date.isNull; // true
/// date.orNow; // Returns current time
/// date.orDefault(DateTime(2020, 1, 1)); // Returns default
/// ```
/// {@endtemplate}
extension NullableDateTimeExtensions on DateTime? {
  /// Returns true if the date is null.
  ///
  /// Example:
  /// ```dart
  /// DateTime? date;
  /// date.isNull; // true
  /// ```
  bool get isNull => this == null;

  /// Returns true if the date is not null.
  ///
  /// Example:
  /// ```dart
  /// DateTime? date = DateTime.now();
  /// date.isNotNull; // true
  /// ```
  bool get isNotNull => this != null;

  /// Returns the date, or the current time if null.
  ///
  /// Example:
  /// ```dart
  /// DateTime? scheduledDate;
  /// final effectiveDate = scheduledDate.orNow;
  /// ```
  DateTime get orNow => this ?? DateTime.now();

  /// Returns the date, or [defaultValue] if null.
  ///
  /// Example:
  /// ```dart
  /// DateTime? birthday;
  /// final displayDate = birthday.orDefault(DateTime(2000, 1, 1));
  /// ```
  DateTime orDefault(DateTime defaultValue) => this ?? defaultValue;
}

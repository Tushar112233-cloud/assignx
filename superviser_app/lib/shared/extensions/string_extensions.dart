/// {@template string_extensions}
/// Extension methods on [String] for common text transformations and validations.
///
/// Provides utilities for case conversion, validation, truncation, and more.
///
/// ## Categories
/// - **Case Transformations**: capitalize, titleCase, camelCase, snakeCase, kebabCase
/// - **Validation**: isValidEmail, isValidPhone, isValidUrl, isNumeric
/// - **Text Manipulation**: truncate, removeWhitespace, initials
/// - **Null Safety**: nullIfEmpty, ifEmpty
///
/// ## Usage
/// ```dart
/// // Capitalize first letter
/// 'hello world'.capitalize; // 'Hello world'
///
/// // Validate email
/// 'test@example.com'.isValidEmail; // true
///
/// // Get initials
/// 'John Doe'.initials; // 'JD'
/// ```
/// {@endtemplate}
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  ///
  /// Returns the string with the first character in uppercase
  /// and the rest unchanged.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalize; // 'Hello'
  /// 'HELLO'.capitalize; // 'HELLO'
  /// ''.capitalize; // ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts the string to Title Case.
  ///
  /// Capitalizes the first letter of each word and lowercases the rest.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.titleCase; // 'Hello World'
  /// 'JOHN DOE'.titleCase; // 'John Doe'
  /// ```
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Converts the string to camelCase.
  ///
  /// Words can be separated by spaces, underscores, or hyphens.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.camelCase; // 'helloWorld'
  /// 'user_name'.camelCase; // 'userName'
  /// 'first-name'.camelCase; // 'firstName'
  /// ```
  String get camelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize).join();
  }

  /// Converts the string to snake_case.
  ///
  /// Inserts underscores before uppercase letters and lowercases all.
  ///
  /// Example:
  /// ```dart
  /// 'helloWorld'.snakeCase; // 'hello_world'
  /// 'firstName'.snakeCase; // 'first_name'
  /// ```
  String get snakeCase {
    if (isEmpty) return this;
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Converts the string to kebab-case.
  ///
  /// Same as snake_case but with hyphens instead of underscores.
  ///
  /// Example:
  /// ```dart
  /// 'helloWorld'.kebabCase; // 'hello-world'
  /// 'firstName'.kebabCase; // 'first-name'
  /// ```
  String get kebabCase {
    return snakeCase.replaceAll('_', '-');
  }

  /// Returns true if the string is a valid email address.
  ///
  /// Uses a standard email regex pattern for validation.
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.isValidEmail; // true
  /// 'invalid-email'.isValidEmail; // false
  /// ```
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Returns true if the string is a valid phone number.
  ///
  /// Accepts digits, spaces, hyphens, parentheses, and optional leading +.
  /// Requires at least 10 characters.
  ///
  /// Example:
  /// ```dart
  /// '+1 (555) 123-4567'.isValidPhone; // true
  /// '555-123-4567'.isValidPhone; // true
  /// '123'.isValidPhone; // false
  /// ```
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-()]{10,}$');
    return phoneRegex.hasMatch(this);
  }

  /// Returns true if the string is a valid HTTP/HTTPS URL.
  ///
  /// Example:
  /// ```dart
  /// 'https://example.com'.isValidUrl; // true
  /// 'http://sub.domain.org/path'.isValidUrl; // true
  /// 'not-a-url'.isValidUrl; // false
  /// ```
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Returns true if the string represents a numeric value.
  ///
  /// Handles integers and decimals.
  ///
  /// Example:
  /// ```dart
  /// '123'.isNumeric; // true
  /// '12.34'.isNumeric; // true
  /// '-5'.isNumeric; // true
  /// 'abc'.isNumeric; // false
  /// ```
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Truncates the string to [maxLength] characters with a suffix.
  ///
  /// If the string is shorter than [maxLength], returns unchanged.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.truncate(8); // 'Hello...'
  /// 'Hi'.truncate(10); // 'Hi'
  /// 'Long text'.truncate(6, suffix: '~'); // 'Long ~'
  /// ```
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Removes all whitespace characters from the string.
  ///
  /// Includes spaces, tabs, newlines, etc.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.removeWhitespace; // 'helloworld'
  /// '  a  b  c  '.removeWhitespace; // 'abc'
  /// ```
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Extracts initials from the string (name).
  ///
  /// Returns up to 2 uppercase letters from the first characters
  /// of the first two words.
  ///
  /// Example:
  /// ```dart
  /// 'John Doe'.initials; // 'JD'
  /// 'Alice'.initials; // 'A'
  /// 'Mary Jane Watson'.initials; // 'MJ'
  /// ''.initials; // ''
  /// ```
  String get initials {
    if (isEmpty) return '';
    final parts = trim().split(RegExp(r'\s+'));
    return parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }

  /// Returns null if the string is empty, otherwise returns the string.
  ///
  /// Useful for conditional rendering or null-coalescing.
  ///
  /// Example:
  /// ```dart
  /// ''.nullIfEmpty; // null
  /// 'hello'.nullIfEmpty; // 'hello'
  ///
  /// // Usage with null-coalescing
  /// final display = input.nullIfEmpty ?? 'Default';
  /// ```
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Returns the string, or [defaultValue] if empty.
  ///
  /// Example:
  /// ```dart
  /// ''.ifEmpty('N/A'); // 'N/A'
  /// 'hello'.ifEmpty('N/A'); // 'hello'
  /// ```
  String ifEmpty(String defaultValue) => isEmpty ? defaultValue : this;
}

/// {@template nullable_string_extensions}
/// Extension methods on nullable [String] for null-safe operations.
///
/// Provides utilities for working with optional strings without
/// explicit null checks.
///
/// ## Usage
/// ```dart
/// String? name;
///
/// name.isNullOrEmpty; // true
/// name.orEmpty; // ''
/// name.orDefault('Anonymous'); // 'Anonymous'
/// ```
/// {@endtemplate}
extension NullableStringExtensions on String? {
  /// Returns true if the string is null or empty.
  ///
  /// Example:
  /// ```dart
  /// String? a;
  /// a.isNullOrEmpty; // true
  ///
  /// String? b = '';
  /// b.isNullOrEmpty; // true
  ///
  /// String? c = 'hello';
  /// c.isNullOrEmpty; // false
  /// ```
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the string is not null and not empty.
  ///
  /// Example:
  /// ```dart
  /// String? name = 'John';
  /// if (name.isNotNullOrEmpty) {
  ///   print('Hello, $name');
  /// }
  /// ```
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the string, or an empty string if null.
  ///
  /// Example:
  /// ```dart
  /// String? name;
  /// Text(name.orEmpty); // Displays empty text
  /// ```
  String get orEmpty => this ?? '';

  /// Returns the string, or [defaultValue] if null or empty.
  ///
  /// Example:
  /// ```dart
  /// String? name;
  /// Text(name.orDefault('Anonymous')); // Displays 'Anonymous'
  ///
  /// String? title = '';
  /// Text(title.orDefault('Untitled')); // Displays 'Untitled'
  /// ```
  String orDefault(String defaultValue) {
    if (isNullOrEmpty) return defaultValue;
    return this!;
  }
}

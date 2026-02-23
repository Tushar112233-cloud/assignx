/// Form validation functions.
///
/// This file provides comprehensive form field validators for the DOER app.
/// All validators follow a consistent pattern: return `null` for valid input,
/// or an error message string for invalid input.
///
/// ## Validator Pattern
/// ```dart
/// static String? validatorName(String? value) {
///   if (/* invalid condition */) {
///     return 'Error message';
///   }
///   return null; // Valid
/// }
/// ```
///
/// ## Categories
/// - **Required Fields**: Basic presence validation
/// - **Contact Info**: Email, phone number
/// - **Authentication**: Password, OTP
/// - **Financial**: Bank account, IFSC, UPI
/// - **Text Fields**: Name, bio, skills, education
/// - **General**: URL, length constraints
/// - **Composition**: Combining multiple validators
///
/// ## Usage
/// Use with Flutter form fields:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
///   // or combine validators:
///   validator: Validators.combine([
///     (v) => Validators.required(v, fieldName: 'Email'),
///     Validators.email,
///   ]),
/// )
/// ```
library;

/// Form validators for the app.
///
/// Provides static validation methods for common form field types.
/// Each validator returns `null` for valid input or an error message
/// for invalid input.
class Validators {
  /// Private constructor to prevent instantiation.
  Validators._();

  // ---------------------------------------------------------------------------
  // Required Field Validation
  // ---------------------------------------------------------------------------

  /// Validates required field.
  ///
  /// Checks that the value is not null and not empty after trimming.
  ///
  /// @param value The value to validate
  /// @param fieldName Custom field name for error message
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.required('', fieldName: 'Name');  // "Name is required"
  /// Validators.required('John');                  // null
  /// ```
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Contact Information
  // ---------------------------------------------------------------------------

  /// Validates email format.
  ///
  /// Checks for valid email structure using regex.
  ///
  /// @param value The email to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.email('user@example.com'); // null
  /// Validators.email('invalid-email');    // "Enter a valid email address"
  /// ```
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone number (Indian).
  ///
  /// Validates 10-digit Indian mobile numbers starting with 6-9.
  ///
  /// @param value The phone number to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.phone('9876543210'); // null
  /// Validators.phone('1234567890'); // "Enter a valid 10-digit phone number"
  /// ```
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Validates password strength.
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  ///
  /// @param value The password to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.password('Abc12345'); // null
  /// Validators.password('weak');     // "Password must be at least 8 characters"
  /// ```
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates password confirmation.
  ///
  /// Checks that the confirmation matches the original password.
  ///
  /// @param value The confirmation password
  /// @param password The original password to match
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.confirmPassword('Pass123', 'Pass123'); // null
  /// Validators.confirmPassword('Pass123', 'Pass456'); // "Passwords do not match"
  /// ```
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates OTP.
  ///
  /// Checks for required length and digits only.
  ///
  /// @param value The OTP to validate
  /// @param length Required OTP length (default: 6)
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.otp('123456');       // null
  /// Validators.otp('12345');        // "Enter 6-digit OTP"
  /// Validators.otp('1234', length: 4); // null
  /// ```
  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != length) {
      return 'Enter $length-digit OTP';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Length Constraints
  // ---------------------------------------------------------------------------

  /// Validates minimum length.
  ///
  /// @param value The value to validate
  /// @param min Minimum required length
  /// @param fieldName Custom field name for error message
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.minLength('Hi', 3);  // "This field must be at least 3 characters"
  /// Validators.minLength('Hello', 3); // null
  /// ```
  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length.
  ///
  /// @param value The value to validate
  /// @param max Maximum allowed length
  /// @param fieldName Custom field name for error message
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.maxLength('Hello World', 5);  // "This field must be at most 5 characters"
  /// Validators.maxLength('Hello', 10);       // null
  /// ```
  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Financial Information
  // ---------------------------------------------------------------------------

  /// Validates bank account number.
  ///
  /// Requirements:
  /// - 9-18 digits
  /// - Digits only
  ///
  /// @param value The account number to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.bankAccountNumber('123456789012'); // null
  /// Validators.bankAccountNumber('12345');        // "Enter a valid account number (9-18 digits)"
  /// ```
  static String? bankAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length < 9 || cleaned.length > 18) {
      return 'Enter a valid account number (9-18 digits)';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Account number must contain only digits';
    }
    return null;
  }

  /// Alias for bankAccountNumber.
  ///
  /// @param value The account number to validate
  /// @returns Error message or null if valid
  static String? bankAccount(String? value) => bankAccountNumber(value);

  /// Validates IFSC code.
  ///
  /// Format: 4 letters + 0 + 6 alphanumeric characters.
  /// Example: SBIN0001234
  ///
  /// @param value The IFSC code to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.ifscCode('SBIN0001234'); // null
  /// Validators.ifscCode('INVALID');     // "Enter a valid IFSC code"
  /// ```
  static String? ifscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Enter a valid IFSC code';
    }
    return null;
  }

  /// Validates UPI ID.
  ///
  /// Format: username@provider
  /// Optional field - returns null for empty values.
  ///
  /// @param value The UPI ID to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.upiId('user@upi');  // null
  /// Validators.upiId('');          // null (optional)
  /// Validators.upiId('invalid');   // "Enter a valid UPI ID"
  /// ```
  static String? upiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // UPI is optional
    }
    if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(value)) {
      return 'Enter a valid UPI ID';
    }
    return null;
  }

  /// Alias for upiId.
  ///
  /// @param value The UPI ID to validate
  /// @returns Error message or null if valid
  static String? upi(String? value) => upiId(value);

  // ---------------------------------------------------------------------------
  // Boolean Email Validation
  // ---------------------------------------------------------------------------

  /// Validates email format and returns boolean.
  ///
  /// Convenience method for boolean validation (true if valid, false if invalid).
  ///
  /// @param value The email to validate
  /// @returns true if email is valid, false otherwise
  ///
  /// ## Example
  /// ```dart
  /// Validators.isValidEmail('user@example.com'); // true
  /// Validators.isValidEmail('invalid-email');    // false
  /// ```
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  // ---------------------------------------------------------------------------
  // URL Validation
  // ---------------------------------------------------------------------------

  /// Validates URL.
  ///
  /// Checks for valid URL format.
  ///
  /// @param value The URL to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.url('https://example.com'); // null
  /// Validators.url('not-a-url');           // "Enter a valid URL"
  /// ```
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAbsolutePath) {
      return 'Enter a valid URL';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Profile Fields
  // ---------------------------------------------------------------------------

  /// Validates a name field.
  ///
  /// Requirements:
  /// - Required field (not empty)
  /// - Minimum 2 characters
  /// - Maximum 100 characters
  /// - Only letters, spaces, hyphens, and periods allowed
  ///
  /// @param value The name to validate
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.name('John Doe');     // null
  /// Validators.name('J');            // "Name must be at least 2 characters"
  /// Validators.name('John123');      // "Name can only contain letters..."
  /// ```
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmed.length > 100) {
      return 'Name must be less than 100 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s\-\.]+$').hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and periods';
    }

    return null;
  }

  /// Validates a bio/about text field (optional).
  ///
  /// Requirements:
  /// - Maximum length (default 500)
  /// - No HTML tags allowed
  ///
  /// @param value The bio text to validate
  /// @param maxLength Maximum allowed characters
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.bio('I am a developer.'); // null
  /// Validators.bio('<script>alert("XSS")</script>'); // "HTML tags are not allowed"
  /// ```
  static String? bio(String? value, {int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (value.length > maxLength) {
      return 'Maximum $maxLength characters allowed';
    }

    // Check for HTML/script tags
    if (RegExp(r'<[^>]*>').hasMatch(value)) {
      return 'HTML tags are not allowed';
    }

    return null;
  }

  /// Validates education field (optional).
  ///
  /// @param value The education text to validate
  /// @returns Error message or null if valid
  static String? education(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (value.length > 200) {
      return 'Maximum 200 characters allowed';
    }

    return null;
  }

  /// Validates skills input (optional).
  ///
  /// Requirements:
  /// - Maximum 20 skills
  /// - Each skill max 50 characters
  /// - Comma-separated input
  ///
  /// @param value Comma-separated skills string
  /// @returns Error message or null if valid
  ///
  /// ## Example
  /// ```dart
  /// Validators.skills('Flutter, Dart, Firebase'); // null
  /// ```
  static String? skills(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final skillsList = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (skillsList.length > 20) {
      return 'Maximum 20 skills allowed';
    }

    for (final skill in skillsList) {
      if (skill.length > 50) {
        return 'Each skill must be less than 50 characters';
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Optional Field Validators
  // ---------------------------------------------------------------------------

  /// Validates optional phone number (Indian format).
  ///
  /// Returns null for empty values (optional).
  ///
  /// @param value The phone number to validate
  /// @returns Error message or null if valid
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!RegExp(r'^(\+91)?[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit mobile number';
    }

    return null;
  }

  /// Validates optional text field with max length.
  ///
  /// @param value The text to validate
  /// @param maxLength Maximum allowed characters
  /// @returns Error message or null if valid
  static String? optional(String? value, {int maxLength = 500}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.length > maxLength) {
      return 'Maximum $maxLength characters allowed';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Validator Composition
  // ---------------------------------------------------------------------------

  /// Combines multiple validators.
  ///
  /// Runs validators in order and returns the first error found.
  ///
  /// @param validators List of validator functions
  /// @returns A combined validator function
  ///
  /// ## Example
  /// ```dart
  /// TextFormField(
  ///   validator: Validators.combine([
  ///     (v) => Validators.required(v, fieldName: 'Email'),
  ///     Validators.email,
  ///   ]),
  /// )
  /// ```
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

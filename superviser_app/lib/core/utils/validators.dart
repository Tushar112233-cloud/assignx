/// Form validation utilities for the Superviser App.
///
/// This file provides reusable validation functions for common form fields
/// such as email, password, name, phone, and URL. All validators follow
/// Flutter's form validation pattern, returning `null` for valid input
/// or an error message string for invalid input.
///
/// ## Validation Pattern
///
/// All validators follow this signature:
/// ```dart
/// String? validator(String? value)
/// ```
/// - Returns `null` if the value is valid
/// - Returns an error message if the value is invalid
///
/// ## Usage
///
/// ```dart
/// // In a TextFormField
/// TextFormField(
///   decoration: const InputDecoration(labelText: 'Email'),
///   validator: Validators.email,
/// );
///
/// // Combining validators
/// TextFormField(
///   validator: Validators.combine([
///     (v) => Validators.required(v, 'Username'),
///     Validators.minLength(3, 'Username'),
///   ]),
/// );
/// ```
///
/// ## Configuration
///
/// Validation rules use constants from [AppConstants]:
/// - [AppConstants.minPasswordLength] - Minimum password length
/// - [AppConstants.maxPasswordLength] - Maximum password length
/// - [AppConstants.minNameLength] - Minimum name length
/// - [AppConstants.maxNameLength] - Maximum name length
///
/// See also:
/// - [AppConstants] for validation configuration values
/// - [TextFormField] for Flutter form field usage
library;

import '../config/constants.dart';

/// Provides static validation functions for form fields.
///
/// This abstract class serves as a namespace for validator functions.
/// All validators are static methods that can be passed directly to
/// [TextFormField.validator] or composed using [combine].
///
/// ## Example
///
/// ```dart
/// Form(
///   child: Column(
///     children: [
///       TextFormField(
///         validator: Validators.email,
///         decoration: const InputDecoration(labelText: 'Email'),
///       ),
///       TextFormField(
///         obscureText: true,
///         validator: Validators.password,
///         decoration: const InputDecoration(labelText: 'Password'),
///       ),
///       TextFormField(
///         validator: (v) => Validators.required(v, 'Bio'),
///         decoration: const InputDecoration(labelText: 'Bio'),
///       ),
///     ],
///   ),
/// );
/// ```
abstract class Validators {
  /// Validates an email address format.
  ///
  /// Checks that the value:
  /// - Is not null or empty
  /// - Matches a standard email pattern
  ///
  /// ## Parameters
  ///
  /// - [value]: The email string to validate
  ///
  /// ## Returns
  ///
  /// - `null` if the email is valid
  /// - An error message if invalid
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.email('user@example.com'); // null (valid)
  /// Validators.email('invalid-email');    // 'Please enter a valid email address'
  /// Validators.email('');                 // 'Email is required'
  /// ```
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates a password meets security requirements.
  ///
  /// Checks that the value:
  /// - Is not null or empty
  /// - Has at least [AppConstants.minPasswordLength] characters
  /// - Has at most [AppConstants.maxPasswordLength] characters
  ///
  /// ## Parameters
  ///
  /// - [value]: The password string to validate
  ///
  /// ## Returns
  ///
  /// - `null` if the password is valid
  /// - An error message if invalid
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.password('securePass123');  // null (valid)
  /// Validators.password('short');          // 'Password must be at least 8 characters'
  /// Validators.password('');               // 'Password is required'
  /// ```
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }

    return null;
  }

  /// Creates a validator that checks if password matches confirmation.
  ///
  /// Returns a validator function that compares the input against the
  /// provided password value.
  ///
  /// ## Parameters
  ///
  /// - [password]: The password to match against
  ///
  /// ## Returns
  ///
  /// A validator function for the confirmation field.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final passwordController = TextEditingController();
  ///
  /// TextFormField(
  ///   controller: passwordController,
  ///   validator: Validators.password,
  /// );
  ///
  /// TextFormField(
  ///   validator: Validators.confirmPassword(passwordController.text),
  ///   decoration: const InputDecoration(labelText: 'Confirm Password'),
  /// );
  /// ```
  static String? Function(String?) confirmPassword(String? password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }

      if (value != password) {
        return 'Passwords do not match';
      }

      return null;
    };
  }

  /// Validates that a field is not empty.
  ///
  /// ## Parameters
  ///
  /// - [value]: The string to validate
  /// - [fieldName]: The field name for the error message (default: 'This field')
  ///
  /// ## Returns
  ///
  /// - `null` if the value is not empty
  /// - '{fieldName} is required' if empty
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.required('hello', 'Name');  // null (valid)
  /// Validators.required('', 'Name');       // 'Name is required'
  /// Validators.required('   ', 'Name');    // 'Name is required' (whitespace only)
  /// ```
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a name field.
  ///
  /// Checks that the value:
  /// - Is not null or empty
  /// - Has at least [AppConstants.minNameLength] characters
  /// - Has at most [AppConstants.maxNameLength] characters
  /// - Contains only letters, spaces, hyphens, and periods
  ///
  /// ## Parameters
  ///
  /// - [value]: The name string to validate
  ///
  /// ## Returns
  ///
  /// - `null` if the name is valid
  /// - An error message if invalid
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.name('John Doe');     // null (valid)
  /// Validators.name('Dr. Jane O\'Brien');  // null (valid)
  /// Validators.name('J');            // 'Name must be at least 2 characters'
  /// Validators.name('John123');      // 'Name can only contain letters...'
  /// ```
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'Name is too long';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s\-\.]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and periods';
    }

    return null;
  }

  /// Validates a phone number format.
  ///
  /// Checks that the value:
  /// - Is not null or empty
  /// - Has 10-15 digits (after removing spaces and dashes)
  /// - Contains only numbers (and optional leading +)
  ///
  /// ## Parameters
  ///
  /// - [value]: The phone number string to validate
  ///
  /// ## Returns
  ///
  /// - `null` if the phone number is valid
  /// - An error message if invalid
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.phone('1234567890');      // null (valid)
  /// Validators.phone('+1 234-567-8900'); // null (valid)
  /// Validators.phone('123');             // 'Please enter a valid phone number'
  /// Validators.phone('abc1234567');      // 'Phone number can only contain numbers'
  /// ```
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and dashes for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return 'Please enter a valid phone number';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Phone number can only contain numbers';
    }

    return null;
  }

  /// Validates a URL format.
  ///
  /// Checks that the value matches a standard HTTP/HTTPS URL pattern.
  /// Empty values are considered valid (URL is optional).
  ///
  /// ## Parameters
  ///
  /// - [value]: The URL string to validate
  ///
  /// ## Returns
  ///
  /// - `null` if the URL is valid or empty
  /// - An error message if invalid
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.url('https://example.com');  // null (valid)
  /// Validators.url('http://sub.domain.org/path');  // null (valid)
  /// Validators.url('');                     // null (empty is valid)
  /// Validators.url('not-a-url');            // 'Please enter a valid URL'
  /// ```
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Creates a validator that checks minimum length.
  ///
  /// Returns a validator function that ensures the input has at least
  /// the specified number of characters. Empty values pass validation
  /// (use [required] for that check).
  ///
  /// ## Parameters
  ///
  /// - [length]: Minimum required length
  /// - [fieldName]: Field name for error message (default: 'This field')
  ///
  /// ## Returns
  ///
  /// A validator function.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final validator = Validators.minLength(5, 'Username');
  /// validator('hello');  // null (valid - 5 chars)
  /// validator('hi');     // 'Username must be at least 5 characters'
  /// validator('');       // null (empty - let required handle this)
  /// ```
  static String? Function(String?) minLength(int length, [String fieldName = 'This field']) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty case
      }

      if (value.length < length) {
        return '$fieldName must be at least $length characters';
      }

      return null;
    };
  }

  /// Creates a validator that checks maximum length.
  ///
  /// Returns a validator function that ensures the input has at most
  /// the specified number of characters.
  ///
  /// ## Parameters
  ///
  /// - [length]: Maximum allowed length
  /// - [fieldName]: Field name for error message (default: 'This field')
  ///
  /// ## Returns
  ///
  /// A validator function.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final validator = Validators.maxLength(10, 'Bio');
  /// validator('short');         // null (valid)
  /// validator('this is too long');  // 'Bio must be at most 10 characters'
  /// ```
  static String? Function(String?) maxLength(int length, [String fieldName = 'This field']) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length > length) {
        return '$fieldName must be at most $length characters';
      }

      return null;
    };
  }

  /// Validates that a value is a valid number.
  ///
  /// Empty values are considered valid.
  ///
  /// ## Parameters
  ///
  /// - [value]: The string to validate as a number
  ///
  /// ## Returns
  ///
  /// - `null` if the value is a valid number or empty
  /// - An error message if not a valid number
  ///
  /// ## Example
  ///
  /// ```dart
  /// Validators.numeric('123');    // null (valid)
  /// Validators.numeric('12.34');  // null (valid)
  /// Validators.numeric('-5');     // null (valid)
  /// Validators.numeric('abc');    // 'Please enter a valid number'
  /// ```
  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  /// Combines multiple validators into a single validator.
  ///
  /// Runs each validator in order and returns the first error encountered,
  /// or `null` if all validators pass.
  ///
  /// ## Parameters
  ///
  /// - [validators]: List of validator functions to combine
  ///
  /// ## Returns
  ///
  /// A combined validator function.
  ///
  /// ## Example
  ///
  /// ```dart
  /// TextFormField(
  ///   validator: Validators.combine([
  ///     (v) => Validators.required(v, 'Username'),
  ///     Validators.minLength(3, 'Username'),
  ///     Validators.maxLength(20, 'Username'),
  ///   ]),
  /// );
  /// ```
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}

/// Type of contact information detected.
enum ContactType {
  phone,
  email,
  social,
  url,
}

/// Result of contact information detection.
class ContactDetectionResult {
  const ContactDetectionResult({
    required this.detected,
    this.type,
    this.value,
  });

  /// Whether contact information was detected.
  final bool detected;

  /// Type of contact info detected.
  final ContactType? type;

  /// The detected contact value.
  final String? value;

  /// Creates a result with no detection.
  const ContactDetectionResult.none()
      : detected = false,
        type = null,
        value = null;
}

/// Contact information detection utility.
///
/// Used to detect and prevent sharing of personal contact details
/// in chat messages (S39 - Contact Sharing Prevention feature).
///
/// ## Detected Patterns
///
/// - **Phone numbers**: 10+ digits with optional country code
/// - **Email addresses**: Standard email format
/// - **Social media**: @handles and social platform mentions
/// - **URLs**: Web links and domains
///
/// ## Example
///
/// ```dart
/// final result = ContactDetector.detect('Call me at 123-456-7890');
/// if (result.detected) {
///   print('Detected ${result.type}: ${result.value}');
///   // Show warning to user
/// }
/// ```
abstract class ContactDetector {
  /// Pattern for phone numbers (10+ digits).
  static final _phonePattern = RegExp(r'(?:\+?[\d\s\-()]{10,})');

  /// Pattern for email addresses.
  static final _emailPattern =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  /// Pattern for social media handles and mentions.
  static final _socialPattern = RegExp(
    r'(?:@[\w]+|(?:instagram|twitter|facebook|linkedin|whatsapp|telegram|discord)[\s:]*[\w@/.]+)',
    caseSensitive: false,
  );

  /// Pattern for URLs.
  static final _urlPattern = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\/\S*)?',
    caseSensitive: false,
  );

  /// Detects contact information in text.
  ///
  /// Checks for phone numbers, email addresses, social media handles,
  /// and URLs in the provided text.
  ///
  /// ## Parameters
  ///
  /// - [text]: The text to check for contact information
  ///
  /// ## Returns
  ///
  /// A [ContactDetectionResult] with detection details.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = ContactDetector.detect('Email me at test@example.com');
  /// print(result.detected);  // true
  /// print(result.type);      // ContactType.email
  /// print(result.value);     // 'test@example.com'
  /// ```
  static ContactDetectionResult detect(String text) {
    // Check for phone numbers
    final phoneMatch = _phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      return ContactDetectionResult(
        detected: true,
        type: ContactType.phone,
        value: phoneMatch.group(0),
      );
    }

    // Check for email addresses
    final emailMatch = _emailPattern.firstMatch(text);
    if (emailMatch != null) {
      return ContactDetectionResult(
        detected: true,
        type: ContactType.email,
        value: emailMatch.group(0),
      );
    }

    // Check for social media handles
    final socialMatch = _socialPattern.firstMatch(text);
    if (socialMatch != null) {
      return ContactDetectionResult(
        detected: true,
        type: ContactType.social,
        value: socialMatch.group(0),
      );
    }

    // Check for URLs
    final urlMatch = _urlPattern.firstMatch(text);
    if (urlMatch != null) {
      return ContactDetectionResult(
        detected: true,
        type: ContactType.url,
        value: urlMatch.group(0),
      );
    }

    return const ContactDetectionResult.none();
  }

  /// Returns a human-readable label for the contact type.
  static String getTypeLabel(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return 'phone number';
      case ContactType.email:
        return 'email address';
      case ContactType.social:
        return 'social media handle';
      case ContactType.url:
        return 'website link';
    }
  }
}

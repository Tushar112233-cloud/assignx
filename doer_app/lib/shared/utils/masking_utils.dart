/// Utilities for masking sensitive data in the UI.
///
/// This file provides static utility methods for protecting user privacy
/// by hiding portions of sensitive information like bank accounts,
/// phone numbers, emails, and government IDs.
///
/// ## Features
/// - Bank account number masking
/// - Phone number masking
/// - Email address masking
/// - Government ID masking (PAN, Aadhaar, IFSC)
/// - Payment ID masking (UPI, card numbers)
/// - Conditional masking toggle
///
/// ## Example
/// ```dart
/// MaskingUtils.maskAccountNumber('123456789012'); // "********9012"
/// MaskingUtils.maskPhone('9876543210'); // "98******10"
/// MaskingUtils.maskEmail('user@email.com'); // "u***@email.com"
/// ```
///
/// ## Security Note
/// These utilities are for UI display only. Sensitive data should still
/// be properly secured in storage and transmission.
///
/// See also:
/// - [DateFormatter] for date formatting
/// - [CurrencyFormatter] for currency formatting
library;

/// Utility class for masking sensitive data in the UI.
///
/// Provides static methods to hide portions of sensitive information
/// while keeping enough visible for users to identify the data.
///
/// ## Usage
/// ```dart
/// MaskingUtils.maskAccountNumber('123456789012'); // "********9012"
/// MaskingUtils.maskPhone('9876543210'); // "98******10"
/// ```
///
/// All methods handle null and empty inputs gracefully by returning
/// an empty string.
class MaskingUtils {
  /// Private constructor to prevent instantiation.
  MaskingUtils._();

  /// Masks a bank account number, showing only the last 4 digits.
  ///
  /// The remaining digits are replaced with asterisks.
  ///
  /// ## Examples
  /// - '123456789012' -> '********9012'
  /// - '1234' -> '1234' (no masking for <= 4 digits)
  /// - null -> '' (empty string)
  static String maskAccountNumber(String? number) {
    if (number == null || number.isEmpty) return '';
    if (number.length <= 4) return number;

    final visible = number.substring(number.length - 4);
    final masked = '*' * (number.length - 4);
    return '$masked$visible';
  }

  /// Masks a phone number, showing first 2 and last 2 digits.
  ///
  /// Removes any formatting characters (spaces, dashes, parentheses)
  /// before masking.
  ///
  /// ## Examples
  /// - '9876543210' -> '98******10'
  /// - '+91 98765 43210' -> '98******10'
  /// - '1234' -> '1234' (no masking for <= 4 digits)
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    if (phone.length <= 4) return phone;

    // Remove any formatting
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length <= 4) return cleaned;

    final prefix = cleaned.substring(0, 2);
    final suffix = cleaned.substring(cleaned.length - 2);
    final masked = '*' * (cleaned.length - 4);
    return '$prefix$masked$suffix';
  }

  /// Masks an email, showing first character and full domain.
  ///
  /// The username portion (before @) is masked except for the first
  /// character. The domain is always shown in full.
  ///
  /// ## Examples
  /// - 'user@email.com' -> 'u***@email.com'
  /// - 'john.doe@company.org' -> 'j*******@company.org'
  /// - 'a@b.com' -> 'a@b.com' (single char username)
  static String maskEmail(String? email) {
    if (email == null || email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 1) return email;

    final visible = name[0];
    final masked = '*' * (name.length - 1);
    return '$visible$masked@$domain';
  }

  /// Masks an IFSC code, showing first 4 and last 3 characters.
  ///
  /// IFSC codes are 11 characters. Invalid length codes are returned
  /// as-is without masking.
  ///
  /// ## Examples
  /// - 'HDFC0001234' -> 'HDFC****234'
  /// - 'SBIN0005678' -> 'SBIN****678'
  /// - 'INVALID' -> 'INVALID' (wrong length)
  static String maskIFSC(String? ifsc) {
    if (ifsc == null || ifsc.isEmpty) return '';
    if (ifsc.length != 11) return ifsc;

    final prefix = ifsc.substring(0, 4);
    final suffix = ifsc.substring(8);
    return '$prefix****$suffix';
  }

  /// Masks a UPI ID, showing first 2 characters and provider.
  ///
  /// The provider (after @) is always shown in full.
  ///
  /// ## Examples
  /// - 'username@upi' -> 'us*****@upi'
  /// - 'john@paytm' -> 'jo**@paytm'
  /// - 'ab@gpay' -> 'ab@gpay' (2 or fewer chars)
  static String maskUPI(String? upi) {
    if (upi == null || upi.isEmpty) return '';

    final parts = upi.split('@');
    if (parts.length != 2) return upi;

    final name = parts[0];
    final provider = parts[1];

    if (name.length <= 2) return upi;

    final visible = name.substring(0, 2);
    final masked = '*' * (name.length - 2);
    return '$visible$masked@$provider';
  }

  /// Masks a PAN number, showing last 4 characters.
  ///
  /// PAN numbers are 10 characters. Invalid length codes are returned
  /// as-is without masking.
  ///
  /// ## Examples
  /// - 'ABCDE1234F' -> '******234F'
  /// - 'ZZZZZ9999A' -> '******999A'
  /// - 'INVALID' -> 'INVALID' (wrong length)
  static String maskPAN(String? pan) {
    if (pan == null || pan.isEmpty) return '';
    if (pan.length != 10) return pan;

    final visible = pan.substring(6);
    return '******$visible';
  }

  /// Masks an Aadhaar number, showing last 4 digits.
  ///
  /// Aadhaar numbers are 12 digits. Spaces are removed before
  /// validation. Invalid length numbers are returned as-is.
  ///
  /// ## Examples
  /// - '123456789012' -> '********9012'
  /// - '1234 5678 9012' -> '********9012'
  /// - 'INVALID' -> 'INVALID' (wrong length)
  static String maskAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.isEmpty) return '';

    // Remove any spaces
    final cleaned = aadhaar.replaceAll(' ', '');
    if (cleaned.length != 12) return aadhaar;

    final visible = cleaned.substring(8);
    return '********$visible';
  }

  /// Masks a credit/debit card number, showing last 4 digits.
  ///
  /// Accepts card numbers between 12 and 19 digits. Spaces and
  /// dashes are removed before masking. Output is formatted with
  /// spaces for readability.
  ///
  /// ## Examples
  /// - '4111111111111111' -> '**** **** **** 1111'
  /// - '4111-1111-1111-1111' -> '**** **** **** 1111'
  /// - '123' -> '123' (invalid length)
  static String maskCardNumber(String? card) {
    if (card == null || card.isEmpty) return '';

    // Remove any spaces or dashes
    final cleaned = card.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length < 12 || cleaned.length > 19) return card;

    final visible = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $visible';
  }

  /// Creates a formatted masked display for bank account.
  ///
  /// Combines the masked account number with the bank name for
  /// easy identification.
  ///
  /// ## Examples
  /// ```dart
  /// formatMaskedAccount(
  ///   accountNumber: '123456789012',
  ///   bankName: 'HDFC Bank',
  /// ); // "HDFC Bank - ********9012"
  /// ```
  static String formatMaskedAccount({
    required String accountNumber,
    String? bankName,
  }) {
    final masked = maskAccountNumber(accountNumber);
    if (bankName != null && bankName.isNotEmpty) {
      return '$bankName - $masked';
    }
    return masked;
  }

  /// Determines if a value should be shown or masked based on context.
  ///
  /// Use this when you want to toggle between masked and unmasked views,
  /// such as with a "show/hide" button.
  ///
  /// ## Example
  /// ```dart
  /// conditionalMask(
  ///   value: '9876543210',
  ///   showFull: isRevealed,
  ///   maskFunction: MaskingUtils.maskPhone,
  /// );
  /// ```
  ///
  /// Returns [value] if [showFull] is true, otherwise returns the
  /// result of [maskFunction].
  static String conditionalMask({
    required String value,
    required bool showFull,
    required String Function(String) maskFunction,
  }) {
    if (showFull) return value;
    return maskFunction(value);
  }
}

/// Utility helper functions for common operations.
///
/// This file provides standalone helper functions for various tasks
/// including clipboard operations, URL launching, string manipulation,
/// file handling, and UI utilities.
///
/// ## Categories
/// - **Clipboard**: Copy text to clipboard
/// - **URL Launching**: Open URLs, emails, phone, WhatsApp
/// - **String Utilities**: Initials generation, masking sensitive data
/// - **File Utilities**: Extension extraction, size formatting
/// - **Performance**: Debounce function
/// - **Security**: Password strength calculation
/// - **UI Helpers**: Urgency color calculation
///
/// ## Usage
/// All methods are static and can be called directly:
/// ```dart
/// await Helpers.copyToClipboard(text, context);
/// await Helpers.openUrl('https://example.com');
/// final initials = Helpers.getInitials('John Doe'); // "JD"
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper functions for the app.
///
/// Provides static utility methods for common operations.
/// All methods are self-contained and don't require instantiation.
class Helpers {
  /// Private constructor to prevent instantiation.
  Helpers._();

  // ---------------------------------------------------------------------------
  // Clipboard Operations
  // ---------------------------------------------------------------------------

  /// Copies text to clipboard.
  ///
  /// Copies the provided text to the system clipboard and shows
  /// a confirmation snackbar.
  ///
  /// @param text The text to copy
  /// @param context BuildContext for showing snackbar
  ///
  /// ## Example
  /// ```dart
  /// await Helpers.copyToClipboard('Hello World', context);
  /// ```
  static Future<void> copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // URL Launching
  // ---------------------------------------------------------------------------

  /// Opens URL in browser.
  ///
  /// Launches the URL in the device's default external browser.
  ///
  /// @param url The URL to open (must be a valid URL string)
  ///
  /// ## Example
  /// ```dart
  /// await Helpers.openUrl('https://example.com');
  /// ```
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens email client.
  ///
  /// Launches the device's email client with the specified recipient,
  /// and optional subject and body.
  ///
  /// @param email The recipient email address
  /// @param subject Optional email subject
  /// @param body Optional email body
  ///
  /// ## Example
  /// ```dart
  /// await Helpers.openEmail(
  ///   'support@example.com',
  ///   subject: 'Help Request',
  ///   body: 'I need help with...',
  /// );
  /// ```
  static Future<void> openEmail(String email, {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens phone dialer.
  ///
  /// Launches the device's phone dialer with the specified number.
  ///
  /// @param phoneNumber The phone number to dial
  ///
  /// ## Example
  /// ```dart
  /// await Helpers.openPhone('+919876543210');
  /// ```
  static Future<void> openPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Opens WhatsApp chat.
  ///
  /// Opens WhatsApp with a chat to the specified phone number
  /// and optional pre-filled message.
  ///
  /// @param phoneNumber The phone number (with or without country code)
  /// @param message Optional pre-filled message
  ///
  /// ## Note
  /// If no country code is provided, +91 (India) is assumed.
  ///
  /// ## Example
  /// ```dart
  /// await Helpers.openWhatsApp(
  ///   '9876543210',
  ///   message: 'Hello, I have a question',
  /// );
  /// ```
  static Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
    final uri = Uri.parse(
      'https://wa.me/${formattedPhone.replaceAll('+', '')}${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // String Utilities
  // ---------------------------------------------------------------------------

  /// Generates initials from name.
  ///
  /// Extracts the first character of the first and last words
  /// in the name, returning uppercase initials.
  ///
  /// @param name The full name to extract initials from
  /// @returns Uppercase initials (1-2 characters)
  ///
  /// ## Example
  /// ```dart
  /// Helpers.getInitials('John Doe');     // "JD"
  /// Helpers.getInitials('Alice');        // "A"
  /// Helpers.getInitials('John Q. Doe');  // "JD"
  /// ```
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Masks sensitive data (e.g., account number).
  ///
  /// Replaces all but the last [visibleChars] characters with asterisks.
  ///
  /// @param value The string to mask
  /// @param visibleChars Number of visible characters at the end
  /// @returns Masked string with asterisks and visible suffix
  ///
  /// ## Example
  /// ```dart
  /// Helpers.maskString('1234567890');           // "******7890"
  /// Helpers.maskString('1234567890', visibleChars: 2); // "********90"
  /// ```
  static String maskString(String value, {int visibleChars = 4}) {
    if (value.length <= visibleChars) return value;
    final masked = '*' * (value.length - visibleChars);
    return '$masked${value.substring(value.length - visibleChars)}';
  }

  // ---------------------------------------------------------------------------
  // File Utilities
  // ---------------------------------------------------------------------------

  /// Gets file extension from path.
  ///
  /// Extracts and returns the file extension in lowercase.
  ///
  /// @param path The file path or filename
  /// @returns The file extension without the dot
  ///
  /// ## Example
  /// ```dart
  /// Helpers.getFileExtension('document.pdf');    // "pdf"
  /// Helpers.getFileExtension('/path/to/file.PNG'); // "png"
  /// ```
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Formats file size.
  ///
  /// Converts bytes to human-readable format (B, KB, MB, GB).
  ///
  /// @param bytes The file size in bytes
  /// @returns Formatted string with appropriate unit
  ///
  /// ## Example
  /// ```dart
  /// Helpers.formatFileSize(500);        // "500 B"
  /// Helpers.formatFileSize(1500);       // "1.5 KB"
  /// Helpers.formatFileSize(1500000);    // "1.4 MB"
  /// ```
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ---------------------------------------------------------------------------
  // Performance Utilities
  // ---------------------------------------------------------------------------

  /// Debounce function for search.
  ///
  /// Returns a function that will only execute the callback if
  /// [duration] has passed since the last call.
  ///
  /// @param duration Minimum time between callback executions
  /// @param callback The function to debounce
  /// @returns A debounced version of the callback
  ///
  /// ## Example
  /// ```dart
  /// final debouncedSearch = Helpers.debounce<String>(
  ///   Duration(milliseconds: 300),
  ///   (query) => performSearch(query),
  /// );
  ///
  /// // In a text field:
  /// onChanged: debouncedSearch,
  /// ```
  ///
  /// ## Note
  /// This is a simple debounce implementation. For more complex
  /// scenarios, consider using a dedicated debounce package.
  static Function(T) debounce<T>(
    Duration duration,
    Function(T) callback,
  ) {
    DateTime? lastCall;
    return (T arg) {
      final now = DateTime.now();
      if (lastCall == null || now.difference(lastCall!) > duration) {
        lastCall = now;
        callback(arg);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // Security Utilities
  // ---------------------------------------------------------------------------

  /// Calculates password strength (0-4).
  ///
  /// Evaluates password strength based on multiple criteria:
  /// - Length >= 8: +1 point
  /// - Length >= 12: +1 point
  /// - Mixed case (upper and lower): +1 point
  /// - Contains digits: +1 point
  /// - Contains special characters: +1 point
  ///
  /// @param password The password to evaluate
  /// @returns Strength score from 0 (weak) to 4 (strong)
  ///
  /// ## Example
  /// ```dart
  /// Helpers.passwordStrength('abc');           // 0
  /// Helpers.passwordStrength('abcd1234');      // 1
  /// Helpers.passwordStrength('Abcd1234!');     // 4
  /// ```
  static int passwordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    }
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(0, 4);
  }

  // ---------------------------------------------------------------------------
  // UI Utilities
  // ---------------------------------------------------------------------------

  /// Returns urgency color based on deadline.
  ///
  /// Calculates the appropriate color based on how soon the deadline is:
  /// - Overdue (past): Gray
  /// - Within 6 hours: Red (high urgency)
  /// - Within 24 hours: Amber (medium urgency)
  /// - More than 24 hours: Green (low urgency)
  ///
  /// @param deadline The deadline datetime
  /// @returns Color appropriate for the urgency level
  ///
  /// ## Example
  /// ```dart
  /// final deadline = DateTime.now().add(Duration(hours: 3));
  /// final color = Helpers.getUrgencyColor(deadline); // Red
  ///
  /// Container(
  ///   decoration: BoxDecoration(
  ///     color: color.withOpacity(0.1),
  ///     border: Border.all(color: color),
  ///   ),
  /// );
  /// ```
  static Color getUrgencyColor(DateTime deadline) {
    final now = DateTime.now();
    final hoursLeft = deadline.difference(now).inHours;

    if (hoursLeft < 0) return Colors.grey;
    if (hoursLeft <= 6) return const Color(0xFFDC2626); // High urgency
    if (hoursLeft <= 24) return const Color(0xFFF59E0B); // Medium urgency
    return const Color(0xFF22C55E); // Low urgency
  }
}

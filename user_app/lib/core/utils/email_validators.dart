/// Shared email validation utilities.
class EmailValidators {
  EmailValidators._();

  static final _collegeEmailPatterns = [
    RegExp(r'\.edu$', caseSensitive: false),
    RegExp(r'\.ac\.in$', caseSensitive: false),
    RegExp(r'\.edu\.in$', caseSensitive: false),
    RegExp(r'\.ac\.uk$', caseSensitive: false),
    RegExp(r'\.edu\.au$', caseSensitive: false),
    RegExp(r'\.edu\.ca$', caseSensitive: false),
  ];

  /// Returns true if the email belongs to an educational institution.
  static bool isCollegeEmail(String email) {
    final parts = email.toLowerCase().split('@');
    if (parts.length != 2) return false;
    final domain = parts[1];
    return _collegeEmailPatterns.any((pattern) => pattern.hasMatch(domain));
  }
}

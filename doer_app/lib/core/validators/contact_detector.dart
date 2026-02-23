/// Contact Information Detection for S39 Feature.
///
/// Prevents sharing of contact information in chat messages
/// to enforce communication through the platform.
library;

/// Result of contact detection scan.
class ContactDetectionResult {
  final bool detected;
  final List<String> matches;
  final List<ContactType> types;

  const ContactDetectionResult({
    this.detected = false,
    this.matches = const [],
    this.types = const [],
  });

  /// Human-readable description of what was detected.
  String get description {
    if (!detected) return 'No contact information detected';
    final typeNames = types.map((t) => t.displayName).toSet().join(', ');
    return 'Detected: $typeNames';
  }
}

/// Types of contact information that can be detected.
enum ContactType {
  phoneNumber('Phone Number'),
  email('Email Address'),
  socialMedia('Social Media'),
  website('Website URL'),
  whatsapp('WhatsApp'),
  telegram('Telegram'),
  instagram('Instagram'),
  discord('Discord');

  final String displayName;
  const ContactType(this.displayName);
}

/// Detects contact information in text content.
///
/// Used to enforce S39: Contact Sharing Prevention in chat messages.
class ContactDetector {
  ContactDetector._();

  // Phone number patterns (Indian and international)
  static final _phonePatterns = [
    // Indian mobile: 10 digits starting with 6-9
    RegExp(r'\b[6-9]\d{9}\b'),
    // With country code: +91 or 91
    RegExp(r'\b(?:\+91|91)?[-\s]?[6-9]\d{9}\b'),
    // International format
    RegExp(r'\b\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}\b'),
    // Formatted Indian: 98765-12345 or 98765 12345
    RegExp(r'\b[6-9]\d{4}[-\s]?\d{5}\b'),
  ];

  // Email patterns
  static final _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
    caseSensitive: false,
  );

  // Social media patterns
  static final _socialPatterns = {
    ContactType.whatsapp: [
      RegExp(r'\bwhatsapp\s*:?\s*\+?\d{10,}', caseSensitive: false),
      RegExp(r'\bwa\.me/\d+', caseSensitive: false),
      RegExp(r'\bwhatsapp\b', caseSensitive: false),
    ],
    ContactType.telegram: [
      RegExp(r'\bt\.me/\w+', caseSensitive: false),
      RegExp(r'\btelegram\s*:?\s*@?\w+', caseSensitive: false),
      RegExp(r'\btelegram\b', caseSensitive: false),
    ],
    ContactType.instagram: [
      RegExp(r'\binstagram\.com/\w+', caseSensitive: false),
      RegExp(r'\binsta\s*:?\s*@?\w+', caseSensitive: false),
      RegExp(r'\b@\w+\s*(?:on\s+)?(?:insta|ig)\b', caseSensitive: false),
    ],
    ContactType.discord: [
      RegExp(r'\bdiscord\s*:?\s*\w+#\d{4}', caseSensitive: false),
      RegExp(r'\bdiscord\.gg/\w+', caseSensitive: false),
    ],
  };

  // URL patterns
  static final _urlPattern = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  // Common obfuscation patterns people use to bypass detection
  static final _obfuscationPatterns = [
    // "nine eight seven six five" etc.
    RegExp(
      r'\b(?:zero|one|two|three|four|five|six|seven|eight|nine)(?:\s+(?:zero|one|two|three|four|five|six|seven|eight|nine)){6,}',
      caseSensitive: false,
    ),
    // "9 eight 7 six" mixed
    RegExp(
      r'\b(?:\d|zero|one|two|three|four|five|six|seven|eight|nine)(?:\s+(?:\d|zero|one|two|three|four|five|six|seven|eight|nine)){6,}',
      caseSensitive: false,
    ),
    // Email with "at" and "dot"
    RegExp(
      r'\b\w+\s*(?:at|@)\s*\w+\s*(?:dot|\.)\s*(?:com|in|org|net)\b',
      caseSensitive: false,
    ),
  ];

  /// Detects contact information in the given text.
  ///
  /// Returns a [ContactDetectionResult] with details about what was found.
  static ContactDetectionResult detect(String text) {
    if (text.isEmpty) {
      return const ContactDetectionResult();
    }

    final matches = <String>[];
    final types = <ContactType>[];

    // Check phone numbers
    for (final pattern in _phonePatterns) {
      final phoneMatches = pattern.allMatches(text);
      for (final match in phoneMatches) {
        final phone = match.group(0)!;
        // Filter out short numbers that might be false positives
        final digits = phone.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 10) {
          matches.add(phone);
          if (!types.contains(ContactType.phoneNumber)) {
            types.add(ContactType.phoneNumber);
          }
        }
      }
    }

    // Check email
    final emailMatches = _emailPattern.allMatches(text);
    for (final match in emailMatches) {
      matches.add(match.group(0)!);
      if (!types.contains(ContactType.email)) {
        types.add(ContactType.email);
      }
    }

    // Check social media
    for (final entry in _socialPatterns.entries) {
      for (final pattern in entry.value) {
        final socialMatches = pattern.allMatches(text);
        for (final match in socialMatches) {
          matches.add(match.group(0)!);
          if (!types.contains(entry.key)) {
            types.add(entry.key);
          }
        }
      }
    }

    // Check URLs (except allowed domains)
    final urlMatches = _urlPattern.allMatches(text);
    for (final match in urlMatches) {
      final url = match.group(0)!;
      if (!_isAllowedUrl(url)) {
        matches.add(url);
        if (!types.contains(ContactType.website)) {
          types.add(ContactType.website);
        }
      }
    }

    // Check obfuscation attempts
    for (final pattern in _obfuscationPatterns) {
      final obfuscatedMatches = pattern.allMatches(text);
      for (final match in obfuscatedMatches) {
        matches.add(match.group(0)!);
        // Determine likely type
        final matchText = match.group(0)!.toLowerCase();
        if (matchText.contains('at') || matchText.contains('dot')) {
          if (!types.contains(ContactType.email)) {
            types.add(ContactType.email);
          }
        } else {
          if (!types.contains(ContactType.phoneNumber)) {
            types.add(ContactType.phoneNumber);
          }
        }
      }
    }

    return ContactDetectionResult(
      detected: matches.isNotEmpty,
      matches: matches.toSet().toList(), // Remove duplicates
      types: types,
    );
  }

  /// Checks if a URL is from an allowed domain (platform URLs, file sharing, etc.)
  static bool _isAllowedUrl(String url) {
    final allowedDomains = [
      'supabase.co',
      'supabase.com',
      'assignx.com',
      'assign-x.com',
      // Add other allowed domains as needed
    ];

    final lowerUrl = url.toLowerCase();
    return allowedDomains.any((domain) => lowerUrl.contains(domain));
  }

  /// Masks detected contact information in text for display.
  ///
  /// Replaces detected contact info with [REDACTED] markers.
  static String maskContactInfo(String text) {
    String masked = text;

    // Mask phone numbers
    for (final pattern in _phonePatterns) {
      masked = masked.replaceAllMapped(pattern, (match) {
        final original = match.group(0)!;
        final digits = original.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 10) {
          return '[PHONE REDACTED]';
        }
        return original;
      });
    }

    // Mask emails
    masked = masked.replaceAllMapped(_emailPattern, (match) {
      return '[EMAIL REDACTED]';
    });

    // Mask social media
    for (final patterns in _socialPatterns.values) {
      for (final pattern in patterns) {
        masked = masked.replaceAllMapped(pattern, (match) {
          return '[SOCIAL REDACTED]';
        });
      }
    }

    // Mask URLs
    masked = masked.replaceAllMapped(_urlPattern, (match) {
      final url = match.group(0)!;
      if (!_isAllowedUrl(url)) {
        return '[URL REDACTED]';
      }
      return url;
    });

    return masked;
  }
}

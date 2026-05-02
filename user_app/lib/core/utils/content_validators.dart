/// Content Validation Utilities
///
/// Provides comprehensive pattern matching for detecting personal information
/// in chat messages. Includes patterns for phone numbers, emails, social media
/// handles, addresses, and external links.
///
/// These patterns are designed to work with Indian and international formats.
library;

/// Content Validators - Static utility class for content validation.
///
/// Provides regex patterns and helper functions for detecting various types
/// of personal information in text content.
class ContentValidators {
  ContentValidators._();

  // ===========================================================================
  // PHONE NUMBER PATTERNS
  // ===========================================================================

  /// Phone number patterns - matches various international formats.
  /// Includes Indian (+91), US/Canada, UK, and generic formats.
  static final List<RegExp> phonePatterns = [
    // International format with country code (general)
    RegExp(r'\+\d{1,4}[\s.-]?\(?\d{1,4}\)?[\s.-]?\d{1,4}[\s.-]?\d{1,4}[\s.-]?\d{1,4}'),

    // Indian phone numbers: +91, 0, or direct 10 digits starting with 6-9
    RegExp(r'(?:\+91|0)?[\s.-]?[6-9]\d{4}[\s.-]?\d{5}'),
    RegExp(r'(?:\+91|0)?[\s.-]?[6-9]\d{9}'),

    // Specific Indian mobile prefixes (Jio, Airtel, Vi, BSNL, etc.)
    RegExp(r'(?:\+91[\s.-]?)?(?:70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99)\d{8}'),

    // US/Canada format: (XXX) XXX-XXXX or XXX-XXX-XXXX
    RegExp(r'\(?[2-9]\d{2}\)?[\s.-]?\d{3}[\s.-]?\d{4}'),

    // UK format: +44 or 0 followed by 10-11 digits
    RegExp(r'(?:\+44|0)[\s.-]?\d{4}[\s.-]?\d{6}'),

    // Generic 10+ consecutive digits
    RegExp(r'\d{10,14}'),

    // Spaced out numbers (trying to evade detection)
    RegExp(r'\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d'),

    // Written out numbers with keywords
    RegExp(
      r'(?:call|contact|whatsapp|phone|mobile|number|msg|text|dial|reach)[\s:]*(?:me\s*(?:at|on)?\s*)?[+]?\d[\d\s.-]{7,}',
      caseSensitive: false,
    ),

    // "my number is" patterns
    RegExp(
      r'(?:my|the)\s*(?:phone|mobile|cell|contact)?\s*(?:number|no\.?|#)?\s*(?:is|:)?\s*[+]?\d[\d\s.-]{7,}',
      caseSensitive: false,
    ),

    // STD codes for India (landlines)
    RegExp(r'(?:0\d{2,4})[\s.-]?\d{6,8}'),
  ];

  // ===========================================================================
  // EMAIL PATTERNS
  // ===========================================================================

  /// Email patterns - matches standard and obfuscated emails.
  static final List<RegExp> emailPatterns = [
    // Standard email format
    RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', caseSensitive: false),

    // Obfuscated: user [at] domain [dot] com
    RegExp(
      r'[a-zA-Z0-9._%+-]+\s*(?:\[at\]|\(at\)|at)\s*[a-zA-Z0-9.-]+\s*(?:\[dot\]|\(dot\)|dot)\s*[a-zA-Z]{2,}',
      caseSensitive: false,
    ),

    // Spaced out: user @ domain . com
    RegExp(r'[a-zA-Z0-9._%+-]+\s*@\s*[a-zA-Z0-9.-]+\s*\.\s*[a-zA-Z]{2,}', caseSensitive: false),

    // "my email is" patterns
    RegExp(
      r'(?:my|the)\s*(?:email|mail|e-mail)\s*(?:id|address)?\s*(?:is|:)?\s*[a-zA-Z0-9._%+-]+\s*[@]\s*[a-zA-Z0-9.-]+',
      caseSensitive: false,
    ),

    // Common Indian email domains explicitly mentioned
    RegExp(
      r'[a-zA-Z0-9._%+-]+\s*(?:@|at)\s*(?:gmail|yahoo|hotmail|outlook|rediffmail)\.(?:com|co\.in|in)',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // SOCIAL MEDIA PATTERNS
  // ===========================================================================

  /// Social media handle patterns.
  static final List<RegExp> socialMediaPatterns = [
    // @ mentions (Twitter, Instagram, etc.)
    RegExp(r'@[a-zA-Z0-9_]{3,30}'),

    // "follow me at" or "dm me at" patterns
    RegExp(
      r'(?:follow|dm|message|ping|add)\s*(?:me)?\s*(?:at|on)?\s*@?[a-zA-Z0-9_]{3,30}',
      caseSensitive: false,
    ),

    // "my handle/username is" patterns
    RegExp(
      r'(?:my|the)\s*(?:handle|username|user\s*name|insta|twitter|ig)\s*(?:is|:)?\s*@?[a-zA-Z0-9_]{3,30}',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // WHATSAPP PATTERNS
  // ===========================================================================

  /// WhatsApp-specific patterns.
  static final List<RegExp> whatsappPatterns = [
    // Direct mentions of WhatsApp
    RegExp(r'whatsapp', caseSensitive: false),
    RegExp(r'whats\s*app', caseSensitive: false),
    RegExp(r'wa\.me\/?\d*', caseSensitive: false),
    RegExp(r'api\.whatsapp\.com', caseSensitive: false),

    // Common abbreviations
    RegExp(r'\bwa\b', caseSensitive: false),
    RegExp(r'\bwapp\b', caseSensitive: false),

    // "ping me on whatsapp" style
    RegExp(
      r'(?:msg|message|text|ping|call|contact)\s*(?:me\s*)?(?:on\s*)?(?:whatsapp|wa|wapp)',
      caseSensitive: false,
    ),

    // Hindi/Hinglish variations
    RegExp(r'\bwhatspp\b', caseSensitive: false),
    RegExp(r'\bwatsapp\b', caseSensitive: false),
    RegExp(r'\bwtsap\b', caseSensitive: false),
  ];

  // ===========================================================================
  // INSTAGRAM PATTERNS
  // ===========================================================================

  /// Instagram-specific patterns.
  static final List<RegExp> instagramPatterns = [
    RegExp(r'instagram', caseSensitive: false),
    RegExp(r'\binsta\b', caseSensitive: false),
    RegExp(r'\big:', caseSensitive: false),
    RegExp(r'instagram\.com\/[a-zA-Z0-9_.]+', caseSensitive: false),

    // "follow me on instagram" style
    RegExp(
      r'(?:follow|dm|check)\s*(?:me\s*)?(?:on\s*)?(?:instagram|insta|ig)',
      caseSensitive: false,
    ),

    // "my instagram is" style
    RegExp(
      r'(?:my|the)\s*(?:instagram|insta|ig)\s*(?:is|:)?\s*@?[a-zA-Z0-9_.]+',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // TELEGRAM PATTERNS
  // ===========================================================================

  /// Telegram-specific patterns.
  static final List<RegExp> telegramPatterns = [
    RegExp(r'telegram', caseSensitive: false),
    RegExp(r'\btelegram\b', caseSensitive: false),
    RegExp(r't\.me\/[a-zA-Z0-9_]+', caseSensitive: false),

    // "msg me on telegram" style
    RegExp(
      r'(?:msg|message|text|ping)\s*(?:me\s*)?(?:on\s*)?telegram',
      caseSensitive: false,
    ),

    // "my telegram is" style
    RegExp(
      r'(?:my|the)\s*telegram\s*(?:is|:)?\s*@?[a-zA-Z0-9_]+',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // OTHER MESSAGING APP PATTERNS
  // ===========================================================================

  /// Other messaging app patterns.
  static final List<RegExp> messagingAppPatterns = [
    // Snapchat
    RegExp(r'snapchat', caseSensitive: false),
    RegExp(r'\bsnap\b', caseSensitive: false),
    RegExp(r'snapchat\.com\/add\/[a-zA-Z0-9_]+', caseSensitive: false),

    // Discord
    RegExp(r'discord', caseSensitive: false),
    RegExp(r'discord\.gg\/[a-zA-Z0-9]+', caseSensitive: false),
    RegExp(r'[a-zA-Z0-9_]+#\d{4}'), // Discord username#1234

    // Signal
    RegExp(r'\bsignal\s*(?:app)?\b', caseSensitive: false),

    // Facebook Messenger
    RegExp(r'(?:facebook|fb)\s*messenger', caseSensitive: false),
    RegExp(r'm\.me\/[a-zA-Z0-9.]+', caseSensitive: false),

    // LinkedIn
    RegExp(r'linkedin\.com\/in\/[a-zA-Z0-9-]+', caseSensitive: false),
    RegExp(r'\blinkedin\b', caseSensitive: false),

    // Twitter/X
    RegExp(r'\btwitter\b', caseSensitive: false),
    RegExp(r'twitter\.com\/[a-zA-Z0-9_]+', caseSensitive: false),
    RegExp(r'\bx\.com\/[a-zA-Z0-9_]+', caseSensitive: false),

    // Kik
    RegExp(r'\bkik\b', caseSensitive: false),
    RegExp(r'kik\.me\/[a-zA-Z0-9_]+', caseSensitive: false),
  ];

  // ===========================================================================
  // LINK PATTERNS
  // ===========================================================================

  /// URL and link patterns.
  static final List<RegExp> linkPatterns = [
    // HTTP/HTTPS URLs
    RegExp(r'https?:\/\/[^\s<>"{}|\\^`\[\]]+', caseSensitive: false),

    // www URLs
    RegExp(r'www\.[^\s<>"{}|\\^`\[\]]+', caseSensitive: false),

    // Common TLDs
    RegExp(
      r'[a-zA-Z0-9-]+\.(?:com|org|net|io|co|in|edu|gov|info|biz|me|app|dev|xyz|online|site|tech|cloud|store|shop|blog|link|click|live|us|uk|ca|au)\b[^\s]*',
      caseSensitive: false,
    ),

    // Shortened URLs
    RegExp(
      r'(?:bit\.ly|goo\.gl|t\.co|tinyurl\.com|ow\.ly|is\.gd|buff\.ly|cutt\.ly|rb\.gy|short\.io|tr\.im|v\.gd)\/[\w-]+',
      caseSensitive: false,
    ),

    // Social media and messaging app links
    RegExp(
      r'(?:instagram|facebook|twitter|linkedin|telegram|discord|snapchat|tiktok|youtube|whatsapp)\.(?:com|me)\/[\w./-]*',
      caseSensitive: false,
    ),

    // Google Drive/Docs/Meet links
    RegExp(r'(?:docs|drive|meet)\.google\.com\/[\w./?=&-]*', caseSensitive: false),

    // Zoom/Teams links
    RegExp(
      r'(?:zoom\.us|teams\.microsoft\.com|teams\.live\.com)\/[\w./?=&-]*',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // ADDRESS PATTERNS
  // ===========================================================================

  /// Address patterns - physical location information.
  static final List<RegExp> addressPatterns = [
    // Indian PIN codes (6 digits)
    RegExp(r'\b\d{6}\b'),

    // US ZIP codes (5 or 9 digits)
    RegExp(r'\b\d{5}(?:-\d{4})?\b'),

    // Street address indicators (common in India)
    RegExp(
      r'\b(?:house|flat|apt|apartment|building|floor|block|sector|plot|street|road|lane|nagar|colony|society|enclave|extension|phase|avenue|boulevard|drive|court|way|place|circle|marg|path|gali|mohalla|chowk|bazar|bazaar)\b[\s,]*(?:#?\d+|no\.?\s*\d+)?',
      caseSensitive: false,
    ),

    // House/Flat number patterns
    RegExp(
      r'\b(?:h\.?no\.?|house\s*no\.?|flat\s*no\.?|door\s*no\.?|plot\s*no\.?)\s*[:\-]?\s*\d+',
      caseSensitive: false,
    ),

    // Address with numbers and locality
    RegExp(
      r'\d+[\s,/]+(?:[\w\s]+)(?:street|road|lane|avenue|nagar|colony|sector)',
      caseSensitive: false,
    ),

    // "my address is" patterns
    RegExp(
      r'(?:my|the)\s*(?:address|location|place|home)\s*(?:is|:)\s*[A-Za-z0-9\s,.-]{15,}',
      caseSensitive: false,
    ),

    // Near/opposite location references
    RegExp(
      r'(?:near|opposite|behind|next\s+to|adjacent\s+to|beside|opp\.?)\s+[\w\s]{5,}',
      caseSensitive: false,
    ),

    // Location sharing intent
    RegExp(
      r'(?:i\s+)?(?:stay|live|reside|residing|located)\s+(?:at|in|near)\s+[\w\s,.-]{10,}',
      caseSensitive: false,
    ),

    // Indian state/city names with context
    RegExp(
      r'(?:from|in|at|to)\s+(?:delhi|mumbai|bangalore|bengaluru|chennai|hyderabad|kolkata|pune|ahmedabad|jaipur|lucknow|kanpur|nagpur|indore|thane|bhopal|visakhapatnam|patna|vadodara|ghaziabad|ludhiana|agra|nashik|faridabad|meerut|rajkot|varanasi|srinagar|aurangabad|dhanbad|amritsar|allahabad|ranchi|howrah|coimbatore|jabalpur|gwalior|vijayawada|jodhpur|madurai|raipur|kota|chandigarh|guwahati|solapur|hubli|mysore|tiruchirappalli|bareilly|aligarh|tiruppur|moradabad|jalandhar|bhubaneswar|salem|warangal|guntur|bhiwandi|saharanpur|gorakhpur|bikaner|amravati|noida|jamshedpur|bhilai|cuttack|firozabad|kochi|nellore|bhavnagar|dehradun|durgapur|asansol|rourkela|nanded|kolhapur|ajmer|akola|gulbarga|jamnagar|ujjain|loni|siliguri|jhansi|ulhasnagar|jammu|sangli|mangalore|erode|belgaum|ambattur|tirunelveli|malegaon|gaya|jalgaon|udaipur|maheshtala|davanagere|kozhikode|kurnool|rajahmundry|bokaro|south\s*dumdum|bellary|patiala|gopalpur|agartala|bhagalpur|muzaffarnagar|bhatpara|panihati|latur|dhule|tirupati|rohtak|korba|bhilwara|berhampur|muzaffarpur|ahmednagar|mathura|kollam|avadi|kadapa|kamarhati|sambalpur|bilaspur|shahjahanpur|satara|bijapur|rampur|shimoga|chandrapur|junagadh|thrissur|alwar|bardhaman|kulti|kakinada|nizamabad|parbhani|tumkur|hisar|ozhukarai|bihar\s*sharif|panipat|darbhanga|bally|aizawl|dewas|ichalkaranji|karnal|bathinda|jalna|eluru|kirari\s*suleman\s*nagar|barasat|purnia|satna|mau|sonipat|farrukhabad|sagar|rourkela|durg|imphal|ratlam|hapur|arrah|anantapur|karimnagar|etawah|ambernath|north\s*dumdum|bharatpur|begusarai|new\s*delhi|gandhidham|baranagar|tiruvottiyur|pondicherry|sikar|thoothukudi|rewa|mirzapur|raichur|pali|ramagundam|haridwar|vijayanagaram|katihar|nagarcoil|sri\s*ganganagar|karawal\s*nagar|mango|thanjavur|bulandshahr|uluberia|katni|sambhal|singrauli|nadiad|secunderabad|naihati|yamunanagar|bidhan\s*nagar|pallavaram|bidar|munger|panchkula|burhanpur|kharagpur|dindigul|gandhinagar|hospet|nangloi\s*jat|malda|ongole|deoghar|chapra|haldia|khandwa|nandyal|morena|amroha|anand|bhind|bhalswa\s*jahangir\s*pur|madhyamgram|bhiwani|berhampore|ambala|morbi|fatehpur|raebareli|khora|bhusawal|orai|bahraich|phusro|vellore|kumbakonam|raiganj|silchar|sirsa|pilkhuwa|jaunpur|panvel)\b',
      caseSensitive: false,
    ),
  ];

  // ===========================================================================
  // UTILITY FUNCTIONS
  // ===========================================================================

  /// Check if content contains any personal information.
  static bool containsPersonalInfo(String content) {
    if (content.isEmpty) return false;

    final allPatterns = [
      ...phonePatterns,
      ...emailPatterns,
      ...socialMediaPatterns,
      ...whatsappPatterns,
      ...instagramPatterns,
      ...telegramPatterns,
      ...messagingAppPatterns,
      ...linkPatterns,
      ...addressPatterns,
    ];

    for (final pattern in allPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }

    return false;
  }

  /// Check if content contains a phone number.
  static bool containsPhoneNumber(String content) {
    for (final pattern in phonePatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains an email address.
  static bool containsEmail(String content) {
    for (final pattern in emailPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains social media handles.
  static bool containsSocialMedia(String content) {
    final patterns = [
      ...socialMediaPatterns,
      ...instagramPatterns,
      ...telegramPatterns,
      ...messagingAppPatterns,
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains WhatsApp references.
  static bool containsWhatsApp(String content) {
    for (final pattern in whatsappPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains external links.
  static bool containsLinks(String content) {
    for (final pattern in linkPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains address information.
  static bool containsAddress(String content) {
    for (final pattern in addressPatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content appears to be trying to evade detection.
  static bool detectEvasionAttempt(String content) {
    // Check for excessive spacing between characters (trying to break up numbers)
    final spacedNumbers = RegExp(r'\d\s+\d\s+\d\s+\d\s+\d');
    if (spacedNumbers.hasMatch(content)) return true;

    // Check for unicode look-alikes (common substitutions)
    // Cyrillic characters that look like Latin
    final unicodeLookalikes = RegExp(r'[\u0430-\u044f\u0410-\u042f]');
    if (unicodeLookalikes.hasMatch(content)) return true;

    // Check for zero-width characters (invisible characters)
    final zeroWidth = RegExp(r'[\u200B-\u200D\uFEFF]');
    if (zeroWidth.hasMatch(content)) return true;

    // Check for leetspeak in sensitive contexts
    final leetspeakPatterns = [
      RegExp(r'ph0ne|pho|\bn[0o]\.?\s*:'), // "phone" variations
      RegExp(r'3m[a4]il|3-m[a4]il'), // "email" variations
      RegExp(r'c[a4]ll\s*m[e3]'), // "call me" variations
      RegExp(r'wh[a4]ts[a4]pp'), // "whatsapp" variations
    ];

    for (final pattern in leetspeakPatterns) {
      if (pattern.hasMatch(content.toLowerCase())) return true;
    }

    return false;
  }

  /// Normalize content for more accurate detection.
  /// Removes common evasion tactics.
  static String normalizeForDetection(String content) {
    var normalized = content;

    // Remove zero-width characters
    normalized = normalized.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

    // Normalize unicode lookalikes to ASCII
    final lookalikes = {
      '\u0430': 'a', '\u0435': 'e', '\u043E': 'o', '\u0440': 'p',
      '\u0441': 'c', '\u0443': 'y', '\u0445': 'x', '\u0410': 'A',
      '\u0415': 'E', '\u041E': 'O', '\u0420': 'P', '\u0421': 'C',
      // Common lookalikes
      '\u0251': 'a', // Latin small letter alpha
      '\u0261': 'g', // Latin small letter script g
      '\u026F': 'm', // Latin small letter turned m
      '\u0280': 'r', // Latin letter small capital r
    };

    lookalikes.forEach((unicode, ascii) {
      normalized = normalized.replaceAll(unicode, ascii);
    });

    // Normalize multiple spaces to single space
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Remove dots/dashes between numbers (common evasion tactic)
    // But preserve the numbers themselves
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d)[\s.\-_]+(?=\d)'),
      (match) => match.group(1)!,
    );

    return normalized;
  }

  /// Sanitize content by redacting detected personal information.
  static String sanitizeContent(String content) {
    var sanitized = content;

    // Redact phone numbers
    for (final pattern in phonePatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '[PHONE REDACTED]',
      );
    }

    // Redact emails
    for (final pattern in emailPatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '[EMAIL REDACTED]',
      );
    }

    // Redact social media handles
    for (final pattern in [
      ...socialMediaPatterns,
      ...instagramPatterns,
      ...telegramPatterns,
    ]) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '[SOCIAL REDACTED]',
      );
    }

    // Redact WhatsApp references
    for (final pattern in whatsappPatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '[WHATSAPP REDACTED]',
      );
    }

    // Redact links
    for (final pattern in linkPatterns) {
      sanitized = sanitized.replaceAllMapped(
        pattern,
        (match) => '[LINK REDACTED]',
      );
    }

    return sanitized;
  }

  /// Validate an Indian phone number format.
  /// Returns true if the phone number is valid.
  static bool isValidIndianPhone(String phone) {
    // Remove all non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Check for 10-digit Indian mobile number
    if (cleaned.length == 10) {
      // Must start with 6, 7, 8, or 9
      return RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned);
    }

    // Check for number with country code (91)
    if (cleaned.length == 12 && cleaned.startsWith('91')) {
      // The remaining 10 digits must start with 6, 7, 8, or 9
      return RegExp(r'^91[6-9]\d{9}$').hasMatch(cleaned);
    }

    return false;
  }

  /// Get all matches of personal info in content.
  /// Returns a list of matched strings with their types.
  static List<Map<String, dynamic>> findAllPersonalInfo(String content) {
    final results = <Map<String, dynamic>>[];

    void addMatches(List<RegExp> patterns, String type) {
      for (final pattern in patterns) {
        for (final match in pattern.allMatches(content)) {
          if (match.group(0) != null && match.group(0)!.length >= 3) {
            results.add({
              'type': type,
              'matched': match.group(0),
              'start': match.start,
              'end': match.end,
            });
          }
        }
      }
    }

    addMatches(phonePatterns, 'phone');
    addMatches(emailPatterns, 'email');
    addMatches(whatsappPatterns, 'whatsapp');
    addMatches(instagramPatterns, 'instagram');
    addMatches(telegramPatterns, 'telegram');
    addMatches(socialMediaPatterns, 'social_media');
    addMatches(messagingAppPatterns, 'messaging_app');
    addMatches(linkPatterns, 'link');
    addMatches(addressPatterns, 'address');

    // Sort by position and remove duplicates
    results.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

    return results;
  }
}

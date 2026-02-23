/**
 * Chat Content Validation & Moderation Utility
 *
 * Provides comprehensive AI-powered moderation to detect and block personal
 * information sharing in chat messages. This includes phone numbers, emails,
 * social media handles, addresses, and external links.
 *
 * @module chat-content
 */

// =============================================================================
// TYPES & INTERFACES
// =============================================================================

/**
 * Types of personal information violations that can be detected
 */
export type ViolationType =
  | 'phone'
  | 'email'
  | 'social_media'
  | 'address'
  | 'link'
  | 'messaging_app';

/**
 * Individual violation match details
 */
export interface ViolationMatch {
  /** Type of violation detected */
  type: ViolationType;
  /** The matched content string */
  matched: string;
  /** Start position in the original content */
  position: number;
  /** End position in the original content */
  endPosition: number;
  /** Specific pattern that was matched (e.g., 'whatsapp', 'instagram') */
  pattern?: string;
}

/**
 * Result of content moderation check
 */
export interface ModerationResult {
  /** Whether the message is allowed to be sent */
  allowed: boolean;
  /** Array of detected violations */
  violations: ViolationMatch[];
  /** User-friendly explanation message */
  message: string;
  /** Severity level: low (1 violation), medium (2-3), high (4+) */
  severity: 'low' | 'medium' | 'high';
  /** Sanitized content with violations redacted (for logging) */
  sanitizedContent: string;
}

/**
 * Legacy result interface for backward compatibility
 */
export interface ContentValidationResult {
  isValid: boolean;
  reason?: ViolationType;
  message?: string;
}

/**
 * Detection result from pattern matching
 */
interface DetectionResult {
  hasViolation: boolean;
  violations: string[];
  sanitized: string;
}

// =============================================================================
// PATTERN DEFINITIONS
// =============================================================================

/**
 * Comprehensive patterns for detecting personal information
 * Organized by category for maintainability
 */
export const personalInfoPatterns = {
  /**
   * Phone number patterns - matches various international formats
   * Includes Indian (+91), US/Canada, UK, and generic formats
   */
  phone: [
    // International format with country code (general)
    /\+\d{1,4}[\s.-]?\(?\d{1,4}\)?[\s.-]?\d{1,4}[\s.-]?\d{1,4}[\s.-]?\d{1,4}/g,
    // Indian phone numbers: +91, 0, or direct 10 digits starting with 6-9
    /(?:\+91|0)?[\s.-]?[6-9]\d{4}[\s.-]?\d{5}/g,
    /(?:\+91|0)?[\s.-]?[6-9]\d{9}/g,
    // US/Canada format: (XXX) XXX-XXXX or XXX-XXX-XXXX
    /\(?[2-9]\d{2}\)?[\s.-]?\d{3}[\s.-]?\d{4}/g,
    // UK format: +44 or 0 followed by 10-11 digits
    /(?:\+44|0)[\s.-]?\d{4}[\s.-]?\d{6}/g,
    // Generic 10+ consecutive digits
    /\d{10,14}/g,
    // Spaced out numbers (trying to evade detection)
    /\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d[\s.-]?\d/g,
    // Written out numbers with keywords
    /(?:call|contact|whatsapp|phone|mobile|number|msg|text|dial|reach)[\s:]*(?:me\s*(?:at|on)?\s*)?[+]?\d[\d\s.-]{7,}/gi,
    // "my number is" patterns
    /(?:my|the)\s*(?:phone|mobile|cell|contact)?\s*(?:number|no\.?|#)?\s*(?:is|:)?\s*[+]?\d[\d\s.-]{7,}/gi,
  ],

  /**
   * Email patterns - matches standard and obfuscated emails
   */
  email: [
    // Standard email format
    /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/gi,
    // Obfuscated: user [at] domain [dot] com
    /[a-zA-Z0-9._%+-]+\s*(?:\[at\]|\(at\)|at)\s*[a-zA-Z0-9.-]+\s*(?:\[dot\]|\(dot\)|dot)\s*[a-zA-Z]{2,}/gi,
    // Spaced out: user @ domain . com
    /[a-zA-Z0-9._%+-]+\s*@\s*[a-zA-Z0-9.-]+\s*\.\s*[a-zA-Z]{2,}/gi,
    // "my email is" patterns
    /(?:my|the)\s*(?:email|mail|e-mail)\s*(?:id|address)?\s*(?:is|:)?\s*[a-zA-Z0-9._%+-]+\s*[@]\s*[a-zA-Z0-9.-]+/gi,
  ],

  /**
   * Social media handle patterns
   */
  socialMedia: [
    // @ mentions (Twitter, Instagram, etc.)
    /@[a-zA-Z0-9_]{3,30}/g,
    // "follow me at" or "dm me at" patterns
    /\b(?:follow|dm|message|ping|add)\b\s*(?:me\b)?\s*(?:at|on\b)?\s*@?[a-zA-Z0-9_]{3,30}/gi,
    // "my handle/username is" patterns
    /(?:my|the)\s*\b(?:handle|username|user\s*name|insta|twitter|ig)\b\s*(?:is|:)?\s*@?[a-zA-Z0-9_]{3,30}/gi,
  ],

  /**
   * WhatsApp-specific patterns
   */
  whatsapp: [
    // Direct mentions of WhatsApp
    /whatsapp/gi,
    /whats\s*app/gi,
    /wa\.me\/?\d*/gi,
    /api\.whatsapp\.com/gi,
    // Common abbreviations
    /\bwa\b/gi,
    /\bwapp\b/gi,
    // "ping me on whatsapp" style
    /(?:msg|message|text|ping|call|contact)\s*(?:me\s*)?(?:on\s*)?(?:whatsapp|wa|wapp)/gi,
  ],

  /**
   * Instagram-specific patterns
   */
  instagram: [
    /instagram/gi,
    /\binsta\b/gi,
    /\big:/gi,
    /instagram\.com\/[a-zA-Z0-9_.]+/gi,
    /(?:follow|dm|check)\s*(?:me\s*)?(?:on\s*)?(?:instagram|insta|ig)/gi,
    /(?:my|the)\s*(?:instagram|insta|ig)\s*(?:is|:)?\s*@?[a-zA-Z0-9_.]+/gi,
  ],

  /**
   * Telegram-specific patterns
   */
  telegram: [
    /telegram/gi,
    /\btelegram\b/gi,
    /t\.me\/[a-zA-Z0-9_]+/gi,
    /(?:msg|message|text|ping)\s*(?:me\s*)?(?:on\s*)?telegram/gi,
    /(?:my|the)\s*telegram\s*(?:is|:)?\s*@?[a-zA-Z0-9_]+/gi,
  ],

  /**
   * Other messaging app patterns
   */
  messagingApps: [
    // Snapchat
    /snapchat/gi,
    /\bsnap\b/gi,
    /snapchat\.com\/add\/[a-zA-Z0-9_]+/gi,
    // Discord
    /discord/gi,
    /discord\.gg\/[a-zA-Z0-9]+/gi,
    /[a-zA-Z0-9_]+#\d{4}/g, // Discord username#1234
    // Signal
    /\bsignal\s*(?:app)?\b/gi,
    // Facebook Messenger
    /(?:facebook|fb)\s*messenger/gi,
    /m\.me\/[a-zA-Z0-9.]+/gi,
    // LinkedIn
    /linkedin\.com\/in\/[a-zA-Z0-9-]+/gi,
    /\blinkedin\b/gi,
  ],

  /**
   * URL and link patterns
   */
  links: [
    // HTTP/HTTPS URLs
    /https?:\/\/[^\s<>"{}|\\^`[\]]+/gi,
    // www URLs
    /www\.[^\s<>"{}|\\^`[\]]+/gi,
    // Common TLDs
    /[a-zA-Z0-9-]+\.(?:com|org|net|io|co|in|edu|gov|info|biz|me|app|dev|xyz|online|site|tech|cloud|store|shop|blog|link|click|live|us|uk|ca|au)\b[^\s]*/gi,
    // Shortened URLs
    /(?:bit\.ly|goo\.gl|t\.co|tinyurl\.com|ow\.ly|is\.gd|buff\.ly|cutt\.ly|rb\.gy|short\.io|tr\.im|v\.gd)\/[\w-]+/gi,
    // Social media and messaging app links
    /(?:instagram|facebook|twitter|linkedin|telegram|discord|snapchat|tiktok|youtube|whatsapp)\.(?:com|me)\/[\w./-]*/gi,
    // Google Drive/Docs/Meet links
    /(?:docs|drive|meet)\.google\.com\/[\w./?=&-]*/gi,
    // Zoom/Teams links
    /(?:zoom\.us|teams\.microsoft\.com|teams\.live\.com)\/[\w./?=&-]*/gi,
  ],

  /**
   * Address patterns - physical location information
   */
  address: [
    // Indian PIN codes (6 digits)
    /\b\d{6}\b/g,
    // US ZIP codes (5 or 9 digits)
    /\b\d{5}(?:-\d{4})?\b/g,
    // Street address indicators
    /\b(?:house|flat|apt|apartment|building|floor|block|sector|plot|street|road|lane|nagar|colony|society|enclave|extension|phase|avenue|boulevard|drive|court|way|place|circle|marg|path|gali)\b[\s,]*(?:#?\d+|no\.?\s*\d+)?/gi,
    // House/Flat number patterns
    /\b(?:h\.?no\.?|house\s*no\.?|flat\s*no\.?|door\s*no\.?|plot\s*no\.?)\s*[:\-]?\s*\d+/gi,
    // Address with numbers and locality
    /\d+[\s,/]+(?:[\w\s]+)(?:street|road|lane|avenue|nagar|colony|sector)/gi,
    // "my address is" patterns
    /(?:my|the)\s*(?:address|location|place|home)\s*(?:is|:)\s*[A-Za-z0-9\s,.-]{15,}/gi,
    // Near/opposite location references
    /(?:near|opposite|behind|next\s+to|adjacent\s+to|beside|opp\.?)\s+[\w\s]{5,}/gi,
    // Location sharing intent
    /(?:i\s+)?(?:stay|live|reside|residing|located)\s+(?:at|in|near)\s+[\w\s,.-]{10,}/gi,
  ],
};

// =============================================================================
// CORE DETECTION FUNCTIONS
// =============================================================================

/**
 * Detect phone numbers in content
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectPhoneNumbers(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  for (const pattern of personalInfoPatterns.phone) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0] && match[0].length >= 7) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[PHONE REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)], // Remove duplicates
    sanitized,
  };
}

/**
 * Detect email addresses in content
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectEmails(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  for (const pattern of personalInfoPatterns.email) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0]) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[EMAIL REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)],
    sanitized,
  };
}

/**
 * Detect social media handles and mentions
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectSocialMedia(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  const allPatterns = [
    ...personalInfoPatterns.socialMedia,
    ...personalInfoPatterns.instagram,
    ...personalInfoPatterns.telegram,
    ...personalInfoPatterns.messagingApps,
  ];

  for (const pattern of allPatterns) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0]) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[SOCIAL MEDIA REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)],
    sanitized,
  };
}

/**
 * Detect WhatsApp references specifically
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectWhatsApp(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  for (const pattern of personalInfoPatterns.whatsapp) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0]) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[WHATSAPP REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)],
    sanitized,
  };
}

/**
 * Detect URLs and external links
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectLinks(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  for (const pattern of personalInfoPatterns.links) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0]) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[LINK REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)],
    sanitized,
  };
}

/**
 * Detect physical addresses
 * @param content - Text to analyze
 * @returns Detection result with violations and sanitized content
 */
export function detectAddresses(content: string): DetectionResult {
  const violations: string[] = [];
  let sanitized = content;

  for (const pattern of personalInfoPatterns.address) {
    const regex = new RegExp(pattern.source, pattern.flags);
    const matches = content.matchAll(regex);

    for (const match of matches) {
      if (match[0] && match[0].length >= 5) {
        violations.push(match[0].trim());
        sanitized = sanitized.replace(match[0], '[ADDRESS REDACTED]');
      }
    }
  }

  return {
    hasViolation: violations.length > 0,
    violations: [...new Set(violations)],
    sanitized,
  };
}

/**
 * Comprehensive personal info detection
 * Combines all detection methods and returns detailed results
 * @param content - Text to analyze
 * @returns Combined detection result
 */
export function detectPersonalInfo(content: string): DetectionResult {
  if (!content || typeof content !== 'string') {
    return { hasViolation: false, violations: [], sanitized: content || '' };
  }

  const normalizedContent = content.trim();
  const allViolations: string[] = [];
  let sanitized = normalizedContent;

  // Check all categories
  const phoneResult = detectPhoneNumbers(sanitized);
  if (phoneResult.hasViolation) {
    allViolations.push(...phoneResult.violations.map(v => `[PHONE] ${v}`));
    sanitized = phoneResult.sanitized;
  }

  const emailResult = detectEmails(sanitized);
  if (emailResult.hasViolation) {
    allViolations.push(...emailResult.violations.map(v => `[EMAIL] ${v}`));
    sanitized = emailResult.sanitized;
  }

  const whatsappResult = detectWhatsApp(sanitized);
  if (whatsappResult.hasViolation) {
    allViolations.push(...whatsappResult.violations.map(v => `[WHATSAPP] ${v}`));
    sanitized = whatsappResult.sanitized;
  }

  const socialResult = detectSocialMedia(sanitized);
  if (socialResult.hasViolation) {
    allViolations.push(...socialResult.violations.map(v => `[SOCIAL] ${v}`));
    sanitized = socialResult.sanitized;
  }

  const linkResult = detectLinks(sanitized);
  if (linkResult.hasViolation) {
    allViolations.push(...linkResult.violations.map(v => `[LINK] ${v}`));
    sanitized = linkResult.sanitized;
  }

  const addressResult = detectAddresses(sanitized);
  if (addressResult.hasViolation) {
    allViolations.push(...addressResult.violations.map(v => `[ADDRESS] ${v}`));
    sanitized = addressResult.sanitized;
  }

  return {
    hasViolation: allViolations.length > 0,
    violations: allViolations,
    sanitized,
  };
}

// =============================================================================
// MODERATION SERVICE FUNCTIONS
// =============================================================================

/**
 * Main moderation function - analyzes content and returns detailed result
 * This is the primary function to call before sending any message
 *
 * @param content - The message content to moderate
 * @returns Detailed moderation result with violations and recommendations
 */
export function moderateContent(content: string): ModerationResult {
  if (!content || typeof content !== 'string') {
    return {
      allowed: true,
      violations: [],
      message: '',
      severity: 'low',
      sanitizedContent: content || '',
    };
  }

  const normalizedContent = content.trim();
  const violations: ViolationMatch[] = [];
  let sanitizedContent = normalizedContent;

  // Helper to find all matches with positions
  const findMatches = (patterns: RegExp[], type: ViolationType, patternName?: string) => {
    for (const pattern of patterns) {
      const regex = new RegExp(pattern.source, pattern.flags);
      let match: RegExpExecArray | null;

      // Reset regex state
      regex.lastIndex = 0;

      while ((match = regex.exec(normalizedContent)) !== null) {
        if (match[0] && match[0].length >= 3) {
          violations.push({
            type,
            matched: match[0],
            position: match.index,
            endPosition: match.index + match[0].length,
            pattern: patternName,
          });
          sanitizedContent = sanitizedContent.replace(
            match[0],
            `[${type.toUpperCase()} REDACTED]`
          );
        }

        // Prevent infinite loops for zero-length matches
        if (match[0].length === 0) {
          regex.lastIndex++;
        }
      }
    }
  };

  // Check all categories
  findMatches(personalInfoPatterns.phone, 'phone');
  findMatches(personalInfoPatterns.email, 'email');
  findMatches(personalInfoPatterns.whatsapp, 'messaging_app', 'whatsapp');
  findMatches(personalInfoPatterns.instagram, 'social_media', 'instagram');
  findMatches(personalInfoPatterns.telegram, 'messaging_app', 'telegram');
  findMatches(personalInfoPatterns.socialMedia, 'social_media');
  findMatches(personalInfoPatterns.messagingApps, 'messaging_app');
  findMatches(personalInfoPatterns.links, 'link');
  findMatches(personalInfoPatterns.address, 'address');

  // Deduplicate violations by position
  const uniqueViolations = violations.reduce((acc, curr) => {
    const exists = acc.some(
      v => v.position === curr.position && v.type === curr.type
    );
    if (!exists) {
      acc.push(curr);
    }
    return acc;
  }, [] as ViolationMatch[]);

  // Sort by position
  uniqueViolations.sort((a, b) => a.position - b.position);

  // Determine severity
  let severity: 'low' | 'medium' | 'high' = 'low';
  if (uniqueViolations.length >= 4) {
    severity = 'high';
  } else if (uniqueViolations.length >= 2) {
    severity = 'medium';
  }

  // Generate user-friendly message
  let message = '';
  if (uniqueViolations.length > 0) {
    const violationTypes = [...new Set(uniqueViolations.map(v => v.type))];
    const typeMessages: Record<ViolationType, string> = {
      phone: 'phone numbers',
      email: 'email addresses',
      social_media: 'social media handles',
      messaging_app: 'messaging app references',
      link: 'external links',
      address: 'physical addresses',
    };

    const detectedTypes = violationTypes.map(t => typeMessages[t]).join(', ');
    message = `For your safety, sharing ${detectedTypes} is not allowed. ` +
      'Please use the in-app communication features.';
  }

  return {
    allowed: uniqueViolations.length === 0,
    violations: uniqueViolations,
    message,
    severity,
    sanitizedContent,
  };
}

// =============================================================================
// LEGACY COMPATIBILITY FUNCTIONS
// =============================================================================

/**
 * Legacy validation function for backward compatibility
 * @deprecated Use moderateContent() instead for more detailed results
 * @param content - The message content to validate
 * @returns Simple validation result
 */
export function validateChatContent(content: string): ContentValidationResult {
  const result = moderateContent(content);

  if (result.allowed) {
    return { isValid: true };
  }

  // Map to legacy reason type
  const firstViolation = result.violations[0];
  let reason: ViolationType = 'phone';

  if (firstViolation) {
    reason = firstViolation.type;
  }

  return {
    isValid: false,
    reason,
    message: result.message,
  };
}

/**
 * Get user-friendly error message for validation failure
 * @deprecated Use moderateContent() which includes the message
 * @param result - Validation result
 * @returns User-friendly error message
 */
export function getValidationErrorMessage(result: ContentValidationResult): string {
  if (result.isValid) return '';

  const messages: Record<string, string> = {
    phone: 'Phone numbers cannot be shared in chat for your safety. This conversation may be flagged.',
    email: 'Email addresses cannot be shared in chat for your safety. This conversation may be flagged.',
    link: 'External links cannot be shared in chat for your safety. This conversation may be flagged.',
    address: 'Personal addresses cannot be shared in chat for your safety. This conversation may be flagged.',
    social_media: 'Social media handles cannot be shared in chat for your safety. This conversation may be flagged.',
    messaging_app: 'Messaging app references cannot be shared in chat. Please use in-app communication.',
  };

  return messages[result.reason || ''] || result.message || 'This content is not allowed.';
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/**
 * Check if a string looks like it's trying to evade detection
 * (e.g., using unicode look-alikes, excessive spacing, etc.)
 * @param content - Text to analyze
 * @returns Whether evasion tactics are detected
 */
export function detectEvasionAttempt(content: string): boolean {
  // Check for excessive spacing between characters
  const spacedNumbers = /\d\s+\d\s+\d\s+\d\s+\d/;
  if (spacedNumbers.test(content)) return true;

  // Check for unicode look-alikes (common substitutions)
  const unicodeLookalikes = /[\u0430-\u044f\u0410-\u042f]/; // Cyrillic
  if (unicodeLookalikes.test(content)) return true;

  // Check for leetspeak in sensitive contexts
  const leetspeakEmail = /[a-zA-Z0-9._%+-]+\s*[@\u0430]\s*[a-zA-Z0-9.-]+/i;
  if (leetspeakEmail.test(content)) return true;

  return false;
}

/**
 * Normalize content for more accurate detection
 * Removes common evasion tactics
 * @param content - Text to normalize
 * @returns Normalized text
 */
export function normalizeForDetection(content: string): string {
  let normalized = content;

  // Remove zero-width characters
  normalized = normalized.replace(/[\u200B-\u200D\uFEFF]/g, '');

  // Normalize unicode lookalikes to ASCII
  const lookalikes: Record<string, string> = {
    '\u0430': 'a', '\u0435': 'e', '\u043E': 'o', '\u0440': 'p',
    '\u0441': 'c', '\u0443': 'y', '\u0445': 'x', '\u0410': 'A',
    '\u0415': 'E', '\u041E': 'O', '\u0420': 'P', '\u0421': 'C',
  };

  for (const [unicode, ascii] of Object.entries(lookalikes)) {
    normalized = normalized.replace(new RegExp(unicode, 'g'), ascii);
  }

  // Normalize multiple spaces to single space
  normalized = normalized.replace(/\s+/g, ' ');

  return normalized;
}

/**
 * Enhanced moderation that includes evasion detection
 * @param content - Text to moderate
 * @returns Moderation result with evasion flag
 */
export function moderateContentEnhanced(content: string): ModerationResult & { evasionDetected: boolean } {
  const normalizedContent = normalizeForDetection(content);
  const result = moderateContent(normalizedContent);
  const evasionDetected = detectEvasionAttempt(content);

  // If evasion detected but no violations found, flag it anyway
  if (evasionDetected && result.allowed) {
    return {
      ...result,
      allowed: false,
      message: 'Your message appears to contain hidden personal information. Please rephrase.',
      severity: 'medium',
      evasionDetected: true,
    };
  }

  return {
    ...result,
    evasionDetected,
  };
}

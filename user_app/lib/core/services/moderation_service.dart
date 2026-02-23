/// Content Moderation Service for Chat
///
/// Provides comprehensive AI-powered moderation to detect and block personal
/// information sharing in chat messages. This includes phone numbers, emails,
/// social media handles, addresses, and external links.
///
/// Usage:
/// ```dart
/// final result = await ModerationService.instance.moderateMessage(
///   content: 'my number is 9876543210',
///   userId: 'user123',
///   projectId: 'project456',
/// );
/// if (!result.allowed) {
///   showModerationDialog(context, result);
/// }
/// ```
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/content_validators.dart';

/// Types of personal information violations that can be detected.
enum ViolationType {
  phone,
  email,
  socialMedia,
  address,
  link,
  messagingApp,
}

/// Extension to get display names for violation types.
extension ViolationTypeExtension on ViolationType {
  String get displayName {
    switch (this) {
      case ViolationType.phone:
        return 'phone numbers';
      case ViolationType.email:
        return 'email addresses';
      case ViolationType.socialMedia:
        return 'social media handles';
      case ViolationType.address:
        return 'physical addresses';
      case ViolationType.link:
        return 'external links';
      case ViolationType.messagingApp:
        return 'messaging app references';
    }
  }
}

/// Individual violation match details.
class ViolationMatch {
  /// Type of violation detected.
  final ViolationType type;

  /// The matched content string.
  final String matched;

  /// Start position in the original content.
  final int position;

  /// End position in the original content.
  final int endPosition;

  /// Specific pattern that was matched (e.g., 'whatsapp', 'instagram').
  final String? pattern;

  const ViolationMatch({
    required this.type,
    required this.matched,
    required this.position,
    required this.endPosition,
    this.pattern,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'matched': matched,
        'position': position,
        'endPosition': endPosition,
        'pattern': pattern,
      };

  factory ViolationMatch.fromJson(Map<String, dynamic> json) => ViolationMatch(
        type: ViolationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ViolationType.phone,
        ),
        matched: json['matched'] as String,
        position: json['position'] as int,
        endPosition: json['endPosition'] as int,
        pattern: json['pattern'] as String?,
      );
}

/// Severity level of moderation violations.
enum ModerationSeverity { low, medium, high }

/// Result of content moderation check.
class ModerationResult {
  /// Whether the message is allowed to be sent.
  final bool allowed;

  /// Array of detected violations.
  final List<ViolationMatch> violations;

  /// User-friendly explanation message.
  final String message;

  /// Severity level: low (1 violation), medium (2-3), high (4+).
  final ModerationSeverity severity;

  /// Sanitized content with violations redacted (for logging).
  final String sanitizedContent;

  /// Whether evasion tactics were detected.
  final bool evasionDetected;

  const ModerationResult({
    required this.allowed,
    required this.violations,
    required this.message,
    required this.severity,
    required this.sanitizedContent,
    this.evasionDetected = false,
  });

  /// Create a result indicating content is allowed.
  factory ModerationResult.allowed(String content) => ModerationResult(
        allowed: true,
        violations: [],
        message: '',
        severity: ModerationSeverity.low,
        sanitizedContent: content,
      );

  /// Create a result indicating content is blocked.
  factory ModerationResult.blocked({
    required List<ViolationMatch> violations,
    required String message,
    required ModerationSeverity severity,
    required String sanitizedContent,
    bool evasionDetected = false,
  }) =>
      ModerationResult(
        allowed: false,
        violations: violations,
        message: message,
        severity: severity,
        sanitizedContent: sanitizedContent,
        evasionDetected: evasionDetected,
      );

  /// Get unique violation types.
  Set<ViolationType> get violationTypes =>
      violations.map((v) => v.type).toSet();
}

/// User violation summary for rate limiting.
class UserViolationSummary {
  final String userId;
  final int totalViolations;
  final int recentViolations;
  final DateTime? lastViolationAt;
  final bool isRateLimited;
  final WarningLevel warningLevel;

  const UserViolationSummary({
    required this.userId,
    required this.totalViolations,
    required this.recentViolations,
    this.lastViolationAt,
    required this.isRateLimited,
    required this.warningLevel,
  });

  factory UserViolationSummary.empty(String userId) => UserViolationSummary(
        userId: userId,
        totalViolations: 0,
        recentViolations: 0,
        isRateLimited: false,
        warningLevel: WarningLevel.none,
      );
}

/// Warning levels for repeated violations.
enum WarningLevel { none, first, second, final_ }

/// Rate limit configuration.
class RateLimitConfig {
  final int maxViolationsPerHour;
  final int maxViolationsPerDay;
  final int cooldownMinutes;
  final int escalationThreshold;

  const RateLimitConfig({
    this.maxViolationsPerHour = 5,
    this.maxViolationsPerDay = 15,
    this.cooldownMinutes = 30,
    this.escalationThreshold = 10,
  });
}

/// Complete moderation action result.
class ModerationActionResult {
  final bool allowed;
  final ModerationResult result;
  final UserViolationSummary? userSummary;
  final bool rateLimited;
  final String? warningMessage;
  final bool shouldNotifyAdmin;

  const ModerationActionResult({
    required this.allowed,
    required this.result,
    this.userSummary,
    required this.rateLimited,
    this.warningMessage,
    required this.shouldNotifyAdmin,
  });
}

/// Content Moderation Service
///
/// Singleton service that handles all moderation-related functionality
/// including pattern detection, violation logging, and rate limiting.
class ModerationService {
  ModerationService._();

  static final ModerationService _instance = ModerationService._();

  /// Get singleton instance.
  static ModerationService get instance => _instance;

  /// Supabase client for database operations.
  SupabaseClient get _supabase => SupabaseConfig.client;

  /// Rate limit configuration.
  RateLimitConfig _config = const RateLimitConfig();

  /// Cache for user violation summaries.
  final Map<String, UserViolationSummary> _violationCache = {};

  /// Cache timeout duration.
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Warning messages for different levels.
  static const Map<String, String> _warningMessages = {
    'first':
        'This is your first warning. Sharing personal information is not allowed for your safety.',
    'second':
        'This is your second warning. Continued violations may result in temporary restrictions.',
    'final':
        'Final warning: You have been temporarily restricted from sending messages. Please contact support.',
    'rateLimited':
        'You have been temporarily restricted from sending messages due to repeated violations. Please try again later.',
  };

  /// Configure the moderation service.
  void configure(RateLimitConfig config) {
    _config = config;
  }

  /// Main moderation function - call this before sending any message.
  ///
  /// [content] - Message content to moderate.
  /// [userId] - User ID of the sender.
  /// [projectId] - Optional project ID for context.
  /// [chatId] - Optional chat/conversation ID.
  ///
  /// Returns [ModerationActionResult] with all details.
  Future<ModerationActionResult> moderateMessage({
    required String content,
    required String userId,
    String? projectId,
    String? chatId,
  }) async {
    // First, check if user is currently rate limited
    final userSummary = await getUserViolationSummary(userId);

    if (userSummary.isRateLimited) {
      return ModerationActionResult(
        allowed: false,
        result: ModerationResult.blocked(
          violations: [],
          message: _warningMessages['rateLimited']!,
          severity: ModerationSeverity.high,
          sanitizedContent: content,
        ),
        userSummary: userSummary,
        rateLimited: true,
        warningMessage: _warningMessages['rateLimited'],
        shouldNotifyAdmin: false,
      );
    }

    // Perform content moderation with evasion detection
    final moderationResult = moderateContentEnhanced(content);

    // If content is allowed, return success
    if (moderationResult.allowed) {
      return ModerationActionResult(
        allowed: true,
        result: moderationResult,
        userSummary: userSummary,
        rateLimited: false,
        shouldNotifyAdmin: false,
      );
    }

    // Content has violations - log and process
    await _logViolation(
      userId: userId,
      projectId: projectId,
      chatId: chatId,
      originalContent: content,
      sanitizedContent: moderationResult.sanitizedContent,
      violationTypes: moderationResult.violations.map((v) => v.type).toList(),
      violationCount: moderationResult.violations.length,
      severity: moderationResult.severity,
      actionTaken: 'blocked',
      metadata: {
        'evasionDetected': moderationResult.evasionDetected,
        'violations':
            moderationResult.violations.map((v) => v.toJson()).toList(),
      },
    );

    // Update user summary
    final updatedSummary = await _updateUserViolationCount(userId);

    // Determine warning level and message
    final warningMessage = _getWarningMessage(updatedSummary);

    // Check if we should notify admin
    final shouldNotifyAdmin =
        updatedSummary.totalViolations >= _config.escalationThreshold ||
            moderationResult.severity == ModerationSeverity.high;

    return ModerationActionResult(
      allowed: false,
      result: moderationResult,
      userSummary: updatedSummary,
      rateLimited: updatedSummary.isRateLimited,
      warningMessage: warningMessage,
      shouldNotifyAdmin: shouldNotifyAdmin,
    );
  }

  /// Quick moderation check without logging (for real-time typing indicators).
  ModerationResult quickCheck(String content) {
    return moderateContent(content);
  }

  /// Check if content can be sent (simplified boolean check).
  bool canSendMessage(String content) {
    final result = moderateContent(content);
    return result.allowed;
  }

  /// Moderate content and return detailed result.
  ModerationResult moderateContent(String content) {
    if (content.isEmpty) {
      return ModerationResult.allowed(content);
    }

    final normalizedContent = content.trim();
    final violations = <ViolationMatch>[];
    var sanitizedContent = normalizedContent;

    // Check all patterns
    void findMatches(
      List<RegExp> patterns,
      ViolationType type, [
      String? patternName,
    ]) {
      for (final pattern in patterns) {
        final matches = pattern.allMatches(normalizedContent);
        for (final match in matches) {
          if (match.group(0) != null && match.group(0)!.length >= 3) {
            violations.add(ViolationMatch(
              type: type,
              matched: match.group(0)!,
              position: match.start,
              endPosition: match.end,
              pattern: patternName,
            ));
            sanitizedContent = sanitizedContent.replaceFirst(
              match.group(0)!,
              '[${type.name.toUpperCase()} REDACTED]',
            );
          }
        }
      }
    }

    // Check all categories using ContentValidators patterns
    findMatches(ContentValidators.phonePatterns, ViolationType.phone);
    findMatches(ContentValidators.emailPatterns, ViolationType.email);
    findMatches(
        ContentValidators.whatsappPatterns, ViolationType.messagingApp, 'whatsapp');
    findMatches(
        ContentValidators.instagramPatterns, ViolationType.socialMedia, 'instagram');
    findMatches(
        ContentValidators.telegramPatterns, ViolationType.messagingApp, 'telegram');
    findMatches(ContentValidators.socialMediaPatterns, ViolationType.socialMedia);
    findMatches(ContentValidators.messagingAppPatterns, ViolationType.messagingApp);
    findMatches(ContentValidators.linkPatterns, ViolationType.link);
    findMatches(ContentValidators.addressPatterns, ViolationType.address);

    // Deduplicate violations by position
    final uniqueViolations = <ViolationMatch>[];
    for (final violation in violations) {
      final exists = uniqueViolations.any(
        (v) => v.position == violation.position && v.type == violation.type,
      );
      if (!exists) {
        uniqueViolations.add(violation);
      }
    }

    // Sort by position
    uniqueViolations.sort((a, b) => a.position.compareTo(b.position));

    // Determine severity
    ModerationSeverity severity = ModerationSeverity.low;
    if (uniqueViolations.length >= 4) {
      severity = ModerationSeverity.high;
    } else if (uniqueViolations.length >= 2) {
      severity = ModerationSeverity.medium;
    }

    // Generate user-friendly message
    String message = '';
    if (uniqueViolations.isNotEmpty) {
      final violationTypes = uniqueViolations.map((v) => v.type).toSet();
      final detectedTypes =
          violationTypes.map((t) => t.displayName).join(', ');
      message = 'For your safety, sharing $detectedTypes is not allowed. '
          'Please use the in-app communication features.';
    }

    if (uniqueViolations.isEmpty) {
      return ModerationResult.allowed(content);
    }

    return ModerationResult.blocked(
      violations: uniqueViolations,
      message: message,
      severity: severity,
      sanitizedContent: sanitizedContent,
    );
  }

  /// Enhanced moderation that includes evasion detection.
  ModerationResult moderateContentEnhanced(String content) {
    final normalizedContent = ContentValidators.normalizeForDetection(content);
    final result = moderateContent(normalizedContent);
    final evasionDetected = ContentValidators.detectEvasionAttempt(content);

    // If evasion detected but no violations found, flag it anyway
    if (evasionDetected && result.allowed) {
      return ModerationResult.blocked(
        violations: [],
        message:
            'Your message appears to contain hidden personal information. Please rephrase.',
        severity: ModerationSeverity.medium,
        sanitizedContent: content,
        evasionDetected: true,
      );
    }

    if (!result.allowed) {
      return ModerationResult.blocked(
        violations: result.violations,
        message: result.message,
        severity: result.severity,
        sanitizedContent: result.sanitizedContent,
        evasionDetected: evasionDetected,
      );
    }

    return result;
  }

  /// Get user violation summary with caching.
  Future<UserViolationSummary> getUserViolationSummary(String userId) async {
    // Check cache first
    if (_violationCache.containsKey(userId)) {
      return _violationCache[userId]!;
    }

    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));

      // Get total violations
      final totalResponse = await _supabase
          .from('moderation_logs')
          .select()
          .eq('user_id', userId)
          .count();

      // Get violations in last hour
      final recentResponse = await _supabase
          .from('moderation_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', oneHourAgo.toIso8601String())
          .count();

      // Get violations in last day
      final dayResponse = await _supabase
          .from('moderation_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', oneDayAgo.toIso8601String())
          .count();

      // Get last violation
      final lastViolationResponse = await _supabase
          .from('moderation_logs')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final totalViolations = totalResponse.count;
      final recentViolations = recentResponse.count;
      final dailyViolations = dayResponse.count;

      // Determine if rate limited
      final isRateLimited =
          recentViolations >= _config.maxViolationsPerHour ||
              dailyViolations >= _config.maxViolationsPerDay;

      // Determine warning level
      WarningLevel warningLevel = WarningLevel.none;
      if (totalViolations >= 3) warningLevel = WarningLevel.first;
      if (totalViolations >= 6) warningLevel = WarningLevel.second;
      if (totalViolations >= 10) warningLevel = WarningLevel.final_;

      final summary = UserViolationSummary(
        userId: userId,
        totalViolations: totalViolations,
        recentViolations: recentViolations,
        lastViolationAt: lastViolationResponse != null
            ? DateTime.parse(lastViolationResponse['created_at'] as String)
            : null,
        isRateLimited: isRateLimited,
        warningLevel: warningLevel,
      );

      // Cache the result
      _violationCache[userId] = summary;
      Future.delayed(_cacheTimeout, () => _violationCache.remove(userId));

      return summary;
    } catch (error) {
      // Return safe default on error
      return UserViolationSummary.empty(userId);
    }
  }

  /// Log a moderation violation to the database.
  Future<bool> _logViolation({
    required String userId,
    String? projectId,
    String? chatId,
    required String originalContent,
    required String sanitizedContent,
    required List<ViolationType> violationTypes,
    required int violationCount,
    required ModerationSeverity severity,
    required String actionTaken,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.from('moderation_logs').insert({
        'user_id': userId,
        'project_id': projectId,
        'chat_id': chatId,
        'original_content': originalContent,
        'sanitized_content': sanitizedContent,
        'violation_types': violationTypes.map((v) => v.name).toList(),
        'violation_count': violationCount,
        'severity': severity.name,
        'action_taken': actionTaken,
        'metadata': metadata,
      });

      // Invalidate cache for this user
      _violationCache.remove(userId);

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Update user violation count and return updated summary.
  Future<UserViolationSummary> _updateUserViolationCount(String userId) async {
    // Invalidate cache to get fresh data
    _violationCache.remove(userId);
    return getUserViolationSummary(userId);
  }

  /// Get appropriate warning message based on violation history.
  String _getWarningMessage(UserViolationSummary summary) {
    if (summary.isRateLimited) {
      return _warningMessages['rateLimited']!;
    }

    switch (summary.warningLevel) {
      case WarningLevel.first:
        return _warningMessages['first']!;
      case WarningLevel.second:
        return _warningMessages['second']!;
      case WarningLevel.final_:
        return _warningMessages['final']!;
      case WarningLevel.none:
        return _warningMessages['first']!;
    }
  }

  /// Clear the violation cache for a user.
  void clearCache(String userId) {
    _violationCache.remove(userId);
  }

  /// Clear all cached data.
  void clearAllCache() {
    _violationCache.clear();
  }
}

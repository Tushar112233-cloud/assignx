/**
 * Content Moderation Service
 *
 * Provides comprehensive content moderation functionality including:
 * - Real-time message moderation before sending
 * - Violation logging to database
 * - Rate limiting for repeated violations
 * - User warning and escalation system
 *
 * @module moderation.service
 */

import { createClient } from '@/lib/supabase/client';
import {
  moderateContent,
  moderateContentEnhanced,
  type ModerationResult,
  type ViolationType,
  type ViolationMatch,
} from '@/lib/validations/chat-content';

// =============================================================================
// TYPES & INTERFACES
// =============================================================================

/**
 * Moderation log entry for database storage
 */
export interface ModerationLogEntry {
  id?: string;
  user_id: string;
  project_id?: string;
  chat_id?: string;
  original_content: string;
  sanitized_content: string;
  violation_types: ViolationType[];
  violation_count: number;
  severity: 'low' | 'medium' | 'high';
  action_taken: 'blocked' | 'warned' | 'flagged';
  created_at?: string;
  metadata?: Record<string, unknown>;
}

/**
 * User violation summary for rate limiting
 */
export interface UserViolationSummary {
  userId: string;
  totalViolations: number;
  recentViolations: number; // In last hour
  lastViolationAt: Date | null;
  isRateLimited: boolean;
  warningLevel: 'none' | 'first' | 'second' | 'final';
}

/**
 * Moderation action result
 */
export interface ModerationActionResult {
  allowed: boolean;
  result: ModerationResult;
  userSummary?: UserViolationSummary;
  rateLimited: boolean;
  warningMessage?: string;
  shouldNotifyAdmin: boolean;
}

/**
 * Rate limit configuration
 */
interface RateLimitConfig {
  maxViolationsPerHour: number;
  maxViolationsPerDay: number;
  cooldownMinutes: number;
  escalationThreshold: number;
}

// =============================================================================
// CONSTANTS
// =============================================================================

/**
 * Default rate limiting configuration
 */
const DEFAULT_RATE_LIMIT_CONFIG: RateLimitConfig = {
  maxViolationsPerHour: 5,
  maxViolationsPerDay: 15,
  cooldownMinutes: 30,
  escalationThreshold: 10,
};

/**
 * Warning messages for different levels
 */
const WARNING_MESSAGES: Record<string, string> = {
  first: 'This is your first warning. Sharing personal information is not allowed for your safety.',
  second: 'This is your second warning. Continued violations may result in temporary restrictions.',
  final: 'Final warning: You have been temporarily restricted from sending messages. Please contact support.',
  rateLimited: 'You have been temporarily restricted from sending messages due to repeated violations. Please try again later.',
};

// =============================================================================
// MODERATION SERVICE CLASS
// =============================================================================

/**
 * Content Moderation Service
 * Handles all moderation-related functionality
 */
export class ModerationService {
  private supabase = createClient();
  private rateLimitConfig: RateLimitConfig;
  private violationCache: Map<string, UserViolationSummary> = new Map();
  private cacheTimeout = 5 * 60 * 1000; // 5 minutes

  constructor(config?: Partial<RateLimitConfig>) {
    this.rateLimitConfig = { ...DEFAULT_RATE_LIMIT_CONFIG, ...config };
  }

  /**
   * Main moderation function - call this before sending any message
   * @param content - Message content to moderate
   * @param userId - User ID of the sender
   * @param projectId - Optional project ID for context
   * @param chatId - Optional chat/conversation ID
   * @returns Moderation action result with all details
   */
  async moderateMessage(
    content: string,
    userId: string,
    projectId?: string,
    chatId?: string
  ): Promise<ModerationActionResult> {
    // First, check if user is currently rate limited
    const userSummary = await this.getUserViolationSummary(userId);

    if (userSummary.isRateLimited) {
      return {
        allowed: false,
        result: {
          allowed: false,
          violations: [],
          message: WARNING_MESSAGES.rateLimited,
          severity: 'high',
          sanitizedContent: content,
        },
        userSummary,
        rateLimited: true,
        warningMessage: WARNING_MESSAGES.rateLimited,
        shouldNotifyAdmin: false,
      };
    }

    // Perform content moderation with evasion detection
    const moderationResult = moderateContentEnhanced(content);

    // If content is allowed, return success
    if (moderationResult.allowed) {
      return {
        allowed: true,
        result: moderationResult,
        userSummary,
        rateLimited: false,
        shouldNotifyAdmin: false,
      };
    }

    // Content has violations - log and process
    await this.logViolation({
      user_id: userId,
      project_id: projectId,
      chat_id: chatId,
      original_content: content,
      sanitized_content: moderationResult.sanitizedContent,
      violation_types: moderationResult.violations.map(v => v.type),
      violation_count: moderationResult.violations.length,
      severity: moderationResult.severity,
      action_taken: 'blocked',
      metadata: {
        evasionDetected: moderationResult.evasionDetected,
        violations: moderationResult.violations,
      },
    });

    // Update user summary
    const updatedSummary = await this.updateUserViolationCount(userId);

    // Determine warning level and message
    const warningMessage = this.getWarningMessage(updatedSummary);

    // Check if we should notify admin
    const shouldNotifyAdmin =
      updatedSummary.totalViolations >= this.rateLimitConfig.escalationThreshold ||
      moderationResult.severity === 'high';

    return {
      allowed: false,
      result: moderationResult,
      userSummary: updatedSummary,
      rateLimited: updatedSummary.isRateLimited,
      warningMessage,
      shouldNotifyAdmin,
    };
  }

  /**
   * Quick moderation check without logging (for real-time typing indicators)
   * @param content - Message content to check
   * @returns Simple moderation result
   */
  quickCheck(content: string): ModerationResult {
    return moderateContent(content);
  }

  /**
   * Get user violation summary with caching
   * @param userId - User ID to look up
   * @returns User violation summary
   */
  async getUserViolationSummary(userId: string): Promise<UserViolationSummary> {
    // Check cache first
    const cached = this.violationCache.get(userId);
    if (cached) {
      return cached;
    }

    try {
      const now = new Date();
      const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
      const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

      // Get total violations
      const { count: totalCount } = await this.supabase
        .from('moderation_logs')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId);

      // Get violations in last hour
      const { count: recentCount } = await this.supabase
        .from('moderation_logs')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .gte('created_at', oneHourAgo.toISOString());

      // Get violations in last day
      const { count: dayCount } = await this.supabase
        .from('moderation_logs')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .gte('created_at', oneDayAgo.toISOString());

      // Get last violation
      const { data: lastViolation } = await this.supabase
        .from('moderation_logs')
        .select('created_at')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();

      const recentViolations = recentCount || 0;
      const dailyViolations = dayCount || 0;
      const totalViolations = totalCount || 0;

      // Determine if rate limited
      const isRateLimited =
        recentViolations >= this.rateLimitConfig.maxViolationsPerHour ||
        dailyViolations >= this.rateLimitConfig.maxViolationsPerDay;

      // Determine warning level
      let warningLevel: UserViolationSummary['warningLevel'] = 'none';
      if (totalViolations >= 3) warningLevel = 'first';
      if (totalViolations >= 6) warningLevel = 'second';
      if (totalViolations >= 10) warningLevel = 'final';

      const summary: UserViolationSummary = {
        userId,
        totalViolations,
        recentViolations,
        lastViolationAt: lastViolation?.created_at
          ? new Date(lastViolation.created_at)
          : null,
        isRateLimited,
        warningLevel,
      };

      // Cache the result
      this.violationCache.set(userId, summary);
      setTimeout(() => this.violationCache.delete(userId), this.cacheTimeout);

      return summary;
    } catch (error) {
      console.error('Error fetching user violation summary:', error);
      // Return safe default
      return {
        userId,
        totalViolations: 0,
        recentViolations: 0,
        lastViolationAt: null,
        isRateLimited: false,
        warningLevel: 'none',
      };
    }
  }

  /**
   * Log a moderation violation to the database
   * @param entry - Moderation log entry
   * @returns Success status
   */
  async logViolation(entry: ModerationLogEntry): Promise<boolean> {
    try {
      const { error } = await this.supabase.from('moderation_logs').insert({
        user_id: entry.user_id,
        project_id: entry.project_id,
        chat_id: entry.chat_id,
        original_content: entry.original_content,
        sanitized_content: entry.sanitized_content,
        violation_types: entry.violation_types,
        violation_count: entry.violation_count,
        severity: entry.severity,
        action_taken: entry.action_taken,
        metadata: entry.metadata,
      });

      if (error) {
        console.error('Error logging violation:', error);
        return false;
      }

      // Invalidate cache for this user
      this.violationCache.delete(entry.user_id);

      return true;
    } catch (error) {
      console.error('Error logging violation:', error);
      return false;
    }
  }

  /**
   * Update user violation count and return updated summary
   * @param userId - User ID
   * @returns Updated violation summary
   */
  private async updateUserViolationCount(userId: string): Promise<UserViolationSummary> {
    // Invalidate cache to get fresh data
    this.violationCache.delete(userId);
    return this.getUserViolationSummary(userId);
  }

  /**
   * Get appropriate warning message based on violation history
   * @param summary - User violation summary
   * @returns Warning message
   */
  private getWarningMessage(summary: UserViolationSummary): string {
    if (summary.isRateLimited) {
      return WARNING_MESSAGES.rateLimited;
    }

    return WARNING_MESSAGES[summary.warningLevel] || WARNING_MESSAGES.first;
  }

  /**
   * Get violation history for a user (admin function)
   * @param userId - User ID
   * @param limit - Maximum number of records to return
   * @returns Array of moderation log entries
   */
  async getViolationHistory(
    userId: string,
    limit = 50
  ): Promise<ModerationLogEntry[]> {
    try {
      const { data, error } = await this.supabase
        .from('moderation_logs')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) {
        console.error('Error fetching violation history:', error);
        return [];
      }

      return data || [];
    } catch (error) {
      console.error('Error fetching violation history:', error);
      return [];
    }
  }

  /**
   * Get violation statistics for a project
   * @param projectId - Project ID
   * @returns Violation statistics
   */
  async getProjectViolationStats(projectId: string): Promise<{
    totalViolations: number;
    uniqueUsers: number;
    violationsByType: Record<ViolationType, number>;
    recentViolations: ModerationLogEntry[];
  }> {
    try {
      const { data, error } = await this.supabase
        .from('moderation_logs')
        .select('*')
        .eq('project_id', projectId);

      if (error || !data) {
        throw error;
      }

      const uniqueUsers = new Set(data.map((d: any) => d.user_id)).size;

      const violationsByType: Record<string, number> = {};
      data.forEach((entry: any) => {
        (entry.violation_types as ViolationType[]).forEach(type => {
          violationsByType[type] = (violationsByType[type] || 0) + 1;
        });
      });

      return {
        totalViolations: data.length,
        uniqueUsers,
        violationsByType: violationsByType as Record<ViolationType, number>,
        recentViolations: data.slice(0, 10),
      };
    } catch (error) {
      console.error('Error fetching project violation stats:', error);
      return {
        totalViolations: 0,
        uniqueUsers: 0,
        violationsByType: {} as Record<ViolationType, number>,
        recentViolations: [],
      };
    }
  }

  /**
   * Clear rate limit for a user (admin function)
   * @param userId - User ID to clear
   * @returns Success status
   */
  async clearRateLimit(userId: string): Promise<boolean> {
    // Simply clear the cache - next check will recalculate
    this.violationCache.delete(userId);
    return true;
  }

  /**
   * Check if content can be sent (simplified boolean check)
   * @param content - Content to check
   * @returns Whether content is allowed
   */
  canSendMessage(content: string): boolean {
    const result = moderateContent(content);
    return result.allowed;
  }
}

// =============================================================================
// SINGLETON INSTANCE
// =============================================================================

/**
 * Default moderation service instance
 * Use this for most cases unless custom configuration is needed
 */
export const moderationService = new ModerationService();

// =============================================================================
// CONVENIENCE FUNCTIONS
// =============================================================================

/**
 * Quick check if content is allowed (no logging)
 * @param content - Content to check
 * @returns Whether content is allowed
 */
export function isContentAllowed(content: string): boolean {
  return moderationService.canSendMessage(content);
}

/**
 * Moderate message with full logging and rate limiting
 * @param content - Content to moderate
 * @param userId - User ID
 * @param projectId - Optional project ID
 * @param chatId - Optional chat ID
 * @returns Moderation action result
 */
export async function moderateAndLog(
  content: string,
  userId: string,
  projectId?: string,
  chatId?: string
): Promise<ModerationActionResult> {
  return moderationService.moderateMessage(content, userId, projectId, chatId);
}

/**
 * Get user's violation summary
 * @param userId - User ID
 * @returns User violation summary
 */
export async function getUserModerationStatus(
  userId: string
): Promise<UserViolationSummary> {
  return moderationService.getUserViolationSummary(userId);
}

// =============================================================================
// REACT HOOKS SUPPORT
// =============================================================================

/**
 * Hook-friendly moderation check for real-time validation
 * Returns a function that can be used in onChange handlers
 */
export function createModerationChecker() {
  let debounceTimer: NodeJS.Timeout | null = null;
  let lastResult: ModerationResult | null = null;

  return {
    /**
     * Check content with debouncing (for typing indicators)
     * @param content - Content to check
     * @param onResult - Callback with result
     * @param debounceMs - Debounce delay in milliseconds
     */
    checkDebounced(
      content: string,
      onResult: (result: ModerationResult) => void,
      debounceMs = 300
    ) {
      if (debounceTimer) {
        clearTimeout(debounceTimer);
      }

      debounceTimer = setTimeout(() => {
        lastResult = moderateContent(content);
        onResult(lastResult);
      }, debounceMs);
    },

    /**
     * Immediate check (for send button)
     * @param content - Content to check
     * @returns Moderation result
     */
    checkImmediate(content: string): ModerationResult {
      lastResult = moderateContent(content);
      return lastResult;
    },

    /**
     * Get last cached result
     * @returns Last moderation result or null
     */
    getLastResult(): ModerationResult | null {
      return lastResult;
    },

    /**
     * Clear cached result and timer
     */
    clear() {
      if (debounceTimer) {
        clearTimeout(debounceTimer);
      }
      lastResult = null;
    },
  };
}

/**
 * Content Moderation Hook
 *
 * Provides React hooks for integrating content moderation into chat components.
 * Handles real-time content checking, violation detection, and user feedback.
 *
 * @module useModeration
 */

'use client';

import { useState, useCallback, useRef, useEffect } from 'react';
import {
  moderateContent,
  moderateContentEnhanced,
  type ModerationResult,
  type ViolationType,
} from '@/lib/validations/chat-content';
import {
  moderationService,
  type ModerationActionResult,
  type UserViolationSummary,
} from '@/lib/services/moderation.service';

// =============================================================================
// TYPES
// =============================================================================

/**
 * Moderation hook state
 */
interface ModerationState {
  /** Current moderation result */
  result: ModerationResult | null;
  /** Whether content is currently being checked */
  isChecking: boolean;
  /** User's violation summary */
  userSummary: UserViolationSummary | null;
  /** Whether user is rate limited */
  isRateLimited: boolean;
  /** Current warning message to show */
  warningMessage: string | null;
  /** Whether to show the warning dialog */
  showWarningDialog: boolean;
}

/**
 * Moderation hook actions
 */
interface ModerationActions {
  /** Check content for violations (debounced for typing) */
  checkContent: (content: string) => void;
  /** Validate content before sending (immediate, with logging) */
  validateBeforeSend: (
    content: string,
    userId: string,
    projectId?: string,
    chatId?: string
  ) => Promise<ModerationActionResult>;
  /** Quick check without logging */
  quickCheck: (content: string) => ModerationResult;
  /** Clear current moderation state */
  clearState: () => void;
  /** Dismiss warning dialog */
  dismissWarning: () => void;
  /** Refresh user violation summary */
  refreshUserSummary: (userId: string) => Promise<void>;
}

/**
 * Combined hook return type
 */
type UseModerationReturn = ModerationState & ModerationActions;

// =============================================================================
// HOOK IMPLEMENTATION
// =============================================================================

/**
 * Main moderation hook for chat components
 *
 * @param options - Hook configuration options
 * @returns Moderation state and actions
 *
 * @example
 * ```tsx
 * const {
 *   result,
 *   isChecking,
 *   checkContent,
 *   validateBeforeSend,
 *   showWarningDialog,
 *   dismissWarning,
 * } = useModeration();
 *
 * // Check content as user types
 * const handleInputChange = (e) => {
 *   setMessage(e.target.value);
 *   checkContent(e.target.value);
 * };
 *
 * // Validate before sending
 * const handleSend = async () => {
 *   const result = await validateBeforeSend(message, userId, projectId);
 *   if (result.allowed) {
 *     // Send the message
 *   }
 * };
 * ```
 */
export function useModeration(options?: {
  /** Debounce delay for content checking (default: 300ms) */
  debounceMs?: number;
  /** Whether to show real-time warnings while typing */
  showTypingWarnings?: boolean;
}): UseModerationReturn {
  const { debounceMs = 300, showTypingWarnings = true } = options || {};

  // State
  const [state, setState] = useState<ModerationState>({
    result: null,
    isChecking: false,
    userSummary: null,
    isRateLimited: false,
    warningMessage: null,
    showWarningDialog: false,
  });

  // Refs for debouncing
  const debounceTimerRef = useRef<NodeJS.Timeout | null>(null);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }
    };
  }, []);

  /**
   * Check content with debouncing (for real-time typing feedback)
   */
  const checkContent = useCallback(
    (content: string) => {
      if (!content || !showTypingWarnings) {
        setState((prev) => ({
          ...prev,
          result: null,
          isChecking: false,
          warningMessage: null,
        }));
        return;
      }

      // Clear previous timer
      if (debounceTimerRef.current) {
        clearTimeout(debounceTimerRef.current);
      }

      setState((prev) => ({ ...prev, isChecking: true }));

      debounceTimerRef.current = setTimeout(() => {
        const result = moderateContent(content);
        setState((prev) => ({
          ...prev,
          result,
          isChecking: false,
          warningMessage: result.allowed ? null : result.message,
        }));
      }, debounceMs);
    },
    [debounceMs, showTypingWarnings]
  );

  /**
   * Quick check without logging or debouncing
   */
  const quickCheck = useCallback((content: string): ModerationResult => {
    return moderateContent(content);
  }, []);

  /**
   * Validate content before sending (with logging and rate limiting)
   */
  const validateBeforeSend = useCallback(
    async (
      content: string,
      userId: string,
      projectId?: string,
      chatId?: string
    ): Promise<ModerationActionResult> => {
      setState((prev) => ({ ...prev, isChecking: true }));

      try {
        const result = await moderationService.moderateMessage(
          content,
          userId,
          projectId,
          chatId
        );

        setState((prev) => ({
          ...prev,
          result: result.result,
          isChecking: false,
          userSummary: result.userSummary || null,
          isRateLimited: result.rateLimited,
          warningMessage: result.warningMessage || null,
          showWarningDialog: !result.allowed,
        }));

        return result;
      } catch (error) {
        console.error('Moderation error:', error);
        // On error, allow the message but log the issue
        const fallbackResult: ModerationActionResult = {
          allowed: true,
          result: {
            allowed: true,
            violations: [],
            message: '',
            severity: 'low',
            sanitizedContent: content,
          },
          rateLimited: false,
          shouldNotifyAdmin: false,
        };

        setState((prev) => ({
          ...prev,
          isChecking: false,
        }));

        return fallbackResult;
      }
    },
    []
  );

  /**
   * Clear moderation state
   */
  const clearState = useCallback(() => {
    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }
    setState({
      result: null,
      isChecking: false,
      userSummary: null,
      isRateLimited: false,
      warningMessage: null,
      showWarningDialog: false,
    });
  }, []);

  /**
   * Dismiss warning dialog
   */
  const dismissWarning = useCallback(() => {
    setState((prev) => ({
      ...prev,
      showWarningDialog: false,
      warningMessage: null,
    }));
  }, []);

  /**
   * Refresh user violation summary
   */
  const refreshUserSummary = useCallback(async (userId: string) => {
    try {
      const summary = await moderationService.getUserViolationSummary(userId);
      setState((prev) => ({
        ...prev,
        userSummary: summary,
        isRateLimited: summary.isRateLimited,
      }));
    } catch (error) {
      console.error('Error refreshing user summary:', error);
    }
  }, []);

  return {
    // State
    ...state,
    // Actions
    checkContent,
    validateBeforeSend,
    quickCheck,
    clearState,
    dismissWarning,
    refreshUserSummary,
  };
}

// =============================================================================
// SIMPLE VALIDATION HOOK
// =============================================================================

/**
 * Simple validation hook for basic content checking
 *
 * @returns Validation function and result
 *
 * @example
 * ```tsx
 * const { isValid, violations, validate } = useContentValidation();
 *
 * const handleChange = (e) => {
 *   setMessage(e.target.value);
 *   validate(e.target.value);
 * };
 *
 * return (
 *   <div>
 *     <input onChange={handleChange} />
 *     {!isValid && <span className="error">{violations.join(', ')}</span>}
 *   </div>
 * );
 * ```
 */
export function useContentValidation() {
  const [isValid, setIsValid] = useState(true);
  const [violations, setViolations] = useState<ViolationType[]>([]);
  const [message, setMessage] = useState<string>('');

  const validate = useCallback((content: string) => {
    const result = moderateContent(content);
    setIsValid(result.allowed);
    setViolations(result.violations.map((v) => v.type));
    setMessage(result.message);
    return result.allowed;
  }, []);

  const reset = useCallback(() => {
    setIsValid(true);
    setViolations([]);
    setMessage('');
  }, []);

  return {
    isValid,
    violations,
    message,
    validate,
    reset,
  };
}

// =============================================================================
// USER STATUS HOOK
// =============================================================================

/**
 * Hook to track user's moderation status
 *
 * @param userId - User ID to track
 * @returns User violation summary and status
 */
export function useModerationStatus(userId: string | undefined) {
  const [summary, setSummary] = useState<UserViolationSummary | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const refresh = useCallback(async () => {
    if (!userId) return;

    setIsLoading(true);
    setError(null);

    try {
      const data = await moderationService.getUserViolationSummary(userId);
      setSummary(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to fetch status'));
    } finally {
      setIsLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  return {
    summary,
    isLoading,
    error,
    isRateLimited: summary?.isRateLimited ?? false,
    warningLevel: summary?.warningLevel ?? 'none',
    totalViolations: summary?.totalViolations ?? 0,
    refresh,
  };
}

// =============================================================================
// UTILITY HOOKS
// =============================================================================

/**
 * Hook for real-time content monitoring with visual feedback
 *
 * @param content - Content to monitor
 * @param debounceMs - Debounce delay
 * @returns Monitoring state
 */
export function useContentMonitor(content: string, debounceMs = 300) {
  const [hasViolation, setHasViolation] = useState(false);
  const [violationTypes, setViolationTypes] = useState<ViolationType[]>([]);
  const [severity, setSeverity] = useState<'low' | 'medium' | 'high'>('low');
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (!content) {
      setHasViolation(false);
      setViolationTypes([]);
      setSeverity('low');
      return;
    }

    if (timerRef.current) {
      clearTimeout(timerRef.current);
    }

    timerRef.current = setTimeout(() => {
      const result = moderateContentEnhanced(content);
      setHasViolation(!result.allowed);
      setViolationTypes([...new Set(result.violations.map((v) => v.type))]);
      setSeverity(result.severity);
    }, debounceMs);

    return () => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }
    };
  }, [content, debounceMs]);

  return {
    hasViolation,
    violationTypes,
    severity,
    getBorderColor: () => {
      if (!hasViolation) return undefined;
      switch (severity) {
        case 'high':
          return 'border-red-500';
        case 'medium':
          return 'border-orange-500';
        case 'low':
          return 'border-yellow-500';
      }
    },
  };
}

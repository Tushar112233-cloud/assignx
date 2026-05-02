/**
 * Retry Utility with Exponential Backoff
 *
 * Provides robust retry logic for network requests and payments.
 * Implements exponential backoff, jitter, and error classification.
 *
 * @example
 * ```typescript
 * const result = await withRetry(
 *   () => fetch('/api/payments/verify', { method: 'POST', body }),
 *   { maxAttempts: 3, retryableErrors: [500, 502, 503, 504] }
 * )
 * ```
 */

/**
 * Retry configuration options
 */
export interface RetryOptions {
  /** Maximum number of retry attempts (default: 3) */
  maxAttempts?: number
  /** Initial delay in milliseconds (default: 1000) */
  initialDelayMs?: number
  /** Maximum delay in milliseconds (default: 30000) */
  maxDelayMs?: number
  /** Backoff multiplier (default: 2) */
  backoffMultiplier?: number
  /** Add random jitter to delays (default: true) */
  jitter?: boolean
  /** HTTP status codes that should trigger a retry */
  retryableStatusCodes?: number[]
  /** Custom function to determine if error is retryable */
  isRetryable?: (error: unknown) => boolean
  /** Callback for each retry attempt */
  onRetry?: (attempt: number, error: unknown, delayMs: number) => void
}

/**
 * Retry result with metadata
 */
export interface RetryResult<T> {
  success: boolean
  data?: T
  error?: unknown
  attempts: number
  totalTimeMs: number
}

/**
 * Default retryable HTTP status codes
 */
const DEFAULT_RETRYABLE_STATUS_CODES = [
  408, // Request Timeout
  429, // Too Many Requests
  500, // Internal Server Error
  502, // Bad Gateway
  503, // Service Unavailable
  504, // Gateway Timeout
]

/**
 * Non-retryable errors (should fail immediately)
 */
const NON_RETRYABLE_STATUS_CODES = [
  400, // Bad Request
  401, // Unauthorized
  403, // Forbidden
  404, // Not Found
  409, // Conflict
  422, // Unprocessable Entity
]

/**
 * Calculate delay with exponential backoff and optional jitter
 */
function calculateDelay(
  attempt: number,
  initialDelayMs: number,
  maxDelayMs: number,
  backoffMultiplier: number,
  jitter: boolean
): number {
  // Exponential backoff: initialDelay * multiplier^attempt
  let delay = initialDelayMs * Math.pow(backoffMultiplier, attempt - 1)

  // Cap at maximum delay
  delay = Math.min(delay, maxDelayMs)

  // Add jitter (0-50% of delay)
  if (jitter) {
    delay = delay * (1 + Math.random() * 0.5)
  }

  return Math.floor(delay)
}

/**
 * Sleep for specified milliseconds
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

/**
 * Default error classification
 */
function isDefaultRetryable(error: unknown, retryableStatusCodes: number[]): boolean {
  // Network errors are usually retryable
  if (error instanceof TypeError && error.message.includes("fetch")) {
    return true
  }

  // Check for Response objects (from fetch)
  if (error && typeof error === "object" && "status" in error) {
    const status = (error as { status: number }).status
    if (NON_RETRYABLE_STATUS_CODES.includes(status)) {
      return false
    }
    return retryableStatusCodes.includes(status)
  }

  // Check for error with status code
  if (error && typeof error === "object" && "statusCode" in error) {
    const status = (error as { statusCode: number }).statusCode
    if (NON_RETRYABLE_STATUS_CODES.includes(status)) {
      return false
    }
    return retryableStatusCodes.includes(status)
  }

  // Default: don't retry unknown errors
  return false
}

/**
 * Execute function with retry logic
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<RetryResult<T>> {
  const {
    maxAttempts = 3,
    initialDelayMs = 1000,
    maxDelayMs = 30000,
    backoffMultiplier = 2,
    jitter = true,
    retryableStatusCodes = DEFAULT_RETRYABLE_STATUS_CODES,
    isRetryable,
    onRetry,
  } = options

  const startTime = Date.now()
  let lastError: unknown

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const data = await fn()
      return {
        success: true,
        data,
        attempts: attempt,
        totalTimeMs: Date.now() - startTime,
      }
    } catch (error) {
      lastError = error

      // Check if we should retry
      const shouldRetry = isRetryable
        ? isRetryable(error)
        : isDefaultRetryable(error, retryableStatusCodes)

      // If not retryable or last attempt, fail
      if (!shouldRetry || attempt === maxAttempts) {
        return {
          success: false,
          error,
          attempts: attempt,
          totalTimeMs: Date.now() - startTime,
        }
      }

      // Calculate delay for next attempt
      const delayMs = calculateDelay(
        attempt,
        initialDelayMs,
        maxDelayMs,
        backoffMultiplier,
        jitter
      )

      // Call retry callback if provided
      if (onRetry) {
        onRetry(attempt, error, delayMs)
      }

      // Wait before retrying
      await sleep(delayMs)
    }
  }

  return {
    success: false,
    error: lastError,
    attempts: maxAttempts,
    totalTimeMs: Date.now() - startTime,
  }
}

/**
 * Retry wrapper for fetch requests
 * Automatically handles Response parsing and error extraction
 */
export async function fetchWithRetry<T>(
  url: string,
  options: RequestInit = {},
  retryOptions: RetryOptions = {}
): Promise<RetryResult<T>> {
  return withRetry(async () => {
    const response = await fetch(url, options)

    if (!response.ok) {
      // Create an error object with status for retry classification
      const errorBody = await response.json().catch(() => ({}))
      const error = new Error(errorBody.error || `HTTP ${response.status}`)
      ;(error as unknown as { status: number }).status = response.status
      ;(error as unknown as { body: unknown }).body = errorBody
      throw error
    }

    return response.json() as Promise<T>
  }, retryOptions)
}

/**
 * Generate idempotency key for payment requests
 * Ensures duplicate requests don't result in duplicate payments
 */
export function generateIdempotencyKey(
  userId: string,
  operation: string,
  additionalData?: string
): string {
  const timestamp = Math.floor(Date.now() / 1000) // Round to nearest second
  const data = `${userId}:${operation}:${additionalData || ""}:${timestamp}`
  // Create a hash-like key (not cryptographically secure, just for deduplication)
  let hash = 0
  for (let i = 0; i < data.length; i++) {
    const char = data.charCodeAt(i)
    hash = (hash << 5) - hash + char
    hash = hash & hash // Convert to 32-bit integer
  }
  return `${operation}_${Math.abs(hash).toString(36)}_${timestamp}`
}

/**
 * Payment-specific retry configuration
 */
export const PAYMENT_RETRY_OPTIONS: RetryOptions = {
  maxAttempts: 3,
  initialDelayMs: 2000,
  maxDelayMs: 10000,
  backoffMultiplier: 2,
  jitter: true,
  retryableStatusCodes: [408, 429, 500, 502, 503, 504],
  isRetryable: (error) => {
    // Never retry client errors for payments
    if (error && typeof error === "object" && "status" in error) {
      const status = (error as { status: number }).status
      if (status >= 400 && status < 500) {
        return false
      }
    }
    // Retry server errors and network issues
    return true
  },
}

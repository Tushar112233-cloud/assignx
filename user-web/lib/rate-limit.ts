/**
 * Rate Limiting Utility
 *
 * Provides in-memory rate limiting for API routes.
 * For production with multiple instances, consider using Upstash Redis.
 *
 * @example
 * ```typescript
 * import { rateLimit, RateLimitConfig } from "@/lib/rate-limit"
 *
 * const limiter = rateLimit({
 *   interval: 60 * 1000, // 1 minute
 *   uniqueTokenPerInterval: 500,
 * })
 *
 * // In API route:
 * const { success, remaining } = await limiter.check(10, identifier)
 * if (!success) {
 *   return NextResponse.json({ error: "Too many requests" }, { status: 429 })
 * }
 * ```
 */

export interface RateLimitConfig {
  /** Time window in milliseconds */
  interval: number
  /** Maximum number of unique tokens (users) to track per interval */
  uniqueTokenPerInterval: number
}

export interface RateLimitResult {
  /** Whether the request is allowed */
  success: boolean
  /** Remaining requests in the current window */
  remaining: number
  /** Timestamp when the rate limit resets */
  reset: number
  /** Maximum requests allowed per window */
  limit: number
}

interface TokenBucket {
  count: number
  lastReset: number
}

/**
 * Creates a rate limiter instance
 */
export function rateLimit(config: RateLimitConfig) {
  const tokenBuckets = new Map<string, TokenBucket>()

  // Cleanup old entries periodically to prevent memory leaks
  const cleanup = () => {
    const now = Date.now()
    for (const [key, bucket] of tokenBuckets.entries()) {
      if (now - bucket.lastReset > config.interval * 2) {
        tokenBuckets.delete(key)
      }
    }

    // Also limit total entries to prevent memory issues
    if (tokenBuckets.size > config.uniqueTokenPerInterval) {
      const entries = Array.from(tokenBuckets.entries())
      entries.sort((a, b) => a[1].lastReset - b[1].lastReset)
      const toDelete = entries.slice(0, entries.length - config.uniqueTokenPerInterval)
      for (const [key] of toDelete) {
        tokenBuckets.delete(key)
      }
    }
  }

  return {
    /**
     * Check if a request should be allowed
     * @param limit Maximum requests per interval
     * @param token Unique identifier (user ID, IP, etc.)
     */
    check: async (limit: number, token: string): Promise<RateLimitResult> => {
      const now = Date.now()
      const bucket = tokenBuckets.get(token)
      const resetTime = now + config.interval

      // New token or expired window
      if (!bucket || now - bucket.lastReset > config.interval) {
        tokenBuckets.set(token, { count: 1, lastReset: now })
        cleanup()
        return {
          success: true,
          remaining: limit - 1,
          reset: resetTime,
          limit,
        }
      }

      // Existing token within window
      if (bucket.count >= limit) {
        return {
          success: false,
          remaining: 0,
          reset: bucket.lastReset + config.interval,
          limit,
        }
      }

      // Increment counter
      bucket.count++
      return {
        success: true,
        remaining: limit - bucket.count,
        reset: bucket.lastReset + config.interval,
        limit,
      }
    },

    /**
     * Reset rate limit for a specific token
     */
    reset: (token: string) => {
      tokenBuckets.delete(token)
    },
  }
}

/**
 * Pre-configured rate limiters for different use cases
 */

// Rate limit for payment endpoints
// More lenient in development (20 req/min), strict in production (10 req/min)
const isDev = process.env.NODE_ENV === "development"
export const paymentRateLimiter = rateLimit({
  interval: 60 * 1000, // 1 minute
  uniqueTokenPerInterval: 500,
})

// Override check limit based on environment
const originalPaymentCheck = paymentRateLimiter.check
paymentRateLimiter.check = async (limit: number, token: string) => {
  // Use higher limit in development for easier testing
  const effectiveLimit = isDev ? Math.max(limit, 20) : limit
  return originalPaymentCheck(effectiveLimit, token)
}

// Standard rate limit for authenticated API endpoints (30 requests per minute)
export const apiRateLimiter = rateLimit({
  interval: 60 * 1000, // 1 minute
  uniqueTokenPerInterval: 1000,
})

// Relaxed rate limit for read operations (100 requests per minute)
export const readRateLimiter = rateLimit({
  interval: 60 * 1000, // 1 minute
  uniqueTokenPerInterval: 2000,
})

/**
 * Helper to get client identifier from request
 * Uses user ID if authenticated, falls back to IP
 */
export function getClientIdentifier(
  userId: string | null | undefined,
  request: Request
): string {
  if (userId) {
    return `user:${userId}`
  }

  // Get IP from various headers (Vercel, Cloudflare, etc.)
  const forwardedFor = request.headers.get("x-forwarded-for")
  const realIp = request.headers.get("x-real-ip")
  const cfConnectingIp = request.headers.get("cf-connecting-ip")

  const ip = cfConnectingIp || realIp || forwardedFor?.split(",")[0]?.trim() || "unknown"
  return `ip:${ip}`
}

/**
 * Rate limit headers to include in response
 */
export function rateLimitHeaders(result: RateLimitResult): HeadersInit {
  return {
    "X-RateLimit-Limit": result.limit.toString(),
    "X-RateLimit-Remaining": result.remaining.toString(),
    "X-RateLimit-Reset": result.reset.toString(),
  }
}

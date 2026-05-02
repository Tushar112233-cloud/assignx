import crypto from "crypto"
import { cookies } from "next/headers"
import { NextRequest, NextResponse } from "next/server"
import { env } from "@/lib/env"

/**
 * CSRF Protection Utility
 *
 * Provides protection against Cross-Site Request Forgery attacks by:
 * 1. Validating Origin/Referer headers
 * 2. Using double-submit cookie pattern with cryptographic tokens
 *
 * @example
 * ```typescript
 * // In API route:
 * import { validateCsrf, csrfError } from "@/lib/csrf"
 *
 * export async function POST(request: NextRequest) {
 *   const csrfResult = await validateCsrf(request)
 *   if (!csrfResult.valid) {
 *     return csrfError(csrfResult.error)
 *   }
 *   // ... handle request
 * }
 * ```
 */

const CSRF_COOKIE_NAME = "__Host-csrf"
const CSRF_HEADER_NAME = "x-csrf-token"
const CSRF_TOKEN_LENGTH = 32

/**
 * Allowed origins for CSRF validation
 * Uses validated environment variables
 */
const ALLOWED_ORIGINS = [
  env.NEXT_PUBLIC_APP_URL,
  process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : null,
  // Development origins - always allow localhost in dev
  ...(process.env.NODE_ENV === "development" ? [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:3001",
    "http://127.0.0.1:3001",
  ] : []),
].filter(Boolean) as string[]

/**
 * CSRF validation result
 */
export interface CsrfValidationResult {
  valid: boolean
  error?: string
}

/**
 * Generate a cryptographically secure CSRF token
 */
export function generateCsrfToken(): string {
  return crypto.randomBytes(CSRF_TOKEN_LENGTH).toString("hex")
}

/**
 * Validate Origin header against allowed origins
 */
export function validateOrigin(request: NextRequest): boolean {
  const origin = request.headers.get("origin")
  const referer = request.headers.get("referer")

  // For same-origin requests, origin might be null
  // In that case, check the referer
  if (!origin && !referer) {
    // Allow requests without origin/referer only in development
    return process.env.NODE_ENV === "development"
  }

  const requestOrigin = origin || (referer ? new URL(referer).origin : null)

  if (!requestOrigin) {
    return false
  }

  // Check if origin is in allowed list
  return ALLOWED_ORIGINS.some((allowed) => {
    if (!allowed) return false
    try {
      const allowedUrl = new URL(allowed)
      const requestUrl = new URL(requestOrigin)
      return (
        allowedUrl.protocol === requestUrl.protocol &&
        allowedUrl.host === requestUrl.host
      )
    } catch {
      return allowed === requestOrigin
    }
  })
}

/**
 * Validate CSRF token using double-submit cookie pattern
 */
export async function validateCsrfToken(request: NextRequest): Promise<boolean> {
  try {
    const cookieStore = await cookies()
    const cookieToken = cookieStore.get(CSRF_COOKIE_NAME)?.value
    const headerToken = request.headers.get(CSRF_HEADER_NAME)

    if (!cookieToken || !headerToken) {
      return false
    }

    // Use constant-time comparison to prevent timing attacks
    if (cookieToken.length !== headerToken.length) {
      return false
    }

    return crypto.timingSafeEqual(
      Buffer.from(cookieToken),
      Buffer.from(headerToken)
    )
  } catch {
    return false
  }
}

/**
 * Comprehensive CSRF validation
 * Validates both origin and CSRF token
 */
export async function validateCsrf(
  request: NextRequest,
  options: {
    requireToken?: boolean
    skipOriginCheck?: boolean
  } = {}
): Promise<CsrfValidationResult> {
  const { requireToken = true, skipOriginCheck = false } = options

  // 1. Validate Origin/Referer header
  if (!skipOriginCheck && !validateOrigin(request)) {
    return {
      valid: false,
      error: "Invalid origin",
    }
  }

  // 2. Validate CSRF token (if required)
  if (requireToken) {
    const tokenValid = await validateCsrfToken(request)
    if (!tokenValid) {
      return {
        valid: false,
        error: "Invalid or missing CSRF token",
      }
    }
  }

  return { valid: true }
}

/**
 * Create CSRF error response
 */
export function csrfError(message: string = "CSRF validation failed"): NextResponse {
  return NextResponse.json(
    { error: message },
    { status: 403 }
  )
}

/**
 * Set CSRF cookie for client
 * Call this in a GET endpoint or page load
 */
export async function setCsrfCookie(): Promise<string> {
  const token = generateCsrfToken()
  const cookieStore = await cookies()

  cookieStore.set(CSRF_COOKIE_NAME, token, {
    httpOnly: true,
    secure: env.NODE_ENV === "production",
    sameSite: "strict",
    path: "/",
    maxAge: 60 * 60 * 24, // 24 hours
  })

  return token
}

/**
 * Get or create CSRF token
 * Returns existing token from cookie or creates new one
 */
export async function getOrCreateCsrfToken(): Promise<string> {
  const cookieStore = await cookies()
  const existingToken = cookieStore.get(CSRF_COOKIE_NAME)?.value

  if (existingToken) {
    return existingToken
  }

  return setCsrfCookie()
}

/**
 * Middleware helper for CSRF protection
 * Use in API routes that need CSRF protection
 */
export async function withCsrfProtection<T>(
  request: NextRequest,
  handler: () => Promise<T>,
  options?: {
    requireToken?: boolean
    skipOriginCheck?: boolean
  }
): Promise<T | NextResponse> {
  const csrfResult = await validateCsrf(request, options)

  if (!csrfResult.valid) {
    return csrfError(csrfResult.error)
  }

  return handler()
}

/**
 * Simple origin-only validation for endpoints that don't use CSRF tokens
 * This is less secure but useful for JSON API endpoints with authentication
 */
export function validateOriginOnly(request: NextRequest): CsrfValidationResult {
  if (!validateOrigin(request)) {
    return {
      valid: false,
      error: "Request origin not allowed",
    }
  }
  return { valid: true }
}

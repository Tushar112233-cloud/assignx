import { z } from "zod"

/**
 * Environment Variable Validation
 *
 * Validates all required environment variables at build time and runtime.
 * This prevents deployment issues caused by missing or invalid env vars.
 *
 * Usage:
 * - Import `env` in server components/API routes for full env access
 * - Import `clientEnv` in client components for NEXT_PUBLIC_ vars only
 * - Variables are validated when the module is first imported
 * - Build will fail if required variables are missing in production
 */

/**
 * Server-side environment variables schema
 * These are only available on the server (not exposed to client)
 */
const serverEnvSchema = z.object({
  // Express API URL
  NEXT_PUBLIC_API_URL: z
    .string()
    .url("NEXT_PUBLIC_API_URL must be a valid URL")
    .optional(),

  // Razorpay (optional - payments disabled when not configured)
  RAZORPAY_KEY_ID: z
    .string()
    .min(1, "RAZORPAY_KEY_ID is required for payments")
    .optional(),
  RAZORPAY_KEY_SECRET: z
    .string()
    .min(1, "RAZORPAY_KEY_SECRET is required for payments")
    .optional(),
  NEXT_PUBLIC_RAZORPAY_KEY_ID: z
    .string()
    .min(1, "NEXT_PUBLIC_RAZORPAY_KEY_ID is required for payments")
    .optional(),

  // Push Notifications (optional)
  VAPID_PRIVATE_KEY: z.string().optional(),
  NEXT_PUBLIC_VAPID_PUBLIC_KEY: z.string().optional(),
  VAPID_EMAIL: z.string().email().optional(),

  // WhatsApp (optional)
  WHATSAPP_PHONE_NUMBER_ID: z.string().optional(),
  WHATSAPP_ACCESS_TOKEN: z.string().optional(),

  // Internal API Key (for server-to-server calls)
  INTERNAL_API_KEY: z
    .string()
    .min(32, "INTERNAL_API_KEY must be at least 32 characters")
    .optional(),

  // App URL (for CSRF and redirects)
  NEXT_PUBLIC_APP_URL: z
    .string()
    .url("NEXT_PUBLIC_APP_URL must be a valid URL")
    .optional(),

  // Node environment
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),
})

/**
 * Client-side environment variables schema
 * These are exposed to the browser (NEXT_PUBLIC_ prefix)
 */
const clientEnvSchema = z.object({
  NEXT_PUBLIC_API_URL: z.string().url().optional(),
  NEXT_PUBLIC_RAZORPAY_KEY_ID: z.string().min(1).optional(),
  NEXT_PUBLIC_VAPID_PUBLIC_KEY: z.string().optional(),
  NEXT_PUBLIC_APP_URL: z.string().url().optional(),
  /** Support WhatsApp for wa.me (E.164 digits, may include + or spaces). */
  NEXT_PUBLIC_SUPPORT_WHATSAPP: z.string().optional(),
  // Development settings for bypassing auth
  NEXT_PUBLIC_REQUIRE_LOGIN: z.string().optional().default("true"),
  NEXT_PUBLIC_DEV_USER_EMAIL: z.string().email().optional(),
})

/**
 * Type-safe environment variable types
 */
export type ServerEnv = z.infer<typeof serverEnvSchema>
export type ClientEnv = z.infer<typeof clientEnvSchema>

/**
 * Validate server environment variables
 * Only runs on the server
 */
function validateServerEnv(): ServerEnv {
  const parsed = serverEnvSchema.safeParse(process.env)

  if (!parsed.success) {
    console.error(
      "Invalid environment variables:",
      parsed.error.flatten().fieldErrors
    )

    // In production, throw to prevent deployment with missing vars
    if (process.env.NODE_ENV === "production") {
      throw new Error(
        `Invalid environment variables: ${JSON.stringify(
          parsed.error.flatten().fieldErrors
        )}`
      )
    }

    // In development, warn but continue with fallback
    console.warn("Continuing with missing environment variables in development")
    return process.env as unknown as ServerEnv
  }

  return parsed.data
}

/**
 * Validate client environment variables
 * These are inlined at build time by Next.js
 */
function validateClientEnv(): ClientEnv {
  const clientEnvValues = {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_RAZORPAY_KEY_ID: process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID,
    NEXT_PUBLIC_VAPID_PUBLIC_KEY: process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY,
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
    NEXT_PUBLIC_SUPPORT_WHATSAPP: process.env.NEXT_PUBLIC_SUPPORT_WHATSAPP,
    NEXT_PUBLIC_REQUIRE_LOGIN: process.env.NEXT_PUBLIC_REQUIRE_LOGIN,
    NEXT_PUBLIC_DEV_USER_EMAIL: process.env.NEXT_PUBLIC_DEV_USER_EMAIL,
  }

  const parsed = clientEnvSchema.safeParse(clientEnvValues)

  if (!parsed.success) {
    console.error(
      "Invalid client environment variables:",
      parsed.error.flatten().fieldErrors
    )
    return clientEnvValues as unknown as ClientEnv
  }

  return parsed.data
}

/**
 * Server environment variables (full access)
 * Use in API routes, server components, and server actions
 *
 * @example
 * import { env } from "@/lib/env"
 * const secret = env.RAZORPAY_KEY_SECRET
 */
export const env: ServerEnv = typeof window === "undefined"
  ? validateServerEnv()
  : ({} as ServerEnv) // Empty on client - prevents bundling secrets

/**
 * Client environment variables (NEXT_PUBLIC_ only)
 * Use in client components
 *
 * @example
 * import { clientEnv } from "@/lib/env"
 * const apiUrl = clientEnv.NEXT_PUBLIC_API_URL
 */
export const clientEnv: ClientEnv = validateClientEnv()

/**
 * Check if a feature is enabled based on env vars
 * Uses process.env directly to work in both contexts
 */
export const features = {
  pushNotifications: Boolean(
    process.env.VAPID_PRIVATE_KEY && process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY
  ),
  whatsApp: Boolean(
    process.env.WHATSAPP_PHONE_NUMBER_ID && process.env.WHATSAPP_ACCESS_TOKEN
  ),
  analytics: Boolean(process.env.NEXT_PUBLIC_ANALYTICS_ID),
  /**
   * When false, bypasses authentication and uses default dev user
   * Useful for development and testing without requiring Google OAuth
   */
  requireLogin: process.env.NEXT_PUBLIC_REQUIRE_LOGIN !== "false",
}

/**
 * Get required env var or throw
 * Use this for vars that must exist at runtime
 */
export function requireEnv(key: string): string {
  const value = process.env[key]
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`)
  }
  return value
}

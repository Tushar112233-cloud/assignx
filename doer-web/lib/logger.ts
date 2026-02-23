/**
 * Development-only logger utility
 * Logs are stripped in production builds
 */

const isDev = process.env.NODE_ENV === 'development'

/**
 * Sanitize sensitive data from log messages
 * Redacts emails, IDs, and other PII
 */
function sanitize(message: string): string {
  return message
    // Redact emails
    .replace(/[\w.-]+@[\w.-]+\.\w+/g, '[EMAIL]')
    // Redact UUIDs
    .replace(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi, '[ID]')
    // Redact phone numbers
    .replace(/\+?\d{10,}/g, '[PHONE]')
}

/**
 * Development-only logger
 * All methods are no-ops in production
 */
export const logger = {
  /**
   * Log debug messages (dev only)
   */
  debug(prefix: string, ...args: unknown[]): void {
    if (!isDev) return
    const sanitizedArgs = args.map(arg =>
      typeof arg === 'string' ? sanitize(arg) : arg
    )
    console.log(`[${prefix}]`, ...sanitizedArgs)
  },

  /**
   * Log info messages (dev only)
   */
  info(prefix: string, ...args: unknown[]): void {
    if (!isDev) return
    const sanitizedArgs = args.map(arg =>
      typeof arg === 'string' ? sanitize(arg) : arg
    )
    console.info(`[${prefix}]`, ...sanitizedArgs)
  },

  /**
   * Log warnings (dev only)
   */
  warn(prefix: string, ...args: unknown[]): void {
    if (!isDev) return
    console.warn(`[${prefix}]`, ...args)
  },

  /**
   * Log errors (always logs, but sanitizes in production)
   * Errors are important for monitoring but should not leak PII
   */
  error(prefix: string, ...args: unknown[]): void {
    const sanitizedArgs = args.map(arg => {
      if (typeof arg === 'string') return sanitize(arg)
      if (arg instanceof Error) {
        return isDev ? arg : sanitize(arg.message)
      }
      return arg
    })
    console.error(`[${prefix}]`, ...sanitizedArgs)
  },
}

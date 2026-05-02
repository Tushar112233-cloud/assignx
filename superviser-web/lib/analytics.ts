/**
 * @fileoverview Analytics and error tracking utilities for monitoring and logging.
 * @module lib/analytics
 */

type EventProperties = Record<string, string | number | boolean | undefined>

interface ErrorContext {
  componentStack?: string
  url?: string
  userId?: string
  extra?: Record<string, unknown>
}

// Error Tracking
export function captureException(error: Error, context?: ErrorContext): void {
  // In development, log to console
  if (process.env.NODE_ENV === "development") {
    console.error("Error captured:", error, context)
    return
  }

  // In production, send to error tracking service
  // Example with Sentry:
  // Sentry.captureException(error, { extra: context })

  // For now, log to console in production as well
  console.error("[Error Tracking]", error.message, context)
}

export function captureMessage(message: string, level: "info" | "warning" | "error" = "info"): void {
  if (process.env.NODE_ENV === "development") {
    console[level === "error" ? "error" : level === "warning" ? "warn" : "log"](message)
    return
  }

  // In production, send to error tracking service
  // Sentry.captureMessage(message, level)
  console.log(`[${level.toUpperCase()}]`, message)
}

// Analytics Events
export function trackEvent(eventName: string, properties?: EventProperties): void {
  if (process.env.NODE_ENV === "development") {
    console.log("[Analytics Event]", eventName, properties)
    return
  }

  // In production, send to analytics service
  // mixpanel.track(eventName, properties)
  // gtag('event', eventName, properties)
}

export function trackPageView(pageName: string, properties?: EventProperties): void {
  trackEvent("page_view", { page_name: pageName, ...properties })
}

// User Identification
export function identifyUser(userId: string, traits?: Record<string, string | number | boolean>): void {
  if (process.env.NODE_ENV === "development") {
    console.log("[Analytics Identify]", userId, traits)
    return
  }

  // In production:
  // Sentry.setUser({ id: userId, ...traits })
  // mixpanel.identify(userId)
  // mixpanel.people.set(traits)
}

export function resetUser(): void {
  if (process.env.NODE_ENV === "development") {
    console.log("[Analytics Reset]")
    return
  }

  // In production:
  // Sentry.setUser(null)
  // mixpanel.reset()
}

// Performance Monitoring
export function measurePerformance(metricName: string, value: number, unit: string = "ms"): void {
  if (process.env.NODE_ENV === "development") {
    console.log(`[Performance] ${metricName}: ${value}${unit}`)
    return
  }

  // In production, send to monitoring service
  trackEvent("performance_metric", {
    metric_name: metricName,
    value,
    unit,
  })
}

// Feature Flags (placeholder for future implementation)
export function getFeatureFlag(flagName: string, defaultValue: boolean = false): boolean {
  // In production, fetch from feature flag service
  // return launchdarkly.variation(flagName, defaultValue)
  return defaultValue
}

// Session Recording (placeholder)
export function startSessionRecording(): void {
  if (process.env.NODE_ENV === "development") {
    return
  }
  // LogRocket.init('app-id')
}

// Custom Error Handler for React Error Boundaries
export function handleBoundaryError(error: Error, errorInfo: React.ErrorInfo): void {
  captureException(error, {
    componentStack: errorInfo.componentStack || undefined,
    url: typeof window !== "undefined" ? window.location.href : undefined,
  })
}

/**
 * @fileoverview Custom React hooks for analytics tracking and event logging.
 * @module hooks/use-analytics
 */

"use client"

import { useEffect, useCallback } from "react"
import { usePathname, useSearchParams } from "next/navigation"
import {
  trackPageView,
  trackEvent,
  identifyUser,
  resetUser,
} from "@/lib/analytics"

type EventProperties = Record<string, string | number | boolean | undefined>

/**
 * Hook for tracking page views automatically
 */
export function usePageTracking() {
  const pathname = usePathname()
  const searchParams = useSearchParams()

  useEffect(() => {
    const url = pathname + (searchParams?.toString() ? `?${searchParams.toString()}` : "")
    trackPageView(pathname, { url })
  }, [pathname, searchParams])
}

/**
 * Hook for tracking events with memoized callbacks
 */
export function useEventTracking() {
  const track = useCallback((eventName: string, properties?: EventProperties) => {
    trackEvent(eventName, properties)
  }, [])

  const identify = useCallback((userId: string, traits?: Record<string, string | number | boolean>) => {
    identifyUser(userId, traits)
  }, [])

  const reset = useCallback(() => {
    resetUser()
  }, [])

  return { track, identify, reset }
}

/**
 * Hook for tracking component-specific events
 */
export function useComponentTracking(componentName: string) {
  const { track } = useEventTracking()

  const trackAction = useCallback(
    (action: string, properties?: EventProperties) => {
      track(`${componentName}_${action}`, {
        component: componentName,
        ...properties,
      })
    },
    [componentName, track]
  )

  return { trackAction }
}

/**
 * Hook for tracking form interactions
 */
export function useFormTracking(formName: string) {
  const { track } = useEventTracking()

  const trackFormStart = useCallback(() => {
    track("form_start", { form_name: formName })
  }, [formName, track])

  const trackFormSubmit = useCallback(
    (success: boolean, errorMessage?: string) => {
      track("form_submit", {
        form_name: formName,
        success,
        error_message: errorMessage,
      })
    },
    [formName, track]
  )

  const trackFieldInteraction = useCallback(
    (fieldName: string, interactionType: "focus" | "blur" | "change") => {
      track("form_field_interaction", {
        form_name: formName,
        field_name: fieldName,
        interaction_type: interactionType,
      })
    },
    [formName, track]
  )

  return { trackFormStart, trackFormSubmit, trackFieldInteraction }
}

/**
 * Hook for tracking button clicks
 */
export function useClickTracking() {
  const { track } = useEventTracking()

  const trackClick = useCallback(
    (buttonName: string, properties?: EventProperties) => {
      track("button_click", {
        button_name: buttonName,
        ...properties,
      })
    },
    [track]
  )

  return { trackClick }
}

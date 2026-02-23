/**
 * @fileoverview Custom React hooks for responsive design and media query detection.
 * @module hooks/use-media-query
 */

"use client"

import { useSyncExternalStore } from "react"

/**
 * Hook to track media query matches using useSyncExternalStore for proper hydration
 */
export function useMediaQuery(query: string): boolean {
  const subscribe = (callback: () => void) => {
    const mediaQueryList = window.matchMedia(query)
    mediaQueryList.addEventListener("change", callback)
    return () => mediaQueryList.removeEventListener("change", callback)
  }

  const getSnapshot = () => {
    return window.matchMedia(query).matches
  }

  const getServerSnapshot = () => false

  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}

/**
 * Breakpoint hooks matching Tailwind CSS defaults
 */
export function useIsMobile(): boolean {
  return !useMediaQuery("(min-width: 640px)")
}

export function useIsTablet(): boolean {
  const isMinSm = useMediaQuery("(min-width: 640px)")
  const isMaxLg = !useMediaQuery("(min-width: 1024px)")
  return isMinSm && isMaxLg
}

export function useIsDesktop(): boolean {
  return useMediaQuery("(min-width: 1024px)")
}

export function useIsLargeDesktop(): boolean {
  return useMediaQuery("(min-width: 1280px)")
}

/**
 * Get current breakpoint name
 */
export function useBreakpoint(): "xs" | "sm" | "md" | "lg" | "xl" | "2xl" {
  const is2xl = useMediaQuery("(min-width: 1536px)")
  const isXl = useMediaQuery("(min-width: 1280px)")
  const isLg = useMediaQuery("(min-width: 1024px)")
  const isMd = useMediaQuery("(min-width: 768px)")
  const isSm = useMediaQuery("(min-width: 640px)")

  if (is2xl) return "2xl"
  if (isXl) return "xl"
  if (isLg) return "lg"
  if (isMd) return "md"
  if (isSm) return "sm"
  return "xs"
}

/**
 * Hook to detect device orientation
 */
export function useOrientation(): "portrait" | "landscape" {
  const isPortrait = useMediaQuery("(orientation: portrait)")
  return isPortrait ? "portrait" : "landscape"
}

/**
 * Hook to detect reduced motion preference
 */
export function usePrefersReducedMotion(): boolean {
  return useMediaQuery("(prefers-reduced-motion: reduce)")
}

/**
 * Hook to detect color scheme preference
 */
export function usePrefersColorScheme(): "light" | "dark" | "no-preference" {
  const prefersDark = useMediaQuery("(prefers-color-scheme: dark)")
  const prefersLight = useMediaQuery("(prefers-color-scheme: light)")

  if (prefersDark) return "dark"
  if (prefersLight) return "light"
  return "no-preference"
}

/**
 * Hook to detect high contrast mode
 */
export function usePrefersContrast(): "more" | "less" | "no-preference" {
  const prefersMore = useMediaQuery("(prefers-contrast: more)")
  const prefersLess = useMediaQuery("(prefers-contrast: less)")

  if (prefersMore) return "more"
  if (prefersLess) return "less"
  return "no-preference"
}

/**
 * Hook to detect touch device using useSyncExternalStore for proper hydration
 */
export function useIsTouchDevice(): boolean {
  const subscribe = () => () => {} // Touch capability doesn't change

  const getSnapshot = () => {
    return "ontouchstart" in window || navigator.maxTouchPoints > 0
  }

  const getServerSnapshot = () => false

  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
}

/**
 * Hook to get viewport dimensions using useSyncExternalStore
 */
export function useViewportSize(): { width: number; height: number } {
  const subscribe = (callback: () => void) => {
    window.addEventListener("resize", callback)
    return () => window.removeEventListener("resize", callback)
  }

  const getSnapshot = () => {
    return JSON.stringify({ width: window.innerWidth, height: window.innerHeight })
  }

  const getServerSnapshot = () => JSON.stringify({ width: 0, height: 0 })

  const sizeString = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
  return JSON.parse(sizeString)
}

/**
 * Hook to detect scroll position using useSyncExternalStore
 */
export function useScrollPosition(): { x: number; y: number } {
  const subscribe = (callback: () => void) => {
    window.addEventListener("scroll", callback, { passive: true })
    return () => window.removeEventListener("scroll", callback)
  }

  const getSnapshot = () => {
    return JSON.stringify({ x: window.scrollX, y: window.scrollY })
  }

  const getServerSnapshot = () => JSON.stringify({ x: 0, y: 0 })

  const positionString = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)
  return JSON.parse(positionString)
}

/**
 * Hook to detect if page has been scrolled
 */
export function useIsScrolled(threshold = 10): boolean {
  const { y } = useScrollPosition()
  return y > threshold
}

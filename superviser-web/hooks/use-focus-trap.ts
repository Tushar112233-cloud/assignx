/**
 * @fileoverview Custom React hooks for focus management and accessibility.
 * @module hooks/use-focus-trap
 */

"use client"

import { useEffect, useRef, useCallback } from "react"

const FOCUSABLE_SELECTORS = [
  "a[href]",
  "area[href]",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "button:not([disabled])",
  "[tabindex]:not([tabindex='-1'])",
  "[contenteditable]",
  "audio[controls]",
  "video[controls]",
  "details > summary:first-of-type",
].join(", ")

interface UseFocusTrapOptions {
  enabled?: boolean
  autoFocus?: boolean
  returnFocusOnDeactivate?: boolean
}

/**
 * Hook to trap focus within a container element
 * Useful for modals, dialogs, and other overlays
 */
export function useFocusTrap<T extends HTMLElement = HTMLDivElement>(
  options: UseFocusTrapOptions = {}
) {
  const { enabled = true, autoFocus = true, returnFocusOnDeactivate = true } = options
  const containerRef = useRef<T>(null)
  const previousActiveElement = useRef<HTMLElement | null>(null)

  const getFocusableElements = useCallback((): HTMLElement[] => {
    if (!containerRef.current) return []
    const elements = containerRef.current.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTORS)
    return Array.from(elements).filter(
      (el) => !el.hasAttribute("disabled") && el.tabIndex !== -1
    )
  }, [])

  const handleKeyDown = useCallback(
    (event: KeyboardEvent) => {
      if (!enabled || event.key !== "Tab") return

      const focusableElements = getFocusableElements()
      if (focusableElements.length === 0) return

      const firstElement = focusableElements[0]
      const lastElement = focusableElements[focusableElements.length - 1]

      if (event.shiftKey) {
        // Shift + Tab: Move focus backward
        if (document.activeElement === firstElement) {
          event.preventDefault()
          lastElement.focus()
        }
      } else {
        // Tab: Move focus forward
        if (document.activeElement === lastElement) {
          event.preventDefault()
          firstElement.focus()
        }
      }
    },
    [enabled, getFocusableElements]
  )

  useEffect(() => {
    if (!enabled) return

    // Store the previously focused element
    if (returnFocusOnDeactivate) {
      previousActiveElement.current = document.activeElement as HTMLElement
    }

    // Auto-focus the first focusable element
    if (autoFocus && containerRef.current) {
      const focusableElements = getFocusableElements()
      if (focusableElements.length > 0) {
        // Focus first element after a short delay to ensure DOM is ready
        requestAnimationFrame(() => {
          focusableElements[0].focus()
        })
      }
    }

    // Add event listener
    document.addEventListener("keydown", handleKeyDown)

    return () => {
      document.removeEventListener("keydown", handleKeyDown)

      // Return focus to previously focused element
      if (returnFocusOnDeactivate && previousActiveElement.current) {
        previousActiveElement.current.focus()
      }
    }
  }, [enabled, autoFocus, returnFocusOnDeactivate, handleKeyDown, getFocusableElements])

  return containerRef
}

/**
 * Hook to manage focus for keyboard navigation
 */
export function useRovingFocus<T extends HTMLElement = HTMLDivElement>(
  itemCount: number,
  options: {
    orientation?: "horizontal" | "vertical" | "both"
    loop?: boolean
    defaultIndex?: number
  } = {}
) {
  const { orientation = "vertical", loop = true, defaultIndex = 0 } = options
  const containerRef = useRef<T>(null)
  const focusIndexRef = useRef(defaultIndex)

  const handleKeyDown = useCallback(
    (event: KeyboardEvent) => {
      const isVertical = orientation === "vertical" || orientation === "both"
      const isHorizontal = orientation === "horizontal" || orientation === "both"

      let newIndex = focusIndexRef.current

      switch (event.key) {
        case "ArrowUp":
          if (isVertical) {
            event.preventDefault()
            newIndex = loop
              ? (focusIndexRef.current - 1 + itemCount) % itemCount
              : Math.max(0, focusIndexRef.current - 1)
          }
          break
        case "ArrowDown":
          if (isVertical) {
            event.preventDefault()
            newIndex = loop
              ? (focusIndexRef.current + 1) % itemCount
              : Math.min(itemCount - 1, focusIndexRef.current + 1)
          }
          break
        case "ArrowLeft":
          if (isHorizontal) {
            event.preventDefault()
            newIndex = loop
              ? (focusIndexRef.current - 1 + itemCount) % itemCount
              : Math.max(0, focusIndexRef.current - 1)
          }
          break
        case "ArrowRight":
          if (isHorizontal) {
            event.preventDefault()
            newIndex = loop
              ? (focusIndexRef.current + 1) % itemCount
              : Math.min(itemCount - 1, focusIndexRef.current + 1)
          }
          break
        case "Home":
          event.preventDefault()
          newIndex = 0
          break
        case "End":
          event.preventDefault()
          newIndex = itemCount - 1
          break
        default:
          return
      }

      if (newIndex !== focusIndexRef.current) {
        focusIndexRef.current = newIndex
        const items = containerRef.current?.querySelectorAll<HTMLElement>('[role="option"], [role="menuitem"], [data-roving-item]')
        items?.[newIndex]?.focus()
      }
    },
    [itemCount, loop, orientation]
  )

  useEffect(() => {
    const container = containerRef.current
    if (!container) return

    container.addEventListener("keydown", handleKeyDown)
    return () => container.removeEventListener("keydown", handleKeyDown)
  }, [handleKeyDown])

  return { containerRef, focusIndexRef }
}

/**
 * Hook to announce messages to screen readers
 */
export function useAnnounce() {
  const announce = useCallback((message: string, politeness: "polite" | "assertive" = "polite") => {
    const liveRegion = document.getElementById("live-region") || createLiveRegion()
    liveRegion.setAttribute("aria-live", politeness)
    liveRegion.textContent = message

    // Clear after announcement
    setTimeout(() => {
      liveRegion.textContent = ""
    }, 1000)
  }, [])

  return announce
}

function createLiveRegion(): HTMLDivElement {
  const liveRegion = document.createElement("div")
  liveRegion.id = "live-region"
  liveRegion.setAttribute("role", "status")
  liveRegion.setAttribute("aria-live", "polite")
  liveRegion.setAttribute("aria-atomic", "true")
  liveRegion.className = "sr-only"
  document.body.appendChild(liveRegion)
  return liveRegion
}

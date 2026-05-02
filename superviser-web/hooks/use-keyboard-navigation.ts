/**
 * @fileoverview Custom React hooks for keyboard navigation and shortcuts.
 * @module hooks/use-keyboard-navigation
 */

"use client"

import { useEffect, useCallback, RefObject } from "react"

type KeyboardHandler = (event: KeyboardEvent) => void

interface UseKeyboardNavigationOptions {
  onEscape?: KeyboardHandler
  onEnter?: KeyboardHandler
  onArrowUp?: KeyboardHandler
  onArrowDown?: KeyboardHandler
  onArrowLeft?: KeyboardHandler
  onArrowRight?: KeyboardHandler
  onTab?: KeyboardHandler
  onSpace?: KeyboardHandler
  onHome?: KeyboardHandler
  onEnd?: KeyboardHandler
  onPageUp?: KeyboardHandler
  onPageDown?: KeyboardHandler
  enabled?: boolean
}

/**
 * Hook for handling common keyboard navigation patterns
 */
export function useKeyboardNavigation(
  options: UseKeyboardNavigationOptions,
  containerRef?: RefObject<HTMLElement>
) {
  const {
    onEscape,
    onEnter,
    onArrowUp,
    onArrowDown,
    onArrowLeft,
    onArrowRight,
    onTab,
    onSpace,
    onHome,
    onEnd,
    onPageUp,
    onPageDown,
    enabled = true,
  } = options

  const handleKeyDown = useCallback(
    (event: KeyboardEvent) => {
      if (!enabled) return

      switch (event.key) {
        case "Escape":
          onEscape?.(event)
          break
        case "Enter":
          onEnter?.(event)
          break
        case "ArrowUp":
          onArrowUp?.(event)
          break
        case "ArrowDown":
          onArrowDown?.(event)
          break
        case "ArrowLeft":
          onArrowLeft?.(event)
          break
        case "ArrowRight":
          onArrowRight?.(event)
          break
        case "Tab":
          onTab?.(event)
          break
        case " ":
          onSpace?.(event)
          break
        case "Home":
          onHome?.(event)
          break
        case "End":
          onEnd?.(event)
          break
        case "PageUp":
          onPageUp?.(event)
          break
        case "PageDown":
          onPageDown?.(event)
          break
      }
    },
    [
      enabled,
      onEscape,
      onEnter,
      onArrowUp,
      onArrowDown,
      onArrowLeft,
      onArrowRight,
      onTab,
      onSpace,
      onHome,
      onEnd,
      onPageUp,
      onPageDown,
    ]
  )

  useEffect(() => {
    const target = containerRef?.current || document

    target.addEventListener("keydown", handleKeyDown as EventListener)
    return () => target.removeEventListener("keydown", handleKeyDown as EventListener)
  }, [containerRef, handleKeyDown])
}

/**
 * Hook for handling escape key to close modals/dialogs
 */
export function useEscapeKey(onEscape: () => void, enabled = true) {
  useKeyboardNavigation({
    onEscape: () => onEscape(),
    enabled,
  })
}

/**
 * Hook for handling click outside and escape key
 */
export function useClickOutside(
  ref: RefObject<HTMLElement>,
  handler: () => void,
  enabled = true
) {
  useEffect(() => {
    if (!enabled) return

    const handleClickOutside = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        handler()
      }
    }

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        handler()
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    document.addEventListener("keydown", handleEscape)

    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
      document.removeEventListener("keydown", handleEscape)
    }
  }, [ref, handler, enabled])
}

/**
 * Hook for handling keyboard shortcuts
 */
export function useKeyboardShortcut(
  key: string,
  callback: () => void,
  options: {
    ctrlKey?: boolean
    shiftKey?: boolean
    altKey?: boolean
    metaKey?: boolean
    enabled?: boolean
  } = {}
) {
  const {
    ctrlKey = false,
    shiftKey = false,
    altKey = false,
    metaKey = false,
    enabled = true,
  } = options

  useEffect(() => {
    if (!enabled) return

    const handleKeyDown = (event: KeyboardEvent) => {
      const keyMatch = event.key.toLowerCase() === key.toLowerCase()
      const ctrlMatch = ctrlKey ? event.ctrlKey || event.metaKey : !event.ctrlKey && !event.metaKey
      const shiftMatch = shiftKey ? event.shiftKey : !event.shiftKey
      const altMatch = altKey ? event.altKey : !event.altKey
      const metaMatch = metaKey ? event.metaKey : true // Meta is optional

      if (keyMatch && ctrlMatch && shiftMatch && altMatch && metaMatch) {
        event.preventDefault()
        callback()
      }
    }

    document.addEventListener("keydown", handleKeyDown)
    return () => document.removeEventListener("keydown", handleKeyDown)
  }, [key, callback, ctrlKey, shiftKey, altKey, metaKey, enabled])
}

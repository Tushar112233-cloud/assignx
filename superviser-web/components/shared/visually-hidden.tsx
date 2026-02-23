/**
 * @fileoverview Visually hidden component for screen reader only content.
 * @module components/shared/visually-hidden
 */

"use client"

import { ReactNode } from "react"

interface VisuallyHiddenProps {
  children: ReactNode
  asChild?: boolean
}

export function VisuallyHidden({ children }: VisuallyHiddenProps) {
  return (
    <span className="sr-only">
      {children}
    </span>
  )
}

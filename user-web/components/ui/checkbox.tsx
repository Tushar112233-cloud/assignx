"use client"

import * as React from "react"
import { CheckIcon } from "lucide-react"
import { cn } from "@/lib/utils"

/**
 * React 19-compatible Checkbox component.
 *
 * Replaces the Radix CheckboxPrimitive.Root which internally uses
 * `(node) => setState(node)` as a ref callback. React 19 calls ref
 * cleanup synchronously on every re-render when the callback identity
 * changes, causing an infinite setState → re-render loop via compose-refs.
 *
 * This implementation uses a plain <button role="checkbox"> with a stable
 * forwardRef, matching the same visual output and API surface.
 */

interface CheckboxProps
  extends Omit<
    React.ButtonHTMLAttributes<HTMLButtonElement>,
    "onChange" | "checked" | "defaultChecked"
  > {
  checked?: boolean
  defaultChecked?: boolean
  onCheckedChange?: (checked: boolean) => void
  disabled?: boolean
  className?: string
}

const Checkbox = React.forwardRef<HTMLButtonElement, CheckboxProps>(
  (
    {
      className,
      checked,
      defaultChecked = false,
      onCheckedChange,
      disabled,
      onClick,
      ...props
    },
    ref
  ) => {
    const [internalChecked, setInternalChecked] = React.useState(defaultChecked)
    const isControlled = checked !== undefined
    const isChecked = isControlled ? checked : internalChecked

    const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
      if (disabled) return
      const next = !isChecked
      if (!isControlled) setInternalChecked(next)
      onCheckedChange?.(next)
      onClick?.(e)
    }

    return (
      <button
        ref={ref}
        type="button"
        role="checkbox"
        aria-checked={isChecked}
        data-state={isChecked ? "checked" : "unchecked"}
        data-slot="checkbox"
        disabled={disabled}
        onClick={handleClick}
        className={cn(
          "peer border-input dark:bg-input/30 data-[state=checked]:bg-primary data-[state=checked]:text-primary-foreground dark:data-[state=checked]:bg-primary data-[state=checked]:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        {...props}
      >
        <span
          data-slot="checkbox-indicator"
          className="grid place-content-center text-current transition-none"
          style={{ visibility: isChecked ? "visible" : "hidden" }}
        >
          <CheckIcon className="size-3.5" />
        </span>
      </button>
    )
  }
)

Checkbox.displayName = "Checkbox"

export { Checkbox }

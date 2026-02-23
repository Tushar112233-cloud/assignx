'use client'

import { useState } from 'react'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'

interface AvailabilityToggleProps {
  /** Initial availability state */
  defaultValue?: boolean
  /** Callback when availability changes */
  onChange?: (available: boolean) => void
  /** Whether the toggle is disabled */
  disabled?: boolean
  /** Show compact version */
  compact?: boolean
}

/**
 * Availability toggle component
 * Allows doers to set their availability status
 */
export function AvailabilityToggle({
  defaultValue = true,
  onChange,
  disabled = false,
  compact = false,
}: AvailabilityToggleProps) {
  const [isAvailable, setIsAvailable] = useState(defaultValue)

  const handleChange = (checked: boolean) => {
    setIsAvailable(checked)
    onChange?.(checked)
  }

  return (
    <div className={cn(
      'flex items-center gap-3',
      compact ? 'justify-between' : 'flex-col items-start gap-2'
    )}>
      <div className="flex items-center gap-3">
        {/* Status indicator */}
        <div
          className={cn(
            'h-3 w-3 rounded-full transition-colors',
            isAvailable ? 'bg-green-500' : 'bg-gray-400'
          )}
        />

        <div className={cn(!compact && 'space-y-0.5')}>
          <Label
            htmlFor="availability"
            className={cn(
              'font-medium cursor-pointer',
              isAvailable ? 'text-green-600 dark:text-green-400' : 'text-muted-foreground'
            )}
          >
            {isAvailable ? 'Available' : 'Busy'}
          </Label>
          {!compact && (
            <p className="text-xs text-muted-foreground">
              {isAvailable
                ? 'You can receive new task assignments'
                : 'You will not receive new assignments'}
            </p>
          )}
        </div>
      </div>

      <Switch
        id="availability"
        checked={isAvailable}
        onCheckedChange={handleChange}
        disabled={disabled}
        className={cn(
          isAvailable && 'data-[state=checked]:bg-green-500'
        )}
      />
    </div>
  )
}

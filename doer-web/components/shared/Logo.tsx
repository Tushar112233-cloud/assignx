'use client'

import { cn } from '@/lib/utils'

interface LogoProps {
  /** Size of the logo */
  size?: 'sm' | 'md' | 'lg' | 'xl'
  /** Whether to show the text */
  showText?: boolean
  /** Additional class names */
  className?: string
}

const sizeClasses = {
  sm: 'w-8 h-8',
  md: 'w-12 h-12',
  lg: 'w-16 h-16',
  xl: 'w-24 h-24',
}

const textSizeClasses = {
  sm: 'text-lg',
  md: 'text-2xl',
  lg: 'text-3xl',
  xl: 'text-4xl',
}

/**
 * Logo component for the Doer application
 * Displays the app logo with optional text
 */
export function Logo({ size = 'md', showText = true, className }: LogoProps) {
  return (
    <div className={cn('flex items-center gap-3', className)}>
      {/* Logo Icon */}
      <div
        className={cn(
          'relative flex items-center justify-center rounded-xl bg-primary',
          sizeClasses[size]
        )}
      >
        <svg
          viewBox="0 0 24 24"
          fill="none"
          className="w-2/3 h-2/3 text-primary-foreground"
          xmlns="http://www.w3.org/2000/svg"
        >
          {/* D letter stylized */}
          <path
            d="M6 4h6a8 8 0 0 1 0 16H6V4z"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            fill="none"
          />
          <path
            d="M9 8v8"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
          />
          <circle
            cx="12"
            cy="12"
            r="2"
            fill="currentColor"
          />
        </svg>
      </div>

      {/* Logo Text */}
      {showText && (
        <span
          className={cn(
            'font-bold tracking-tight text-foreground',
            textSizeClasses[size]
          )}
        >
          DOER
        </span>
      )}
    </div>
  )
}

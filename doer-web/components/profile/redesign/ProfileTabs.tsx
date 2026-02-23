'use client'

import { motion } from 'framer-motion'
import {
  LayoutGrid,
  Edit2,
  CreditCard,
  Building2,
  TrendingUp,
  MoreHorizontal,
} from 'lucide-react'
import { cn } from '@/lib/utils'

/** Tab types for profile navigation */
export type ProfileTabType = 'overview' | 'edit' | 'payments' | 'bank' | 'earnings' | 'more'

/** Tab configuration interface */
interface TabConfig {
  id: ProfileTabType
  label: string
  icon: React.ComponentType<{ className?: string }>
}

/** ProfileTabs component props */
interface ProfileTabsProps {
  /** Currently active tab */
  activeTab: ProfileTabType
  /** Callback when tab is changed */
  onTabChange: (tab: ProfileTabType) => void
  /** Optional className for custom styling */
  className?: string
}

/** Tab configurations matching the projects page style */
const tabs: TabConfig[] = [
  {
    id: 'overview',
    label: 'Overview',
    icon: LayoutGrid,
  },
  {
    id: 'edit',
    label: 'Edit Profile',
    icon: Edit2,
  },
  {
    id: 'payments',
    label: 'Payments',
    icon: CreditCard,
  },
  {
    id: 'bank',
    label: 'Bank',
    icon: Building2,
  },
  {
    id: 'earnings',
    label: 'Earnings',
    icon: TrendingUp,
  },
  {
    id: 'more',
    label: 'More',
    icon: MoreHorizontal,
  },
]

/**
 * ProfileTabs - Premium tab navigation component
 *
 * A beautiful rounded tab bar with gradient active states, icons, and smooth animations.
 * Matches the design pattern from the projects page for consistency.
 *
 * @example
 * ```tsx
 * <ProfileTabs
 *   activeTab={activeTab}
 *   onTabChange={setActiveTab}
 * />
 * ```
 */
export function ProfileTabs({ activeTab, onTabChange, className }: ProfileTabsProps) {
  return (
    <div
      className={cn(
        'w-full',
        className
      )}
    >
      <div className="rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)] backdrop-blur-sm">
        <div className="grid grid-cols-6 gap-1">
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id

            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={cn(
                  'relative rounded-full px-3 py-2.5 text-sm font-medium transition-all duration-300',
                  'flex items-center justify-center gap-2',
                  'hover:bg-gray-100/50',
                  isActive
                    ? 'text-white'
                    : 'text-gray-600 hover:text-gray-900'
                )}
              >
                {/* Gradient background for active tab */}
                {isActive && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute inset-0 rounded-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]"
                    transition={{
                      type: 'spring',
                      stiffness: 500,
                      damping: 35,
                    }}
                  />
                )}

                {/* Icon and label */}
                <span className="relative z-10 flex items-center gap-2">
                  <Icon className="h-4 w-4 shrink-0" />
                  <span className="hidden sm:inline">{tab.label}</span>
                </span>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}

/**
 * ProfileTabsCompact - Compact version for smaller screens
 *
 * Same functionality but optimized for mobile with icon-only display
 */
export function ProfileTabsCompact({ activeTab, onTabChange, className }: ProfileTabsProps) {
  return (
    <div
      className={cn(
        'w-full',
        className
      )}
    >
      <div className="rounded-full bg-white/85 p-1 shadow-[0_14px_28px_rgba(30,58,138,0.08)] backdrop-blur-sm">
        <div className="grid grid-cols-6 gap-1">
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id

            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={cn(
                  'relative rounded-full p-2.5 text-sm font-medium transition-all duration-300',
                  'flex items-center justify-center',
                  'hover:bg-gray-100/50',
                  isActive
                    ? 'text-white'
                    : 'text-gray-600 hover:text-gray-900'
                )}
                aria-label={tab.label}
              >
                {/* Gradient background for active tab */}
                {isActive && (
                  <motion.div
                    layoutId="activeTabCompact"
                    className="absolute inset-0 rounded-full bg-gradient-to-r from-[#5A7CFF] to-[#49C5FF]"
                    transition={{
                      type: 'spring',
                      stiffness: 500,
                      damping: 35,
                    }}
                  />
                )}

                {/* Icon only */}
                <span className="relative z-10">
                  <Icon className="h-4 w-4" />
                </span>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}

/**
 * ProfileTabsResponsive - Responsive version that switches between full and compact
 *
 * Automatically shows full labels on desktop and icon-only on mobile
 */
export function ProfileTabsResponsive({ activeTab, onTabChange, className }: ProfileTabsProps) {
  return (
    <>
      {/* Desktop version - hidden on small screens */}
      <div className="hidden md:block">
        <ProfileTabs
          activeTab={activeTab}
          onTabChange={onTabChange}
          className={className}
        />
      </div>

      {/* Mobile version - hidden on medium+ screens */}
      <div className="md:hidden">
        <ProfileTabsCompact
          activeTab={activeTab}
          onTabChange={onTabChange}
          className={className}
        />
      </div>
    </>
  )
}

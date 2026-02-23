'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ChevronRight,
  ChevronDown,
  Shield,
  BadgeCheck,
  Clock,
  Star,
  TrendingUp,
  Award,
  Activity,
  Users,
  Target,
  Zap,
} from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { cn } from '@/lib/utils'

/**
 * Props for ProfileInsights component
 */
export interface ProfileInsightsProps {
  /** Account activation status */
  isActivated: boolean
  /** On-time delivery rate percentage */
  onTimeDeliveryRate: number
  /** Total projects completed */
  completedProjects: number
  /** Average rating */
  averageRating: number
  /** Total number of reviews */
  totalReviews: number
  /** Total earnings amount */
  totalEarnings: number
  /** Current profile completion percentage */
  profileCompletion: number
  /** Experience level */
  experienceLevel: string
  /** Whether sidebar is initially collapsed on mobile */
  initiallyCollapsed?: boolean
  /** Callback when quick action is clicked */
  onQuickAction?: (action: string) => void
}

/**
 * Quick action card for common tasks
 */
interface QuickActionProps {
  label: string
  description: string
  icon: React.ElementType
  onClick?: () => void
  variant?: 'default' | 'primary' | 'success'
}

/**
 * Quick action button component
 */
function QuickAction({ label, description, icon: Icon, onClick, variant = 'default' }: QuickActionProps) {
  const variantStyles = {
    default: 'bg-[#E3E9FF] text-[#4F6CF7] hover:bg-[#D5DFFF]',
    primary: 'bg-[#E6F4FF] text-[#4B9BFF] hover:bg-[#D5ECFF]',
    success: 'bg-[#E1F5F3] text-[#0D9488] hover:bg-[#D1EDE9]',
  }

  return (
    <motion.button
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className={cn(
        'flex w-full items-center justify-between rounded-2xl p-3 transition-colors gap-2',
        variantStyles[variant]
      )}
    >
      <div className="flex items-center gap-3 min-w-0 flex-1">
        <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-xl bg-white/40">
          <Icon className="h-4 w-4" />
        </div>
        <div className="text-left min-w-0 flex-1">
          <p className="text-sm font-semibold truncate">{label}</p>
          <p className="text-xs opacity-75 truncate">{description}</p>
        </div>
      </div>
      <ChevronRight className="h-4 w-4 opacity-50 flex-shrink-0" />
    </motion.button>
  )
}

/**
 * Profile Insights Sidebar Component
 *
 * Displays account status, quick actions, and profile analytics in a right sidebar.
 * Includes account verification status, recent activity metrics, and performance insights.
 * Responsive with collapse functionality on mobile devices.
 *
 * Styling matches the projects page InsightsSidebar with premium rounded design and blue accents.
 *
 * @component
 * @example
 * ```tsx
 * <ProfileInsights
 *   isActivated={true}
 *   onTimeDeliveryRate={92}
 *   completedProjects={24}
 *   averageRating={4.8}
 *   totalReviews={18}
 *   totalEarnings={45000}
 *   profileCompletion={85}
 *   experienceLevel="intermediate"
 *   onQuickAction={(action) => console.log(action)}
 * />
 * ```
 */
export function ProfileInsights({
  isActivated,
  onTimeDeliveryRate,
  completedProjects,
  averageRating,
  totalReviews,
  totalEarnings,
  profileCompletion,
  experienceLevel,
  initiallyCollapsed = false,
  onQuickAction,
}: ProfileInsightsProps) {
  const [isCollapsed, setIsCollapsed] = useState(initiallyCollapsed)

  // Calculate performance score (weighted average)
  const performanceScore = Math.round(
    (onTimeDeliveryRate * 0.4 + averageRating * 20 * 0.4 + profileCompletion * 0.2)
  )

  return (
    <div className="w-full space-y-4">
      {/* Mobile collapse toggle */}
      <div className="lg:hidden">
        <Button
          variant="outline"
          size="sm"
          onClick={() => setIsCollapsed(!isCollapsed)}
          className="w-full justify-between border-white/70 bg-white/80 shadow-[0_10px_22px_rgba(30,58,138,0.08)]"
        >
          <span className="text-sm font-semibold text-slate-900">
            {isCollapsed ? 'Show Insights' : 'Hide Insights'}
          </span>
          <ChevronDown
            className={cn(
              'h-4 w-4 transition-transform',
              !isCollapsed && 'rotate-180'
            )}
          />
        </Button>
      </div>

      <AnimatePresence>
        {!isCollapsed && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="w-full space-y-4"
          >
            {/* Account Status Card - Blue Theme */}
            <Card className="w-full max-w-full overflow-hidden border-white/70 bg-gradient-to-br from-[#E6F4FF] to-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] rounded-2xl">
              <CardContent className="space-y-4 p-5">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-[#4B9BFF]/10">
                      <Shield className="h-5 w-5 text-[#4B9BFF]" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-[#4B9BFF] truncate">
                        Account Status
                      </p>
                      <p className="text-sm text-slate-600 truncate">Security & verification</p>
                    </div>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between rounded-2xl bg-white/60 px-3 py-2.5 gap-3">
                    <span className="text-xs font-medium text-slate-600 truncate flex-shrink-0">Activation</span>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      {isActivated ? (
                        <>
                          <Badge variant="secondary" className="gap-1 bg-emerald-100 text-emerald-700 border-0">
                            <BadgeCheck className="h-3 w-3" />
                            Active
                          </Badge>
                        </>
                      ) : (
                        <Badge variant="secondary" className="bg-amber-100 text-amber-700 border-0">
                          Pending
                        </Badge>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl bg-white/60 px-3 py-2.5 gap-3">
                    <span className="text-xs font-medium text-slate-600 truncate flex-shrink-0">On-time delivery</span>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Progress value={onTimeDeliveryRate} className="w-16 h-1.5" />
                      <span className="text-xs font-semibold text-[#4B9BFF] min-w-[2.5rem] text-right">
                        {onTimeDeliveryRate.toFixed(0)}%
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl bg-white/60 px-3 py-2.5 gap-3">
                    <span className="text-xs font-medium text-slate-600 truncate flex-shrink-0">Experience level</span>
                    <Badge variant="secondary" className="bg-[#E3E9FF] text-[#4F6CF7] capitalize border-0 flex-shrink-0">
                      {experienceLevel}
                    </Badge>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Quick Actions Panel */}
            <Card className="w-full max-w-full overflow-hidden border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] rounded-2xl">
              <CardContent className="space-y-4 p-5">
                <div className="min-w-0">
                  <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400 truncate">
                    Quick Actions
                  </p>
                  <p className="text-sm text-slate-500 truncate">Manage your profile</p>
                </div>

                <div className="space-y-2">
                  <QuickAction
                    label="Edit Profile"
                    description="Update details"
                    icon={Users}
                    variant="default"
                    onClick={() => onQuickAction?.('edit')}
                  />
                  <QuickAction
                    label="View Payments"
                    description="Track earnings"
                    icon={TrendingUp}
                    variant="primary"
                    onClick={() => onQuickAction?.('payments')}
                  />
                  <QuickAction
                    label="Verify Skills"
                    description="Add certifications"
                    icon={Target}
                    variant="success"
                    onClick={() => onQuickAction?.('skills')}
                  />
                </div>

                <div className="rounded-2xl bg-slate-50/80 px-3 py-2">
                  <div className="flex items-center justify-between text-xs gap-3">
                    <span className="text-slate-500 truncate flex-shrink-0">Profile Completion</span>
                    <div className="flex items-center gap-2 flex-shrink-0">
                      <Progress value={profileCompletion} className="w-16 h-1.5" />
                      <span className="font-semibold text-slate-900 min-w-[2.5rem] text-right">
                        {profileCompletion}%
                      </span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Recent Activity Card */}
            <Card className="w-full max-w-full overflow-hidden border-white/70 bg-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] rounded-2xl">
              <CardContent className="space-y-3 p-5">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-xl bg-[#E6F4FF]">
                    <Activity className="h-4 w-4 text-[#4B9BFF]" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-semibold uppercase tracking-[0.25em] text-slate-400 truncate">
                      Recent Activity
                    </p>
                    <p className="text-sm text-slate-500 truncate">Your highlights</p>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2.5 text-xs gap-3">
                    <div className="flex items-center gap-2 min-w-0">
                      <div className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-lg bg-[#E6F4FF]">
                        <Award className="h-3 w-3 text-[#4B9BFF]" />
                      </div>
                      <span className="text-slate-600 font-medium truncate">Projects Done</span>
                    </div>
                    <Badge variant="secondary" className="bg-[#E3E9FF] text-[#4F6CF7] flex-shrink-0">
                      {completedProjects}
                    </Badge>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2.5 text-xs gap-3">
                    <div className="flex items-center gap-2 min-w-0">
                      <div className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-lg bg-amber-50">
                        <Star className="h-3 w-3 text-amber-500 fill-amber-500" />
                      </div>
                      <span className="text-slate-600 font-medium truncate">Average Rating</span>
                    </div>
                    <Badge variant="secondary" className="bg-amber-50 text-amber-700 flex-shrink-0">
                      {averageRating.toFixed(1)} ★
                    </Badge>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2.5 text-xs gap-3">
                    <div className="flex items-center gap-2 min-w-0">
                      <div className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-lg bg-emerald-50">
                        <TrendingUp className="h-3 w-3 text-emerald-600" />
                      </div>
                      <span className="text-slate-600 font-medium truncate">Total Earnings</span>
                    </div>
                    <Badge variant="secondary" className="bg-emerald-50 text-emerald-700 flex-shrink-0">
                      ₹{totalEarnings.toLocaleString('en-IN')}
                    </Badge>
                  </div>

                  <div className="flex items-center justify-between rounded-2xl bg-slate-50/80 px-3 py-2.5 text-xs gap-3">
                    <div className="flex items-center gap-2 min-w-0">
                      <div className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-lg bg-purple-50">
                        <Users className="h-3 w-3 text-purple-600" />
                      </div>
                      <span className="text-slate-600 font-medium truncate">Total Reviews</span>
                    </div>
                    <Badge variant="secondary" className="bg-purple-50 text-purple-700 flex-shrink-0">
                      {totalReviews}
                    </Badge>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Performance Score Card */}
            <Card className="w-full max-w-full overflow-hidden border-white/70 bg-gradient-to-br from-[#E3E9FF] to-white/85 shadow-[0_16px_35px_rgba(30,58,138,0.08)] rounded-2xl">
              <CardContent className="space-y-4 p-5">
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-xl bg-[#4F6CF7]/10">
                      <Zap className="h-5 w-5 text-[#4F6CF7]" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-xs font-semibold uppercase tracking-[0.25em] text-[#4F6CF7] truncate">
                        Performance
                      </p>
                      <p className="text-sm text-slate-600 truncate">Overall score</p>
                    </div>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-2xl font-bold text-[#4F6CF7]">{performanceScore}</p>
                    <p className="text-xs text-slate-500 whitespace-nowrap">out of 100</p>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="space-y-1">
                    <div className="flex items-center justify-between text-xs gap-3">
                      <span className="text-slate-600 truncate">Delivery Rate</span>
                      <span className="font-semibold text-slate-900 flex-shrink-0">{onTimeDeliveryRate.toFixed(0)}%</span>
                    </div>
                    <Progress value={onTimeDeliveryRate} className="h-1.5 w-full" />
                  </div>

                  <div className="space-y-1">
                    <div className="flex items-center justify-between text-xs gap-3">
                      <span className="text-slate-600 truncate">Rating Score</span>
                      <span className="font-semibold text-slate-900 flex-shrink-0">{(averageRating * 20).toFixed(0)}%</span>
                    </div>
                    <Progress value={averageRating * 20} className="h-1.5 w-full" />
                  </div>

                  <div className="space-y-1">
                    <div className="flex items-center justify-between text-xs gap-3">
                      <span className="text-slate-600 truncate">Profile Quality</span>
                      <span className="font-semibold text-slate-900 flex-shrink-0">{profileCompletion}%</span>
                    </div>
                    <Progress value={profileCompletion} className="h-1.5 w-full" />
                  </div>
                </div>

                <div className="rounded-2xl bg-white/60 px-3 py-2 text-center overflow-hidden">
                  <p className="text-xs text-slate-600 line-clamp-2">
                    {performanceScore >= 80 && "Excellent performance! Keep it up!"}
                    {performanceScore >= 60 && performanceScore < 80 && "Good work! Room for improvement"}
                    {performanceScore < 60 && "Let's improve your metrics"}
                  </p>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

'use client'

import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { BadgeCheck, Star, Edit2, Wallet, TrendingUp, Award } from 'lucide-react'
import { cn } from '@/lib/utils'

/**
 * Profile Hero component props
 */
type ProfileHeroProps = {
  profile: {
    full_name: string
    email: string
    avatar_url?: string | null
  }
  doer: {
    is_activated: boolean
    qualification?: string | null
    experience_level?: string | null
  }
  stats: {
    totalEarnings: number
    completedProjects: number
    averageRating: number
    onTimeDeliveryRate: number
    totalReviews: number
  }
  profileCompletion: number
  onEditProfile?: () => void
  onViewPayouts?: () => void
  onViewEarnings?: () => void
}

/**
 * Stat card component for inline statistics
 */
function StatCard({
  label,
  value,
  subtitle
}: {
  label: string
  value: string | number
  subtitle: string
}) {
  return (
    <div className="rounded-2xl bg-white/85 p-5 shadow-[0_12px_30px_rgba(90,124,255,0.08)] transition hover:shadow-[0_16px_40px_rgba(90,124,255,0.12)] min-w-0 overflow-hidden">
      <p className="text-xs font-medium text-slate-500 truncate">{label}</p>
      <p className="mt-1.5 text-2xl font-bold text-slate-900 break-words">{value}</p>
      <p className="mt-0.5 text-xs text-slate-400 truncate">{subtitle}</p>
    </div>
  )
}

/**
 * Premium Profile Hero Section
 *
 * Features:
 * - Large avatar with blue gradient border
 * - User name with gradient text highlight
 * - Verification badges in blue
 * - 4 inline stat cards (earnings, projects, rating, on-time rate)
 * - Profile completion progress bar
 * - Quick action buttons with blue gradient
 * - Premium rounded design with shadows
 * - Matches dashboard's visual hierarchy
 *
 * Design colors: #5A7CFF, #5B86FF, #4F6CF7, #49C5FF, #EEF2FF
 */
export function ProfileHero({
  profile,
  doer,
  stats,
  profileCompletion,
  onEditProfile,
  onViewPayouts,
  onViewEarnings,
}: ProfileHeroProps) {
  // Get user initials for avatar fallback
  const initials = profile.full_name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()

  return (
    <div className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-8 shadow-[0_24px_60px_rgba(90,124,255,0.12)]">
      {/* Background gradient overlay */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(90,124,255,0.15),transparent_55%)]" />

      {/* Content */}
      <div className="relative space-y-6">
        {/* Top section: Avatar + Name + Badges */}
        <div className="flex flex-col gap-6 lg:flex-row lg:items-start lg:justify-between">
          {/* Left: Avatar and Info */}
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center">
            {/* Avatar with gradient border */}
            <div className="relative">
              <div className="absolute -inset-1 rounded-[26px] bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] blur-sm opacity-75" />
              <Avatar className="relative h-24 w-24 border-4 border-white shadow-xl">
                <AvatarImage src={profile.avatar_url || undefined} alt={profile.full_name} />
                <AvatarFallback className="text-2xl bg-gradient-to-br from-[#5A7CFF] to-[#49C5FF] text-white">
                  {initials}
                </AvatarFallback>
              </Avatar>
            </div>

            {/* Name and badges */}
            <div className="space-y-2">
              <div className="flex flex-wrap items-center gap-2">
                <h1 className="text-3xl font-bold text-slate-900">
                  <span className="bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] bg-clip-text text-transparent">
                    {profile.full_name}
                  </span>
                </h1>
                {doer.is_activated && (
                  <Badge className="gap-1 border-0 bg-[#5A7CFF] text-white shadow-[0_8px_20px_rgba(90,124,255,0.25)]">
                    <BadgeCheck className="h-3.5 w-3.5" />
                    Verified
                  </Badge>
                )}
              </div>
              <p className="text-sm text-slate-600">{profile.email}</p>
              <div className="flex flex-wrap gap-2">
                {doer.qualification && (
                  <Badge
                    variant="secondary"
                    className="border-[#5A7CFF]/20 bg-white/80 text-slate-700 capitalize shadow-[0_4px_12px_rgba(90,124,255,0.08)]"
                  >
                    {doer.qualification.replace('_', ' ')}
                  </Badge>
                )}
                {doer.experience_level && (
                  <Badge
                    variant="secondary"
                    className="border-[#5A7CFF]/20 bg-white/80 text-slate-700 capitalize shadow-[0_4px_12px_rgba(90,124,255,0.08)]"
                  >
                    {doer.experience_level}
                  </Badge>
                )}
                <Badge
                  variant="secondary"
                  className="gap-1 border-[#5A7CFF]/20 bg-white/80 text-slate-700 shadow-[0_4px_12px_rgba(90,124,255,0.08)]"
                >
                  <Star className="h-3 w-3 fill-[#5A7CFF] text-[#5A7CFF]" />
                  {stats.averageRating.toFixed(1)}
                </Badge>
              </div>
            </div>
          </div>

          {/* Right: Quick action buttons */}
          <div className="flex flex-row flex-wrap gap-3 lg:flex-col">
            <Button
              onClick={onEditProfile}
              className="gap-2 rounded-2xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-6 text-sm font-semibold text-white shadow-[0_8px_30px_rgba(90,124,255,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_12px_40px_rgba(90,124,255,0.45)]"
            >
              <Edit2 className="h-4 w-4" />
              Edit Profile
            </Button>
            <Button
              onClick={onViewPayouts}
              variant="outline"
              className="gap-2 rounded-2xl border-white/80 bg-white/85 text-slate-700 shadow-[0_10px_22px_rgba(90,124,255,0.1)] transition hover:border-[#5A7CFF] hover:text-[#5A7CFF]"
            >
              <Wallet className="h-4 w-4" />
              Payouts
            </Button>
            <Button
              onClick={onViewEarnings}
              variant="ghost"
              className="gap-2 rounded-2xl bg-white/60 text-slate-700 shadow-[0_8px_18px_rgba(90,124,255,0.08)] transition hover:bg-white/90 hover:text-[#5A7CFF]"
            >
              <TrendingUp className="h-4 w-4" />
              Earnings
            </Button>
          </div>
        </div>

        {/* Middle section: 4 stat cards in a grid */}
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4 w-full">
          <StatCard
            label="Total Earnings"
            value={`₹${stats.totalEarnings.toLocaleString('en-IN')}`}
            subtitle="All-time revenue"
          />
          <StatCard
            label="Projects Done"
            value={stats.completedProjects}
            subtitle="Successfully completed"
          />
          <StatCard
            label="Rating"
            value={stats.averageRating.toFixed(1)}
            subtitle={`${stats.totalReviews} reviews`}
          />
          <StatCard
            label="On-time Rate"
            value={`${stats.onTimeDeliveryRate.toFixed(0)}%`}
            subtitle="Last 90 days"
          />
        </div>

        {/* Bottom section: Profile completion and badges */}
        <div className="flex flex-col gap-4 rounded-2xl bg-white/70 p-5 shadow-[0_12px_28px_rgba(90,124,255,0.08)] sm:flex-row sm:items-center sm:justify-between">
          {/* Profile completion */}
          <div className="flex-1 space-y-2">
            <div className="flex items-center justify-between text-sm">
              <span className="font-medium text-slate-700">Profile Completion</span>
              <span className="font-bold text-[#5A7CFF]">{profileCompletion}%</span>
            </div>
            <Progress
              value={profileCompletion}
              className="h-2.5 bg-slate-200/80"
              indicatorClassName="bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF]"
            />
          </div>

          {/* Achievement badges */}
          <div className="flex flex-wrap items-center gap-2 sm:ml-6">
            <Badge
              variant="secondary"
              className="gap-1 border-[#5A7CFF]/20 bg-white text-slate-700 shadow-[0_4px_12px_rgba(90,124,255,0.08)]"
            >
              <Award className="h-3.5 w-3.5 text-[#5A7CFF]" />
              Top Performer
            </Badge>
            {doer.is_activated && (
              <Badge
                variant="secondary"
                className="gap-1 border-[#5A7CFF]/20 bg-white text-slate-700 shadow-[0_4px_12px_rgba(90,124,255,0.08)]"
              >
                <BadgeCheck className="h-3.5 w-3.5 text-[#5A7CFF]" />
                Verified Professional
              </Badge>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

/**
 * Export component as default
 */
export default ProfileHero

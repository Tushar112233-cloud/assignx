'use client'

import { useState, useEffect, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Skeleton } from '@/components/ui/skeleton'
import { Button } from '@/components/ui/button'
import {
  ProfileHero,
  ProfileTabs,
  ProfileInsights,
  type ProfileTabType,
  EditProfile,
  PaymentHistory,
  BankSettings,
  SupportSection,
  RequestPayout,
  EarningsGraph,
  SkillVerification,
} from '@/components/profile'
import { useAuth } from '@/hooks/useAuth'
import { getDoerProfile } from '@/services/profile.service'
import { toast } from 'sonner'
import type { Doer, DoerStats } from '@/types/database'

/**
 * Profile Page - Redesigned with Premium Blue Theme
 *
 * Features:
 * - Removed sidebar navigation (old left column)
 * - New ProfileHero component at top
 * - ProfileTabs component for navigation
 * - Two-column layout (65% content, 35% insights)
 * - Blue gradient background (matches dashboard)
 * - Fade-in-up animations
 * - Blue color palette throughout
 * - Premium rounded cards
 * - Responsive design
 */
export default function ProfilePage() {
  const { user, doer: authDoer, isLoading: authLoading } = useAuth()
  const [isLoading, setIsLoading] = useState(true)
  const [activeTab, setActiveTab] = useState<ProfileTabType>('overview')
  const [doer, setDoer] = useState<Doer | null>(null)
  const [stats, setStats] = useState<DoerStats | null>(null)

  /**
   * Build basic stats from cached doer data so the page can render immediately.
   */
  const buildBasicStats = useCallback((d: Doer): DoerStats => ({
    activeAssignments: 0,
    completedProjects: d.total_projects_completed || 0,
    totalEarnings: Number(d.total_earnings) || 0,
    pendingEarnings: 0,
    averageRating: Number(d.average_rating) || 0,
    totalReviews: d.total_reviews || 0,
    successRate: Number(d.success_rate) || 0,
    onTimeDeliveryRate: Number(d.on_time_delivery_rate) || 0,
    qualityRating: 0,
    timelinessRating: 0,
    communicationRating: 0,
  }), [])

  /**
   * Seed local state from auth store cache for instant render.
   */
  useEffect(() => {
    if (authDoer && !doer) {
      setDoer(authDoer)
      setStats(buildBasicStats(authDoer))
      setIsLoading(false)
    }
  }, [user, authDoer, doer, buildBasicStats])

  /**
   * Fetch detailed profile data (reviews, wallet, active count) in background.
   */
  const loadProfile = useCallback(async () => {
    if (!user?.id) {
      setIsLoading(false)
      return
    }

    // Don't show loading skeleton if we already have cached data
    if (!doer) setIsLoading(true)

    try {
      const data = await getDoerProfile()
      if (data.doer) setDoer(data.doer)
      if (data.stats) setStats(data.stats)
    } catch (error) {
      console.error('Error loading profile:', error)
      // Only show toast if we have no fallback data
      if (!doer) {
        toast.error('Failed to load profile')
      }
    } finally {
      setIsLoading(false)
    }
  }, [user?.id])

  /** Fetch detailed data once auth is ready */
  useEffect(() => {
    if (user?.id && !authLoading) {
      loadProfile()
    } else if (!authLoading && !user?.id) {
      setIsLoading(false)
    }
  }, [user?.id, authLoading, loadProfile])

  /** Calculate profile completion percentage */
  const getProfileCompletion = (doer: Doer): number => {
    const completionFields = [
      Boolean(doer.full_name),
      Boolean(doer.email),
      Boolean(doer.phone),
      Boolean(doer.avatar_url),
      Boolean(doer.qualification),
      Boolean(doer.experience_level),
      Boolean(doer.bio),
      Boolean(doer.university_name),
      Boolean(doer.bank_account_name),
      Boolean(doer.bank_account_number),
      Boolean(doer.bank_ifsc_code),
    ]
    return Math.round(
      (completionFields.filter(Boolean).length / completionFields.length) * 100
    )
  }

  /** Handle quick actions from insights panel */
  const handleQuickAction = useCallback((action: string) => {
    switch (action) {
      case 'edit':
        setActiveTab('edit')
        break
      case 'payments':
        setActiveTab('payments')
        break
      case 'skills':
        setActiveTab('more') // Skills is in the "more" tab
        break
      default:
        break
    }
  }, [])

  // Skeleton gate removed — show page content or loading message
  if (!doer || !stats) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <p className="text-slate-600 mb-4">{isLoading ? 'Loading profile...' : 'Failed to load profile'}</p>
        {!isLoading && <Button onClick={loadProfile}>Try Again</Button>}
      </div>
    )
  }

  const profileCompletion = getProfileCompletion(doer)

  return (
    <div className="relative min-h-screen">
      {/* Radial gradient background matching dashboard */}
      <div className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top,rgba(90,124,255,0.18),transparent_55%),radial-gradient(circle_at_80%_20%,rgba(73,197,255,0.16),transparent_50%)]" />

      {/* Main content with fade-in-up animation */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: 'easeOut' }}
        className="space-y-8"
      >
        {/* Hero Section */}
        <ProfileHero
          profile={doer}
          doer={doer}
          stats={stats}
          profileCompletion={profileCompletion}
          onEditProfile={() => setActiveTab('edit')}
          onViewPayouts={() => setActiveTab('payments')}
          onViewEarnings={() => setActiveTab('earnings')}
        />

        {/* Tabs Navigation */}
        <ProfileTabs
          activeTab={activeTab}
          onTabChange={setActiveTab}
        />

        {/* Two-column layout: Content (65%) + Insights (35%) */}
        <div className="grid gap-6 2xl:grid-cols-[minmax(0,1fr)_380px]">
          {/* Main content area - min-w-0 prevents overflow */}
          <motion.main
            key={activeTab}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, ease: 'easeOut' }}
            className="space-y-6 min-w-0"
          >
            <AnimatePresence mode="wait">
              {activeTab === 'overview' && (
                <motion.div
                  key="overview"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                  className="space-y-6"
                >
                  <EarningsGraph />
                </motion.div>
              )}

              {activeTab === 'edit' && (
                <motion.div
                  key="edit"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                  className="w-full max-w-full overflow-hidden"
                >
                  <EditProfile
                    profile={doer}
                    doer={doer}
                    onCancel={() => setActiveTab('overview')}
                  />
                </motion.div>
              )}

              {activeTab === 'payments' && (
                <motion.div
                  key="payments"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                  className="space-y-6"
                >
                  <RequestPayout doer={doer} />
                  <PaymentHistory />
                </motion.div>
              )}

              {activeTab === 'bank' && (
                <motion.div
                  key="bank"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                >
                  <BankSettings doer={doer} />
                </motion.div>
              )}

              {activeTab === 'earnings' && (
                <motion.div
                  key="earnings"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                >
                  <EarningsGraph />
                </motion.div>
              )}

              {activeTab === 'more' && (
                <motion.div
                  key="more"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.3 }}
                  className="space-y-6"
                >
                  <SkillVerification />
                  <SupportSection />
                </motion.div>
              )}
            </AnimatePresence>
          </motion.main>

          {/* Insights sidebar (35%) - sticky positioning for better UX */}
          <aside className="space-y-6 2xl:sticky 2xl:top-6 2xl:self-start">
            <ProfileInsights
              isActivated={doer.is_activated}
              onTimeDeliveryRate={stats.onTimeDeliveryRate}
              completedProjects={stats.completedProjects}
              averageRating={stats.averageRating}
              totalReviews={stats.totalReviews}
              totalEarnings={stats.totalEarnings}
              profileCompletion={profileCompletion}
              experienceLevel={doer.experience_level || 'beginner'}
              initiallyCollapsed={false}
              onQuickAction={handleQuickAction}
            />
          </aside>
        </div>
      </motion.div>
    </div>
  )
}

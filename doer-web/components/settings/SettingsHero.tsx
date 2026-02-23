'use client'

import { motion } from 'framer-motion'
import { Settings, User, Bell, Shield, Palette } from 'lucide-react'
import { Badge } from '@/components/ui/badge'

type SettingsHeroProps = {
  userName?: string
  userEmail?: string
}

/**
 * SettingsHero - Hero section for settings page
 * Displays user info and settings overview
 */
export function SettingsHero({ userName = 'User', userEmail = '' }: SettingsHeroProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="relative overflow-hidden rounded-[28px] bg-gradient-to-br from-[#EEF2FF] via-[#F3F5FF] to-[#E9FAFA] p-6 shadow-[0_24px_60px_rgba(30,58,138,0.12)]"
    >
      {/* Background decoration */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(99,102,241,0.18),transparent_55%)]" />
      <div className="absolute -right-16 -top-16 h-64 w-64 rounded-full bg-[#E7ECFF] blur-3xl opacity-60" />

      <div className="relative grid gap-5 lg:grid-cols-[minmax(0,1fr)_280px]">
        {/* Left section - Main content */}
        <div className="space-y-4">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-white/90 shadow-lg">
              <Settings className="h-5 w-5 text-[#5A7CFF]" />
            </div>
            <Badge className="bg-[#E6F4FF] text-[#4B9BFF] border-0 text-xs">
              Account Settings
            </Badge>
          </div>

          <div className="space-y-2">
            <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
              Settings & Preferences
            </h1>
            <p className="text-sm text-slate-600 max-w-2xl">
              Manage your account settings, notifications, privacy preferences, and customize your workspace experience.
            </p>
          </div>

          <div className="flex items-center gap-2 text-sm text-slate-500">
            <span>Signed in as</span>
            <span className="font-medium text-slate-700">{userEmail}</span>
          </div>
        </div>

        {/* Right section - Quick stats */}
        <div className="space-y-3">
          <div className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E3E9FF]">
                <User className="h-4 w-4 text-[#4F6CF7]" />
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">Profile</p>
                <p className="text-sm font-semibold text-slate-900">{userName}</p>
              </div>
            </div>
          </div>

          <div className="rounded-2xl bg-white/85 p-4 shadow-[0_12px_28px_rgba(30,58,138,0.08)]">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E6F4FF]">
                <Shield className="h-4 w-4 text-[#4B9BFF]" />
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">Security</p>
                <p className="text-sm font-semibold text-slate-900">Protected</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  )
}

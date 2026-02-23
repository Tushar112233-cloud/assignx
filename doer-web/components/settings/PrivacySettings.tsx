'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Shield, Eye, Lock, Database } from 'lucide-react'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'

/**
 * PrivacySettings - Manage privacy and security preferences
 */
export function PrivacySettings() {
  const [privacy, setPrivacy] = useState({
    profileVisibility: true,
    showEmail: false,
    showPhone: false,
    allowAnalytics: true,
    twoFactorAuth: false,
  })

  const handleToggle = (key: keyof typeof privacy) => {
    setPrivacy(prev => ({ ...prev, [key]: !prev[key] }))
  }

  const privacyItems = [
    {
      key: 'profileVisibility' as const,
      icon: Eye,
      title: 'Public Profile',
      description: 'Make your profile visible to other users',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
    {
      key: 'showEmail' as const,
      icon: Shield,
      title: 'Show Email Address',
      description: 'Display your email on your public profile',
      iconBg: 'bg-[#E6F4FF]',
      iconColor: 'text-[#4B9BFF]',
    },
    {
      key: 'showPhone' as const,
      icon: Shield,
      title: 'Show Phone Number',
      description: 'Display your phone number on your profile',
      iconBg: 'bg-[#ECE9FF]',
      iconColor: 'text-[#6B5BFF]',
    },
    {
      key: 'allowAnalytics' as const,
      icon: Database,
      title: 'Analytics & Usage Data',
      description: 'Help us improve by sharing anonymous usage data',
      iconBg: 'bg-[#FFE7E1]',
      iconColor: 'text-[#FF8B6A]',
    },
    {
      key: 'twoFactorAuth' as const,
      icon: Lock,
      title: 'Two-Factor Authentication',
      description: 'Add an extra layer of security to your account',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className="rounded-[28px] border border-white/70 bg-white/85 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]"
    >
      <div className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold text-slate-900">Privacy & Security</h2>
          <p className="mt-2 text-sm text-slate-500">
            Control your privacy settings and account security
          </p>
        </div>

        <div className="space-y-4">
          {privacyItems.map((item) => (
            <div
              key={item.key}
              className="flex items-center justify-between rounded-2xl bg-slate-50/80 p-5 transition hover:bg-slate-50"
            >
              <div className="flex items-center gap-4">
                <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${item.iconBg}`}>
                  <item.icon className={`h-5 w-5 ${item.iconColor}`} />
                </div>
                <div>
                  <Label htmlFor={item.key} className="text-sm font-semibold text-slate-900 cursor-pointer">
                    {item.title}
                  </Label>
                  <p className="text-xs text-slate-500">{item.description}</p>
                </div>
              </div>
              <Switch
                id={item.key}
                checked={privacy[item.key]}
                onCheckedChange={() => handleToggle(item.key)}
              />
            </div>
          ))}
        </div>
      </div>
    </motion.div>
  )
}

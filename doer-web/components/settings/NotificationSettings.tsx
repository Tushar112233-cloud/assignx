'use client'

import { useState, useEffect, useCallback } from 'react'
import { motion } from 'framer-motion'
import { Bell, Mail, MessageSquare, Save, Loader2 } from 'lucide-react'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
// apiClient import removed - preferences stored in localStorage until API endpoint is available
import { toast } from 'sonner'

type NotificationSettingsProps = {
  userId: string
}

/** Notification preferences matching user_preferences table columns */
interface NotificationPrefs {
  push_notifications: boolean
  email_notifications: boolean
  project_updates: boolean
  marketing_emails: boolean
}

/**
 * NotificationSettings - Manage notification preferences
 * Loads and persists settings to the user_preferences table
 */
export function NotificationSettings({ userId }: NotificationSettingsProps) {
  const [prefs, setPrefs] = useState<NotificationPrefs>({
    push_notifications: true,
    email_notifications: true,
    project_updates: true,
    marketing_emails: false,
  })
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [hasChanges, setHasChanges] = useState(false)
  const [savedPrefs, setSavedPrefs] = useState<NotificationPrefs | null>(null)

  /**
   * Load notification preferences from user_preferences table
   */
  const loadPreferences = useCallback(async () => {
    if (!userId) {
      setIsLoading(false)
      return
    }

    try {
      // Preferences endpoint not yet available - use localStorage fallback
      const stored = localStorage.getItem('notification_prefs')
      if (stored) {
        const parsed = JSON.parse(stored) as NotificationPrefs
        setPrefs(parsed)
        setSavedPrefs(parsed)
      }
    } catch {
      console.error('Failed to load notification preferences')
    } finally {
      setIsLoading(false)
    }
  }, [userId])

  useEffect(() => {
    loadPreferences()
  }, [loadPreferences])

  /**
   * Toggle a notification preference
   */
  const handleToggle = (key: keyof NotificationPrefs) => {
    setPrefs(prev => {
      const updated = { ...prev, [key]: !prev[key] }
      setHasChanges(
        savedPrefs === null ||
        Object.keys(updated).some(
          (k) => updated[k as keyof NotificationPrefs] !== savedPrefs[k as keyof NotificationPrefs]
        )
      )
      return updated
    })
  }

  /**
   * Save notification preferences to user_preferences table
   */
  const handleSave = async () => {
    if (!userId) return

    setIsSaving(true)
    try {
      // Preferences endpoint not yet available - use localStorage fallback
      localStorage.setItem('notification_prefs', JSON.stringify(prefs))

      setSavedPrefs({ ...prefs })
      setHasChanges(false)
      toast.success('Notification preferences saved')
    } catch {
      toast.error('Failed to save notification preferences')
    } finally {
      setIsSaving(false)
    }
  }

  const notificationItems: {
    key: keyof NotificationPrefs
    icon: typeof Bell
    title: string
    description: string
    iconBg: string
    iconColor: string
  }[] = [
    {
      key: 'email_notifications',
      icon: Mail,
      title: 'Email Notifications',
      description: 'Receive notifications via email',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
    {
      key: 'push_notifications',
      icon: Bell,
      title: 'Push Notifications',
      description: 'Enable browser push notifications',
      iconBg: 'bg-[#E6F4FF]',
      iconColor: 'text-[#4B9BFF]',
    },
    {
      key: 'project_updates',
      icon: MessageSquare,
      title: 'Project Updates',
      description: 'Get notified about project status changes',
      iconBg: 'bg-[#ECE9FF]',
      iconColor: 'text-[#6B5BFF]',
    },
    {
      key: 'marketing_emails',
      icon: Mail,
      title: 'Marketing Emails',
      description: 'Receive promotional content and feature announcements',
      iconBg: 'bg-[#FFE7E1]',
      iconColor: 'text-[#FF8B6A]',
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
          <h2 className="text-xl font-semibold text-slate-900">Notification Preferences</h2>
          <p className="mt-2 text-sm text-slate-500">
            Choose how you want to receive updates and notifications
          </p>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-[#5A7CFF]" />
            <span className="ml-2 text-sm text-slate-500">Loading preferences...</span>
          </div>
        ) : (
          <>
            <div className="space-y-4">
              {notificationItems.map((item) => (
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
                    checked={prefs[item.key]}
                    onCheckedChange={() => handleToggle(item.key)}
                  />
                </div>
              ))}
            </div>

            {/* Save Button */}
            <div className="flex justify-end gap-3 pt-2">
              <Button
                onClick={handleSave}
                disabled={isSaving || !hasChanges}
                className="h-12 rounded-2xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-8 text-white shadow-[0_12px_28px_rgba(90,124,255,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_16px_35px_rgba(90,124,255,0.45)] disabled:opacity-50"
              >
                {isSaving ? (
                  <>
                    <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="mr-2 h-5 w-5" />
                    Save Changes
                  </>
                )}
              </Button>
            </div>
          </>
        )}
      </div>
    </motion.div>
  )
}

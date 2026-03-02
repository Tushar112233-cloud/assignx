'use client'

import { useState, useEffect, useCallback } from 'react'
import { motion } from 'framer-motion'
import { Shield, Eye, Database, Save, Loader2 } from 'lucide-react'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { apiClient } from '@/lib/api/client'
import { toast } from 'sonner'

type PrivacySettingsProps = {
  userId: string
}

/** Privacy preferences matching user_preferences table columns */
interface PrivacyPrefs {
  show_online_status: boolean
  analytics_opt_out: boolean
}

/**
 * PrivacySettings - Manage privacy and security preferences
 * Loads and persists settings to the user_preferences table
 */
export function PrivacySettings({ userId }: PrivacySettingsProps) {
  const [prefs, setPrefs] = useState<PrivacyPrefs>({
    show_online_status: true,
    analytics_opt_out: false,
  })
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [hasChanges, setHasChanges] = useState(false)
  const [savedPrefs, setSavedPrefs] = useState<PrivacyPrefs | null>(null)

  /**
   * Load privacy preferences from user_preferences table
   */
  const loadPreferences = useCallback(async () => {
    if (!userId) {
      setIsLoading(false)
      return
    }

    try {
      const data = await apiClient<PrivacyPrefs>('/api/profiles/me/preferences')
      if (data) {
        const loaded: PrivacyPrefs = {
          show_online_status: data.show_online_status ?? true,
          analytics_opt_out: data.analytics_opt_out ?? false,
        }
        setPrefs(loaded)
        setSavedPrefs(loaded)
      }
    } catch {
      console.error('Failed to load privacy preferences')
    } finally {
      setIsLoading(false)
    }
  }, [userId])

  useEffect(() => {
    loadPreferences()
  }, [loadPreferences])

  /**
   * Toggle a privacy preference
   */
  const handleToggle = (key: keyof PrivacyPrefs) => {
    setPrefs(prev => {
      const updated = { ...prev, [key]: !prev[key] }
      setHasChanges(
        savedPrefs === null ||
        Object.keys(updated).some(
          (k) => updated[k as keyof PrivacyPrefs] !== savedPrefs[k as keyof PrivacyPrefs]
        )
      )
      return updated
    })
  }

  /**
   * Save privacy preferences to user_preferences table
   */
  const handleSave = async () => {
    if (!userId) return

    setIsSaving(true)
    try {
      await apiClient('/api/profiles/me/preferences', {
        method: 'PUT',
        body: JSON.stringify({
          show_online_status: prefs.show_online_status,
          analytics_opt_out: prefs.analytics_opt_out,
        }),
      })

      setSavedPrefs({ ...prefs })
      setHasChanges(false)
      toast.success('Privacy settings saved')
    } catch {
      toast.error('Failed to save privacy settings')
    } finally {
      setIsSaving(false)
    }
  }

  const privacyItems: {
    key: keyof PrivacyPrefs
    icon: typeof Shield
    title: string
    description: string
    iconBg: string
    iconColor: string
  }[] = [
    {
      key: 'show_online_status',
      icon: Eye,
      title: 'Show Online Status',
      description: 'Let others see when you are online',
      iconBg: 'bg-[#E3E9FF]',
      iconColor: 'text-[#4F6CF7]',
    },
    {
      key: 'analytics_opt_out',
      icon: Database,
      title: 'Opt Out of Analytics',
      description: 'Disable anonymous usage data collection',
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
          <h2 className="text-xl font-semibold text-slate-900">Privacy & Security</h2>
          <p className="mt-2 text-sm text-slate-500">
            Control your privacy settings and account security
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

'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Palette, Sun, Moon, Monitor, Languages } from 'lucide-react'
import { Label } from '@/components/ui/label'

/**
 * DisplaySettings - Manage appearance and display preferences
 */
export function DisplaySettings() {
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('light')
  const [language, setLanguage] = useState('en')

  const themeOptions = [
    {
      value: 'light',
      label: 'Light',
      icon: Sun,
      description: 'Clean and bright',
    },
    {
      value: 'dark',
      label: 'Dark',
      icon: Moon,
      description: 'Easy on the eyes',
    },
    {
      value: 'system',
      label: 'System',
      icon: Monitor,
      description: 'Match your device',
    },
  ]

  const languages = [
    { value: 'en', label: 'English' },
    { value: 'es', label: 'Español' },
    { value: 'fr', label: 'Français' },
    { value: 'de', label: 'Deutsch' },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className="rounded-[28px] border border-white/70 bg-white/85 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]"
    >
      <div className="space-y-8">
        <div>
          <h2 className="text-xl font-semibold text-slate-900">Display & Appearance</h2>
          <p className="mt-2 text-sm text-slate-500">
            Customize how the application looks and feels
          </p>
        </div>

        {/* Theme Selection */}
        <div className="space-y-4">
          <Label className="text-sm font-medium text-slate-700">Theme</Label>
          <div className="grid gap-4 sm:grid-cols-3">
            {themeOptions.map((option) => (
              <button
                key={option.value}
                onClick={() => setTheme(option.value as 'light' | 'dark' | 'system')}
                className={`rounded-2xl p-5 text-left transition ${
                  theme === option.value
                    ? 'bg-gradient-to-br from-[#EEF2FF] to-[#E6F4FF] ring-2 ring-[#5A7CFF]'
                    : 'bg-slate-50/80 hover:bg-slate-50'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`flex h-11 w-11 items-center justify-center rounded-xl ${
                    theme === option.value ? 'bg-white' : 'bg-white/80'
                  }`}>
                    <option.icon className={`h-5 w-5 ${
                      theme === option.value ? 'text-[#5A7CFF]' : 'text-slate-600'
                    }`} />
                  </div>
                  <div>
                    <p className="text-sm font-semibold text-slate-900">{option.label}</p>
                    <p className="text-xs text-slate-500">{option.description}</p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Language Selection */}
        <div className="space-y-4">
          <Label className="text-sm font-medium text-slate-700">Language</Label>
          <div className="relative">
            <Languages className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
            <select
              value={language}
              onChange={(e) => setLanguage(e.target.value)}
              className="h-12 w-full appearance-none rounded-2xl border-slate-200/80 bg-white pl-12 pr-4 text-slate-900 shadow-sm transition focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF]"
            >
              {languages.map((lang) => (
                <option key={lang.value} value={lang.value}>
                  {lang.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>
    </motion.div>
  )
}

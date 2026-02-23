'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { User, Mail, Phone, Globe, Save } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Input } from '@/components/ui/input'
import { toast } from 'sonner'

type AccountSettingsProps = {
  profile: any
}

/**
 * AccountSettings - Edit account information
 */
export function AccountSettings({ profile }: AccountSettingsProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    fullName: profile?.full_name || '',
    email: profile?.email || '',
    phone: profile?.phone || '',
    location: profile?.location || '',
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    try {
      // TODO: Implement actual save logic
      await new Promise(resolve => setTimeout(resolve, 1000))
      toast.success('Account settings saved successfully')
    } catch (error) {
      toast.error('Failed to save settings')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className="rounded-[28px] border border-white/70 bg-white/85 p-8 shadow-[0_18px_40px_rgba(30,58,138,0.08)]"
    >
      <div className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold text-slate-900">Account Information</h2>
          <p className="mt-2 text-sm text-slate-500">
            Update your personal information and contact details
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Full Name */}
          <div className="space-y-3">
            <Label htmlFor="fullName" className="text-sm font-medium text-slate-700">
              Full Name
            </Label>
            <div className="relative">
              <User className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
              <Input
                id="fullName"
                value={formData.fullName}
                onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                className="h-12 rounded-2xl border-slate-200/80 bg-white pl-12 text-slate-900 shadow-sm transition focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF]"
                placeholder="Enter your full name"
              />
            </div>
          </div>

          {/* Email */}
          <div className="space-y-3">
            <Label htmlFor="email" className="text-sm font-medium text-slate-700">
              Email Address
            </Label>
            <div className="relative">
              <Mail className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="h-12 rounded-2xl border-slate-200/80 bg-white pl-12 text-slate-900 shadow-sm transition focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF]"
                placeholder="your.email@example.com"
              />
            </div>
          </div>

          {/* Phone */}
          <div className="space-y-3">
            <Label htmlFor="phone" className="text-sm font-medium text-slate-700">
              Phone Number
            </Label>
            <div className="relative">
              <Phone className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
              <Input
                id="phone"
                type="tel"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                className="h-12 rounded-2xl border-slate-200/80 bg-white pl-12 text-slate-900 shadow-sm transition focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF]"
                placeholder="+1 (555) 000-0000"
              />
            </div>
          </div>

          {/* Location */}
          <div className="space-y-3">
            <Label htmlFor="location" className="text-sm font-medium text-slate-700">
              Location
            </Label>
            <div className="relative">
              <Globe className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
              <Input
                id="location"
                value={formData.location}
                onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                className="h-12 rounded-2xl border-slate-200/80 bg-white pl-12 text-slate-900 shadow-sm transition focus:border-[#5A7CFF] focus:ring-4 focus:ring-[#E7ECFF]"
                placeholder="City, Country"
              />
            </div>
          </div>

          {/* Save Button */}
          <div className="flex justify-end gap-3 pt-4">
            <Button
              type="submit"
              disabled={isLoading}
              className="h-12 rounded-2xl bg-gradient-to-r from-[#5A7CFF] via-[#5B86FF] to-[#49C5FF] px-8 text-white shadow-[0_12px_28px_rgba(90,124,255,0.35)] transition hover:-translate-y-0.5 hover:shadow-[0_16px_35px_rgba(90,124,255,0.45)]"
            >
              <Save className="mr-2 h-5 w-5" />
              {isLoading ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>
        </form>
      </div>
    </motion.div>
  )
}
